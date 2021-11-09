# Intratumor graph neural network recovers hidden prognostic value of multi-biomarker spatial heterogeneity
IGNN (IGNNE) is a graph neural network-based interpretable machine learning model for recovering hidden prognostic value from the recently reported tumor-associated collagen signatures (TACS1-8) observed in MPM imaging. For more details, see the acompanying paper.
# Hardware requirements  
* Computer with windows 7 or windows 10 OS  
* NVIDIA GPU card with Windows x86_64 Driver Version >=418.96
# Dependency and installation 
* CUDA >= 10.1.105 
* CUDNN >=7.6.0  
Download the NVIDIA CUDA Toolkit from https://developer.nvidia.com/cuda-toolkit-archive and install CUDA for windows OS with the installation Guide https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#installcuda-windows, then download and install the NVIDIA cuDNN corresponding to CUDA from https://developer.nvidia.com/rdp/cudnn-archive#a-collapse742-10 with the installation Guide https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#installwindows.
* Anaconda3  
Download the Anaconda3 with python 3.8 version (data science toolkit to perform Python/R data science and machine learnin) from https://repo.anaconda.com/archive/Anaconda3-2020.07-Windows-x86_64.exe and install it for windows OS with the installation Guide https://docs.continuum.io/anaconda/install/windows/
*	Python = 3.8.3
*	Lifelines = 0.26.0,  natsort = 7.1.1,  openpyxl = 3.0.9,  bitarray = 2.3.4,  dec2bin = 1.0.4
*	PyTorch = 1.6.0,  torchvision = 0.7.0
*	Torch-geometric = 1.6.1,  Torch-cluster = 1.5.8,  Torch-scatter = 2.0.5,  Torch-sparse = 0.6.8,  Torch-spline-conv = 1.2.0   

Create and activate a virtual environment for project using Anaconda Prompt within Anaconda3:
 ```
conda create -n IGNN python=3.8.3  
conda activate IGNN
```
Install the required packages within the activated virtual environment (IGNN):
```
pip install lifelines
pip install natsort
pip install openpyxl
pip install bitarray
pip install dec2bin
```
Install the Pytorch and PyTorch-Geometric (A library built upon PyTorch to develop Graph Neural Networks https://pytorch-geometric.readthedocs.io/en/latest/notes/installation.html#quick-start) within the activated virtual environment   

(IGNN):
```  
conda install pytorch==1.6.0 torchvision==0.7.0 torchaudio cudatoolkit=${CUDATOOLKIT} -c pytorch
pip install torch-geometric==1.6.1
```
where ${CUDATOOLKIT} should be replaced by the specific CUDA version (10.1, 10.2).
Download the relevant packages of PyTorch-Geometric according to your specific CUDA and Pytorch version from https://data.pyg.org/whl/, take CUDA = 10.2 and Pytorch = 1.6.0 as example, download the following packages from https://data.pyg.org/whl/torch-1.6.0%2Bcu102.html :

