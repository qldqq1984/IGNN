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
Data_file = paste0(dir_root,"/Souce Data/Figure_S4/Figure_S4.xlsx")



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
      s_out <- timeROC(T=s_DFS, delta=s_STATUS, marker=s_model_risk, cause=1,weighting="cox",times=c(s_utimes[j]),iid=FALSE)
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

# pre-validation with 3-cross validation for TACS model on training cohort (n=731) 
TACS_data_fold1 <- read.xlsx( Data_file , sheet = "TACS_fold1")
TACS_data_fold2 <- read.xlsx( Data_file , sheet = "TACS_fold2")
TACS_data_fold3 <- read.xlsx( Data_file , sheet = "TACS_fold3")
TACS_data <- rbind(TACS_data_fold1, TACS_data_fold2, TACS_data_fold3)
TACS_iAUCs <- iAUC_analysis(TACS_data, "model1_TACS")


# pre-validation with 3-cross validation for Nomogram model on training cohort (n=731) 
Nomogram_data_fold1 <- read.xlsx( Data_file , sheet = "Nomogram_fold1")
Nomogram_data_fold2 <- read.xlsx( Data_file , sheet = "Nomogram_fold2")
Nomogram_data_fold3 <- read.xlsx( Data_file , sheet = "Nomogram_fold3")
Nomogram_data <- rbind(Nomogram_data_fold1, Nomogram_data_fold2, Nomogram_data_fold3)
Nomogram_iAUCs <- iAUC_analysis(Nomogram_data, "model2_Nomogram")


# pre-validation with 3-cross validation for IGNN model on training cohort (n=731) 
IGNN_data_fold1 <- read.xlsx( Data_file , sheet = "IGNN_fold1")
IGNN_data_fold2 <- read.xlsx( Data_file , sheet = "IGNN_fold2")
IGNN_data_fold3 <- read.xlsx( Data_file , sheet = "IGNN_fold3")
IGNN_data <- rbind(IGNN_data_fold1, IGNN_data_fold2, IGNN_data_fold3)
IGNN_iAUCs <- iAUC_analysis(IGNN_data, "model3_IGNN")


# pre-validation with 3-cross validation for IGNNE model on training cohort (n=731) 
IGNNE_data_fold1 <- read.xlsx( Data_file , sheet = "IGNNE_fold1")
IGNNE_data_fold2 <- read.xlsx( Data_file , sheet = "IGNNE_fold2")
IGNNE_data_fold3 <- read.xlsx( Data_file , sheet = "IGNNE_fold3")
IGNNE_data <- rbind(IGNNE_data_fold1, IGNNE_data_fold2, IGNNE_data_fold3)
IGNNE_iAUCs <- iAUC_analysis(IGNNE_data, "model4_IGNNE")

iAUC_panel_pre_validation <- iAUC_panel(TACS_iAUCs, Nomogram_iAUCs, IGNN_iAUCs, IGNNE_iAUCs, 0.70, 0.85)


JPG<- ggpubr::ggarrange(iAUC_panel_pre_validation, nrow = 1, ncol = 1)
ggsave(JPG, file="Figure_S4_b_2.emf",width=7.0, height=6.5)

