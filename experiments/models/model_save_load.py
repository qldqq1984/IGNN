import torch
import warnings
warnings.filterwarnings("ignore")


def model_parameters(args, model, epoch, best_model = None, best_epoch = None):
    """   
    Saves or loads parameters for the model.
    
    Args:
        args(argparse.Namespace): all arguments for models and experiments.
        model(models.models): The model that needs to be saved with all parameters.  
        epoch(int): Current training iteration number.              
        best_model(models.models): The well-trained model.  
        best_epoch(int): The epoch to interrupt training process with the minist training loss.      
    """  
            
    if ( ( args.MODEL_STATE == "Train" )|( args.MODEL_STATE == "Result" ) ) & ( args.EXPERIMENT_TYPE == "pre" ) & ( args.MODEL_TYPE == "IGNN" ):
        paramfile_path = '../experiments/models_parameters/Train/IGNN/pre_validation/' + 'fold_{:01d}/'.format(int(args.FOLD_N))

    if ( ( args.MODEL_STATE == "Train" )|( args.MODEL_STATE == "Result" ) ) & ( args.EXPERIMENT_TYPE == "pre" ) & ( args.MODEL_TYPE == "IGNNE" ):  
        paramfile_path = '../experiments/models_parameters/Train/IGNNE/pre_validation/' + 'fold_{:01d}/'.format(int(args.FOLD_N))
     
    if ( ( args.MODEL_STATE == "Train" )|( args.MODEL_STATE == "Result" ) ) & ( args.EXPERIMENT_TYPE == "external" ) & ( args.MODEL_TYPE == "IGNN" ):  
        paramfile_path = '../experiments/models_parameters/Train/IGNN/external_validation/' 
        
    if ( ( args.MODEL_STATE == "Train" )|( args.MODEL_STATE == "Result" ) ) & ( args.EXPERIMENT_TYPE == "external" ) & ( args.MODEL_TYPE == "IGNNE" ):     
        paramfile_path = '../experiments/models_parameters/Train/IGNNE/external_validation/'
         
    if ( ( args.MODEL_STATE == "Train" )|( args.MODEL_STATE == "Result" ) ) & ( args.EXPERIMENT_TYPE == "user" ) & ( args.MODEL_TYPE == "IGNN" ):  
        paramfile_path = '../experiments/models_parameters/Train/IGNN/user/' 
        
    if ( ( args.MODEL_STATE == "Train" )|( args.MODEL_STATE == "Result" ) ) & ( args.EXPERIMENT_TYPE == "user" ) & ( args.MODEL_TYPE == "IGNNE" ):     
        paramfile_path = '../experiments/models_parameters/Train/IGNNE/user/'
        
        
    
    if ( args.MODEL_STATE == "Reproduce" ) & ( args.EXPERIMENT_TYPE == "pre" ) & ( args.MODEL_TYPE == "IGNN" ):
        paramfile_path = '../experiments/models_parameters/Reproduce/IGNN/pre_validation/' + 'fold_{:01d}/'.format(int(args.FOLD_N))

    if ( args.MODEL_STATE == "Reproduce" ) & ( args.EXPERIMENT_TYPE == "pre" ) & ( args.MODEL_TYPE == "IGNNE" ):  
        paramfile_path = '../experiments/models_parameters/Reproduce/IGNNE/pre_validation/' + 'fold_{:01d}/'.format(int(args.FOLD_N))
     
    if ( args.MODEL_STATE == "Reproduce" ) & ( args.EXPERIMENT_TYPE == "external" ) & ( args.MODEL_TYPE == "IGNN" ):  
        paramfile_path = '../experiments/models_parameters/Reproduce/IGNN/external_validation/' 
        
    if ( args.MODEL_STATE == "Reproduce" ) & ( args.EXPERIMENT_TYPE == "external" ) & ( args.MODEL_TYPE == "IGNNE" ):     
        paramfile_path = '../experiments/models_parameters/Reproduce/IGNNE/external_validation/'

    # Saves model parameters.
    if ( ( args.MODEL_STATE == "Train" ) & (args.PARAM_STATE == "save") ) :            
        torch.save( model.state_dict(), paramfile_path + 'parameters_epoch_{:01d}.tar'.format(epoch) )   
        if (epoch == best_epoch) & (best_model != None):
            torch.save( best_model.state_dict(), paramfile_path + 'parameters_best.tar' )  
            
    # Loads model parameters.         
    elif ( ( args.MODEL_STATE == "Reproduce" )|( args.MODEL_STATE == "Result" ) ):   
        if best_model == "GET":
            print("the best model....")
            model.load_state_dict(torch.load(paramfile_path + 'parameters_best.tar' ) )    
            return
        model.load_state_dict(torch.load(paramfile_path + 'parameters_epoch_{:01d}.tar'.format(epoch) ) )                
    else : 
        None