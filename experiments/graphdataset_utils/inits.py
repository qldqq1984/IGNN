import math


def uniform(size, tensor):
    """
    Fills tensor with numbers sampled from a uniform distribution.
    """
    stdv = 1.0 / math.sqrt(size)
    if tensor is not None:
        tensor.data.uniform_(-stdv, stdv)


def glorot(tensor):
    """
    Fills tensor with numbers sampled from a normal distribution.
    """    
    stdv = math.sqrt(2.0 / (tensor.size(0) + tensor.size(1)))
    if tensor is not None:
        tensor.data.uniform_(-stdv, stdv)

        
def zeros(tensor):
    if tensor is not None:
        tensor.data.fill_(0)


def ones(tensor):
    if tensor is not None:
        tensor.data.fill_(1)


# def reset(nn):
#     def _reset(item):
#         if hasattr(item, 'reset_parameters'):
#             item.reset_parameters()

#     if nn is not None:
#         if hasattr(nn, 'children') and len(list(nn.children())) > 0:
#             for item in nn.children():
#                 _reset(item)
#         else:
#             _reset(nn)
