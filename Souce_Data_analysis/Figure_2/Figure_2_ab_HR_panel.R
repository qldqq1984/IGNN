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
require_library("survminer")
require_library("openxlsx")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))

dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Souce Data/Figure_2/Figure_2.xlsx")


# HR measured with the low or high risk stratified by prognostic models in survival analysis
Survival_analysis <- function(pbc_data){

   DFS <- as.numeric(pbc_data$DFS);
   STATUS <- as.numeric(pbc_data$STATUS);
   
   model_score <- as.numeric(pbc_data$model_score);
   model_risk <- as.numeric(pbc_data$model_risk); 

   COX_Survs <- coxph(Surv(DFS, STATUS) ~ model_risk, data = pbc_data ) # survival analysis
   
   x<- summary(COX_Survs)
   wald.test <- x$waldtest["test"]

   HR <- {}   
   HR$value <- round(x$coef[2], 2) # hazard ratio
   HR$pvalue <- round(x$waldtest["pvalue"], 2) # p value
   HR$ci_lower <- round(x$conf.int[,"lower .95"],2) # lower boundaries of 95% CI
   HR$ci_upper <- round(x$conf.int[,"upper .95"],2) # upper boundaries of 95% CI 

   return (HR)
   
}

# HR panel drawing, HR panel show the HRs for different prognostic models
HR_panel <- function(TACS_results, Nomogram_results, IGNN_results, IGNNE_results){

   boxLabels = c("model1_TACS", "model2_Nomogram", "model3_IGNN", "model4_IGNNE")
   df <- data.frame(yAxis = length(boxLabels):1, 
                    HR_value = c(TACS_results$value,  Nomogram_results$value, IGNN_results$value, IGNNE_results$value), 
                    HR_ci_lower = c(TACS_results$ci_lower, Nomogram_results$ci_lower, IGNN_results$ci_lower, IGNNE_results$ci_lower), 
                    HR_ci_upper = c(TACS_results$ci_upper, Nomogram_results$ci_upper, IGNN_results$ci_upper, IGNNE_results$ci_upper))
   
   panel <- ggplot(df, aes(x = HR_value, y = boxLabels,color=boxLabels)) + 
               coord_flip()+
               geom_vline(aes(xintercept = 1), size = 1.0, linetype = "dashed", color = "orange") + 
               geom_errorbarh(aes(xmax = HR_ci_upper, xmin = HR_ci_lower), size = 1.5, height = 0.2, color = "gray50") +
               geom_point(size = 7.5) +
               scale_color_manual(values=c("lightgreen","#E18727FF", "#0072B5FF", "#BC3C29FF")) +  
               scale_x_continuous(breaks = seq(1, round(IGNNE_results$ci_upper)+1, 3), labels = seq(1, round(IGNNE_results$ci_upper)+1, 3),limits = c(1,round(IGNNE_results$ci_upper)+1)  ) +
               theme_minimal()+
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
TACS_results <- Survival_analysis(TACS_data_training)
Nomogram_results <- Survival_analysis(Nomogram_data_training)
IGNN_results <- Survival_analysis(IGNN_data_training)
IGNNE_results <- Survival_analysis(IGNNE_data_training)

HR_panel_training <- HR_panel(TACS_results, Nomogram_results, IGNN_results, IGNNE_results)
   

# Validation (n=264) 
TACS_data_validation <- read.xlsx( Data_file , sheet = "TACS_validation_cohort")
Nomogram_data_validation <- read.xlsx( Data_file , sheet = "Nomogram_validation_cohort")
IGNN_data_validation <- read.xlsx( Data_file , sheet = "IGNN_validation_cohort")
IGNNE_data_validation <- read.xlsx( Data_file , sheet = "IGNNE_validation_cohort")
TACS_results <- Survival_analysis(TACS_data_validation)
Nomogram_results <- Survival_analysis(Nomogram_data_validation)
IGNN_results <- Survival_analysis(IGNN_data_validation)
IGNNE_results <- Survival_analysis(IGNNE_data_validation)

HR_panel_validation  <- HR_panel(TACS_results, Nomogram_results, IGNN_results, IGNNE_results)


# Tumor size > 5cm (n=55) 
TACS_data_tumorsize_5cm <- subset( rbind(TACS_data_training, TACS_data_validation), size==3)
Nomogram_data_tumorsize_5cm <- subset( rbind(Nomogram_data_training, Nomogram_data_validation), size==3)
IGNN_data_tumorsize_5cm <- subset( rbind(IGNN_data_training, IGNN_data_validation), size==3)
IGNNE_data_tumorsize_5cm <- subset( rbind(IGNNE_data_training, IGNNE_data_validation), size==3)
TACS_results <- Survival_analysis(TACS_data_tumorsize_5cm)
Nomogram_results <- Survival_analysis(Nomogram_data_tumorsize_5cm)
IGNN_results <- Survival_analysis(IGNN_data_tumorsize_5cm)
IGNNE_results <- Survival_analysis(IGNNE_data_tumorsize_5cm)

HR_panel_tumorsize_5cm  <- HR_panel(TACS_results, Nomogram_results, IGNN_results, IGNNE_results)


# Tumor size 2-5cm (n=495) 
TACS_data_tumorsize_2to5cm <- subset( rbind(TACS_data_training, TACS_data_validation), size==2)
Nomogram_data_tumorsize_2to5cm <- subset( rbind(Nomogram_data_training, Nomogram_data_validation), size==2)
IGNN_data_tumorsize_2to5cm <- subset( rbind(IGNN_data_training, IGNN_data_validation), size==2)
IGNNE_data_tumorsize_2to5cm <- subset( rbind(IGNNE_data_training, IGNNE_data_validation), size==2)
TACS_results <- Survival_analysis(TACS_data_tumorsize_2to5cm)
Nomogram_results <- Survival_analysis(Nomogram_data_tumorsize_2to5cm)
IGNN_results <- Survival_analysis(IGNN_data_tumorsize_2to5cm)
IGNNE_results <- Survival_analysis(IGNNE_data_tumorsize_2to5cm)

HR_panel_tumorsize_2to5cm  <- HR_panel(TACS_results, Nomogram_results, IGNN_results, IGNNE_results)


# Tumor size <= 2cm (n=445) 
TACS_data_tumorsize_2cm <- subset( rbind(TACS_data_training, TACS_data_validation), size<=1)
Nomogram_data_tumorsize_2cm <- subset( rbind(Nomogram_data_training, Nomogram_data_validation), size<=1)
IGNN_data_tumorsize_2cm <- subset( rbind(IGNN_data_training, IGNN_data_validation), size<=1)
IGNNE_data_tumorsize_2cm <- subset( rbind(IGNNE_data_training, IGNNE_data_validation), size<=1)
TACS_results <- Survival_analysis(TACS_data_tumorsize_2cm)
Nomogram_results <- Survival_analysis(Nomogram_data_tumorsize_2cm)
IGNN_results <- Survival_analysis(IGNN_data_tumorsize_2cm)
IGNNE_results <- Survival_analysis(IGNNE_data_tumorsize_2cm)

HR_panel_tumorsize_2cm  <- HR_panel(TACS_results, Nomogram_results, IGNN_results, IGNNE_results)



#ggsave(HR_panel_training, file="Fig_2_a_1.tiff",width=20, height=6)
#ggsave(HR_panel_validation, file="Fig_2_a_5.tiff",width=20, height=6)
#ggsave(HR_panel_tumorsize_5cm, file="Fig_2_b_1.tiff",width=20, height=6)
#ggsave(HR_panel_tumorsize_2to5cm, file="Fig_2_b_5.tiff",width=20, height=6)
#ggsave(HR_panel_tumorsize_2cm, file="Fig_2_b_9.tiff",width=20, height=6)

