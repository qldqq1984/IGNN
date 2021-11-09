# library(xlsx)
# library(glmnet)
# library(foreign)
# library(survminer)
# library(here)
warnings('off')
options(warn =-1)


# install the necessary libraries
require_library <- function(library_name){
  result <- lapply(library_name, require, character.only = TRUE)
  if(result[[1]]){
    print(paste0(library_name," is loaded correctly"))
  } else {
    print(paste0("trying to install ", library_name))
    lapply(library_name, install.packages)
    result <- lapply(library_name, require, character.only = TRUE)
    if(result[[1]]){
      print(paste0(library_name, " installed and loaded"))
    } else {
      stop(paste0("could not install ",library_name))
    }
  }
}

# the necessary libraries
require_library("xlsx")
require_library("glmnet")
require_library("foreign")
require_library("survminer")
require_library("here")



# implement external validation experiment for IGNN and IGNNE prognostic model 
dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
source(paste0(dir_root,'/Souce_Data_analysis/IGNN_IGNNE_performance/IGNN_IGNNE_models.R'), encoding = 'UTF-8') 
Patient_information_file = paste0(dir_root,"/Souce Data/IGNN_IGNNE_performance/Patient_information.xlsx")



# external validation experiment results of IGNN prognostic model  
IGNN_train_cohort_file = paste0(dir_root,"/experiments/experiment_results/external_train_cohort_IGNN.xlsx")
IGNN_test_cohort_file = paste0(dir_root,"/experiments/experiment_results/external_test_cohort_IGNN.xlsx")
IGNN_train_cohort <- read.xlsx( IGNN_train_cohort_file, sheetName = "1", skipEmptyRows = TRUE)
IGNN_test_cohort <- read.xlsx( IGNN_test_cohort_file, sheetName = "1", skipEmptyRows = TRUE)
IGNN_train_cohort_prediction <- IGNN_model(dataset=IGNN_train_cohort, train=TRUE,  cutoff = 0.0 )
IGNN_test_cohort_prediction <- IGNN_model(dataset=IGNN_test_cohort, train=FALSE, cutoff = IGNN_train_cohort_prediction$cutoff )
IGNN_train_cohort_prediction_results <- data.frame(id = IGNN_train_cohort$Graph_id, y = IGNN_train_cohort$y, DFS = IGNN_train_cohort$DFS, STATUS = IGNN_train_cohort$STATUS, model_score = IGNN_train_cohort$model_score, model_risk = IGNN_train_cohort$model_risk)
IGNN_test_cohort_prediction_results <- data.frame(id = IGNN_test_cohort$Graph_id, y = IGNN_test_cohort$y, DFS = IGNN_test_cohort$DFS, STATUS = IGNN_test_cohort$STATUS,  model_score = IGNN_test_cohort$model_score, model_risk = IGNN_test_cohort$model_risk)
IGNN_results_file = paste0(dir_root,"/Souce Data/IGNN_IGNNE_performance/external_validation_IGNN_model_prediction.xlsx")

write.xlsx(x = IGNN_train_cohort_prediction_results, file = IGNN_results_file,sheetName = "train_cohort", row.names = F)
write.xlsx(x = IGNN_test_cohort_prediction_results, file = IGNN_results_file,sheetName = "test_cohort", row.names = F, append=TRUE)



# external validation experiment results of IGNNE prognostic model  
IGNNE_train_cohort_file = paste0(dir_root,"/experiments/experiment_results/external_train_cohort_IGNNE.xlsx")
IGNNE_test_cohort_file = paste0(dir_root,"/experiments/experiment_results/external_test_cohort_IGNNE.xlsx")
IGNNE_train_cohort <- read.xlsx( IGNNE_train_cohort_file, sheetName = "1", skipEmptyRows = TRUE)
IGNNE_test_cohort <- read.xlsx( IGNNE_test_cohort_file, sheetName = "1", skipEmptyRows = TRUE)
IGNNE_train_cohort_prediction <- IGNNE_model(dataset=IGNNE_train_cohort, train=TRUE,  cutoff = 0.0 )
IGNNE_test_cohort_prediction <- IGNNE_model(dataset=IGNNE_test_cohort, train=FALSE, cutoff = IGNNE_train_cohort_prediction$cutoff )
IGNNE_train_cohort_prediction_results <- data.frame(id = IGNNE_train_cohort$Graph_id, y = IGNNE_train_cohort$y, DFS = IGNNE_train_cohort$DFS, STATUS = IGNNE_train_cohort$STATUS, model_score = IGNNE_train_cohort$model_score, model_risk = IGNNE_train_cohort$model_risk)
IGNNE_test_cohort_prediction_results <- data.frame(id = IGNNE_test_cohort$Graph_id, y = IGNNE_test_cohort$y, DFS = IGNNE_test_cohort$DFS, STATUS = IGNNE_test_cohort$STATUS,  model_score = IGNNE_test_cohort$model_score, model_risk = IGNNE_test_cohort$model_risk)
IGNNE_results_file = paste0(dir_root,"/Souce Data/IGNN_IGNNE_performance/external_validation_IGNNE_model_prediction.xlsx")

write.xlsx(x = IGNNE_train_cohort_prediction_results, file = IGNNE_results_file,sheetName = "train_cohort", row.names = F)
write.xlsx(x = IGNNE_test_cohort_prediction_results, file = IGNNE_results_file,sheetName = "test_cohort", row.names = F, append=TRUE)




