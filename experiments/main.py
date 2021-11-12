"""
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
"""

import os.path as osp
import torch
import toml
import warnings
from graphdataset_utils.CreateGraphDataset import create_GraphDataset
from graphdataset_utils.graphs_dataset import GraphDataset
from graphdataset_utils.split_dataset import split_dataset
from torch_geometric.data import DataLoader
from models.CenterLoss import CenterLoss
from configs.configs import init_config_args, config_update
from models.models import model, model_optimizer, standardized_x_ex
from models.training import train, weights_init, Astopper
from experiment_utils.experiment_utils import seed_everything, experiment_info, experiment_results_save
from models.model_save_load import model_parameters
warnings.filterwarnings("ignore")


# Command-line interface entry point.    
if __name__ == "__main__":
    print("main...................")
    
    # Loading configuration of models and experiments from the command line or initial configuration file.    
    args = init_config_args()    
    if args.toml is not None:
        tomls = "\n".join(args.toml)     
        new_config = toml.loads(tomls)          
    config = toml.load( '{:s}configs/{:s}_{:s}validation_config.toml'.format(args.DIR_ROOT, new_config['MODEL_TYPE'], new_config['EXPERIMENT_TYPE']) )
    config_update(config, new_config)
    args.__dict__ = config      
    print("args...",vars(args))

    
    path = osp.join(osp.dirname(osp.realpath(__file__)), 'Graphdatasets', args.GRAPH_DATA_NAME)
    
    DEVICE_GPU = ( torch.cuda.is_available() ) & (args.PROCESSUNIT_STATE=='GPU');
    global device
    device = torch.device('cuda' if DEVICE_GPU  else 'cpu')    
    torch.cuda.empty_cache()    

    # Generate graphdataset from TACS coding, clinical and follow up data of patients
    create_GraphDataset(args)
    
    # load graphdataset
    dataset = GraphDataset(path, name = args.GRAPH_DATA_NAME,use_node_attr=False)                
    train_dataset, test_dataset = split_dataset(args, dataset)
    
    # Calculate the mean and standard deviation valure for each clinical factor on the training cohort
    x_ex_mean, x_ex_std = standardized_x_ex(device, DataLoader(train_dataset, shuffle = False, batch_size= args.num_FMU) )
    
    seed_everything( seed = args.seed_init );    
    
    # Construct the IGNN or IGNNE model
    model = model(DEVICE_GPU, args, dataset, x_ex_mean, x_ex_std).to(device)
    model.apply(weights_init)
    centerloss = CenterLoss(2, 32).to(device)       
        
    optimizer = model_optimizer(model, args)    
    
    # An adaptive stopping scheduler (Astopper) was developed to automatically select a suitable epoch for interrupting training process
    astopper = Astopper(args) 

    # Load batch of training data from training cohort for model training
    trainRT_loader = DataLoader(train_dataset, shuffle=True, batch_size=args.batchsize)  
    # Load the entire training cohort again for evaluation
    train_loader = DataLoader(train_dataset, shuffle=False, batch_size= args.num_FMU) 
    # Load the validation cohort for evaluation
    test_loader = DataLoader(test_dataset, shuffle=False, batch_size= args.num_HMU)            

    
    # Train the model from scratch        
    if args.MODEL_STATE == "Train":
        print("Train...")
        
        TrainLoss_info=[]
        TestLoss_info=[]                
                
        for epoch in range(1, args.epochs):
            
            train_loss = train(device, train_dataset, model,optimizer, loader = trainRT_loader)        
            astopper.stopping(args, model, epoch, optimizer, train_loss)                                
            
            trainRT_loss = experiment_info(device,train_dataset,  model, data_loader = trainRT_loader, TRAIN_RT = True, TRAIN_DATA = True,  cutoff_init = 0 );  
            
            # Evaluate the prognostic performance of IGNN/IGNNE on the training cohort by measuring HR, AUC, sensitivity, specificity, C-index
            train_loss_all, \
            train_cutoff, train_AUC, train_sensitivity, train_specificity, \
            train_HR, train_Cindex = experiment_info(device, train_dataset,  model,  data_loader = train_loader, TRAIN_RT = False, TRAIN_DATA = True, cutoff_init = 0 ); 
            
            # Evaluate the prognostic performance of IGNN/IGNNE on the validation cohort by measuring HR, AUC, sensitivity, specificity, C-index
            test_loss, \
            test_cutoff, test_AUC, test_sensitivity, test_specificity, \
            test_HR, test_Cindex = experiment_info(device, test_dataset, model,data_loader = test_loader, TRAIN_RT = False, TRAIN_DATA = False, cutoff_init = train_cutoff );                    
            
            print('Epoch: {:03d}, TrainLoss: {:.4f}, TrainAuc: {:.3f}, TrainSen: {:.3f}, TrainSpe: {:.3f}, TrainHR: {:.3f}, TrainC: {:.3f}, TestAuc: {:.3f}, TestSen: {:.3f}, TestSpe: {:.3f}, TestHR: {:.2f}, TestC: {:.3f}'.\
                    format(epoch, train_loss, train_AUC, train_sensitivity, train_specificity, train_HR, train_Cindex,\
                                              test_AUC, test_sensitivity, test_specificity, test_HR, test_Cindex ) ) 

            TrainLoss_info.append(trainRT_loss)
            TestLoss_info.append(test_loss)
                                          
                
                

    # Reproduce the experimental results with the well-trained model by loading the saved model parameters                 
    if (args.MODEL_STATE == "Reproduce") | (args.MODEL_STATE == "Result") :
        print("Reproduce...")
        
        # for epoch in range(1, args.epochs):
        #     model_parameters(args, model, epoch)     
            
        #     _, \
        #     train_cutoff, train_AUC, train_sensitivity, train_specificity, \
        #     train_HR, train_Cindex = experiment_info(device, train_dataset, model, data_loader = train_loader, TRAIN_RT = False, TRAIN_DATA = True, cutoff_init = 0 );  # train cohort (n=731)            
        #     _, \
        #     test_cutoff, test_AUC, test_sensitivity, test_specificity, \
        #     test_HR, test_Cindex = experiment_info(device, test_dataset, model, data_loader = test_loader, TRAIN_RT = False, TRAIN_DATA = False, cutoff_init = train_cutoff );  # validation cohort (n=264)                
             
        #     print('Epoch: {:03d}, TrainAuc: {:.3f}, TrainSen: {:.3f}, TrainSpe: {:.3f}, TrainHR: {:.3f}, TrainC: {:.3f},  TestAuc: {:.3f}, TestSen: {:.3f}, TestSpe: {:.3f}, TestHR: {:.2f}, TestC: {:.3f}'.\
        #             format(epoch, train_AUC, train_sensitivity, train_specificity, train_HR, train_Cindex,\
        #                           test_AUC, test_sensitivity, test_specificity, test_HR, test_Cindex ) )   
                
                    
        # load the saved model parameters  
        model_parameters(args, model, None, "GET", None)   
       
        
        # Evaluate the prognostic performance of IGNN/IGNNE on the training cohort
        _, \
        train_cutoff, train_AUC, train_sensitivity, train_specificity, \
        train_HR, train_Cindex = experiment_info(device, train_dataset, model, data_loader = train_loader,TRAIN_RT = False,  TRAIN_DATA = True, cutoff_init = 0 );  # train cohort (n=731)        
  
        
        # Evaluate the prognostic performance of IGNN/IGNNE on the validation cohort
        _, \
        test_cutoff, test_AUC, test_sensitivity, test_specificity, \
        test_HR, test_Cindex = experiment_info(device, test_dataset, model, data_loader = test_loader, TRAIN_RT = False, TRAIN_DATA = False, cutoff_init = train_cutoff );  # validation cohort (n=264)                
         
        
        print('TrainAuc: {:.3f}, TrainSen: {:.3f}, TrainSpe: {:.3f}, TrainHR: {:.3f}, TrainC: {:.3f},  TestAuc: {:.3f}, TestSen: {:.3f}, TestSpe: {:.3f}, TestHR: {:.2f}, TestC: {:.3f}'.\
                format(train_AUC, train_sensitivity, train_specificity, train_HR, train_Cindex,\
                              test_AUC, test_sensitivity, test_specificity, test_HR, test_Cindex ) )     

        experiment_results_save(device, args, train_dataset, model, data_loader = train_loader, TRAIN_DATA = True,  cutoff_init = 0)      
        experiment_results_save(device, args, test_dataset, model, data_loader = test_loader, TRAIN_DATA =False,  cutoff_init = train_cutoff)        
                
                

                
                
                
                
                
                
                
                
                
                
