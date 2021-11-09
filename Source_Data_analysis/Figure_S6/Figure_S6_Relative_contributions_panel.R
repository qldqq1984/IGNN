library(ggplot2)
library(survminer)
library(rms)
library(openxlsx)
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
require_library("ggplot2")
require_library("rms")
require_library("survminer")
require_library("openxlsx")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))

dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_S6/Figure_S6.xlsx")



# Training (n=731) 
TACS_data_training <- read.xlsx( Data_file , sheet = "TACS_training_cohort")
TACS_data_training$age <- ifelse(TACS_data_training$age  > 50, 1, 0)
IGNN_data_training <- read.xlsx( Data_file , sheet = "IGNN_training_cohort")
IGNN_data_training$age <- ifelse(IGNN_data_training$age  > 50, 1, 0)


# survival analysis for clinical factors on training cohort
Clinical_COX_Survs_training <- cph(Surv(DFS, STATUS) ~ size + type + lym + stage + grade + age + Chemotherapy + Radiation, data = TACS_data_training) 
# Relative contributions of biomarkers in predicting DFS of patients according to survival analysis
Clinical_training_plot <- plot(anova(Clinical_COX_Survs_training), what='proportion chisq') 


# survival analysis for clinical factors plus TACS score on training cohort
TACS_COX_Survs_training <- cph(Surv(DFS, STATUS) ~ size + type + lym + stage + grade + age + Chemotherapy + Radiation + model_risk, data = TACS_data_training) 
# Relative contributions of biomarkers in predicting DFS of patients according to survival analysis
TACS_training_plot <- plot(anova(TACS_COX_Survs_training), what='proportion chisq') 


# survival analysis for clinical factors plus TACS score on validation cohort
IGNN_COX_Survs_training <- cph(Surv(DFS, STATUS) ~ size + type + lym + stage + grade + age + Chemotherapy + Radiation + model_risk, data = IGNN_data_training) 
# Relative contributions of biomarkers in predicting DFS of patients according to survival analysis
IGNN_training_plot <- plot(anova(IGNN_COX_Survs_training), what='proportion chisq') 




# Validation (n=264) 
TACS_data_validation <- read.xlsx( Data_file , sheet = "TACS_validation_cohort")
TACS_data_validation$age <- ifelse(TACS_data_validation$age  > 50, 1, 0)

IGNN_data_validation <- read.xlsx( Data_file , sheet = "IGNN_validation_cohort")
IGNN_data_validation$age <- ifelse(IGNN_data_validation$age  > 50, 1, 0)


# survival analysis for clinical factors on validation cohort
Clinical_COX_Survs_validation <- cph(Surv(DFS, STATUS) ~ size + type + lym + stage + grade + age + Chemotherapy + Radiation, data = TACS_data_validation) 
# Relative contributions of biomarkers in predicting DFS of patients according to survival analysis
Clinical_validation_plot <- plot(anova(Clinical_COX_Survs_validation), what='proportion chisq') 


# survival analysis for clinical factors plus TACS score on validation cohort
TACS_COX_Survs_validation <- cph(Surv(DFS, STATUS) ~ size + type + lym + stage + grade + age + Chemotherapy + Radiation + model_risk, data = TACS_data_validation) 
# Relative contributions of biomarkers in predicting DFS of patients according to survival analysis
TACS_validation_plot <- plot(anova(TACS_COX_Survs_validation), what='proportion chisq') 


# survival analysis for clinical factors plus TACS score on validation cohort
IGNN_COX_Survs_validation <- cph(Surv(DFS, STATUS) ~ size + type + lym + stage + grade + age + Chemotherapy + Radiation + model_risk, data = IGNN_data_validation) 
# Relative contributions of biomarkers in predicting DFS of patients according to survival analysis
IGNN_validation_plot <- plot(anova(IGNN_COX_Survs_validation), what='proportion chisq') 
