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
```
torch_cluster-1.5.8-cp38-cp38-win_amd64.whl
torch_scatter-2.0.5-cp38-cp38-win_amd64.whl
torch_sparse-0.6.8-cp38-cp38-win_amd64.whl
torch_spline_conv-1.2.0-cp38-cp38-win_amd64.whl
```  
and install them within the activated virtual environment(IGNN):  
```  
pip install./torch_scatter-2.0.5-cp38-cp38-win_amd64.whl
pip install./torch_sparse-0.6.8-cp38-cp38-win_amd64.whl
pip install./ torch_cluster-1.5.8-cp38-cp38-win_amd64.whl
pip install./ torch_spline_conv-1.2.0-cp38-cp38-win_amd64.whl
```
*	R software >= 3.6.0
*	RStudio >=1.4.0  
R is a free software environment for statistical computing and graphics. It compiles and runs on a wide variety of UNIX platforms, Windows and MacOS. Download and install the R software (verson 3.6.0) for windows OS from https://cloud.r-project.org/bin/windows/base/old/3.6.0/R-3.6.0-win.exe.    

We strongly recommend installing Rstudio after installing R, which is an integrated development environment (IDE) for R, including console, workspace management and tools for drawing and debugging, and is convenient for users to direct execution and debug R code. Download and install the free Rstudio Desktop (verson 2021.09.0-351) for windows OS from https://download1.rstudio.org/desktop/windows/RStudio-2021.09.0-351.exe. Run Rstudio and click "Tools" -> "Global Options" -> "General" -> "Change" (Basic panel) in turn to select a specific version of R software (verson 3.6.0).  
# Raw Data
The raw data includes TACS coding observed from MPM imaging, clinical and follow-up information of 995 patients from Fujian Medical University Union Hospital (FMU) and Harbin Medical University Cancer Hospital (HMU). By default, these data are saved as xlsx format files in the `./experiments/Patients_Information/DataSets_995/` directory, where the data of patients with DFS less than 5 years are placed in `./experiments/Patients_Information/DataSets_995/class_1/` (in which, from FMU (1).xlsx to FMU (261).xlsx for FMU patients and from HMU (1).xlsx to HMU (96).xlsx for HMU patients ) while the data of patients with DFS greater than 5 years are placed in `./experiments/ Patients_Information DataSets_995/class_2/` (in which, from FMU (1)xlsx to FMU (470).xlsx for FMU patients and from HMU (1).xlsx to HMU (168).xlsx for HMU patients).
# Source code
The source code related to the training and evaluation of the IGNN and IGNNE models is deposited in the ./experiments directory, and the source code provides the following content and methods:  
*	The framework to construct graph structures and generate specialized graph dataset from TACS coding, clinical and follow-up information of patients.
*	Attention-based graph convolutional layer with optional GPU units (GNNGruConv), and the IGNN (IGNNE) prognostic model based on GNNGruConv.
*	The methods for adaptive training and validation of IGNN (IGNNE) model on raw data or user's own data.
*	Reproduction of experimental results and data analysis demonstrated in the paper.    
The main components of the source code as following:  
`main.py`. Procedures for training, evaluation and reproducibility of IGNN (IGNNE) model on raw data in the pre-validation or external validation experiments shown in paper.







