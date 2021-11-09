import torch
from graphdataset_utils.in_memory_dataset import InMemoryDataset
from graphdataset_utils.graphs import read_graph_data

class GraphDataset(InMemoryDataset):
    """
    A graph kernel benchmark dataset.

    Args:
        root(str): Root directory where the dataset should be saved.
        name(str): The name of the dataset.
        transform(callable, optional): A function/transform that takes in an
            :obj:`torch_geometric.data.Data` object and returns a transformed
            version. The data object will be transformed before every access. Default: None.
        pre_transform(callable, optional): A function/transform that takes in
            an :obj:`torch_geometric.data.Data` object and returns a
            transformed version. The data object will be transformed before
            being saved to disk. Default: None.
        pre_filter(callable, optional): A function that takes in an
            :obj:`torch_geometric.data.Data` object and returns a boolean
            value, indicating whether the data object should be included in the
            final dataset.  Default: None.
        use_node_attr(bool, optional): If :obj:`True`, the dataset will
            contain additional continuous node features (if present). Default: False.
    """

    def __init__(self,
                 root,
                 name,
                 transform=None,
                 pre_transform=None,
                 pre_filter=None,
                 use_node_attr=False):
        self.name = name
        super(GraphDataset, self).__init__(root, transform, pre_transform,
                                        pre_filter)
        self.data, self.slices = torch.load(self.processed_paths[0])
        print("processed_paths....",self.processed_paths[0])
        if self.data.x is not None and not use_node_attr:
            self.data.x = self.data.x[:, 0:8]
            

        
    @property
    def num_node_labels(self):       
        if self.data.x is None:
            return 0
        for i in range(self.data.x.size(1)):
            if self.data.x[:, i:].sum().item() == self.data.x.size(0):
                return self.data.x.size(1) - i

        return 0

    @property
    def num_node_attributes(self):
        if self.data.x is None:
            return 0
        return self.data.x.size(1) - self.num_node_labels

    @property
    def raw_file_names(self):
        names = ['A', 'graph_indicator']
        return ['{}_{}.txt'.format(self.name, name) for name in names]

    @property
    def processed_file_names(self):
        return 'data.pt'
    

    def process(self):
        """
        Transform and store information read from raw data into specialized data objects.
        """
        # Load the described graphdataset from a series of related file sets.
        self.data, self.slices = read_graph_data(self.raw_dir, self.name)

        if self.pre_filter is not None:
            data_list = [self.get(idx) for idx in range(len(self))]
            data_list = [data for data in data_list if self.pre_filter(data)]
            self.data, self.slices = self.collate(data_list)

        if self.pre_transform is not None:
            data_list = [self.get(idx) for idx in range(len(self))]
            data_list = [self.pre_transform(data) for data in data_list]
            self.data, self.slices = self.collate(data_list)
                 
        torch.save((self.data, self.slices), self.processed_paths[0])

    def __repr__(self):
        return '{}({})'.format(self.name, len(self))
