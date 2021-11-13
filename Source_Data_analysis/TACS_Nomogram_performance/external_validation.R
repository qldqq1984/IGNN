# library(openxlsx)
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
require_library("glmnet")
require_library("foreign")
require_library("survminer")
require_library("here")


# implement external validation experiment for TACS and IGNNE Nomogram model 
dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
source(paste0(dir_root,'/Source_Data_analysis/TACS_Nomogram_performance/TACS_Nomogram_models.R'), encoding = 'UTF-8') 
Patient_information_file = paste0(dir_root,"/Source Data/TACS_Nomogram_performance/Patient_information.xlsx")



# external validation experiment results of TACS prognostic model
train_cohort <- read.xlsx( Patient_information_file, sheet = "FMU_dataset", skipEmptyRows = TRUE)
test_cohort <- read.xlsx( Patient_information_file, sheet = "HMU_dataset", skipEmptyRows = TRUE)
TACS_train_cohort_prediction <- TACS_model(dataset=train_cohort, train=TRUE, model.coef={}, cutoff = 0.0 )
TACS_test_cohort_prediction <- TACS_model(dataset=test_cohort, train=FALSE, model.coef = TACS_train_cohort_prediction$coef, cutoff = TACS_train_cohort_prediction$cutoff )
TACS_train_cohort_prediction_results <- data.frame(id = train_cohort$id, y = train_cohort$y, DFS = train_cohort$DFS, STATUS = train_cohort$STATUS, model_score = TACS_train_cohort_prediction$model_score, model_risk = TACS_train_cohort_prediction$model_risk)
TACS_test_cohort_prediction_results <- data.frame(id = test_cohort$id, y = test_cohort$y, DFS = test_cohort$DFS, STATUS = test_cohort$STATUS,  model_score = TACS_test_cohort_prediction$model_score, model_risk = TACS_test_cohort_prediction$model_risk)
TACS_results_file = paste0(dir_root,"/Source Data/TACS_Nomogram_performance/external_validation_TACS_model_prediction.xlsx")
# write.xlsx(x = TACS_train_cohort_prediction_results, file = TACS_results_file,sheetName = "train_cohort", row.names = F)
# write.xlsx(x = TACS_test_cohort_prediction_results, file = TACS_results_file,sheetName = "test_cohort", row.names = F, append=TRUE)


# external validation experiment results of Nomogram prognostic model 
Nomogram_train_cohort_prediction <- Nomogram_model(dataset=train_cohort, TACS_score=TACS_train_cohort_prediction$model_score,  train=TRUE, allcoefs={}, cutoff = 0.0 )
Nomogram_test_cohort_prediction <- Nomogram_model(dataset=test_cohort, TACS_score=TACS_test_cohort_prediction$model_score, train=FALSE, allcoefs=Nomogram_train_cohort_prediction$coefs, cutoff = Nomogram_train_cohort_prediction$cutoff )
Nomogram_train_cohort_prediction_results <- data.frame(id = train_cohort$id, y = train_cohort$y, DFS = train_cohort$DFS, STATUS = train_cohort$STATUS, model_score = Nomogram_train_cohort_prediction$model_score, model_risk = Nomogram_train_cohort_prediction$model_risk)
Nomogram_test_cohort_prediction_results <- data.frame(id = test_cohort$id, y = test_cohort$y, DFS = test_cohort$DFS, STATUS = test_cohort$STATUS,  model_score = Nomogram_test_cohort_prediction$model_score, model_risk = Nomogram_test_cohort_prediction$model_risk)
Nomogram_results_file = paste0(dir_root,"/Source Data/TACS_Nomogram_performance/external_validation_Nomogram_model_prediction.xlsx")
# write.xlsx(x = Nomogram_train_cohort_prediction_results, file = Nomogram_results_file,sheetName = "train_cohort", row.names = F)
# write.xlsx(x = Nomogram_test_cohort_prediction_results, file = Nomogram_results_file,sheetName = "test_cohort", row.names = F, append=TRUE)



