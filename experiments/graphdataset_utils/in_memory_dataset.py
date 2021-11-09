import torch
from itertools import repeat, product
from graphdataset_utils.dataset import Dataset
from torch_geometric.data import Data

class InMemoryDataset(Dataset):
    """
    Dataset base class for creating graphdataset which fit completely into memory.

    Args:
        root(str): Root directory where the dataset should be saved.
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
            final dataset. Default: None.
    """

    @property
    def raw_file_names(self):
        """
        The name of the files to find in the :obj:`self.raw_dir` folder inorder to skip the download.
        """
        raise NotImplementedError

    @property
    def processed_file_names(self):
        """
        The name of the files to find in the :obj:`self.processed_dir` folder in order to skip the processing.
        """
        raise NotImplementedError

    def process(self):
        """
        Processes the dataset to the :obj:`self.processed_dir` folder.
        """
        raise NotImplementedError

    def __init__(self,
                 root,
                 transform=None,
                 pre_transform=None,
                 pre_filter=None):
        super(InMemoryDataset, self).__init__(root, transform, pre_transform,
                                              pre_filter)
        self.data, self.slices = None, None

    @property
    def num_classes(self):
        """
        The number of classes in the dataset.
        """
        data = self.data
        return data.y.max().item() + 1 if data.y.dim() == 1 else data.y.size(1)

    def __len__(self):
        return self.slices[list(self.slices.keys())[0]].size(0) - 1

    def __getitem__(self, idx):
        """
        Gets the data object at index :obj:`idx` and transforms it (in case a :obj:`self.transform` is given).
        Returns a data object, if :obj:`idx` is a scalar, and a new dataset in
        case :obj:`idx` is a slicing object, *e.g.*, :obj:`[2:5]`, a LongTensor
        or a ByteTensor.
        
        Args:
            idx(optional): index of data object.     
        """
        if isinstance(idx, int):
            data = self.get(idx)
            data = data if self.transform is None else self.transform(data)
            return data
        elif isinstance(idx, slice):
            return self._indexing(range(*idx.indices(len(self))))
        elif isinstance(idx, torch.LongTensor):
            return self._indexing(idx)
        elif isinstance(idx, torch.ByteTensor):
            return self._indexing(idx.nonzero())

        raise IndexError(
            'Only integers, slices (`:`) and long or byte tensors are valid '
            'indices (got {}).'.format(type(idx).__name__))

    def shuffle(self):
        """
        Randomly shuffles the examples in the dataset.
        """
        return self._indexing(torch.randperm(len(self)))

    def get(self, idx):
        data = Data()
        for key in self.data.keys:
            item, slices = self.data[key], self.slices[key]
            s = list(repeat(slice(None), item.dim()))
            s[self.data.__cat_dim__(key, item)] = slice(slices[idx],
                                                    slices[idx + 1])
            data[key] = item[s]
        return data

    def _indexing(self, index):
        copy = self.__class__.__new__(self.__class__)
        copy.__dict__ = self.__dict__.copy()
        copy.data, copy.slices = self.collate([self.get(i) for i in index])
        return copy

    def collate(self, data_list):
        """
        Collates a python list of data objects to the internal storage
        format of :class:`torch_geometric.data.InMemoryDataset`.
        
        Args:
            data_list(list): A python list of data objects.        
        """
        keys = data_list[0].keys
        data = Data()

        for key in keys:
            data[key] = []
        slices = {key: [0] for key in keys}

        for item, key in product(data_list, keys):
            data[key].append(item[key])
            s = slices[key][-1] + item[key].size(item.__cat_dim__(key, item[key]))
            slices[key].append(s)

        for key in keys:
            data[key] = torch.cat(
                data[key], dim=data_list[0].__cat_dim__(key, data_list[0][key]))
            slices[key] = torch.LongTensor(slices[key])

        return data, slices

