import torch
import warnings
from models.model_save_load import model_parameters
warnings.filterwarnings("ignore")


def weights_init(m): 
    """
    Initialize model parameters.
    
    Args:
        m(torch.nn.modules): Model layers.    
    """
    classname = m.__class__.__name__ # print(classname) 
    if classname.find('Linear') != -1:
        torch.nn.init.xavier_uniform_(m.weight.data,gain = 1) 
        torch.nn.init.constant_(m.bias.data, 0.0)
        

def train(device, dataset, model, optimizer, loader):
    """   
    Implements model training on the training data by minimizing the specified loss function.
    
    Args:
        device(torch.device): GPU or CPU.    
        dataset(Gdataset_utils.tu_dataset_qld.TUDataset): Data objects of graph structures from graphdataset.
        model(models.models): The model to be trained.           
        optimizer(torch.optim): The optimizer to perform training process.    
        loader(torch_geometric.data.dataloader.DataLoader): Data loader. 
        
    Returns:
        loss (float): The training loss.    
    """ 
    
    model.train()    
                     
    loss_all = 0
    
    # Load training data
    for data in loader:
        data = data.to(device)
                
        optimizer.zero_grad()
        
        # Forward pass
        output, output_features = model(data.x, data.x_ex, data.DFS, data.STATUS, data.edge_index, data.batch)
     
        # To minimize the negative log partial likelihood of Cox proportional hazards regression loss
        R_matrix_test = torch.zeros(data.y.shape[0], data.y.shape[0])
        ONES = torch.ones(1,data.DFS.shape[0]).to(device)
        R_matrix_test[((ONES*data.DFS).T - ONES*data.DFS) <= 0] = 1                        
        test_R = torch.FloatTensor(R_matrix_test).to(device)
        theta = output.reshape(-1).to(device)
        exp_theta = torch.exp(theta)
        neg_log_loss= -torch.mean( (theta- torch.log(torch.sum( exp_theta*test_R ,dim=1))) * data.STATUS) 
        
        # Backward and optimize
        neg_log_loss.backward()
        loss_all += neg_log_loss.item() * data.num_graphs
        optimizer.step()
        
        loss = loss_all / len(dataset)

    return loss

def test(device, dataset, model, loader):
    """   
    Calculate the model response on specific data.
    
    Args:
        device(torch.device): GPU or CPU.    
        dataset(Gdataset_utils.tu_dataset_qld.TUDataset): Data objects of graph structures from graphdataset.
        model(models.models): The model to be evaluated.             
        loader(torch_geometric.data.dataloader.DataLoader): Data loader. 
        
    Returns:
        loss(float): The validation loss.    
        output(torch.Tensor): The output values from prediction layer as prognostic scores. 
        data.y(torch.Tensor):  y set of patients. Note: y=0 indicates the patient with DFS > 5 years, 
                                                        y=1 indicates the patient with DFS <= 5 years.
        data.DFS(torch.Tensor): DFS set of patients. 
        data.STATUS(torch.Tensor): STATUS set of patients. 
        data.x_ex(torch.Tensor): clinical factor set of patients. 
        output_features(torch.Tensor): The set of node feature vectors output from the fully connected layer. 
    """ 
    
    model.eval()
    
    loss_all = 0
    
    # Load validation data
    for data in loader:
        data = data.to(device)
        
        # Forward pass
        output, output_features  = model(data.x, data.x_ex.float(), data.DFS, data.STATUS, data.edge_index, data.batch)       

        # To computer the negative log partial likelihood of Cox proportional hazards regression loss
        R_matrix_test = torch.zeros(data.y.shape[0], data.y.shape[0])
        ONES = torch.ones(1,data.DFS.shape[0]).to(device)
        R_matrix_test[((ONES*data.DFS).T - ONES*data.DFS) <= 0] = 1                        
        test_R = torch.FloatTensor(R_matrix_test).to(device)
        theta = output.reshape(-1).to(device)
        exp_theta = torch.exp(theta)
        neg_log_loss= -torch.mean( (theta- torch.log(torch.sum( exp_theta*test_R ,dim=1))) * data.STATUS)     
        
        loss_all += neg_log_loss.item() * data.num_graphs
        loss= loss_all / len(dataset)
    
    return loss, output, data.y, data.DFS, data.STATUS, data.x_ex, output_features        

class Astopper(object):
    """
    This class implements an adaptive stopping scheduler (Astopper) 
    to automatically select a suitable epoch for interrupting training process.
    """
    def __init__(self, args):
        # args = args
        self.train_loss_init = -1
        self.train_loss_min = 1000
        self.train_loss_min2 = 1000
        self.wd_default = True
        self.best_model = None
        self.best_epoch = None

    def stopping(self, args, model, epoch, optimizer, train_loss):
        """   
        Selecta a suitable epoch to interrupt training process.
        
        Args:
            args(argparse.Namespace): all arguments for models and experiments.
            model(models.models): The model to be trained.  
            epoch(int): Current training iteration number.              
            optimizer(torch.optim): The optimizer to perform training process.  
            train_loss(float): The training loss at current epoch.     
        """         
                
        if train_loss < self.train_loss_min:
            self.train_loss_min = train_loss
            
        if epoch == 1:
            self.train_loss_init = train_loss  

        # Checks the decay of training loss for the first time at checkpoint1 
        # and decides whether to update the learning rate and weight_decay of optimizer.    
        if epoch == args.checkpoint1:
            if self.train_loss_min/self.train_loss_init > args.loss_decratio1:
                self.wd_default = False
                for param_group in optimizer.param_groups:
                    param_group['lr'] = args.lr1  
                    param_group['weight_decay'] = args.wd_rate1 * param_group['weight_decay']
                    print("wd and lr are changed at checkpoint1",self.train_loss_min/self.train_loss_init)

        # Checks the decay of training loss for the second time at checkpoint2 
        # and decides whether to update the learning rate and weight_decay of optimizer.                         
        if epoch == args.checkpoint2:                       
            if ( train_loss/self.train_loss_init >= args.loss_decratio2 )  & ( self.wd_default  == True ):  
                for param_group in optimizer.param_groups: 
                    param_group['lr'] = args.lr2_1    
                    param_group['weight_decay'] = args.wd_rate2_1 * param_group['weight_decay']
                self.wd_default = False
                print("wd and lr are changed at checkpoint2_1",train_loss/self.train_loss_init)
                
            if ( train_loss/self.train_loss_init < args.loss_decratio2 )  & ( self.wd_default == True ):     
                for param_group in optimizer.param_groups: 
                    param_group['lr'] = args.lr2_2     
                    param_group['weight_decay'] = args.wd_rate2_2 * param_group['weight_decay']
                self.wd_default = False
                print("wd and lr are changed at checkpoint2_2",train_loss/self.train_loss_init)                                

        # Starting from checkpoint 3, checks the training loss 
        # and decide the epoch to interrupt training process with the minist training loss.                  
        if epoch == args.checkpoint3:   
            self.train_loss_min2 = train_loss
        if ( train_loss <= self.train_loss_min2  ) & ( epoch >= args.checkpoint3 ):
            self.train_loss_min2  = train_loss 
            self.best_model = model
            self.best_epoch = epoch
            print("the well-trained model in epoch",self.best_epoch)  
        
        # Saves all parameters of the well-trained model
        model_parameters(args, model, epoch, self.best_model, self.best_epoch)   
            
    

