# library(survival)
# library(ggplot2)
# library(pec)
# library(openxlsx)
warnings('off')
set.seed(123456)


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
require_library("ggplot2")
require_library("pec")
require_library("openxlsx")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))


dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_S4/Figure_S4.xlsx")



# Computer distribution of C-index of prognostic risk for prognostic model
Cindex_analysis <- function(pbc_data,model_name){

  DFS <- as.numeric(pbc_data$DFS);
  STATUS <- as.numeric(pbc_data$STATUS);

  model_score <- as.numeric(pbc_data$model_score);
  model_risk <- as.numeric(pbc_data$model_risk);
  
  COX_Survs <- coxph( Surv(DFS,STATUS) ~ model_risk, x=T,y=T,data=pbc_data ) # survival analysis

  cindex_data <- array()
  for (i in 1:1000){
    select.index <- sample(1:nrow(pbc_data), nrow(pbc_data), replace  = T) # bootstrap sampling
    s_pbc <- pbc_data[select.index,]
    s_pbc <- transform(s_pbc,sample= order(nrow(s_pbc)))
    s_DFS <- DFS[select.index]
    s_STATUS <- STATUS[select.index]
    s_model_score <- model_score[select.index]
    s_model_risk <- model_risk[select.index]
    
    s_cindex  <- cindex( list("Model" = COX_Survs),   # Compute the Cindex from subset samples           
                         formula=Surv(s_DFS,s_STATUS ==1)~s_model_risk,
                         data=s_pbc,
                         eval.times=60,
                         splitMethod="cv",
                         B=1)
    cindex_data[i] <- s_cindex$AppCindex[[1]]
  }
  
  group <- ifelse(cindex_data !="NA", model_name, "NA")
  Cindexs <- data.frame(cindex_data, group)
  names(Cindexs)[names(Cindexs) == 'cindex_data'] <- 'Cindex';
  names(Cindexs)[names(Cindexs) == 'group'] <- 'Models'

  return (Cindexs)

}

# Cindex panel drawing, Cindex panel show the distribution of C-index for different prognostic models
Cindex_panel <- function(TACS_Cindexs, Nomogram_Cindexs, IGNN_Cindexs, IGNNE_Cindexs, scale_y_lower, scale_y_upper){

  Cindexs<-rbind(TACS_Cindexs, Nomogram_Cindexs, IGNN_Cindexs, IGNNE_Cindexs)
  
  panel<-ggplot(Cindexs,aes(x=Models, y=Cindex, fill=Models))+ 
            stat_boxplot(geom = "errorbar",width=0.3, size = 1.5, color = "gray50")+
            geom_boxplot(width=0.4)+ 
            scale_fill_manual(values=c("lightgreen","#E18727FF", "#0072B5FF", "#BC3C29FF")) +  
            theme_minimal()+
            scale_y_continuous(limits=c(scale_y_lower,scale_y_upper), breaks=seq(scale_y_lower,scale_y_upper,0.05))+
            theme(legend.position="none",
                  legend.text = element_text(size=30),
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
TACS_Cindexs <- Cindex_analysis(TACS_data, "model1_TACS")


# pre-validation with 3-cross validation for Nomogram model on training cohort (n=731) 
Nomogram_data_fold1 <- read.xlsx( Data_file , sheet = "Nomogram_fold1")
Nomogram_data_fold2 <- read.xlsx( Data_file , sheet = "Nomogram_fold2")
Nomogram_data_fold3 <- read.xlsx( Data_file , sheet = "Nomogram_fold3")
Nomogram_data <- rbind(Nomogram_data_fold1, Nomogram_data_fold2, Nomogram_data_fold3)
Nomogram_Cindexs <- Cindex_analysis(Nomogram_data, "model2_Nomogram")


# pre-validation with 3-cross validation for IGNN model on training cohort (n=731) 
IGNN_data_fold1 <- read.xlsx( Data_file , sheet = "IGNN_fold1")
IGNN_data_fold2 <- read.xlsx( Data_file , sheet = "IGNN_fold2")
IGNN_data_fold3 <- read.xlsx( Data_file , sheet = "IGNN_fold3")
IGNN_data <- rbind(IGNN_data_fold1, IGNN_data_fold2, IGNN_data_fold3)
IGNN_Cindexs <- Cindex_analysis(IGNN_data, "model3_IGNN")


# pre-validation with 3-cross validation for IGNNE model on training cohort (n=731) 
IGNNE_data_fold1 <- read.xlsx( Data_file , sheet = "IGNNE_fold1")
IGNNE_data_fold2 <- read.xlsx( Data_file , sheet = "IGNNE_fold2")
IGNNE_data_fold3 <- read.xlsx( Data_file , sheet = "IGNNE_fold3")
IGNNE_data <- rbind(IGNNE_data_fold1, IGNNE_data_fold2, IGNNE_data_fold3)
IGNNE_Cindexs <- Cindex_analysis(IGNNE_data, "model4_IGNNE")

Cindex_panel_pre_validation <- Cindex_panel(TACS_Cindexs, Nomogram_Cindexs, IGNN_Cindexs, IGNNE_Cindexs, 0.65, 0.85)


# JPG<- ggpubr::ggarrange(Cindex_panel_pre_validation, nrow = 1, ncol = 1)
# ggsave(JPG, file="Figure_S4_b_1.emf",width=7.0, height=6.5)




