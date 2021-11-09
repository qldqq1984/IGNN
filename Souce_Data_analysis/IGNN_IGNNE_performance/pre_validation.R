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


dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
source(paste0(dir_root,'/Souce_Data_analysis/IGNN_IGNNE_performance/IGNN_IGNNE_models.R'), encoding = 'UTF-8') 
Patient_information_file = paste0(dir_root,"/Souce Data/IGNN_IGNNE_performance/Patient_information.xlsx")

# implement pre-validation experiment with 3-cross validation for IGNN and IGNNE prognostic model 
pre_validation_experiment <- function(cv_test_cohort_file, model_type){
  
  train_cohort <- read.xlsx( cv_train_cohort_file, sheetName = "1", skipEmptyRows = TRUE)
  test_cohort <- read.xlsx( cv_test_cohort_file, sheetName = "1", skipEmptyRows = TRUE)

  if (model_type== "IGNN"){ 
      train_cohort_prediction <- IGNN_model(dataset=train_cohort, train=TRUE,  cutoff = 0.0 )
      test_cohort_prediction <- IGNN_model(dataset=test_cohort, train=FALSE, cutoff = train_cohort_prediction$cutoff )
  }  
  
  else if (model_type== "IGNNE"){ 
    train_cohort_prediction <- IGNNE_model(dataset=train_cohort, train=TRUE,  cutoff = 0.0 )
    test_cohort_prediction <- IGNNE_model(dataset=test_cohort, train=FALSE, cutoff = train_cohort_prediction$cutoff )
  }  
  
  results <- {}
  results$train_cohort_prediction <- data.frame(id = train_cohort$Graph_id, y = train_cohort$y, DFS = train_cohort$DFS, STATUS = train_cohort$STATUS, model_score = train_cohort$model_score, model_risk = train_cohort$model_risk)
  results$test_cohort_prediction <- data.frame(id = test_cohort$Graph_id, y = test_cohort$y, DFS = test_cohort$DFS, STATUS = test_cohort$STATUS,  model_score = test_cohort$model_score, model_risk = test_cohort$model_risk)
  return(results)
}

# pre-validation experiment results of IGNN prognostic model

for (fold_id in 1:3){
  
  cv_train_cohort_file = paste0(dir_root,"/experiments/experiment_results/pre_train_cohort_fold",fold_id,"_IGNN.xlsx")
  cv_test_cohort_file = paste0(dir_root,"/experiments/experiment_results/pre_test_cohort_fold",fold_id,"_IGNN.xlsx")
  cv_results_file = paste0(dir_root,"/Souce Data/IGNN_IGNNE_performance/pre_validation_IGNN_model_prediction.xlsx")
  
  results <- pre_validation_experiment(cv_test_cohort_file, model_type = "IGNN")
  
  write.xlsx(x = results$train_cohort_prediction, file = cv_results_file,sheetName =  paste0("fold",fold_id,"_train_cohort"), row.names = F, append=TRUE)
  write.xlsx(x = results$test_cohort_prediction, file = cv_results_file,sheetName =  paste0("fold",fold_id,"_test_cohort"), row.names = F, append=TRUE)
  
}



# pre-validation experiment results of IGNNE prognostic model
for (fold_id in 1:3){
  
  cv_train_cohort_file = paste0(dir_root,"/experiments/experiment_results/pre_train_cohort_fold",fold_id,"_IGNNE.xlsx")
  cv_test_cohort_file = paste0(dir_root,"/experiments/experiment_results/pre_test_cohort_fold",fold_id,"_IGNNE.xlsx")
  cv_results_file = paste0(dir_root,"/Souce Data/IGNN_IGNNE_performance/pre_validation_IGNNE_model_prediction.xlsx")
  
  results <- pre_validation_experiment(cv_test_cohort_file, model_type = "IGNNE")
  
  write.xlsx(x = results$train_cohort_prediction, file = cv_results_file,sheetName =  paste0("fold",fold_id,"_train_cohort"), row.names = F, append=TRUE)
  write.xlsx(x = results$test_cohort_prediction, file = cv_results_file,sheetName =  paste0("fold",fold_id,"_test_cohort"), row.names = F, append=TRUE)
  
}

