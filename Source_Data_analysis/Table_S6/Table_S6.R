# library(timeROC)
# library(tidyverse)
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
require_library("tidyverse")
require_library("openxlsx")



dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Table_S6/Table_S6.xlsx")

# Evaluate model performance with metrics of AUC, sensitivity, specificity, ppv, npv and accuracy"
ROCStatFunc2 <- function(dat, group, threshold = 0, var,retype = c("threshold", "specificity", "sensitivity", "ppv","npv", "accuracy"),digit = 4)
{
        subgroup <- levels(as.factor(dat[[group]]))
        subgroup1 <- paste0(subgroup[2], " vs ", subgroup[1])
        rocmodel <- roc(dat[[group]], dat[[var]], percent = F,algorithm = 3)
        other <- coords(rocmodel, x = threshold, transpose = FALSE,ret=c("threshold", "specificity", "sensitivity", "ppv","npv", "accuracy"))
        #other <- round(other, digit)
        
        auc <- round(ci.auc(rocmodel),digit)
        auc <- paste0(auc[2],"(",auc[1],"-",auc[3],")")
        abc <- coords(rocmodel, x = threshold,transpose = FALSE)
        result <- c(group, subgroup1, auc, other, threshold)
        
        names(result) <- c("group", "subgroup","auc(95%CI)", retype, "threshold")
        
        
        return(result)
}

quiteROCFunc <- quietly(ROCStatFunc2)

###############
TACS_data_fold1 <- read.xlsx( Data_file , sheet = "TACS_fold1")
TACS_data_fold2 <- read.xlsx( Data_file , sheet = "TACS_fold2")
TACS_data_fold3 <- read.xlsx( Data_file , sheet = "TACS_fold3")
TACS_data <- rbind(TACS_data_fold1, TACS_data_fold2, TACS_data_fold3)

Y = TACS_data$y
risk_groups = TACS_data$model_risk
data <- data.frame(Y,risk_groups)

# Evaluation for the TACS model
quiteROCFunc( data, group = "Y", var = "risk_groups", threshold = 0.5)$result


##############
Nomogram_data_fold1 <- read.xlsx( Data_file , sheet = "Nomogram_fold1")
Nomogram_data_fold2 <- read.xlsx( Data_file , sheet = "Nomogram_fold2")
Nomogram_data_fold3 <- read.xlsx( Data_file , sheet = "Nomogram_fold3")
Nomogram_data <- rbind(Nomogram_data_fold1, Nomogram_data_fold2, Nomogram_data_fold3)

Y = Nomogram_data$y
risk_groups = Nomogram_data$model_risk
data <- data.frame(Y,risk_groups)

# Evaluation for the Nomogram model
quiteROCFunc( data, group = "Y", var = "risk_groups", threshold = 0.5)$result


###############
IGNN_data_fold1 <- read.xlsx( Data_file , sheet = "IGNN_fold1")
IGNN_data_fold2 <- read.xlsx( Data_file , sheet = "IGNN_fold2")
IGNN_data_fold3 <- read.xlsx( Data_file , sheet = "IGNN_fold3")
IGNN_data <- rbind(IGNN_data_fold1, IGNN_data_fold2, IGNN_data_fold3)

Y = IGNN_data$y
risk_groups = IGNN_data$model_risk
data <- data.frame(Y,risk_groups)

# Evaluation for the IGNN model
quiteROCFunc( data, group = "Y", var = "risk_groups", threshold = 0.5)$result


###############
IGNNE_data_fold1 <- read.xlsx( Data_file , sheet = "IGNNE_fold1")
IGNNE_data_fold2 <- read.xlsx( Data_file , sheet = "IGNNE_fold2")
IGNNE_data_fold3 <- read.xlsx( Data_file , sheet = "IGNNE_fold3")
IGNNE_data <- rbind(IGNNE_data_fold1, IGNNE_data_fold2, IGNNE_data_fold3)

Y = IGNNE_data$y
risk_groups = IGNNE_data$model_risk
data <- data.frame(Y,risk_groups)

# Evaluation for the IGNNE model
quiteROCFunc( data, group = "Y", var = "risk_groups", threshold = 0.5)$result






