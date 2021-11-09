# library(ggplot2)
# library(survival)
# library(survminer)
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
require_library("survival")
require_library("ggplot2")
require_library("survminer")
require_library("openxlsx")


windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))

dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_3/Figure_3.xlsx")


# HR measured with the low or high risk stratified by prognostic models in survival analysis
Survival_analysis <- function(pbc_data){

   DFS <- as.numeric(pbc_data$DFS);
   STATUS <- as.numeric(pbc_data$STATUS);
   
   model_score <- as.numeric(pbc_data$model_score);
   model_risk <- as.numeric(pbc_data$model_risk); 

   fit <- surv_fit(Surv(DFS, STATUS) ~ model_risk, data = pbc_data )    
   COX_Survs <- coxph(Surv(DFS, STATUS) ~ model_risk, data = pbc_data ) # survival analysis
   
   x<- summary(COX_Survs)
   wald.test <- x$waldtest["test"]

   HR <- {}   
   HR$fit <- fit
   HR$pbc_data <- pbc_data
   HR$value <- round(x$coef[2], 2) # hazard ratio
   HR$pvalue <- round(x$waldtest["pvalue"], 2) # p value
   HR$ci_lower <- round(x$conf.int[,"lower .95"],2) # lower boundaries of 95% CI
   HR$ci_upper <- round(x$conf.int[,"upper .95"],2) # upper boundaries of 95% CI 
   HR$info <- paste0( HR$value, " (95% CI ", HR$ci_lower, "-", HR$ci_upper, ")")

   return (HR)
   
}

# KM panel drawing, KM panel show the  Kaplan-Meier survival curves for different prognostic models
KM_panel <- function(HR_results, model_type){

   gg_theme<-list()
   gg_theme[[1]] <- theme(text=element_text(family="ARL"),
                          axis.line = element_line(colour = "black", size=1.0),
                          axis.title.x= element_text(size=20),
                          axis.title.y= element_text(size=20),
                          axis.text.x = element_text(size=20),
                          axis.text.y = element_text(size=20),
                          plot.title = element_text(size =20),
                          legend.key=element_blank(),
                          legend.text = element_text(size=20))

   panel <- ggsurvplot(HR_results$fit, data = HR_results$pbc_data, 
                            conf.int = TRUE,
                            linetype = c('solid', 'solid'),
                            palette = c("#0072B5FF", "#BC3C29FF") ,
                            pval =  paste("p<0.0001\n","HR:",HR_results$info) ,
                            pval.coord = c(1.5,10.5),
                            pval.size = 6,
                            risk.table = T, 
                            tables.theme = theme_cleantable(),
                            risk.table.fontsize = 6,
                            tables.y.text = F,
                            legend.title = c("  "),
                            title = "",
                            subtitle = model_type,
                            font.title= c(20, "bold", "black"), 
                            font.subtitle= c(20, "black"), 
                            legend = "none",
                            xlab="Time(month)",
                            ylab="DFS(%)",
                            fun = 'pct',
                            censor= T,
                            ggtheme = gg_theme[[1]])   
   return(panel)
}   

information_training_cohort <- read.xlsx( Data_file , sheet = "information_training_cohort")
information_validation_cohort <- read.xlsx( Data_file , sheet = "information_validation_cohort")
information <- subset( rbind(information_training_cohort, information_validation_cohort))

type <- as.numeric(information$type);
size <- as.numeric(information$size);
lym <- as.numeric(information$lym);
stage <- as.numeric(information$stage);
grade <- as.numeric(information$grade);
age <- as.numeric(information$age);
ER <- as.numeric(information$ER);
PR <- as.numeric(information$PR);
HER2 <- as.numeric(information$HER2);

# guideline-defined low, moderate and high risk
guideline_low_risk = as.numeric( (lym==0) & (size==1) & (grade==1) & ((ER==1)|(PR==1) ) &  (HER2==0) & (age>=35) );
guideline_moderate_risk1 = (lym==0) & ( (size>1)|(grade>1)|( (ER==0)&(PR==0) )|(HER2==1)|(age<35) );
guideline_moderate_risk2 = (lym==1) & ( (HER2==0) & ( (ER==1)|(PR==1) ) );
guideline_moderate_risk = as.numeric( guideline_moderate_risk1|guideline_moderate_risk2 );
guideline_high_risk1 = (lym==1) & (  (HER2==1) | ( (ER==0) &(PR==0) )  );
guideline_high_risk2 = (lym==2);
guideline_high_risk = as.numeric( guideline_high_risk1|guideline_high_risk2 );

# TACS Model prediction for the patient groups with guideline-defined low/moderate or high risk
TACS_data_training <- read.xlsx( Data_file , sheet = "TACS_training_cohort")
TACS_data_validation <- read.xlsx( Data_file , sheet = "TACS_validation_cohort")
TACS_data <- subset( rbind(TACS_data_training, TACS_data_validation))
TACS_data_with_guideline_low_moderate_risk <- TACS_data[(guideline_low_risk==1 ) |(guideline_moderate_risk==1),];
TACS_data_with_guideline_high_risk <- TACS_data[guideline_high_risk==1,];


# IGNN Model prediction for the patient groups with guideline-defined low/moderate or high risk
IGNN_data_training <- read.xlsx( Data_file , sheet = "IGNN_training_cohort")
IGNN_data_validation <- read.xlsx( Data_file , sheet = "IGNN_validation_cohort")
IGNN_data <- subset( rbind(IGNN_data_training, IGNN_data_validation))
IGNN_data_with_guideline_low_moderate_risk <- IGNN_data[(guideline_low_risk==1 ) |(guideline_moderate_risk==1),];
IGNN_data_with_guideline_high_risk <- IGNN_data[guideline_high_risk==1,];



# guideline-defined low/moderate risk (n=626) 
TACS_data_with_guideline_low_moderate_risk_results <- Survival_analysis(TACS_data_with_guideline_low_moderate_risk) # survival analysis for TACS model on patient groups with guideline-defined low/moderate risk
TACS_data_with_guideline_low_moderate_risk_KM_panel <- KM_panel(TACS_data_with_guideline_low_moderate_risk_results, "TACS1-8")
IGNN_data_with_guideline_low_moderate_risk_results <- Survival_analysis(IGNN_data_with_guideline_low_moderate_risk) # survival analysis for IGNN model on patient groups with guideline-defined low/moderate risk
IGNN_data_with_guideline_low_moderate_risk_KM_panel <- KM_panel(IGNN_data_with_guideline_low_moderate_risk_results, "IGNN")


# guideline-defined high risk (n=369) 
TACS_data_with_guideline_high_risk_results <- Survival_analysis(TACS_data_with_guideline_high_risk) # survival analysis for TACS model on patient groups with guideline-defined high risk 
TACS_data_with_guideline_high_risk_KM_panel <- KM_panel(TACS_data_with_guideline_high_risk_results , "TACS1-8")
IGNN_data_with_guideline_high_risk_results <- Survival_analysis(IGNN_data_with_guideline_high_risk) # survival analysis for IGNN model on patient groups with guideline-defined high risk
IGNN_data_with_guideline_high_risk_KM_panel <- KM_panel(IGNN_data_with_guideline_high_risk_results , "IGNN")


# Tumor size <= 2cm (n=445) 
TACS_data_tumorsize_2cm <- subset( rbind(TACS_data_training, TACS_data_validation), size<=1)
TACS_data_tumorsize_2cm_results <- Survival_analysis(TACS_data_tumorsize_2cm) # survival analysis for TACS model on patient groups with Tumor size <= 2cm 
TACS_data_tumorsize_2cm_KM_panel <- KM_panel(TACS_data_tumorsize_2cm_results , "TACS1-8")
IGNN_data_tumorsize_2cm <- subset( rbind(IGNN_data_training, IGNN_data_validation), size<=1)
IGNN_data_tumorsize_2cm_results <- Survival_analysis(IGNN_data_tumorsize_2cm) # survival analysis for IGNN model on patient groups with Tumor size <= 2cm 
IGNN_data_tumorsize_2cm_KM_panel <- KM_panel(IGNN_data_tumorsize_2cm_results , "IGNN")


splots <-list()
splots[[1]] <- TACS_data_with_guideline_low_moderate_risk_KM_panel
splots[[2]] <- IGNN_data_with_guideline_low_moderate_risk_KM_panel

splots[[3]] <- TACS_data_with_guideline_high_risk_KM_panel
splots[[4]] <- IGNN_data_with_guideline_high_risk_KM_panel

splots[[5]] <- TACS_data_tumorsize_2cm_KM_panel 
splots[[6]] <- IGNN_data_tumorsize_2cm_KM_panel
JPG <- arrange_ggsurvplots(splots,print=TRUE,ncol=2,nrow=3)
# ggsave(JPG, file="Figure_3_ab.emf",width=14.2, height=15.5)

