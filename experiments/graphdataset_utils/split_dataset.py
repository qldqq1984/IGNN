

def split_dataset(args, dataset):
    """   
    Split data from graphdataset for model training and validation.
    
    Args:
        args(argparse.Namespace): all arguments for models and experiments.      
        dataset(Gdataset_utils.tu_dataset_qld.TUDataset): The graphdataset of patients. Default: "TACS_G".
        
    Returns:
        train_dataset(torch.utils.data.dataset.ConcatDataset): Training data splited from the graphdataset.
        test_dataset(torch.utils.data.dataset.ConcatDataset): Validation data splited from the graphdataset.       
    """  
    
    # external-validation experiments    
    if (args.EXPERIMENT_TYPE == "external"):
        FMU_dataset = dataset[args.f1_FMU : args.l1_FMU ] + dataset[args.f2_FMU : args.l2_FMU]          
        HMU_dataset = dataset[args.f1_HMU : args.l1_HMU ] + dataset[args.f2_HMU : args.l2_HMU]
        train_dataset = FMU_dataset
        test_dataset = HMU_dataset
        return train_dataset, test_dataset

    # pre-validation experiments with 3-cross validation
    if (args.EXPERIMENT_TYPE == "pre"):
        
        #fold1
        if (args.FOLD_N == '1'):
            fold1_train_dataset = dataset[87:261]  + dataset[577:664] + dataset[680:767]    
            fold1_test_dataset = dataset[0:87] + dataset[357:513]
            train_dataset = fold1_train_dataset
            test_dataset = fold1_test_dataset
            return train_dataset, test_dataset
        
        #fold2    
        elif (args.FOLD_N == '2'):
            fold2_train_dataset = dataset[0:87] + dataset[174:261] + dataset[357:513]  + dataset[798:816]   
            fold2_test_dataset = dataset[87:174] + dataset[513:670]
            train_dataset = fold2_train_dataset
            test_dataset = fold2_test_dataset    
            return train_dataset, test_dataset
        
        #fold3
        elif (args.FOLD_N == '3'):
            fold3_train_dataset = dataset[0:174] + dataset[357:531]   
            fold3_test_dataset = dataset[174:261] + dataset[670:827]
            train_dataset = fold3_train_dataset
            test_dataset = fold3_test_dataset    
            return train_dataset, test_dataset        
       
    # user-defined experiments     
    if (args.EXPERIMENT_TYPE == "user"):
        train_dataset = dataset[args.f1_train : args.l1_train ] + dataset[args.f2_train : args.l2_train]          
        test_dataset = dataset[args.f1_test : args.l1_test ] + dataset[args.f2_test : args.l2_test]
        return train_dataset, test_dataset