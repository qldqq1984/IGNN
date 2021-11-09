# library(ggplot2)
# library(survminer)
# library(rms)
# library(openxlsx)
warnings('off')


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
require_library("survminer")
require_library("rms")
require_library("openxlsx")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))

dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_2/Figure_2.xlsx")



TACS_data_training <- read.xlsx( Data_file , sheet = "TACS_training_cohort")
IGNN_data_training <- read.xlsx( Data_file , sheet = "IGNN_training_cohort")
TACS_data_validation <- read.xlsx( Data_file , sheet = "TACS_validation_cohort")
IGNN_data_validation <- read.xlsx( Data_file , sheet = "IGNN_validation_cohort")

# Tumor size <= 2cm (n=445) 
TACS_data_tumorsize_2cm <- subset( rbind(TACS_data_training, TACS_data_validation), size<=1)
TACS_data_tumorsize_2cm$age <- ifelse(TACS_data_tumorsize_2cm$age  > 50, 1, 0)

IGNN_data_tumorsize_2cm <- subset( rbind(IGNN_data_training, IGNN_data_validation), size<=1)
IGNN_data_tumorsize_2cm$age <- ifelse(IGNN_data_tumorsize_2cm$age  > 50, 1, 0)


# survival analysis
Clinical_COX_Survs <- cph(Surv(DFS, STATUS) ~ type + lym + stage + grade + age + Chemotherapy + Radiation, data = TACS_data_tumorsize_2cm) 
# Relative contributions of biomarkers in predicting DFS of patients according to survival analysis
Clinical_plot <- plot(anova(Clinical_COX_Survs), what='proportion chisq') 


# survival analysis
TACS_COX_Survs <- cph(Surv(DFS, STATUS) ~ type + lym + stage + grade + age + Chemotherapy + Radiation + model_risk, data = TACS_data_tumorsize_2cm) 
# Relative contributions of biomarkers in predicting DFS of patients according to survival analysis
TACS_plot <- plot(anova(TACS_COX_Survs), what='proportion chisq') 


# survival analysis
IGNN_COX_Survs <- cph(Surv(DFS, STATUS) ~ type + lym + stage + grade + age + Chemotherapy + Radiation + model_risk, data = IGNN_data_tumorsize_2cm) 
# Relative contributions of biomarkers in predicting DFS of patients according to survival analysis
IGNN_plot <- plot(anova(IGNN_COX_Survs), what='proportion chisq') 
