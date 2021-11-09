import os
import os.path as osp
import torch
import json
import collections
import warnings
import argparse
warnings.filterwarnings("ignore")

device = torch.device('cpu' if torch.cuda.is_available() else 'cpu')
path = osp.join(osp.dirname(osp.realpath(__file__)), 'Graphdatasets', 'TACS_G')
currpath = os.getcwd();
abspath = os.path.abspath(os.path.dirname(os.getcwd()));

try:
    collectionsAbc = collections.abc
except:
    collectionsAbc = collections 



def config_update(config, new_config):    
    """
    Update Configuration.
    
    Args:
        config(dict): Configuration containing arguments for models and experiments.        
        new_config(dict): New Configuration.
                
    Returns:
        config(dict): Updated configuration.
    """
    
    for k, v in new_config.items():
        dv = config.get(k, {})
        if not isinstance(dv, collectionsAbc.Mapping):
            config[k] = v
        elif isinstance(v, collectionsAbc.Mapping):
            config[k] = config_update(dv, v)
        else:
            config[k] = v
    return config


def init_config_args():
    """
    Initial Configuration containing arguments for models and experiments.    
    """
    
    parser = argparse.ArgumentParser(description = 'init_config_args...')
    
    parser.add_argument("-t", "--toml", type=str, action="append")
    
    # Raw data ande dataset containing graph structure。  
    parser.add_argument("--DIR_ROOT", type=str, default="../experiments/", help="root directory.")
    parser.add_argument("--EXPERIMENT_RESULTS_DIR", type=str, default="../experiments/experiment_results/", help="experiment_results directory.")
    parser.add_argument("--PATIENT_INFO_DIR", type=str, default="../experiments/Patients_Information/DataSets_995/", help="directory of raw data including TACS coding and clinical/follow-up information from patients.")
    parser.add_argument("--GRAPH_DATA_DIR", type=str, default="../experiments/Graphdatasets/", help="directory of graphdataset containing graph structure.")
    parser.add_argument("--GRAPH_DATA_NAME", type=str, default="TACS_G", help="directory name of graphdataset.")  
    parser.add_argument("--REBULIT_GRAPH_DATA_STATE",   metavar='bool', type=bool,  default=False, help = "[default: False] whether to rebuild the graphdataset.")     

    
    # Environment configuration。  
    parser.add_argument('--EXPERIMENT_TYPE', dest = "EXPERIMENT_TYPE", choices=["pre", "external"], default = "none",\
                                            help = "[pre]  experiment for 3-cross pre-validation."
                                                  "[external] experiment for external validation.")  

    parser.add_argument('--FOLD_N', dest = "FOLD_N", choices=['1', '2', '3'], default = 'none',\
                                            help = "current fold number in the 3-cross pre-validation.")    
        
    parser.add_argument('--MODEL_TYPE', dest = "MODEL_TYPE", choices=["IGNN", "IGNNE"], default = "none",\
                                            help = "[IGNN]  IGNN model."
                                                  "[IGNNE] IGNNE model.")          
    
    parser.add_argument('--PROCESSUNIT_STATE', dest = "PROCESSUNIT_STATE", choices=["GPU","GRU"], default = "CPU",\
                                            help = "[default:CPU]  train the model using the CPU."
                                                  "[GPU] train the model using the GPU.")  
        
    parser.add_argument('--MODEL_STATE', dest = "MODEL_STATE", choices=["Train","Result","Reproduce"], default = "none",\
                                            help = "[Train]  train the IGNNE model on the training cohort from scratch."
                                                  "[Result]  get the experimental result from the trained IGNNE model."
                                                  "[Reproduce] reproduce the well trained IGNNE model shown in the paper.")

    parser.add_argument('--PARAM_STATE', dest = "PARAM_STATE", choices=["save", "none"], default = "none",\
                                            help = "[save]  save the model parameters.")

        
    parser.add_argument('--seed_init', metavar='int', type=int, default= 1, help= "the seed for generating random numbers in PyTorch, numpy and Python.")   

     
    # The information of FMU(HMU) dataset composed of the TACS coding, clinical and follow-up data from FMU(HMU) patients. 
    parser.add_argument('--num_FMU', type=int, metavar='int', default=731, help = "[default: 731] the number of patients in FMU dataset.")                
    parser.add_argument('--f1_FMU', type=int, metavar='int',default=0, help = "[default: 0] first FMU patient index with DFS < 5 years in FMU dataset.")
    parser.add_argument('--l1_FMU', type=int, metavar='int',default=261, help = "[default: 261] last FMU patient index with DFS < 5 years in FMU dataset.")    
    parser.add_argument('--f2_FMU', type=int, metavar='int',default=357, help = "[default: 357] first FMU patient index with DFS > 5 years in FMU dataset.")
    parser.add_argument('--l2_FMU', type=int, metavar='int',default=827, help = "[default: 827] last FMU patient index with DFS > 5 years in FMU dataset.")   

    parser.add_argument('--num_HMU', type=int, metavar='int',default=264, help = "[default: 264] the number of patients in HMU dataset.")      
    parser.add_argument('--f1_HMU', type=int, metavar='int',default=261, help = "[default: 261] first HMU patient index with DFS < 5 years in HMU dataset.")
    parser.add_argument('--l1_HMU', type=int, metavar='int',default=357, help = "[default: 357] last HMU patient index with DFS < 5 years in HMU dataset.")    
    parser.add_argument('--f2_HMU', type=int, metavar='int', default=827, help = "[default: 827] first HMU patient index with DFS > 5 years in HMU dataset.")
    parser.add_argument('--l2_HMU', type=int, metavar='int',default=995, help = "[default: 995] last HMU patientindex  with DFS > 5 years in HMU dataset.")  

    # Initialization of model parameters for training。 
    parser.add_argument("--GRU_STATE",   metavar='bool', type=bool,  default=False, help = "[default: False] Optional GRU units in the model structure.")
    parser.add_argument("--epochs", type=int, metavar='int', default=59, help = "number of epochs for training.")
    parser.add_argument('--batchsize', type=int, metavar='int',default=16, help = "batch size for training.") 
    parser.add_argument('--lr_init', type=float, metavar='float',default=0.01, help = "initial learning rate for training.") 
    parser.add_argument('--weight_decay_init', type=json.loads, metavar='dict', default={'wd_gnn_layer1': 0.05,'wd_gnn_layer2': 0.05, 'wd_embeddings': 0.05, 'wd_fc_embed': 0.05, 'wd_fc_all': 0.05, 'wd_lin1': 0.05, 'wd_lin2': 0.05, 'wd_fc1': 0.05, 'wd_fc2': 0.05, 'wd_fc3': 0.05}, help='initial weight decay rate of IGNNE model for training.')
    
    # Adaptive early stopping strategy for training that changes the learning rate and decay rate according to the training loss. 
    parser.add_argument('--checkpoint1', type=int, metavar='int',default=9, help = "epoch number to check the training loss first time.")  
    parser.add_argument('--wd_rate1', type=float, metavar='float',default=0.20, help = "change rate of model weight decay at checkpoint1.") 
    parser.add_argument('--lr1', type=float, metavar='float',default=0.01, help = "new learning rate of training at checkpoint1.") 
    parser.add_argument('--loss_decratio1', type=float, metavar='float',default=0.961, help = "change rate of training loss at checkpoint1.") 
    
    parser.add_argument('--checkpoint2', type=int, metavar='int',default=19, help = "epoch number to check the training loss second time.")  
    parser.add_argument('--wd_rate2_1', type=float, metavar='float',default=0.10, help = "change rate of model weight decay at checkpoint2.") 
    parser.add_argument('--wd_rate2_2', type=float, metavar='float',default=0.30, help = "change rate of model weight decay at checkpoint2.") 
    parser.add_argument('--lr2_1', type=float, metavar='float',default=0.02, help = "new learning rate of training at checkpoint2.")     
    parser.add_argument('--lr2_2', type=float, metavar='float',default=0.00001  , help = "new learning rate of training at checkpoint2.") 
    parser.add_argument('--loss_decratio2', type=float, metavar='float',default=0.910, help = "change rate of training loss at checkpoint2.") 
    
    parser.add_argument('--checkpoint3', type=int, metavar='int',default=54, help = "epoch number to check the training loss third time.")  
    
    return parser.parse_args()

##############################################

def pre_IGNN_config_args(parent_parser = init_config_args() ):   
    """
    Initial Configuration containing arguments for pre-validation experiments with IGNN model.
    
    Args:
        parent_parser(argparse.Namespace): Parsers whose arguments should be copied into this one.
                
    Returns:
        parser.parse_args(argparse.Namespace): Configuration.
    """    
    
    parser = argparse.ArgumentParser(parents=[parent_parser], description = 'Experiment and model configuration...')

    # Initialization of IGNN model parameters for training。 
    parser.add_argument("--GRU_STATE",   metavar='bool', type=bool,  default=False, help = "[default: False] Optional GRU units in the model structure.")
    parser.add_argument("--epochs", type=int, metavar='int', default=325, help = "number of epochs for training.")
    parser.add_argument('--batchsize', type=int, metavar='int',default=16, help = "batch size for training.") 
    parser.add_argument('--lr_init', type=float, metavar='float',default=0.01, help = "initial learning rate for training.") 
    parser.add_argument('--weight_decay_init', type=lambda x: {k:int(v) for k,v in (i.split(':') for i in x.split(','))}, metavar='dict', default={'wd_gnn_layer1': 0.05,\
                                                                                                                                                   'wd_gnn_layer2': 0.05,\
                                                                                                                                                   'wd_lin1': 0.05,\
                                                                                                                                                   'wd_lin2': 0.05,\
                                                                                                                                                   'wd_fc1': 0.05,\
                                                                                                                                                   'wd_fc2': 0.05,\
                                                                                                                                                   'wd_fc3': 0.05}, help='initial weight decay rate of IGNNE model for training.')
    
    # Adaptive early stopping strategy for training that changes the learning rate and decay rate according to the training loss. 
    parser.add_argument('--checkpoint1', type=int, metavar='int',default=139, help = "epoch number to check the training loss first time.")  
    parser.add_argument('--wd_rate1', type=float, metavar='float',default=0.22, help = "change rate of model weight decay at checkpoint1.") 
    parser.add_argument('--lr1', type=float, metavar='float',default=0.01, help = "new learning rate of training at checkpoint1.") 
    parser.add_argument('--loss_decratio1', type=float, metavar='float',default=0.965, help = "change rate of training loss at checkpoint1.") 
    
    parser.add_argument('--checkpoint2', type=int, metavar='int',default=244, help = "epoch number to check the training loss second time.")  
    parser.add_argument('--wd_rate2_1', type=float, metavar='float',default=0.77, help = "change rate of model weight decay at checkpoint2.") 
    parser.add_argument('--wd_rate2_2', type=float, metavar='float',default=0.91, help = "change rate of model weight decay at checkpoint2.") 
    parser.add_argument('--lr2_1', type=float, metavar='float',default=0.000001, help = "new learning rate of training at checkpoint2.")     
    parser.add_argument('--lr2_2', type=float, metavar='float',default=0.01 , help = "new learning rate of training at checkpoint2.") 
    parser.add_argument('--loss_decratio2', type=float, metavar='float',default=0.965, help = "change rate of training loss at checkpoint2.") 
    
    parser.add_argument('--checkpoint3', type=int, metavar='int',default=299, help = "epoch number to check the training loss third time.")  
    
    return parser.parse_args()


##############################################
def pre_IGNNE_config_args(parent_parser = init_config_args()):
    """
    Initial Configuration containing arguments for pre-validation experiments with IGNNE model.
    
    Args:
        parent_parser(argparse.Namespace): Parsers whose arguments should be copied into this one.
                
    Returns:
        parser.parse_args(argparse.Namespace): Configuration.
    """   
    
    parser = argparse.ArgumentParser(parents=[parent_parser], description = 'Experiment and model configuration...')
    
    # Initialization of IGNNE model parameters for training。 
    parser.add_argument("--GRU_STATE",   metavar='bool', type=bool,  default=False, help = "[default: False] Optional GRU units in the model structure.")
    parser.add_argument("--epochs", type=int, metavar='int', default=59, help = "number of epochs for training.")
    parser.add_argument('--batchsize', type=int, metavar='int',default=16, help = "batch size for training.") 
    parser.add_argument('--lr_init', type=float, metavar='float',default=0.01, help = "initial learning rate for training.") 
    parser.add_argument('--weight_decay_init', type=lambda x: {k:int(v) for k,v in (i.split(':') for i in x.split(','))}, metavar='dict', default={'wd_gnn_layer1': 0.05,\
                                                                                                                                                   'wd_gnn_layer2': 0.05,\
                                                                                                                                                   'wd_embeddings': 0.05,\
                                                                                                                                                   'wd_fc_embed': 0.05,\
                                                                                                                                                   'wd_fc_all': 0.05,\
                                                                                                                                                   'wd_lin1': 0.05,\
                                                                                                                                                   'wd_lin2': 0.05,\
                                                                                                                                                   'wd_fc1': 0.05,\
                                                                                                                                                   'wd_fc2': 0.05,\
                                                                                                                                                   'wd_fc3': 0.05}, help='initial weight decay rate of IGNNE model for training.')
    
    # Adaptive early stopping strategy for training that changes the learning rate and decay rate according to the training loss. 
    parser.add_argument('--checkpoint1', type=int, metavar='int',default=9, help = "epoch number to check the training loss first time.")  
    parser.add_argument('--wd_rate1', type=float, metavar='float',default=0.20, help = "change rate of model weight decay at checkpoint1.") 
    parser.add_argument('--lr1', type=float, metavar='float',default=0.01, help = "new learning rate of training at checkpoint1.") 
    parser.add_argument('--loss_decratio1', type=float, metavar='float',default=0.961, help = "change rate of training loss at checkpoint1.") 
    
    parser.add_argument('--checkpoint2', type=int, metavar='int',default=19, help = "epoch number to check the training loss second time.")  
    parser.add_argument('--wd_rate2_1', type=float, metavar='float',default=0.10, help = "change rate of model weight decay at checkpoint2.") 
    parser.add_argument('--wd_rate2_2', type=float, metavar='float',default=0.30, help = "change rate of model weight decay at checkpoint2.") 
    parser.add_argument('--lr2_1', type=float, metavar='float',default=0.02, help = "new learning rate of training at checkpoint2.")     
    parser.add_argument('--lr2_2', type=float, metavar='float',default=0.00001  , help = "new learning rate of training at checkpoint2.") 
    parser.add_argument('--loss_decratio2', type=float, metavar='float',default=0.910, help = "change rate of training loss at checkpoint2.") 
    
    parser.add_argument('--checkpoint3', type=int, metavar='int',default=54, help = "epoch number to check the training loss third time.")  
    
    return parser.parse_args()


##############################################
def external_IGNN_config_args(parent_parser = init_config_args() ):
    """
    Initial Configuration containing arguments for external-validation experiments with IGNN model.
    
    Args:
        parent_parser(argparse.Namespace): Parsers whose arguments should be copied into this one.
                
    Returns:
        parser.parse_args(argparse.Namespace): Configuration.
    """   
    
    parser = argparse.ArgumentParser(parents=[parent_parser], description = 'Experiment and model configuration...')

    # Initialization of IGNN model parameters for training。 
    parser.add_argument("--GRU_STATE",   metavar='bool', type=bool,  default=False, help = "[default: False] Optional GRU units in the model structure.")
    parser.add_argument("--epochs", type=int, metavar='int', default=656, help = "number of epochs for training.")
    parser.add_argument('--batchsize', type=int, metavar='int',default=16, help = "batch size for training.") 
    parser.add_argument('--lr_init', type=float, metavar='float',default=0.01, help = "initial learning rate for training.") 
    parser.add_argument('--weight_decay_init', type=lambda x: {k:int(v) for k,v in (i.split(':') for i in x.split(','))}, metavar='dict', default={'wd_gnn_layer1': 0.0045,\
                                                                                                                                                   'wd_gnn_layer2': 0.0045,\
                                                                                                                                                   'wd_lin1': 0.0001,\
                                                                                                                                                   'wd_lin2': 0.0001,\
                                                                                                                                                   'wd_fc1': 0.0000,\
                                                                                                                                                   'wd_fc2': 0.0001,\
                                                                                                                                                   'wd_fc3': 0.0000}, help='initial weight decay rate of IGNNE model for training.')
    
    # Adaptive early stopping strategy for training that changes the learning rate and decay rate according to the training loss. 
    parser.add_argument('--checkpoint1', type=int, metavar='int',default=396, help = "epoch number to check the training loss first time.")  
    parser.add_argument('--wd_rate1', type=float, metavar='float',default=10.0, help = "change rate of model weight decay at checkpoint1.") 
    parser.add_argument('--lr1', type=float, metavar='float',default=0.01, help = "new learning rate of training at checkpoint1.") 
    parser.add_argument('--loss_decratio1', type=float, metavar='float',default=0.965, help = "change rate of training loss at checkpoint1.") 
    
    parser.add_argument('--checkpoint2', type=int, metavar='int',default=629, help = "epoch number to check the training loss second time.")  
    parser.add_argument('--wd_rate2_1', type=float, metavar='float',default=0.77, help = "change rate of model weight decay at checkpoint2.") 
    parser.add_argument('--wd_rate2_2', type=float, metavar='float',default=0.72, help = "change rate of model weight decay at checkpoint2.") 
    parser.add_argument('--lr2_1', type=float, metavar='float',default=0.01, help = "new learning rate of training at checkpoint2.")     
    parser.add_argument('--lr2_2', type=float, metavar='float',default=1e-5 , help = "new learning rate of training at checkpoint2.") 
    parser.add_argument('--loss_decratio2', type=float, metavar='float',default=0.963, help = "change rate of training loss at checkpoint2.") 
    
    parser.add_argument('--checkpoint3', type=int, metavar='int',default=640, help = "epoch number to check the training loss third time.")  
    
    return parser.parse_args()


##############################################
def external_IGNNE_config_args(parent_parser = init_config_args() ):
    """
    Initial Configuration containing arguments for external-validation experiments with IGNNE model.
    
    Args:
        parent_parser(argparse.Namespace): Parsers whose arguments should be copied into this one.
                
    Returns:
        parser.parse_args(argparse.Namespace): Configuration.
    """     
    
    parser = argparse.ArgumentParser(parents=[parent_parser], description = 'Experiment and model configuration...')
     
    # Initialization of IGNNE model parameters for training。 
    parser.add_argument("--GRU_STATE",   metavar='bool', type=bool,  default=False, help = "[default: False] Optional GRU units in the model structure.")
    parser.add_argument("--epochs", type=int, metavar='int', default=1000, help = "number of epochs for training.")
    parser.add_argument('--batchsize', type=int, metavar='int',default=128, help = "batch size for training.") 
    parser.add_argument('--lr_init', type=float, metavar='float',default=0.005, help = "initial learning rate for training.") 
    parser.add_argument('--weight_decay_init', type=lambda x: {k:int(v) for k,v in (i.split(':') for i in x.split(','))}, metavar='dict', default={'wd_gnn_layer1': 0.005,\
                                                                                                                                                   'wd_gnn_layer2': 0.005,\
                                                                                                                                                   'wd_embeddings': 0.0045,\
                                                                                                                                                   'wd_fc_embed': 0.0045,\
                                                                                                                                                   'wd_fc_all': 0.0045,\
                                                                                                                                                   'wd_lin1': 0.005,\
                                                                                                                                                   'wd_lin2': 0.005,\
                                                                                                                                                   'wd_fc1': 0.005,\
                                                                                                                                                   'wd_fc2': 0.005,\
                                                                                                                                                   'wd_fc3': 0.0035}, help='initial weight decay rate of IGNNE model for training.')
    
    # Adaptive early stopping strategy for training that changes the learning rate and decay rate according to the training loss. 
    parser.add_argument('--checkpoint1', type=int, metavar='int',default=687, help = "epoch number to check the training loss first time.")  
    parser.add_argument('--wd_rate1', type=float, metavar='float',default=2.0, help = "change rate of model weight decay at checkpoint1.") 
    parser.add_argument('--lr1', type=float, metavar='float',default=0.01, help = "new learning rate of training at checkpoint1.") 
    parser.add_argument('--loss_decratio1', type=float, metavar='float',default=0.905, help = "change rate of training loss at checkpoint1.") 
    
    parser.add_argument('--checkpoint2', type=int, metavar='int',default=887, help = "epoch number to check the training loss second time.")  
    parser.add_argument('--wd_rate2_1', type=float, metavar='float',default=0.5, help = "change rate of model weight decay at checkpoint2.") 
    parser.add_argument('--wd_rate2_2', type=float, metavar='float',default=1.0, help = "change rate of model weight decay at checkpoint2.") 
    parser.add_argument('--lr2_1', type=float, metavar='float',default=0.01, help = "new learning rate of training at checkpoint2.")     
    parser.add_argument('--lr2_2', type=float, metavar='float',default=5e-8, help = "new learning rate of training at checkpoint2.") 
    parser.add_argument('--loss_decratio2', type=float, metavar='float',default=0.850, help = "change rate of training loss at checkpoint2.") 
    
    parser.add_argument('--checkpoint3', type=int, metavar='int',default=947, help = "epoch number to check the training loss third time.")  
    
    return parser.parse_args()

