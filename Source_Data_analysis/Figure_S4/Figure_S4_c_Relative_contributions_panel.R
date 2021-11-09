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
require_library("openxlsx")
require_library("rms")


windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))

dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_S4/Figure_S4.xlsx")


Patient_information <-  read.xlsx( Data_file , sheet = "Patient_information")
   
# pre-validation with 3-cross validation for TACS model on training cohort (n=731) 
TACS_data_fold1 <- read.xlsx( Data_file , sheet = "TACS_fold1")
TACS_data_fold2 <- read.xlsx( Data_file , sheet = "TACS_fold2")
TACS_data_fold3 <- read.xlsx( Data_file , sheet = "TACS_fold3")
TACS_data <- rbind(TACS_data_fold1, TACS_data_fold2, TACS_data_fold3)
TACS_information <- Patient_information[TACS_data$id, c(5:17)]
TACS_data_information <- cbind(TACS_data, TACS_information)
TACS_data_information$age <- ifelse(TACS_data_information$age  > 50, 1, 0)

# survival analysis
TACS_COX_Survs <- cph(Surv(DFS, STATUS) ~ size + type + lym + stage + grade + age + Chemotherapy + Radiation + model_risk,data = TACS_data_information) 
# Relative contributions of biomarkers in predicting DFS of patients according to survival analysis
TACS_plot <- plot(anova(TACS_COX_Survs), what='proportion chisq') 


# pre-validation with 3-cross validation for IGNN model on training cohort (n=731) 
IGNN_data_fold1 <- read.xlsx( Data_file , sheet = "IGNN_fold1")
IGNN_data_fold2 <- read.xlsx( Data_file , sheet = "IGNN_fold2")
IGNN_data_fold3 <- read.xlsx( Data_file , sheet = "IGNN_fold3")
IGNN_data <- rbind(IGNN_data_fold1, IGNN_data_fold2, IGNN_data_fold3)
IGNN_information <- Patient_information[IGNN_data$id, c(5:17)]
IGNN_data_information <- cbind(IGNN_data, IGNN_information)
IGNN_data_information$age <- ifelse(IGNN_data_information$age  > 50, 1, 0)

# survival analysis
IGNN_COX_Survs <- cph(Surv(DFS, STATUS) ~ size + type + lym + stage + grade + age + Chemotherapy + Radiation + model_risk,data = IGNN_data_information) 
# Relative contributions of biomarkers in predicting DFS of patients according to survival analysis
IGNN_plot <- plot(anova(IGNN_COX_Survs), what='proportion chisq') 
