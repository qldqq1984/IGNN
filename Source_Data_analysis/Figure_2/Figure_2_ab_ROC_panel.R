# library(survival)
# library(timeROC)
# library(ggplot2)
# library(risksetROC)
# library(openxlsx)
# library(plotROC)
warnings('off')
set.seed(1)

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
require_library("timeROC")
require_library("risksetROC")
require_library("openxlsx")
require_library("plotROC")


windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))


dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_2/Figure_2.xlsx")


# Computer ROC curves with associated AUC  for prognostic model
ROC_analysis <- function(pbc_data,model_name){

  DFS <- as.numeric(pbc_data$DFS);
  STATUS <- as.numeric(pbc_data$STATUS);
  Y <- as.numeric(pbc_data$y);

  model_score <- as.numeric(pbc_data$model_score);
  model_risk <- as.numeric(pbc_data$model_risk);

  ROC_info <- {}
  ROC_info$data <- data.frame(Y, model_score)
  score <- timeROC(T=DFS, delta=STATUS, marker=model_score, cause=1, weighting="marginal",times=60,iid=TRUE)
  ROC_info$AUC_value <- score$AUC[2]
  ROC_info$AUC_ci_lower <- confint(score)$CI_AUC[1] / 100
  ROC_info$AUC_ci_upper<- confint(score)$CI_AUC[2] / 100

  return (ROC_info)

}

# ROC panel drawing, ROC panel show the ROC curves with associated AUC comparison between different models
ROC_panel <- function(TACS_ROC, Nomogram_ROC, IGNN_ROC, IGNNE_ROC){

  AUC_legends <-c("TACS1-8"= "lightgreen" ,"Nomogram" = "#E18727FF" ,"IGNN" = "#0072B5FF","IGNN-E" = "#BC3C29FF")
  AUC1_legends <- sprintf( "TACS1-8 [AUC: %s]\n", format(TACS_ROC$AUC_value, digits = 3, nsmall = 3))
  AUC2_legends <- sprintf( "Nomogram [AUC: %s]\n", format(Nomogram_ROC$AUC_value, digits = 3, nsmall = 3))
  AUC3_legends <- sprintf( "IGNN [AUC: %s]\n", format(IGNN_ROC$AUC_value, digits = 3, nsmall = 3))
  AUC4_legends <- sprintf( "IGNN-E [AUC: %s]\n", format(IGNNE_ROC$AUC_value, digits = 3, nsmall = 3))
  
  names(AUC_legends)[1] <- AUC1_legends
  names(AUC_legends)[2] <- AUC2_legends
  names(AUC_legends)[3] <- AUC3_legends
  names(AUC_legends)[4] <- AUC4_legends
  
  scaleFUN <- function(x) sprintf("%.1f", x) 
  
  panel<-ggplot(digits = 1)+
            geom_roc(data=TACS_ROC$data, aes(m = model_score, d = Y, color = AUC1_legends),n.cuts=0, size=1.5)+
            geom_roc(data=Nomogram_ROC$data, aes(m = model_score, d = Y, color = AUC2_legends),n.cuts=0, size=1.5)+
            geom_roc(data=IGNN_ROC$data, aes(m = model_score, d = Y, color = AUC3_legends),n.cuts=0, size=1.5)+
            geom_roc(data=IGNNE_ROC$data, aes(m = model_score, d = Y, color = AUC4_legends),n.cuts=0, size=1.5)+
            scale_color_manual("",values = AUC_legends)+
            guides(col = guide_legend(reverse = TRUE))+
            scale_x_continuous(breaks = seq(0, 1.0, 0.2), labels = scaleFUN ,limits = c(0,1.0 ) ) +
            scale_y_continuous(breaks = seq(0, 1.0, 0.2), labels = scaleFUN ,limits = c(0,1.0 ) ) +
            theme_minimal()+
            theme(text=element_text(family="ARL"),
                  axis.line = element_line(colour = "black", size=1.0),
                  axis.title.x=element_text(size=30),
                  axis.title.y=element_text(size=30),
                  axis.text.x = element_text(size=35,  margin=margin(10,10,10,10)),
                  axis.text.y = element_text(size=35,  margin=margin(10,10,10,10)),
                  plot.title = element_text(size =30),
                  legend.background = element_blank(),
                  legend.position = c(0.55,0.2),
                  legend.key= element_blank(),
                  legend.text = element_text(size=30,margin=margin(-10,0,-10,0)))+
            
            labs(x="1-Specificity",
                 y="Sensitivity",
                 title=" ")

  return(panel)
}



# Training (n=731) 
TACS_data_training <- read.xlsx( Data_file , sheet = "TACS_training_cohort")
Nomogram_data_training <- read.xlsx( Data_file , sheet = "Nomogram_training_cohort")
IGNN_data_training <- read.xlsx( Data_file , sheet = "IGNN_training_cohort")
IGNNE_data_training <- read.xlsx( Data_file , sheet = "IGNNE_training_cohort")
TACS_ROC <- ROC_analysis(TACS_data_training, "model1_TACS")
Nomogram_ROC <- ROC_analysis(Nomogram_data_training, "model2_Nomogram")
IGNN_ROC <- ROC_analysis(IGNN_data_training, "model3_IGNN")
IGNNE_ROC <- ROC_analysis(IGNNE_data_training, "model4_IGNNE")

ROC_panel_training <- ROC_panel(TACS_ROC, Nomogram_ROC, IGNN_ROC, IGNNE_ROC)


# Validation (n=264) 
TACS_data_validation <- read.xlsx( Data_file , sheet = "TACS_validation_cohort")
Nomogram_data_validation <- read.xlsx( Data_file , sheet = "Nomogram_validation_cohort")
IGNN_data_validation <- read.xlsx( Data_file , sheet = "IGNN_validation_cohort")
IGNNE_data_validation <- read.xlsx( Data_file , sheet = "IGNNE_validation_cohort")
TACS_ROC <- ROC_analysis(TACS_data_validation, "model1_TACS")
Nomogram_ROC <- ROC_analysis(Nomogram_data_validation, "model2_Nomogram")
IGNN_ROC <- ROC_analysis(IGNN_data_validation, "model3_IGNN")
IGNNE_ROC <- ROC_analysis(IGNNE_data_validation, "model4_IGNNE")

ROC_panel_validation <- ROC_panel(TACS_ROC, Nomogram_ROC, IGNN_ROC, IGNNE_ROC)



# Tumor size > 5cm (n=55) 
TACS_data_tumorsize_5cm <- subset( rbind(TACS_data_training, TACS_data_validation), size==3)
Nomogram_data_tumorsize_5cm <- subset( rbind(Nomogram_data_training, Nomogram_data_validation), size==3)
IGNN_data_tumorsize_5cm <- subset( rbind(IGNN_data_training, IGNN_data_validation), size==3)
IGNNE_data_tumorsize_5cm <- subset( rbind(IGNNE_data_training, IGNNE_data_validation), size==3)
TACS_ROC <- ROC_analysis(TACS_data_tumorsize_5cm, "model1_TACS")
Nomogram_ROC <- ROC_analysis(Nomogram_data_tumorsize_5cm, "model2_Nomogram")
IGNN_ROC <- ROC_analysis(IGNN_data_tumorsize_5cm, "model3_IGNN")
IGNNE_ROC <- ROC_analysis(IGNNE_data_tumorsize_5cm, "model4_IGNNE")

ROC_panel_tumorsize_5cm <- ROC_panel(TACS_ROC, Nomogram_ROC, IGNN_ROC, IGNNE_ROC)


# Tumor size 2-5cm (n=495) 
TACS_data_tumorsize_2to5cm <- subset( rbind(TACS_data_training, TACS_data_validation), size==2)
Nomogram_data_tumorsize_2to5cm <- subset( rbind(Nomogram_data_training, Nomogram_data_validation), size==2)
IGNN_data_tumorsize_2to5cm <- subset( rbind(IGNN_data_training, IGNN_data_validation), size==2)
IGNNE_data_tumorsize_2to5cm <- subset( rbind(IGNNE_data_training, IGNNE_data_validation), size==2)
TACS_ROC <- ROC_analysis(TACS_data_tumorsize_2to5cm, "model1_TACS")
Nomogram_ROC <- ROC_analysis(Nomogram_data_tumorsize_2to5cm, "model2_Nomogram")
IGNN_ROC <- ROC_analysis(IGNN_data_tumorsize_2to5cm, "model3_IGNN")
IGNNE_ROC <- ROC_analysis(IGNNE_data_tumorsize_2to5cm, "model4_IGNNE")

ROC_panel_tumorsize_2to5cm <- ROC_panel(TACS_ROC, Nomogram_ROC, IGNN_ROC, IGNNE_ROC)


# Tumor size <= 2cm (n=445) 
TACS_data_tumorsize_2cm <- subset( rbind(TACS_data_training, TACS_data_validation), size<=1)
Nomogram_data_tumorsize_2cm <- subset( rbind(Nomogram_data_training, Nomogram_data_validation), size<=1)
IGNN_data_tumorsize_2cm <- subset( rbind(IGNN_data_training, IGNN_data_validation), size<=1)
IGNNE_data_tumorsize_2cm <- subset( rbind(IGNNE_data_training, IGNNE_data_validation), size<=1)
TACS_ROC <- ROC_analysis(TACS_data_tumorsize_2cm, "model1_TACS")
Nomogram_ROC <- ROC_analysis(Nomogram_data_tumorsize_2cm, "model2_Nomogram")
IGNN_ROC <- ROC_analysis(IGNN_data_tumorsize_2cm, "model3_IGNN")
IGNNE_ROC <- ROC_analysis(IGNNE_data_tumorsize_2cm, "model4_IGNNE")

ROC_panel_tumorsize_2cm <- ROC_panel(TACS_ROC, Nomogram_ROC, IGNN_ROC, IGNNE_ROC)


#ggsave(ROC_panel_training, file="Fig_2_a_4.tiff",width=20, height=6)
#ggsave(ROC_panel_validation, file="Fig_2_a_78.tiff",width=20, height=6)
#ggsave(ROC_panel_tumorsize_5cm, file="Fig_2_b_4.tiff",width=20, height=6)
#ggsave(ROC_panel_tumorsize_2to5cm, file="Fig_2_b_8.tiff",width=20, height=6)
#ggsave(ROC_panel_tumorsize_2cm, file="Fig_2_b_12.tiff",width=20, height=6)
