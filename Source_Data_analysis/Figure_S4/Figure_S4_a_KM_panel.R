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
require_library("ggplot2")
require_library("survival")
require_library("survminer")
require_library("openxlsx")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))

dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_S4/Figure_S4.xlsx")



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
   
# pre-validation with 3-cross validation for TACS model on training cohort (n=731) 
TACS_data_fold1 <- read.xlsx( Data_file , sheet = "TACS_fold1")
TACS_data_fold2 <- read.xlsx( Data_file , sheet = "TACS_fold2")
TACS_data_fold3 <- read.xlsx( Data_file , sheet = "TACS_fold3")
TACS_data <- rbind(TACS_data_fold1, TACS_data_fold2, TACS_data_fold3)
TACS_results <- Survival_analysis(TACS_data)
TACS_KM_panel <- KM_panel(TACS_results, "TACS1-8")


# pre-validation with 3-cross validation for Nomogram model on training cohort (n=731) 
Nomogram_data_fold1 <- read.xlsx( Data_file , sheet = "Nomogram_fold1")
Nomogram_data_fold2 <- read.xlsx( Data_file , sheet = "Nomogram_fold2")
Nomogram_data_fold3 <- read.xlsx( Data_file , sheet = "Nomogram_fold3")
Nomogram_data <- rbind(Nomogram_data_fold1, Nomogram_data_fold2, Nomogram_data_fold3)
Nomogram_results <- Survival_analysis(Nomogram_data)
Nomogram_KM_panel <- KM_panel(Nomogram_results, "Nomogram")


# pre-validation with 3-cross validation for IGNN model on training cohort (n=731) 
IGNN_data_fold1 <- read.xlsx( Data_file , sheet = "IGNN_fold1")
IGNN_data_fold2 <- read.xlsx( Data_file , sheet = "IGNN_fold2")
IGNN_data_fold3 <- read.xlsx( Data_file , sheet = "IGNN_fold3")
IGNN_data <- rbind(IGNN_data_fold1, IGNN_data_fold2, IGNN_data_fold3)
IGNN_results <- Survival_analysis(IGNN_data)
IGNN_KM_panel <- KM_panel(IGNN_results, "IGNN")


# pre-validation with 3-cross validation for IGNNE model on training cohort (n=731) 
IGNNE_data_fold1 <- read.xlsx( Data_file , sheet = "IGNNE_fold1")
IGNNE_data_fold2 <- read.xlsx( Data_file , sheet = "IGNNE_fold2")
IGNNE_data_fold3 <- read.xlsx( Data_file , sheet = "IGNNE_fold3")
IGNNE_data <- rbind(IGNNE_data_fold1, IGNNE_data_fold2, IGNNE_data_fold3)
IGNNE_results <- Survival_analysis(IGNNE_data)
IGNNE_KM_panel <- KM_panel(IGNNE_results, "IGNN-E")

# splots <-list()
# splots[[1]] <- TACS_KM_panel
# splots[[2]] <- Nomogram_KM_panel
# splots[[3]] <- IGNN_KM_panel
# splots[[4]] <- IGNNE_KM_panel
# JPG <- arrange_ggsurvplots(splots,print=TRUE,ncol=2,nrow=2)
# ggsave(JPG, file="Figure_S4_a.emf",width=14.2, height=15.5)

