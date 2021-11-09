# library(timeROC)
# library(ggplot2)
# library(risksetROC)
# library(openxlsx)
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
require_library("timeROC")
require_library("ggplot2")
require_library("risksetROC")
require_library("openxlsx")


windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))


dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_2/Figure_2.xlsx")


# Computer distribution of iAUC for prognostic model
iAUC_analysis <- function(pbc_data,model_name){

  DFS <- as.numeric(pbc_data$DFS);
  STATUS <- as.numeric(pbc_data$STATUS);

  model_score <- as.numeric(pbc_data$model_score);
  model_risk <- as.numeric(pbc_data$model_risk);
  
  iAUC_data <- array()
  for (i in 1:1000){
    select.index <- sample(1:nrow(pbc_data), nrow(pbc_data), replace  = T) # bootstrap sampling
    select.index <- sort(unique(select.index))
    s_pbc <- pbc_data[select.index,]
    s_DFS <- DFS[select.index]
    s_STATUS <- STATUS[select.index]
    s_model_score <- model_score[select.index]
    s_model_risk <- model_risk[select.index]

    s_Surv_prob <- survfit(Surv(s_DFS,s_STATUS)~1)$surv
    s_utimes <- unique( s_DFS[s_DFS >= 24] )
    s_utimes <- s_utimes[ order(s_utimes) ]
    
    s_AUC <- rep( NA, length(s_utimes) )
    for( j in 1:length(s_utimes) ){
      s_out <- timeROC(T=s_DFS, delta=s_STATUS, marker=s_model_score,cause=1,weighting="cox",times=c(s_utimes[j]),iid=FALSE)
      s_AUC[j] <- ifelse(is.na(s_out$AUC[[2]]), 0, s_out$AUC[[2]])
    }
    
    iAUC_data[i] <- IntegrateAUC( s_AUC[1:length(s_AUC)], s_utimes[1:length(s_utimes)], s_Surv_prob[1:length(s_Surv_prob)], tmax=360) # iAUC measured with Time-dependent AUC analysis
  }
  
  group <- ifelse(iAUC_data !="NA", model_name, "NA")
  iAUCs <- data.frame(iAUC_data, group)
  names(iAUCs)[names(iAUCs) == 'iAUC_data'] <- 'iAUC';
  names(iAUCs)[names(iAUCs) == 'group'] <- 'Models'

  return (iAUCs)

}

# iAUC panel drawing, iAUC panel show the distribution of iAUC for different prognostic models
iAUC_panel <- function(TACS_iAUCs, Nomogram_iAUCs, IGNN_iAUCs, IGNNE_iAUCs, scale_y_lower, scale_y_upper){

  iAUCs<-rbind(TACS_iAUCs, Nomogram_iAUCs, IGNN_iAUCs, IGNNE_iAUCs)

  panel<-ggplot(iAUCs,aes(x=Models, y=iAUC, fill=Models))+
            stat_boxplot(geom = "errorbar",width=0.35)+
            geom_boxplot(width=0.4)+
            scale_fill_manual(values=c("lightgreen","#E18727FF", "#0072B5FF", "#BC3C29FF")) +
            theme_minimal()+
            scale_y_continuous(limits=c(scale_y_lower,scale_y_upper), breaks=seq(scale_y_lower,scale_y_upper,0.05))+
            theme(legend.position="none",
                  legend.text = element_text(size=35),
                  legend.key= element_blank(),
                  axis.line = element_line(colour = "black", size=1.0),
                  axis.title.x = element_blank(),
                  axis.title.y = element_blank(),
                  axis.text.x = element_blank(),
                  axis.text.y = element_text(size=40),
                  plot.title = element_text(size =40))

  return(panel)
}



# Training (n=731) 
TACS_data_training <- read.xlsx( Data_file , sheet = "TACS_training_cohort")
Nomogram_data_training <- read.xlsx( Data_file , sheet = "Nomogram_training_cohort")
IGNN_data_training <- read.xlsx( Data_file , sheet = "IGNN_training_cohort")
IGNNE_data_training <- read.xlsx( Data_file , sheet = "IGNNE_training_cohort")
TACS_iAUCs <- iAUC_analysis(TACS_data_training, "model1_TACS")
Nomogram_iAUCs <- iAUC_analysis(Nomogram_data_training, "model2_Nomogram")
IGNN_iAUCs <- iAUC_analysis(IGNN_data_training, "model3_IGNN")
IGNNE_iAUCs <- iAUC_analysis(IGNNE_data_training, "model4_IGNNE")

iAUC_panel_training <- iAUC_panel(TACS_iAUCs, Nomogram_iAUCs, IGNN_iAUCs, IGNNE_iAUCs, 0.75, 0.95)


# Validation (n=264) 
TACS_data_validation <- read.xlsx( Data_file , sheet = "TACS_validation_cohort")
Nomogram_data_validation <- read.xlsx( Data_file , sheet = "Nomogram_validation_cohort")
IGNN_data_validation <- read.xlsx( Data_file , sheet = "IGNN_validation_cohort")
IGNNE_data_validation <- read.xlsx( Data_file , sheet = "IGNNE_validation_cohort")
TACS_iAUCs <- iAUC_analysis(TACS_data_validation, "model1_TACS")
Nomogram_iAUCs <- iAUC_analysis(Nomogram_data_validation, "model2_Nomogram")
IGNN_iAUCs <- iAUC_analysis(IGNN_data_validation, "model3_IGNN")
IGNNE_iAUCs <- iAUC_analysis(IGNNE_data_validation, "model4_IGNNE")

iAUC_panel_validation <- iAUC_panel(TACS_iAUCs, Nomogram_iAUCs, IGNN_iAUCs, IGNNE_iAUCs, 0.65, 0.95)



# Tumor size > 5cm (n=55) 
TACS_data_tumorsize_5cm <- subset( rbind(TACS_data_training, TACS_data_validation), size==3)
Nomogram_data_tumorsize_5cm <- subset( rbind(Nomogram_data_training, Nomogram_data_validation), size==3)
IGNN_data_tumorsize_5cm <- subset( rbind(IGNN_data_training, IGNN_data_validation), size==3)
IGNNE_data_tumorsize_5cm <- subset( rbind(IGNNE_data_training, IGNNE_data_validation), size==3)
TACS_iAUCs <- iAUC_analysis(TACS_data_tumorsize_5cm, "model1_TACS")
Nomogram_iAUCs <- iAUC_analysis(Nomogram_data_tumorsize_5cm, "model2_Nomogram")
IGNN_iAUCs <- iAUC_analysis(IGNN_data_tumorsize_5cm, "model3_IGNN")
IGNNE_iAUCs <- iAUC_analysis(IGNNE_data_tumorsize_5cm, "model4_IGNNE")

iAUC_panel_tumorsize_5cm <- iAUC_panel(TACS_iAUCs, Nomogram_iAUCs, IGNN_iAUCs, IGNNE_iAUCs, 0.60, 1.0)



# Tumor size 2-5cm (n=495) 
TACS_data_tumorsize_2to5cm <- subset( rbind(TACS_data_training, TACS_data_validation), size==2)
Nomogram_data_tumorsize_2to5cm <- subset( rbind(Nomogram_data_training, Nomogram_data_validation), size==2)
IGNN_data_tumorsize_2to5cm <- subset( rbind(IGNN_data_training, IGNN_data_validation), size==2)
IGNNE_data_tumorsize_2to5cm <- subset( rbind(IGNNE_data_training, IGNNE_data_validation), size==2)
TACS_iAUCs <- iAUC_analysis(TACS_data_tumorsize_2to5cm, "model1_TACS")
Nomogram_iAUCs <- iAUC_analysis(Nomogram_data_tumorsize_2to5cm, "model2_Nomogram")
IGNN_iAUCs <- iAUC_analysis(IGNN_data_tumorsize_2to5cm, "model3_IGNN")
IGNNE_iAUCs <- iAUC_analysis(IGNNE_data_tumorsize_2to5cm, "model4_IGNNE")

iAUC_panel_tumorsize_2to5cm <- iAUC_panel(TACS_iAUCs, Nomogram_iAUCs, IGNN_iAUCs, IGNNE_iAUCs, 0.75, 0.95)


# Tumor size <= 2cm (n=445) 
TACS_data_tumorsize_2cm <- subset( rbind(TACS_data_training, TACS_data_validation), size<=1)
Nomogram_data_tumorsize_2cm <- subset( rbind(Nomogram_data_training, Nomogram_data_validation), size<=1)
IGNN_data_tumorsize_2cm <- subset( rbind(IGNN_data_training, IGNN_data_validation), size<=1)
IGNNE_data_tumorsize_2cm <- subset( rbind(IGNNE_data_training, IGNNE_data_validation), size<=1)
TACS_iAUCs <- iAUC_analysis(TACS_data_tumorsize_2cm, "model1_TACS")
Nomogram_iAUCs <- iAUC_analysis(Nomogram_data_tumorsize_2cm, "model2_Nomogram")
IGNN_iAUCs <- iAUC_analysis(IGNN_data_tumorsize_2cm, "model3_IGNN")
IGNNE_iAUCs <- iAUC_analysis(IGNNE_data_tumorsize_2cm, "model4_IGNNE")

iAUC_panel_tumorsize_2cm <- iAUC_panel(TACS_iAUCs, Nomogram_iAUCs, IGNN_iAUCs, IGNNE_iAUCs, 0.70, 0.90)


#ggsave(iAUC_panel_training, file="Fig_2_a_3.tiff",width=20, height=6)
#ggsave(iAUC_panel_validation, file="Fig_2_a_7.tiff",width=20, height=6)
#ggsave(iAUC_panel_tumorsize_5cm, file="Fig_2_b_3.tiff",width=20, height=6)
#ggsave(iAUC_panel_tumorsize_2to5cm, file="Fig_2_b_7.tiff",width=20, height=6)
#ggsave(iAUC_panel_tumorsize_2cm, file="Fig_2_b_11.tiff",width=20, height=6)
