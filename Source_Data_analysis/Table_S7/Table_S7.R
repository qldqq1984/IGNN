# library(timeROC)
# library(pROC)
# library(ROCit)
# library(openxlsx)
options(digits=4)
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
require_library("timeROC")
require_library("pROC")
require_library("ROCit")
require_library("openxlsx")



dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Table_S7/Table_S7.xlsx")

# Evaluate model performance with metrics of AUC, sensitivity, specificity, ppv, npv and accuracy"
ROCStatFunc2 <- function(dat, group, threshold = 0, var,retype = c("threshold", "specificity", "sensitivity", "ppv","npv", "accuracy"),digit = 4)
{
        subgroup <- levels(as.factor(dat[[group]]))
        subgroup1 <- paste0(subgroup[2], " vs ", subgroup[1])
        rocmodel <- roc(dat[[group]], dat[[var]], percent = F,algorithm = 3)
        other <- coords(rocmodel, x = threshold, transpose = FALSE,ret=c("threshold", "specificity", "sensitivity", "ppv","npv", "accuracy"))
        auc <- round(ci.auc(rocmodel),digit)
        auc <- paste0(auc[2],"(",auc[1],"-",auc[3],")")
        abc <- coords(rocmodel, x = threshold,transpose = FALSE)
        result <- c(group, subgroup1, auc, other, threshold)
        
        names(result) <- c("group", "subgroup","auc(95%CI)", retype, "threshold")
        return(result)
}

quiteROCFunc <- ROCStatFunc2


# Training (n=731) 
TACS_data_training <- read.xlsx( Data_file , sheet = "TACS_training_cohort")
Nomogram_data_training <- read.xlsx( Data_file , sheet = "Nomogram_training_cohort")
IGNN_data_training <- read.xlsx( Data_file , sheet = "IGNN_training_cohort")
IGNNE_data_training <- read.xlsx( Data_file , sheet = "IGNNE_training_cohort")


# Evaluation for the TACS model on training cohort
Y = TACS_data_training$y
risk_groups = TACS_data_training$model_score
data <- data.frame(Y,risk_groups)
TACS_training_result <- quiteROCFunc( data, group = "Y", var = "risk_groups", threshold = -0.3107)
print("TACS_training_result............")
print(TACS_training_result)


# Evaluation for the Nomogram model on training cohort
Y = Nomogram_data_training$y
risk_groups = Nomogram_data_training$model_score
data <- data.frame(Y,risk_groups)
Nomogram_training_result <- quiteROCFunc( data, group = "Y", var = "risk_groups", threshold = 0.5421)
print("Nomogram_training_result............")
print(Nomogram_training_result)


# Evaluation for the IGNN model on training cohort
Y = IGNN_data_training$y
risk_groups = IGNN_data_training$model_score
data <- data.frame(Y,risk_groups)
IGNN_training_result <- quiteROCFunc( data, group = "Y", var = "risk_groups", threshold = 1.156)
print("IGNN_training_result............")
print(IGNN_training_result)



# Evaluation for the IGNN model on training cohort
Y = IGNNE_data_training$y
risk_groups = IGNNE_data_training$model_score
data <- data.frame(Y,risk_groups)
IGNNE_training_result <- quiteROCFunc( data, group = "Y", var = "risk_groups", threshold = -0.4299)
print("IGNNE_training_result............")
print(IGNNE_training_result)



##############
# Validation (n=264) 
TACS_data_validation <- read.xlsx( Data_file , sheet = "TACS_validation_cohort")
Nomogram_data_validation <- read.xlsx( Data_file , sheet = "Nomogram_validation_cohort")
IGNN_data_validation <- read.xlsx( Data_file , sheet = "IGNN_validation_cohort")
IGNNE_data_validation <- read.xlsx( Data_file , sheet = "IGNNE_validation_cohort")


# Evaluation for the TACS model on validation cohort
Y = TACS_data_validation$y
risk_groups = TACS_data_validation$model_score
data <- data.frame(Y,risk_groups)
TACS_validation_result <- quiteROCFunc( data, group = "Y", var = "risk_groups", threshold = -0.3107)
print("TACS_validation_result............")
print(TACS_validation_result)



# Evaluation for the Nomogram model on validation cohort
Y = Nomogram_data_validation$y
risk_groups = Nomogram_data_validation$model_score
data <- data.frame(Y,risk_groups)
Nomogram_validation_result <- quiteROCFunc( data, group = "Y", var = "risk_groups", threshold = 0.5421)
print("Nomogram_validation_result............")
print(Nomogram_validation_result)



# Evaluation for the IGNN model on validation cohort
Y = IGNN_data_validation$y
risk_groups = IGNN_data_validation$model_score
data <- data.frame(Y,risk_groups)
IGNN_validation_result <- quiteROCFunc( data, group = "Y", var = "risk_groups", threshold = 1.156)
print("IGNN_validation_result............")
print(IGNN_validation_result)



# Evaluation for the IGNN model on validation cohort
Y = IGNNE_data_validation$y
risk_groups = IGNNE_data_validation$model_score
data <- data.frame(Y,risk_groups)
IGNNE_validation_result <- quiteROCFunc( data, group = "Y", var = "risk_groups", threshold = -0.4299)
print("IGNNE_validation_result............")
print(IGNNE_validation_result)


