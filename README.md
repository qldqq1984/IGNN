# Intratumor graph neural network recovers hidden prognostic value of multi-biomarker spatial heterogeneity
IGNN (IGNNE) is a graph neural network-based interpretable machine learning model for recovering hidden prognostic value from the recently reported tumor-associated collagen signatures (TACS1-8) observed in MPM imaging. For more details, see the acompanying paper.
# Hardware requirements  
* Computer with windows 7 or windows 10 OS  
* NVIDIA GPU card with Windows x86_64 Driver Version >= 418.96
# Dependency and installation 
* CUDA >= 10.1.105 
* CUDNN >= 7.6.0  
Download the NVIDIA CUDA Toolkit from https://developer.nvidia.com/cuda-toolkit-archive and install CUDA for windows OS with the installation Guide https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#installcuda-windows, then download and install the NVIDIA cuDNN corresponding to CUDA from https://developer.nvidia.com/rdp/cudnn-archive#a-collapse742-10 with the installation Guide https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#installwindows.
* Anaconda3  
Download the Anaconda3 with python 3.8 version (data science toolkit to perform Python/R data science and machine learning) from https://repo.anaconda.com/archive/Anaconda3-2020.07-Windows-x86_64.exe and install it for windows OS with the installation Guide https://docs.continuum.io/anaconda/install/windows/
*	Python = 3.8.3
*	lifelines = 0.26.0,  natsort = 7.1.1,  openpyxl = 3.0.9,  bitarray = 2.3.4,  dec2bin = 1.0.4,  toml = 0.10.2
*	PyTorch = 1.6.0,  torchvision = 0.7.0
*	Torch-geometric = 1.6.1, 
*	Torch-cluster = 1.5.8,  Torch-scatter = 2.0.5,  Torch-sparse = 0.6.8,  Torch-spline-conv = 1.2.0   

Create and activate a virtual environment for project using Anaconda Prompt within Anaconda3:
 ```bash
conda create -n IGNN python=3.8.3  
conda activate IGNN
```
Install the required packages within the activated virtual environment (IGNN):
```bash
pip install lifelines
pip install natsort
pip install openpyxl
pip install bitarray
pip install dec2bin
pip indtsll toml
```
Install the Pytorch and PyTorch-Geometric (A library built upon PyTorch to develop Graph Neural Networks https://pytorch-geometric.readthedocs.io/en/latest/notes/installation.html#quick-start) within the activated virtual environment (IGNN):
```bash 
conda install pytorch==1.6.0 torchvision==0.7.0 torchaudio cudatoolkit=${CUDATOOLKIT} -c pytorch
pip install torch-geometric==1.6.1
```
Where ${CUDATOOLKIT} should be replaced by the specific CUDA version (10.1, 10.2).   
Download the relevant packages of PyTorch-Geometric according to your specific CUDA and Pytorch version from https://data.pyg.org/whl/, take the version of CUDA = 10.2 and Pytorch = 1.6.0 as example, download the following packages from https://data.pyg.org/whl/torch-1.6.0%2Bcu102.html :
```bash
torch_cluster-1.5.8-cp38-cp38-win_amd64.whl
torch_scatter-2.0.5-cp38-cp38-win_amd64.whl
torch_sparse-0.6.8-cp38-cp38-win_amd64.whl
torch_spline_conv-1.2.0-cp38-cp38-win_amd64.whl
```  
and install them within the activated virtual environment (IGNN):  
```bash  
pip install ./torch_scatter-2.0.5-cp38-cp38-win_amd64.whl
pip install ./torch_sparse-0.6.8-cp38-cp38-win_amd64.whl
pip install ./torch_cluster-1.5.8-cp38-cp38-win_amd64.whl
pip install ./torch_spline_conv-1.2.0-cp38-cp38-win_amd64.whl
```
*	R software >= 3.6.0
*	RStudio >= 1.4.0     

R is a free software environment for statistical computing and graphics. It compiles and runs on a wide variety of Linux platforms, Windows and MacOS. Download and install the R software (verson 3.6.0) for windows OS from https://cloud.r-project.org/bin/windows/base/old/3.6.0/R-3.6.0-win.exe.    

We strongly recommend installing Rstudio after installing R, which is an integrated development environment (IDE) for R, including console, workspace management and tools for drawing and debugging, and is convenient for users to directly execute and debug R code. Download and install the free Rstudio Desktop (verson 2021.09.0-351) for windows OS from https://download1.rstudio.org/desktop/windows/RStudio-2021.09.0-351.exe. Run Rstudio and click "Tools" -> "Global Options" -> "General" -> "Change" (Basic panel) in turn to select a specific version of R software (verson 3.6.0).  
# Raw Data
The raw data includes TACS coding observed from MPM imaging, clinical and follow-up information of 995 patients from Fujian Medical University Union Hospital(FMU) and Harbin Medical University Cancer Hospital(HMU). By default, these data are saved as xlsx format files in the `./experiments/Patients_Information/DataSets_995/` directory, where the data of patients with DFS less than 5 years are placed in `./experiments/Patients_Information/DataSets_995/class_1/`(in which, from FMU(1).xlsx to FMU(261).xlsx for FMU patients and from HMU(1).xlsx to HMU(96).xlsx for HMU patients) while the data of patients with DFS greater than 5 years are placed in
`./experiments/ Patients_Information DataSets_995/class_2/` (in which, from FMU(1) .xlsx to FMU(470).xlsx for FMU patients and from HMU(1).xlsx to HMU(168).xlsx for HMU patients). <br>
***Note:*** To simplify the input, some clinical and follow-up information were assigned with a value in the *.xlsx files: <br>
* ***y*** : **0**, DFS(disease-free survival) > 5 years; **1**, DFS ≤ 5 years.
*	***Type*** (Molecular subtype): **1**, Luminal A; **2**, Luminal B; **3**, HER2 enriched; **4**, Triple Negative.
*	***Size*** (Tumor size): **1**, ≤ 2cm; **2**, 2-5cm; **3**, > 2cm.
*	***Lym*** (Lymph node metastasis): **1**, 0; **2**, 1-3; **3**, ≥ 4.
*	***Stage*** (Clinical stage): **1**, Ⅰ; **2**, Ⅱ; **3**, Ⅲ.
*	***Grade*** (Histological grade): **1**, G1; **2**, G2; **3**, G3.
*	***Chemotherapy***: **0**, No; **1**, Yes.
*	***Endocrine***: **0**, No; **1**, Yes.
*	***Radiation***: **0**, No; **1**, Yes.
*	***Targeted***: **0**, No; **1**, Yes.
*	***ER***: **0**, negative; **1**, positive.
*	***PR***: **0**, negative; **1**, positive.
*	***HER2***: **0**, negative; **1**, positive.



# Source code
The source code related to the training and evaluation of the IGNN and IGNNE models is deposited in the `./experiments` directory, and the source code provides the following content and methods:  
*	The framework to construct graph structures and generate specialized graph dataset from TACS coding, clinical and follow-up information of patients.
*	Attention-based graph convolutional layer with optional GPU units (GNNGruConv), and the IGNN (IGNNE) prognostic model based on GNNGruConv.
*	The methods for adaptive training and validation of IGNN(IGNNE) model on raw data or user-defined own data.
*	Reproduction of experimental results and data analysis demonstrated in the paper.    

The main components of the source code as following:  
  * `main.py`. <br>
    Procedures for training, evaluation and reproducibility of IGNN(IGNNE) model on raw data in the pre-validation or external validation experiments.  

  *  `main_user.py`. <br>
    Template program for the IGNN(IGNNE) model to be trained and verified on the user-defined data.    

  *  `./experiments/Patients_Informatio/DataSets_995/`. <br>
    The raw data including TACS coding observed from MPM imaging, clinical and follow-up information of 995 patients from Fujian Medical University Union Hospital(FMU) and Harbin Medical University Cancer Hospital(HMU).  

  *  `./experiments/Patients_Information/DataSets_demo/`. <br>
    The user-defined data of patients.

  *  `./experiments/graphdataset_utils/`. <br>
    The directory includes main functional modules for constructing graph structures and generating graphdataset.  

  *  `./experiments/Graphdatasets/`. <br>
    This directory saves the specific graphdatasets generated from the raw data (TACS_G) and the user-defined data (User_G).  

  *  `./experiments/models/`. <br>
    The directory includes the architecture of GNNGruConv and IGNN(IGNNE) models with the functional modules for model adaptive training.

  *  `./experiments/experiment_utils/`. <br>
    The directory includes the functional modules for analyzing and evaluating the prognostic value of the model output (i.e. AUC, Sensitivity, Specificity, HR, Cindex). 

  *  `./experiments/models_parameters/Train/`. <br>
    Model parameters at each epoch during the training processing.  

  *  `./experiments/models_parameters/Reproduce/`. <br>
    All parameters for IGNN and IGNNE at each epoch during the training process and the parameters of final well-trained models, which can be used to reproduce the experimental results in this paper.  
# Experiments
## Training and evaluation of IGNN(IGNNE) model on the raw data  
#### 1. Pre-validation <br>
In the pre-validation experiments, the model will be trained and validated within the FMU dataset by 3-fold cross validation.   

To launch the pre-validation experiments for IGNN model within the activated virtual environment(IGNN):    
```bash  
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='1'" -t "MODEL_TYPE='IGNN'" -t "MODEL_STATE='Train'" 
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='2'" -t "MODEL_TYPE='IGNN'" -t "MODEL_STATE='Train'"
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='3'" -t "MODEL_TYPE='IGNN'" -t "MODEL_STATE='Train'"
```   

Then launch the procedure as following: 
```bash   
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='1'" -t "MODEL_TYPE='IGNN'" -t "MODEL_STATE='Result'" 
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='2'" -t "MODEL_TYPE='IGNN'" -t "MODEL_STATE='Result'"
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='3'" -t "MODEL_TYPE='IGNN'" -t "MODEL_STATE='Result'"
```      
The predictions of the well-trained IGNN model on the training and test data for each fold in the 3-fold cross validation will be saved in specific Excel files in the `./experiments/experiment_results/` directory:
```  
pre_train_cohort_fold1_IGNN.xlsx;  pre_test_cohort_fold1_IGNN.xlsx
pre_train_cohort_fold2_IGNN.xlsx;  pre_test_cohort_fold2_IGNN.xlsx
pre_train_cohort_fold3_IGNN.xlsx;  pre_test_cohort_fold3_IGNN.xlsx
``` 
To launch the pre-validation experiments for IGNNE model:
```bash
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='1'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Train'" 
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='2'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Train'"
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='3'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Train'"
```  
Then launch the procedure as following:  
```bash
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='1'" -t "MODEL_TYPE='IGNN'E" -t "MODEL_STATE='Result'" 
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='2'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Result'"
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='3'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Result'"
```  
The predictions of the well-trained IGNNE model will be saved as:  
```
pre_train_cohort_fold1_IGNNE.xlsx;  pre_test_cohort_fold1_IGNNE.xlsx
pre_train_cohort_fold2_IGNNE.xlsx;  pre_test_cohort_fold2_IGNNE.xlsx
pre_train_cohort_fold3_IGNNE.xlsx;  pre_test_cohort_fold3_IGNNE.xlsx
```   
To reproduce the experimental results of pre-validation for IGNN model:  
```bash   
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='1'" -t "MODEL_TYPE='IGNN'" -t "MODEL_STATE='Reproduce'" 
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='2'" -t "MODEL_TYPE='IGNN'" -t "MODEL_STATE='Reproduce'"
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='3'" -t "MODEL_TYPE='IGNN'" -t "MODEL_STATE='Reproduce'"
```  
Expected performance of IGNN for the 3-fold cross validation in the pre-validation experiments:    
  
``` 
>>> TrainAuc: 0.860, TrainSen: 0.851, TrainSpe: 0.764, TrainHR: 7.654, TrainC: 0.751, 
    TestAuc: 0.862, TestSen: 0.759, TestSpe: 0.891, TestHR: 9.61, TestC: 0.797
>>> TrainAuc: 0.866, TrainSen: 0.799, TrainSpe: 0.874, TrainHR: 8.167, TrainC: 0.761,  
    TestAuc: 0.804, TestSen: 0.908, TestSpe: 0.611, TestHR: 8.07, TestC: 0.741
>>> TrainAuc: 0.871, TrainSen: 0.816, TrainSpe: 0.833, TrainHR: 7.968, TrainC: 0.765, 
    TestAuc: 0.830, TestSen: 0.805, TestSpe: 0.783, TestHR: 7.99, TestC: 0.766   
```    
The predictions of the reproduced IGNN model will be saved as:  
```
pre_train_cohort_fold1_IGNN.xlsx;  pre_test_cohort_fold1_IGNN.xlsx
pre_train_cohort_fold2_IGNN.xlsx;  pre_test_cohort_fold2_IGNN.xlsx
pre_train_cohort_fold3_IGNN.xlsx;  pre_test_cohort_fold3_IGNN.xlsx
```   

 To reproduce the experimental results of pre-validation for IGNNE model:  
```bash    
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='1'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Reproduce'" 
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='2'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Reproduce'"
python main.py -t "EXPERIMENT_TYPE='pre'" -t "FOLD_N='3'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Reproduce'"
```  
Expected performance of IGNNE for the 3-fold cross validation in the pre-validation experiments:  
```   
>>> TrainAuc: 0.895, TrainSen: 0.862, TrainSpe: 0.828, TrainHR: 10.267, TrainC: 0.792, 
    TestAuc: 0.900, TestSen: 0.816, TestSpe: 0.878, TestHR: 14.44, TestC: 0.826
>>> TrainAuc: 0.914, TrainSen: 0.828, TrainSpe: 0.891, TrainHR: 10.791, TrainC: 0.805,  
    TestAuc: 0.848, TestSen: 0.874, TestSpe: 0.713, TestHR: 8.00, TestC: 0.781 
>>> TrainAuc: 0.917, TrainSen: 0.845, TrainSpe: 0.868, TrainHR: 10.987, TrainC: 0.817, 
    TestAuc: 0.870, TestSen: 0.828, TestSpe: 0.796, TestHR: 9.67, TestC: 0.807
``` 
The predictions of the reproduced IGNNE model will be saved as:  
```
pre_train_cohort_fold1_IGNNE.xlsx;  pre_test_cohort_fold1_IGNNE.xlsx
pre_train_cohort_fold2_IGNNE.xlsx;  pre_test_cohort_fold2_IGNNE.xlsx
pre_train_cohort_fold3_IGNNE.xlsx;  pre_test_cohort_fold3_IGNNE.xlsx
```   
#### 2. External-validation <br>
In the external validation experiments, the model will be trained on the FMU dataset and validated on the HMU dataset.   

To launch the experiments for IGNN model:  
```bash
python main.py -t "EXPERIMENT_TYPE='external'" -t "MODEL_TYPE='IGNN'" -t "MODEL_STATE='Train'"   
```     
Then launch the procedure as following:
```bash 
python main.py -t "EXPERIMENT_TYPE='external'" -t "MODEL_TYPE='IGNN'" -t "MODEL_STATE='Result'"
```  
The predictions of the well-trained IGNN model on the training and test data will be saved in the `./experiments/experiment_results/` directory:
``` 
external_train_cohort_IGNN.xlsx;  external_test_cohort_IGNN.xlsx
```  
To launch the experiments for IGNNE model:
```bash
python main.py -t "EXPERIMENT_TYPE='external'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Train'"
```    
Then launch the procedure as following:  
```bash
python main.py -t "EXPERIMENT_TYPE='external'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Result'"  
```
The predictions of the well-trained IGNNE model on the training and test data will be also saved as:
```
external_train_cohort_IGNNE.xlsx;  external_test_cohort_IGNNE.xlsx
```  
To reproduce the experimental results of external validation for IGNN model:
```bash
python main.py -t "EXPERIMENT_TYPE='external'" -t "MODEL_TYPE='IGNN'" -t "MODEL_STATE='Reproduce'"
```   
 
Expected performance of IGNN in the external validation experiments:  
```  
>>> TrainAuc: 0.869, TrainSen: 0.782, TrainSpe: 0.857, TrainHR: 9.585, TrainC: 0.798, 
    TestAuc: 0.826, TestSen: 0.750, TestSpe: 0.833, TestHR: 6.21, TestC: 0.743
```  
The predictions of the reproduced IGNN model will be also saved as:
```
external_train_cohort_IGNN.xlsx;  external_test_cohort_IGNN.xlsx
``` 

To reproduce the experimental results of external validation for IGNNE model:  
```bash  
python main.py -t "EXPERIMENT_TYPE='external'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Reproduce'"  
```    
Expected performance of IGNNE in the external validation experiments:  
```  
>>> TrainAuc: 0.913, TrainSen: 0.828, TrainSpe: 0.881, TrainHR: 14.040, TrainC: 0.848, 
    TestAuc: 0.877, TestSen: 0.750, TestSpe: 0.893, TestHR: 8.40, TestC: 0.795    
```   
The predictions of the reproduced IGNNE model will be also saved as:
```
external_train_cohort_IGNNE.xlsx;  external_test_cohort_IGNNE.xlsx
``` 

For more detailed about the configuration of models and experiments, please refer to the `./experiments/configs/configs.py` and `./experiments/configs/*.toml` or launch the procedure as following:  
```bash 
python main.py -h
``` 
***Note:*** The training and validation of IGNN (IGNNE) model can be executed with windows or linux OS on both CPU and GPU. In this paper, IGNN and IGNNE were implemented by default with windows OS on CPU in all experiments to ensure reproducibility of the experimental results on the raw data as presented in the paper. The experiments are executed on CPU by default, and if the program needs to be executed on GPU, please set  
`-t "PROCESSUNIT_STATE='GPU'"`.   
Due to the variability of different operating systems and hardware platforms, the model output and performance of IGNN and IGNNE models trained and validated from scratch on different devices may have variability. Please load the models with the parameters of well-trained models in the default configuration to reproduce the experimental results of this paper as described before.
 
## Training and evaluation of IGNN(IGNNE) model on the user-defined data  
We provide a demo to demonstrate how to conveniently train, validate and evaluate the IGNN (IGNNE) model on the user's own data. First, the TACS coding, clinical and follow-up information from the patients should be recorded in xlsx files and placed in the `./experiments/Patients_Information/DataSets_demo/` directory as we did previously for the FMU dataset and the HMU dataset, then the configuration file `./experiments/configs/user_config.toml` should be modified to set the experimental and model parameters, and finally launch the main as following:   
```
python main_user.py -t "EXPERIMENT_TYPE='user'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Train'" -t "REBULIT_GRAPH_DATA_STATE= 'True'"   
``` 
Then Launch the program as following to evaluate the performance of the trained model:  
```
python main_user.py -t "EXPERIMENT_TYPE='user'" -t "MODEL_TYPE='IGNNE'" -t "MODEL_STATE='Result'"
```
The predictions of the well-trained model on the training and test data will be saved in the `./experiments/experiment_results/` directory:  
```
user_train_cohort_IGNNE.xlsx;  user_test_cohort_IGNNE.xlsx
```  
For more detailed, please refer to the `./experiments/configs/user_configs.py` and `./experiments/configs/user_config.toml` or launch the procedure as following:
```
python main_user.py -h
```
# Source Data  
To maximize the reproducibility of our study, we provided the raw data underlying all the figures and tables demonstrated in our paper. These raw data were saved for each figure/table in specific Excel file with multiple labeled sheets, respectively. The Excel files were deposited in the `./Source Data/` directory.  
# Data analysis  
In addition, the analytical procedures with R code for Source Data were also provided to reproduce the experimental results and displayable items. These procedures were deposited in the specific folders for each figure/table under the `./Source_Data_analysis/` directory.  

***Note:*** Please ensure that the `Source Data` directory and `Source_Data_analysis` directory are in the same parent folder. Meanwhile, we recommend implementing these analytical programs in Rstudio to avoid manually setting the relative working directory. Analysis programs based on R code usually depends on some specific R packages for specialized functions. So when these programs are run for the first time, they will automatically download and install the dependent R packages. If the installation fails, please check the network connection status and the availability of the data sources for these R packages, and manually downloading and installing some R packages is also optional.
# License
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation.<br>
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. <https://www.gnu.org/licenses/>.







