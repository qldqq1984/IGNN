# library(openxlsx)
# library(readxl)
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
require_library("openxlsx")
require_library("readxl")
require_library("glmnet")
require_library("foreign")
require_library("survminer")
require_library("here")


dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
source(paste0(dir_root,'/Source_Data_analysis/Figure_S1/TACS_Nomogram_models.R'), encoding = 'UTF-8') 
Patient_information_file = paste0(dir_root,"/Source Data/Figure_S1/Patient_information.xlsx")


# implement pre-validation experiment with 3-cross validation for TACS and Nomogram prognostic prediction model 
pre_validation_experiment <- function(cv_train_cohort, cv_test_cohort){
  
  train_cohort <- cv_train_cohort
  test_cohort <- cv_test_cohort
  
  TACS_train_cohort_prediction <- TACS_model(dataset=train_cohort, train=TRUE, model.coef={}, cutoff = 0.0 )
  TACS_test_cohort_prediction <- TACS_model(dataset=test_cohort, train=FALSE, model.coef = TACS_train_cohort_prediction$coef, cutoff = TACS_train_cohort_prediction$cutoff )
  
  results <- {}    
  results$TACS_train_cohort_prediction <- data.frame(y = train_cohort$y, DFS = train_cohort$DFS, STATUS = train_cohort$STATUS, model_score = TACS_train_cohort_prediction$model_score, model_risk = TACS_train_cohort_prediction$model_risk)
  results$TACS_test_cohort_prediction <- data.frame(y = test_cohort$y, DFS = test_cohort$DFS, STATUS = test_cohort$STATUS,  model_score = TACS_test_cohort_prediction$model_score, model_risk = TACS_test_cohort_prediction$model_risk)
  
  
  Nomogram_train_cohort_prediction <- Nomogram_model(dataset=train_cohort, TACS_score=TACS_train_cohort_prediction$model_score,  train=TRUE, allcoefs={}, cutoff = 0.0 )
  Nomogram_test_cohort_prediction <- Nomogram_model(dataset=test_cohort, TACS_score=TACS_test_cohort_prediction$model_score, train=FALSE, allcoefs=Nomogram_train_cohort_prediction$coefs, cutoff = Nomogram_train_cohort_prediction$cutoff )
  
  results$Nomogram_train_cohort_prediction <- data.frame(y = train_cohort$y, DFS = train_cohort$DFS, STATUS = train_cohort$STATUS, model_score = Nomogram_train_cohort_prediction$model_score, model_risk = Nomogram_train_cohort_prediction$model_risk)
  results$Nomogram_test_cohort_prediction <- data.frame(y = test_cohort$y, DFS = test_cohort$DFS, STATUS = test_cohort$STATUS,  model_score = Nomogram_test_cohort_prediction$model_score, model_risk = Nomogram_test_cohort_prediction$model_risk)
  
  return(results)
  
}




# pre-validation experiment results of TACS and Nomogram prognostic model 

for (fold_id in 1:3){
  cv_train_cohort <- read.xlsx( Patient_information_file, sheet = paste0("pre_train_cohort_fold",fold_id), skipEmptyRows = TRUE) # training data of TACS and Nomogram models for each cross validation in pre-validation
  cv_test_cohort <- read.xlsx( Patient_information_file, sheet = paste0("pre_test_cohort_fold",fold_id), skipEmptyRows = TRUE) # validation data of TACS and Nomogram models for each cross validation in pre-validation
  
  results <- pre_validation_experiment(cv_train_cohort, cv_test_cohort)
  
  TACS_cv_results_file = paste0(dir_root,"/Source Data/Figure_S1/pre_validation_TACS_model_prediction.xlsx")
  Nomogram_cv_results_file = paste0(dir_root,"/Source Data/Figure_S1/pre_validation_Nomogram_model_prediction.xlsx")
  
  
  # write.xlsx(x = results$TACS_train_cohort_prediction, file = TACS_cv_results_file,sheetName =  paste0("fold",fold_id,"_train_cohort"), row.names = F, append=TRUE)
  # write.xlsx(x = results$TACS_test_cohort_prediction, file = TACS_cv_results_file,sheetName =  paste0("fold",fold_id,"_test_cohort"), row.names = F, append=TRUE)
  # write.xlsx(x = results$Nomogram_train_cohort_prediction, file = Nomogram_cv_results_file,sheetName =  paste0("fold",fold_id,"_train_cohort"), row.names = F, append=TRUE)
  # write.xlsx(x = results$Nomogram_test_cohort_prediction, file = Nomogram_cv_results_file,sheetName =  paste0("fold",fold_id,"_test_cohort"), row.names = F, append=TRUE)
}


