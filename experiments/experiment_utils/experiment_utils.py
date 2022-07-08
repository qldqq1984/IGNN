import os.path as osp
import torch
import numpy as np
import  pandas  as pd
import random
import warnings
from lifelines import CoxPHFitter
from lifelines.utils import concordance_index
from pandas import DataFrame
from sklearn.metrics import roc_curve, auc

from models.training import test


warnings.filterwarnings("ignore")
path = osp.join(osp.dirname(osp.realpath(__file__)), 'data', 'CDTM_G')




def seed_everything(seed: int):
    """
    Sets the seed for generating random numbers in PyTorch, numpy and Python.
    
    Args:
        seed(int): The desired seed.
    """

    torch.manual_seed(seed)
    random.seed(seed)
    np.random.seed(seed)
    torch.cuda.manual_seed(seed) 
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic=True
    torch.backends.cudnn.benchmark = False   
    

def Find_Optimal_Cutoff(y, probas_, train = True, cutoff = 0):  
    """    
    Finds the optimal cutoff value of the prognostic scores to stratify patients into low- and high-risk groups.
    
    Args:
        y(numpy.ndarray):  ndarray of y. Note: y=0 indicates the patient with DFS > 5 years, 
                                               y=1 indicates the patient with DFS <= 5 years.   
        probas_(numpy.ndarray): ndarray of prognostic scores.
        train(bool):  If `True`, the optimal cutoff value will be computered according to the `y` and `probas_` during training process.     
                      Otherwise, the optimal cutoff value will be specified by `cutoff`.        
        cutoff(float): Data loader. 
        
    Returns:
        optimal_cutoff(float): Optimal cutoff value.    
        optimal_sensitivity(float): Sensitivity to predict 5-year DFS rate of patients with the optimal cutoff value.     
        optimal_specificity(float): Specificity to predict 5-year DFS rate of patients with the optimal cutoff value. 
    """
    
    # During training process
    if train == True:
        fpr, tpr, threshold = roc_curve(1-y, -1*probas_[:, 0], pos_label=0, drop_intermediate=True)

        j_scores =   tpr + (1-fpr) 
        j_ordered =  DataFrame({'j_scores':j_scores,'cutoff':-1*threshold,'specificity':1-fpr, 'sensitivity':tpr})
        j_ordered.sort_values("j_scores",inplace=True, ascending=False)
        j_ordered = j_ordered.reset_index(drop=True)

        optimal_cutoff = j_ordered['cutoff'][len(j_ordered)-1]
        optimal_cutoff =round(optimal_cutoff, 4)
        
        
    elif train == False:
        optimal_cutoff = cutoff

    # print("optimal_cutoff..", optimal_cutoff)        
    fpr, tpr, threshold = roc_curve(y, 1*probas_[:, 0], pos_label=1)
    j_ordered =  DataFrame({'cutoff':threshold,'specificity':1-fpr, 'sensitivity':tpr})
    j_ordered.sort_values("cutoff",inplace=True, ascending=False)
    j_ordered = j_ordered.reset_index(drop=True)   
    j_ordered = j_ordered[(j_ordered.cutoff > optimal_cutoff)]
    j_ordered = j_ordered.reset_index(drop=True) 
                
    
    optimal_sensitivity = j_ordered['sensitivity'][len(j_ordered)-1]
    optimal_specificity = j_ordered['specificity'][len(j_ordered)-1] 
    
    return optimal_cutoff, optimal_sensitivity, optimal_specificity
    
    
            
def ROC_auc(y, probas_):
    """    
    computer the associated area under receiver operating characteristic curves (AUC).
    
    Args:
        y(numpy.ndarray):  ndarray of y. Note: y=0 indicates the patient with DFS > 5 years, 
                                               y=1 indicates the patient with DFS <= 5 years.   
        probas_(numpy.ndarray): ndarray of prognostic scores.
        
    Returns:
        aucs(list): the list of areas Under the ROC Curve calculated with the trapezoidal rule.    
    """
    
    fpr, tpr, threshold = roc_curve(y, 1*probas_[:, 0], pos_label=1)        
    tprs = []
    aucs = []
    mean_fpr = np.linspace(0, 1, 100)
    tprs.append(np.interp(mean_fpr, fpr, tpr))
    tprs[-1][0] = 0.0
    roc_auc = auc(fpr, tpr)
    aucs.append(roc_auc)

    return aucs
    
    
def experiment_info(device, dataset,  model, data_loader,TRAIN_RT = True, TRAIN_DATA = True,  cutoff_init = 0):
    """    
    Evaluate model performance by measuring AUC, sensitivity, specificity, HR and Cindex.
     
     Args:
         device(torch.device): GPU or CPU.
         dataset(Gdataset_utils.tu_dataset_qld.TUDataset): Data objects of graph structures from graphdataset.
         model(models.models): The selected model instance.  
         data_loader(torch_geometric.data.dataloader.DataLoader): Data loader.        
         TRAIN_RT(bool): If `True`, the model is being trained. 
                         Otherwise, the trained model is being evaluated.
         TRAIN_DATA(bool): If `True`, the model performance is being evaluated on the training data.   
                           Otherwise, the model performance is being evaluated on the validation data. 
         cutoff_init(float): initial cutoff value.  
         
     Returns:
         loss(float): Training loss or validation loss.    
         cutoff(float): Cutoff value.  
         AUC(float): the associated area under receiver operating characteristic curves.  
         sensitivity(float): Sensitivity to predict 5-year DFS rate of patients.  
         specificity(float): Specificity to predict 5-year DFS rate of patients.  
         HR(float): Hazard ratio measured on the patients stratified into low- and high-risk groups.  
         Cindex(float): Coincidence index.  
    """
    
    #  Get the model response on specific data.
    loss, pre, y, DFS, STATUS, Tindicators, features = test(device, dataset, model, data_loader) ;
    
    pre_score = 1*pre.cpu().detach().numpy()

    y = y.cpu().numpy()
    DFS =DFS.cpu().numpy() 
    STATUS = STATUS.cpu().numpy() 
    
    aucs = ROC_auc(y, pre_score)
    
    if (TRAIN_RT == True) :
        return loss
    
    # Evaluate model performance.
    AUC = aucs[0]
    cutoff,sensitivity,specificity = Find_Optimal_Cutoff(y, pre_score, train = TRAIN_DATA, cutoff = cutoff_init)
    pre_risk = (pre_score[:,0] > cutoff).astype(np.int_)
    
    Survdata = DataFrame({'risk':pre_risk,'STATUS':STATUS,'DFS':DFS})   
    cphdata = CoxPHFitter();
    cphdata.fit(Survdata, duration_col='DFS', event_col='STATUS')
    HR = float( cphdata.hazard_ratios_ )
    Cindex = concordance_index(Survdata['DFS'], -1*pre_score[:,0], Survdata['STATUS'])
    
    return loss, cutoff, AUC, sensitivity, specificity, HR, Cindex



def experiment_results_save(device, args,  dataset,  model, data_loader,TRAIN_DATA = True,  cutoff_init = 0):
    """    
    Preservation of model performance as experimental results.
     
     Args:
         device(torch.device): GPU or CPU.
         args(argparse.Namespace): all arguments for models and experiments.         
         dataset(Gdataset_utils.tu_dataset_qld.TUDataset): Data objects of graph structures from graphdataset.
         model(models.models): The selected model instance.  
         data_loader(torch_geometric.data.dataloader.DataLoader): Data loader.        
         TRAIN_DATA(bool): If `True`, the model performance is being evaluated on the training data.   
                           Otherwise, the model performance is being evaluated on the validation data. 
         cutoff_init(float): initial cutoff value.  
    """
    
    #  Get the model response on specific data.    
    loss, pre, y, DFS, STATUS, Tindicators, features = test(device, dataset, model,data_loader) ;
    
    pre_score = 1*pre.cpu().detach().numpy()

    y = y.cpu().numpy()
    DFS =DFS.cpu().numpy() 
    STATUS = STATUS.cpu().numpy() 
    Tindicators = Tindicators.cpu().numpy().astype(np.int_)
    
        
    cutoff,sensitivity,specificity = Find_Optimal_Cutoff(y, pre_score, train = TRAIN_DATA, cutoff =cutoff_init)
    pre_risk = (pre_score[:,0] > round(cutoff, 4)).astype(np.int_)
    
    results = pd.DataFrame( {'Graph_id':Tindicators[:,13], 'y': y.T, 'DFS':DFS.T, 'STATUS':STATUS.T,\
                              'type':Tindicators[:,0], 'size':Tindicators[:,1],'lym':Tindicators[:,2],'stage':Tindicators[:,3],'grade':Tindicators[:,4],'age':Tindicators[:,5],\
                              'Chemotherapy':Tindicators[:,6], 'Endocrine':Tindicators[:,7], 'Radiation':Tindicators[:,8], 'Targeted':Tindicators[:,9],\
                              # 'ER':Tindicators[:,10],'PR':Tindicators[:,11],'HER2':Tindicators[:,12],\
                              'model_score': 1*pre_score[:,0].T,'model_risk':pre_risk.T} )
        
    results.sort_values(by=['Graph_id'],inplace=True)  
    results.drop('Graph_id', axis=1,inplace=True)
    
    # results_file = '{:s}{:s}_{:s}_cohort_{:s}.xlsx'.format(args.EXPERIMENT_RESULTS_DIR, args.EXPERIMENT_TYPE,  "train" if TRAIN_DATA==True else "test",  args.MODEL_TYPE)    
    results_file = '{:s}{:s}_{:s}_cohort_{:s}{:s}.xlsx'.format(args.EXPERIMENT_RESULTS_DIR, args.EXPERIMENT_TYPE,  "train" if TRAIN_DATA==True else "test", "fold{:s}_".format(args.FOLD_N) if args.EXPERIMENT_TYPE=="pre" else "",  args.MODEL_TYPE)     
    print("filename....", results_file)
    
    results.to_excel(results_file, sheet_name="1", index=False)    














