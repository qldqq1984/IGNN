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



def user_config_args():
    """
    Initial Configuration containing arguments for User-defined experiments.
    
    Args:
        parent_parser(argparse.Namespace): Parsers whose arguments should be copied into this one.
                
    Returns:
        parser.parse_args(argparse.Namespace): Configuration.
    """ 
    
    parser = argparse.ArgumentParser(description = 'user experiment and model configuration...')

    parser.add_argument("-t", "--toml", type=str, action="append")
    
    # Raw data ande dataset containing graph structure。  
    parser.add_argument("--DIR_ROOT", type=str, default="../experiments/", help="root directory.")
    parser.add_argument("--EXPERIMENT_RESULTS_DIR", type=str, default="../experiments/experiment_results/", help="experiment_results directory.")    
    parser.add_argument("--PATIENT_INFO_DIR", type=str, default="../experiments/Patients_Information/DataSets_demo/", help="directory of user data including TACS coding and clinical/follow-up information from patients.")
    parser.add_argument("--GRAPH_DATA_DIR", type=str, default="../experiments/Graphdatasets/", help="directory of graphdataset containing graph structure.")
    parser.add_argument("--GRAPH_DATA_NAME", type=str, default="User_G", help="directory name of graphdataset.")  
    parser.add_argument("--REBULIT_GRAPH_DATA_STATE",   metavar='bool', type=bool,  default=True, help = "[default: False] whether to rebuild the graphdataset.")     

    
    # Environment configuration。   
    parser.add_argument('--EXPERIMENT_TYPE', dest = "EXPERIMENT_TYPE", choices=["user"], default = "user",\
                                           help = "[user] user-defined experiment.")  

        
    parser.add_argument('--MODEL_TYPE', dest = "MODEL_TYPE", choices=["IGNN", "IGNNE"], default = "IGNNE",\
                                           help = "[IGNN]  IGNN model."
                                                  "[IGNNE] IGNNE model.")          
    
    parser.add_argument('--PROCESSUNIT_STATE', dest = "PROCESSUNIT_STATE", choices=["GPU","GRU"], default = "CPU",\
                                           help = "[default:CPU]  train the model using the CPU."
                                                  "[GPU] train the model using the GPU.")  
        
    parser.add_argument('--MODEL_STATE', dest = "MODEL_STATE", choices=["Train","Result"], default = "Result",\
                                           help = "[Train]  train the IGNNE model on the training cohort from scratch."
                                                  "[Result]  get the experimental result from the trained IGNNE model.")

    parser.add_argument('--PARAM_STATE', dest = "PARAM_STATE", choices=["save", "none"], default = "none",\
                                           help = "[save]  save the model parameters.")

        
    parser.add_argument('--seed_init', metavar='int', type=int, default= 1, help= "the seed for generating random numbers in PyTorch, numpy and Python.")   
    
    # The user dataset composed of the TACS coding, clinical and follow-up data from FMU(HMU) patients. 
    parser.add_argument('--num_train', type=int, metavar='int', default=731, help = "[default: 731] the number of patients in user dataset.")                
    parser.add_argument('--f1_train', type=int, metavar='int',default=0, help = "[default: 0] first train patient index with DFS < 5 years in user dataset.")
    parser.add_argument('--l1_train', type=int, metavar='int',default=261, help = "[default: 261] last train patient index with DFS < 5 years in user dataset.")    
    parser.add_argument('--f2_train', type=int, metavar='int',default=357, help = "[default: 357] first train patient index with DFS > 5 years in user dataset.")
    parser.add_argument('--l2_train', type=int, metavar='int',default=827, help = "[default: 827] last train patient index with DFS > 5 years in user dataset.")   

    parser.add_argument('--num_test', type=int, metavar='int',default=264, help = "[default: 264] the number of patients in test dataset.")      
    parser.add_argument('--f1_test', type=int, metavar='int',default=261, help = "[default: 261] first test patient index with DFS < 5 years in user dataset.")
    parser.add_argument('--l1_test', type=int, metavar='int',default=357, help = "[default: 357] last test patient index with DFS < 5 years in user dataset.")    
    parser.add_argument('--f2_test', type=int, metavar='int', default=827, help = "[default: 827] first test patient index with DFS > 5 years in user dataset.")
    parser.add_argument('--l2_test', type=int, metavar='int',default=995, help = "[default: 995] last test patientindex  with DFS > 5 years in user dataset.")  
    
    
    # Initialization of user model parameters for training。
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