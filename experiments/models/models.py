import torch
import torch.nn.functional as F
import warnings
from torch.nn import Linear
from torch_geometric.nn import global_mean_pool
from models.GNNGruConv import GNNGruConv
warnings.filterwarnings("ignore")


def standardized_x_ex(device, loader):
    """
    Calculate the mean and standard deviation valure for each clinical factor on the specified dataset.
    
    Args:
        device(torch.device): GPU or CPU.
        loader(torch_geometric.data.dataloader.DataLoader): Data loader which merges data objects from a graphdataset to a mini-batch.
        
    Returns:
        x_ex_mean(float): The mean value.
        x_ex_std(float): The standard deviation value.        
    """  
    
    for data in loader:
        data = data.to(device)
        x_ex_mean = torch.mean(data.x_ex,0)
        x_ex_std = torch.std(data.x_ex,0)

    return x_ex_mean.float(), x_ex_std.float()



class IGNN(torch.nn.Module):
    """
    This class Constructs a IGNN prognostic model.
    
    Args:
        DEVICE_GPU(bool): GPU or CPU.
        args(argparse.Namespace): all arguments for models and experiments.
        dataset(Gdataset_utils.tu_dataset_qld.TUDataset): Data objects of graph structures from graphdataset.
        dataset.num_features(int): Initial node feature dimension. Default: 8, the dimension of TACS coding.
    """ 
    
    def __init__(self, DEVICE_GPU, args, dataset):
        super(IGNN, self).__init__()
        
        self.lin1 = torch.nn.Linear(dataset.num_features, 8, bias=True)
        self.gnn_layer1 = GNNGruConv(DEVICE_GPU, args.GRU_STATE,requires_grad=True)
        self.gnn_layer2 = GNNGruConv(DEVICE_GPU, args.GRU_STATE,requires_grad=True)
        self.lin2 = Linear(8, 8, bias=True)                
        self.fc1 = Linear(8, 32, bias=True)
        self.fc2 = Linear(8, 32, bias=True)
        self.fc3= Linear(32, 1, bias=True)
        
        
    def forward(self, x, x_ex, DFS, STATUS, edge_index, batch):
        """
        implements the construction of IGNN model.
        
        Args:
            x(torch.Tensor): TACS coding from corresponding graph structures.
            x_ex(torch.Tensor): Clinical factors from corresponding graph structures.
            DFS(torch.Tensor): DFS set of patients represented by the corresponding graph structures.
            STATUS(torch.Tensor): STATUS set of patients represented by the corresponding graph structures.
            edge_index(torch.Tensor): The set of corresponding edge indexs within graph structures.
            batch(torch.Tensor): The set of corresponding node indexs within graph structures.
            
        Returns:
            x_out(torch.Tensor): The output value as prognostic score for each patient.
            x_features(torch.Tensor): The set of node feature vectors output from the fully connected layer.   
        """
       
        # Constructing the neural network           
        x1 = F.selu(self.lin1(x)) 
        
        F.dropout(x1, p=0.1,training=self.training)   
        x2 = self.gnn_layer1(x1, edge_index)
        x2 = F.selu(self.lin2(x2)) 

        x3 = F.dropout(x2, p=0.1,training=self.training)         
        x4 = self.gnn_layer2(x3, edge_index)   
        x4 = F.selu(self.lin2(x4)) 
        
        x5 = global_mean_pool(x4, batch)   
        x7 = F.normalize(x5, p=2, dim=-1)
        x_features = F.selu(self.fc2(x7))
        x_out  =  self.fc3(x_features) 
        
        return x_out, x_features


    
class IGNNE(torch.nn.Module):
    """
    This class Constructs a IGNNE prognostic model.
    
    Args:
        DEVICE_GPU(bool): GPU or CPU.
        args(argparse.Namespace): all arguments for models and experiments.
        dataset(Gdataset_utils.tu_dataset_qld.TUDataset): Data objects of graph structures from graphdataset.
        dataset.num_features(int): Initial node feature dimension. Default: 8, the dimension of TACS coding.
        x_ex_mean(torch.Tensor): The mean value of each clinical factor calculated on the training cohort.
        x_ex_std(torch.Tensor): The standard deviation value of each clinical factor calculated on the training cohort.
    """ 
    
    def __init__(self, DEVICE_GPU, args, dataset, x_ex_mean, x_ex_std):
        super(IGNNE, self).__init__()
    
        self.x_ex_mean = x_ex_mean
        self.x_ex_std = x_ex_std
        
        self.lin1 = torch.nn.Linear(dataset.num_features, 8)
        self.gnn_layer1 = GNNGruConv(DEVICE_GPU, args.GRU_STATE,requires_grad=True)
        self.gnn_layer2 = GNNGruConv(DEVICE_GPU, args.GRU_STATE,requires_grad=True)
        self.lin2 = Linear(8, 8)
        
        self.embeddings = Linear(8, 16)
        self.fc_embed = Linear(16, 16)
        
        self.fc1 = Linear(16, 32)
        self.fc2 = Linear(8, 16)
        self.fc3= Linear(32, 1)
        
        self.fc_all = Linear(32, 32)
        
    def forward(self, x, x_ex, DFS, STATUS,edge_index, batch):
        """
        implements the construction of IGNNE model.
        
        Args:
            x(torch.Tensor): TACS coding from corresponding graph structures.
            x_ex(torch.Tensor): Clinical factors from corresponding graph structures.
            DFS(torch.Tensor): DFS set of patients represented by the corresponding graph structures.
            STATUS(torch.Tensor): STATUS set of patients represented by the corresponding graph structures.
            edge_index(torch.Tensor): The set of corresponding edge indexs within graph structures.
            batch(torch.Tensor): The set of corresponding node indexs within graph structures.
            
        Returns:
            x_out(torch.Tensor): The output value as prognostic score for each patient.
            x_features(torch.Tensor): The set of node feature vectors output from the fully connected layer.   
        """
        
        # normalize the clinical factors as input of MLP with mean and standard deviation.
        x_ex = (x_ex - self.x_ex_mean)
        x_ex = x_ex.div(self.x_ex_std)
        
        # Constructing the MLP   
        # x_ex[:,[0,1,2,3,4,5,6,8] = (molecular_type, tumor_size, Lymphnode_metastasis, clinical_stage, histological_grade, age, chemotherapy, radiation) 
        x_embeds = self.embeddings(x_ex[:,[0,1,2,3,4,5,6,8]])
        x_embeds = x_embeds.view(x_embeds.size(0), -1)
        x_embeds = F.selu(x_embeds)
        x_embeds = F.normalize(x_embeds, p=2, dim=-1)

        # Constructing the neural network        
        x1 = F.selu(self.lin1(x)) 
        
        x2 = F.dropout(x1, p=0.1,training=self.training)   
        x2 = self.gnn_layer1(x1, edge_index)
        x2 = F.selu(self.lin2(x2)) 

        x3 = F.dropout(x2, p=0.1,training=self.training)         
        x4 = self.gnn_layer2(x3, edge_index)   
        x4 = F.selu(self.lin2(x4)) 
         
        x5 = global_mean_pool(x4, batch)   
        x_features = F.selu(self.fc2(x5))

     
        x_all = torch.cat((x_features, x_embeds),1)
        x_all = F.normalize(x_all, p=2, dim=-1)
        x_all  = F.selu(self.fc_all(x_all))
        
        x_out  = self.fc3(x_all)
        return x_out, x_features


    
def model(DEVICE_GPU, args, dataset, x_ex_mean, x_ex_std):
    """
    Model selection and initialization based on pre-configuration.  
    
    Args:
        DEVICE_GPU(bool): GPU or CPU.
        args(argparse.Namespace): all arguments for models and experiments.
        dataset(Gdataset_utils.tu_dataset_qld.TUDataset): Data objects of graph structures from graphdataset.  
        x_ex_mean(torch.Tensor): The mean value of each clinical factor calculated on the training cohort.
        x_ex_std(torch.Tensor): The standard deviation value of each clinical factor calculated on the training cohort. 
            
    Returns:
        model(models.models): The selected model instance.        
    """ 
    
    if(args.MODEL_TYPE == "IGNN"): 
        return IGNN(DEVICE_GPU, args, dataset)
      
    if(args.MODEL_TYPE == "IGNNE"): 
        return IGNNE(DEVICE_GPU, args, dataset, x_ex_mean, x_ex_std) 
    


def model_optimizer(model, args):
    """
    Optimizer selection and initialization based on pre-configuration.  
    
    Args:
        model(models.models): The selected model instance.
        args(argparse.Namespace): all arguments for models and experiments.
            
    Returns:
        optimizer(torch.optim): The selected optimizer instance.        
    """  
    
    params_list = []        
    for (pname, p) in model.named_parameters():
        if any([pname.endswith(k) for k in ['weight']]):
            name =  pname.rstrip(".weight")
            param = "dict(params=model.{:s}.parameters(), weight_decay=args.weight_decay_init['wd_{:s}'])".format(name, name)
            params_list +=[ eval(param)]
        
    if(args.EXPERIMENT_TYPE == "pre"): 
      optimizer = torch.optim.Adam(params_list, lr=args.lr_init)

    if(args.EXPERIMENT_TYPE == "external"): 
      optimizer = torch.optim.Adamax(params_list, lr=args.lr_init)
      
    if(args.EXPERIMENT_TYPE == "user"): 
      optimizer = torch.optim.Adamax(params_list, lr=args.lr_init)      
    
    return optimizer

        
        
        
        
        
        
        
        
        
        
        
        
        
        