import torch
import torch.nn.functional as F
from torch.nn import GRUCell
from torch_geometric.typing import Adj, OptTensor
from torch import Tensor
from torch_sparse import SparseTensor, set_diag, spmm
from torch_geometric.nn.conv import MessagePassing
from torch_geometric.utils import remove_self_loops, add_self_loops, softmax
from typing import Optional
  
class GNNGruConv(MessagePassing):
    """
    Graph convolution network module with attention layer 
    and optional Gated Recurrent Units (GRU). 
    
    within the attention layer,
    .. math::
        \mathbf{X}^{\prime} = \mathbf{P} \mathbf{X},
    where the propagation matrix :math:`\mathbf{P}` is computed as
    .. math::
        P_{i,j} = \frac{\exp( \beta \cdot \cos(\mathbf{x}_i, \mathbf{x}_j))}
        {\sum_{k \in \mathcal{N}(i)\cup \{ i \}} \exp( \beta \cdot
        \cos(\mathbf{x}_i, \mathbf{x}_k))}
    with trainable parameter :math:`\beta`.
    
    Args:
        DEVICE_GPU(bool): GPU or CPU.
        GRU_STATE(bool): If `True`, the optional GRU blocks are available.
                         Otherwise, the optional GRU blocks are unavailable.        
        requires_grad(bool, optional): If `False`, :math:`\beta` will not be trainable. 
                                       Default: True.
        add_self_loops(bool, optional): If `False`, will not add self-loops to the input graph. 
                                        Default: True.
        **kwargs(optional): Additional arguments of :class:`torch_geometric.nn.conv.MessagePassing`.
    """
    
    def __init__(self, DEVICE_GPU = False,  GRU_STATE = True,  requires_grad: bool = True, add_self_loops: bool = True,  **kwargs):
        super(GNNGruConv, self).__init__(aggr='add', **kwargs)
                
        self.weight = torch.nn.Parameter(torch.Tensor(8, 8))
        self.GRU = GRU_STATE
        self.GPU = DEVICE_GPU
        
        if self.GRU == True:
            self.RNN = GRUCell(8,8)
            
        self.requires_grad = requires_grad
        self.add_self_loops = add_self_loops

        if requires_grad:
            self.beta = torch.nn.Parameter(torch.Tensor(1))
        else:
            self.register_buffer('beta', torch.ones(1))

        self.reset_parameters()
        
    def reset_parameters(self):
        if self.requires_grad:
            self.beta.data.fill_(1)
            # glorot(self.weight)


    def forward(self, x: Tensor, edge_index: Adj) -> Tensor:
        
        if self.GRU == True:
            if isinstance(edge_index, Tensor):
                edge_index, _ = remove_self_loops(edge_index)                
            
            row, col = edge_index   
            
            x = torch.mm(x, self.weight)
            x = F.selu(x)            
            x = x.unsqueeze(-1) if x.dim() == 1 else x
            x = F.normalize(x, p=2, dim=-1)

            edge_weight =  (x[row] * x[col]).sum(dim=-1)
            edge_weight = softmax(edge_weight, row, num_nodes=x.size(0))        

            attention_out = spmm(edge_index, edge_weight, x.size(0), x.size(0),x)
      
            gru_input = attention_out.unsqueeze(1)
            gru_H_t_1 = x.unsqueeze(1)            
            
            if self.GPU == True:
                out = torch.zeros(x.size()).cuda()    
            else:     
                out = torch.zeros(x.size()).cpu() 
                
            for i in range(x.size(0)):
                out[i] = self.RNN(gru_input[i], gru_H_t_1[i])
            return out
            
        if self.add_self_loops:
            if isinstance(edge_index, Tensor):
                edge_index, _ = remove_self_loops(edge_index)
                edge_index, _ = add_self_loops(edge_index, num_nodes=x.size(self.node_dim))
                
            elif isinstance(edge_index, SparseTensor):
                edge_index = set_diag(edge_index)

        x_norm = F.normalize(x, p=2., dim=-1)

        # propagate_type: (x: Tensor, x_norm: Tensor)
        return self.propagate(edge_index, x=x, x_norm=x_norm, size=None)
    
    
    def message(self, x_j: Tensor, x_norm_i: Tensor, x_norm_j: Tensor,
                index: Tensor, ptr: OptTensor,
                size_i: Optional[int]) -> Tensor:
        alpha = self.beta * (x_norm_i * x_norm_j).sum(dim=-1)
        alpha = softmax(alpha, index, ptr, size_i)
        return x_j * alpha.view(-1, 1)

    def __repr__(self):
        return '{}()'.format(self.__class__.__name__)


