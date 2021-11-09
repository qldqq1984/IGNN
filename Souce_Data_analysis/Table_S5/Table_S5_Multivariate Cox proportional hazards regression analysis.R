# library(survival)
# library(openxlsx)
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
require_library("survival")
require_library("openxlsx")



dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Souce Data/Table_S5/Table_S5.xlsx")

# Training (n=731) 
TACS_data_training <- read.xlsx( Data_file , sheet = "TACS_training_cohort")
IGNN_data_training <- read.xlsx( Data_file , sheet = "IGNN_training_cohort")


# Validation (n=264) 
TACS_data_validation <- read.xlsx( Data_file , sheet = "TACS_validation_cohort")
IGNN_data_validation <- read.xlsx( Data_file , sheet = "IGNN_validation_cohort")


TACS_data_training$age <- ifelse(TACS_data_training$age  > 50, 1, 0)
TACS_data_training$age <- factor(TACS_data_training$age,labels=c('1','2'))
TACS_data_training$type <- factor(TACS_data_training$type,labels=c('1','2','3','4'))
TACS_data_training$size <- factor(TACS_data_training$size,labels=c('1','2','3'))
TACS_data_training$lym <- factor(TACS_data_training$lym,labels=c('1','2', '3'))
TACS_data_training$stage <- factor(TACS_data_training$stage,labels=c('1','2','3'))
TACS_data_training$grade <- factor(TACS_data_training$grade,labels=c('1','2','3'))
TACS_data_training$Chemotherapy <- factor(TACS_data_training$Chemotherapy,labels=c('1','2'))
TACS_data_training$Radiation <- factor(TACS_data_training$Radiation,labels=c('1','2'))
TACS_data_training$model_risk <- factor(TACS_data_training$model_risk,labels=c('1','2'))

TACS_data_validation$age <- ifelse(TACS_data_validation$age  > 50, 1, 0)
TACS_data_validation$age <- factor(TACS_data_validation$age,labels=c('1','2'))
TACS_data_validation$type <- factor(TACS_data_validation$type,labels=c('1','2','3','4'))
TACS_data_validation$size <- factor(TACS_data_validation$size,labels=c('1','2','3'))
TACS_data_validation$lym <- factor(TACS_data_validation$lym,labels=c('1','2', '3'))
TACS_data_validation$stage <- factor(TACS_data_validation$stage,labels=c('1','2','3'))
TACS_data_validation$grade <- factor(TACS_data_validation$grade,labels=c('1','2','3'))
TACS_data_validation$Chemotherapy <- factor(TACS_data_validation$Chemotherapy,labels=c('1','2'))
TACS_data_validation$Radiation <- factor(TACS_data_validation$Radiation,labels=c('1','2'))
TACS_data_validation$model_risk <- factor(TACS_data_validation$model_risk,labels=c('1','2'))


IGNN_data_training$age <- ifelse(IGNN_data_training$age  > 50, 1, 0)
IGNN_data_training$age <- factor(IGNN_data_training$age,labels=c('1','2'))
IGNN_data_training$type <- factor(IGNN_data_training$type,labels=c('1','2','3','4'))
IGNN_data_training$size <- factor(IGNN_data_training$size,labels=c('1','2','3'))
IGNN_data_training$lym <- factor(IGNN_data_training$lym,labels=c('1','2', '3'))
IGNN_data_training$stage <- factor(IGNN_data_training$stage,labels=c('1','2','3'))
IGNN_data_training$grade <- factor(IGNN_data_training$grade,labels=c('1','2','3'))
IGNN_data_training$Chemotherapy <- factor(IGNN_data_training$Chemotherapy,labels=c('1','2'))
IGNN_data_training$Radiation <- factor(IGNN_data_training$Radiation,labels=c('1','2'))
IGNN_data_training$model_risk <- factor(IGNN_data_training$model_risk,labels=c('1','2'))


IGNN_data_validation$age <- ifelse(IGNN_data_validation$age  > 50, 1, 0)
IGNN_data_validation$age <- factor(IGNN_data_validation$age,labels=c('1','2'))
IGNN_data_validation$type <- factor(IGNN_data_validation$type,labels=c('1','2','3','4'))
IGNN_data_validation$size <- factor(IGNN_data_validation$size,labels=c('1','2','3'))
IGNN_data_validation$lym <- factor(IGNN_data_validation$lym,labels=c('1','2', '3'))
IGNN_data_validation$stage <- factor(IGNN_data_validation$stage,labels=c('1','2','3'))
IGNN_data_validation$grade <- factor(IGNN_data_validation$grade,labels=c('1','2','3'))
IGNN_data_validation$Chemotherapy <- factor(IGNN_data_validation$Chemotherapy,labels=c('1','2'))
IGNN_data_validation$Radiation <- factor(IGNN_data_validation$Radiation,labels=c('1','2'))
IGNN_data_validation$model_risk <- factor(IGNN_data_validation$model_risk,labels=c('1','2'))

# Multivariate Cox proportional hazards regression analysis including TACS score and clinicopathological factors for DFS in training and validation cohorts. 
TACS_data_training_results <- coxph(Surv(DFS, STATUS) ~ type + size + lym + stage + grade + age + Chemotherapy + Radiation + model_risk,data = TACS_data_training) 
TACS_data_validation_results <- coxph(Surv(DFS, STATUS) ~ type + size + lym + stage + grade + age + Chemotherapy + Radiation + model_risk,data = TACS_data_validation) 
summary(TACS_data_training_results)
summary(TACS_data_validation_results)

# Multivariate Cox proportional hazards regression analysis including IGNN score and clinicopathological factors for DFS in training and validation cohorts. 
IGNN_data_training_results <- coxph(Surv(DFS, STATUS) ~ type + size + lym + stage + grade + age + Chemotherapy + Radiation + model_risk,data = IGNN_data_training) 
IGNN_data_validation_results <- coxph(Surv(DFS, STATUS) ~ type + size + lym + stage + grade + age + Chemotherapy + Radiation + model_risk,data = IGNN_data_validation) 
summary(IGNN_data_training_results)
summary(IGNN_data_validation_results)


