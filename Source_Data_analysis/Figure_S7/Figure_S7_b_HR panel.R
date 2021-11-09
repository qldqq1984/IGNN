# library(survival)
# library(ggplot2)
# library(openxlsx)
warnings('off')
options(warn =-1)
options(digits=4)
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
require_library("ggplot2")
require_library("openxlsx")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))


dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_S7/Figure_S7.xlsx")

# HR measured with the low or high risk stratified by prognostic models in survival analysis
Survival_analysis <- function(s_pbcx, s_pbcs_names, models_names){
   
   DFS <- as.numeric(s_pbcx$DFS);
   Y <- as.numeric(s_pbcx$y);
   STATUS <- as.numeric(s_pbcx$STATUS);
   model_risk <- s_pbcx$model_risk;
   s_pbc_size = length(DFS);
   
   COX_Survs <- coxph(Surv(s_pbcx$DFS, s_pbcx$STATUS) ~ model_risk, data = s_pbcx) 
   
   x<- summary(COX_Survs)
   COX_Survs_results <- data.frame(HR = x$coef[2], HR_ci_lower= x$conf.int[,"lower .95"], HR_ci_upper = x$conf.int[,"upper .95"])
   
   return( COX_Survs_results )
}



# Training (n=731) 
TACS_data_training <- read.xlsx( Data_file , sheet = "TACS_training_cohort")
Nomogram_data_training <- read.xlsx( Data_file , sheet = "Nomogram_training_cohort")
IGNN_data_training <- read.xlsx( Data_file , sheet = "IGNN_training_cohort")
IGNNE_data_training <- read.xlsx( Data_file , sheet = "IGNNE_training_cohort")

# Validation (n=264) 
TACS_data_validation <- read.xlsx( Data_file , sheet = "TACS_validation_cohort")
Nomogram_data_validation <- read.xlsx( Data_file , sheet = "Nomogram_validation_cohort")
IGNN_data_validation <- read.xlsx( Data_file , sheet = "IGNN_validation_cohort")
IGNNE_data_validation <- read.xlsx( Data_file , sheet = "IGNNE_validation_cohort")


# Data of TACS model performance on all 995 patients
pbc1 <- rbind(TACS_data_training, TACS_data_validation)
pbc1_size2cm <- subset(pbc1, size<=1)  # patient groups with tumor size <= 2cm
pbc1_size2_5cm <- subset(pbc1, size==2) # patient groups with tumor size 2-5cm
pbc1_size5cm <- subset(pbc1, size==3) # patient groups with tumor size > 5cm

# Data of Nomogram model performance on all 995 patients
pbc2 <- rbind(Nomogram_data_training, Nomogram_data_validation)
pbc2_size2cm <- subset(pbc2, size<=1)
pbc2_size2_5cm <- subset(pbc2, size==2)
pbc2_size5cm <- subset(pbc2, size==3)

# Data of IGNN model performance on all 995 patients
pbc3 <- rbind(IGNN_data_training, IGNN_data_validation )
pbc3_size2cm <- subset(pbc3, size<=1)
pbc3_size2_5cm <- subset(pbc3, size==2)
pbc3_size5cm <- subset(pbc3, size==3)

# Data of IGNNE model performance on all 995 patients
pbc4 <- rbind(IGNNE_data_training, IGNNE_data_validation)
pbc4_size2cm <- subset(pbc4, size<=1)
pbc4_size2_5cm <- subset(pbc4, size==2)
pbc4_size5cm <- subset(pbc4, size==3)

#############################
type <- as.numeric(pbc1$type);
size <- as.numeric(pbc1$size);
lym <- as.numeric(pbc1$lym);
stage <- as.numeric(pbc1$stage);
grade <- as.numeric(pbc1$grade);
age <- as.numeric(pbc1$age);
ER <- as.numeric(pbc1$ER);
PR <- as.numeric(pbc1$PR);
HER2 <- as.numeric(pbc1$HER2);

# guideline-defined low, moderate and high risk
guideline_low_risk = as.numeric( (lym==0) & (size==1) & (grade==1) & ((ER==1)|(PR==1) ) &  (HER2==0) & (age>=35) );
guideline_moderate_risk1 = (lym==0) & ( (size>1)|(grade>1)|( (ER==0)&(PR==0) )|(HER2==1)|(age<35) );
guideline_moderate_risk2 = (lym==1) & ( (HER2==0) & ( (ER==1)|(PR==1) ) );
guideline_moderate_risk = as.numeric( guideline_moderate_risk1|guideline_moderate_risk2 );
guideline_high_risk1 = (lym==1) & (  (HER2==1) | ( (ER==0) &(PR==0) )  );
guideline_high_risk2 = (lym==2);
guideline_high_risk = as.numeric( guideline_high_risk1|guideline_high_risk2 );

#############################
pbcs <- list()
models_names <- list()
subgroups <- list()
s_pbcs_names <- list()
panel <- list()

pbcs[[1]] <- pbc1;pbcs[[2]] <- pbc2;pbcs[[3]] <- pbc3;pbcs[[4]] <- pbc4
models_names <- c("TACS1-8","Nomogram", "IGNN", "IGNN-E")
subgroups <- c("age <=50", "age >50", "type==1", "type==2", "type==3", "type==4", "size<=1", "size==2", "size==3", "lym==0", "lym==1", "lym==2", "stage==1", "stage==2", "stage==3", "grade==1", "grade==2", "grade==3", "size<=5", "size<=5")
subgroups_names <- c("Age <=50 years", "Age >50 years", "Luminal A", "Luminal B", "HER2-enriched", "Triple_Negative", "Tumor size <=2cm", "Tumor size 2-5cm", "Tumor size >5cm", "Node status 0", "Node status 1-3", "Node status 4", "Clinical Stage 1", "Clinical Stage 2", "Clinical Stage 3", "Histological grade G1", "Histological grade G2", "Histological grade G3", "guideline (low/moderate risk)", "guideline (high risk)")


for (n in 1:20){
   pbcs[[1]] <- pbc1;pbcs[[2]] <- pbc2;pbcs[[3]] <- pbc3;pbcs[[4]] <- pbc4
   s_pbcs_names[[n]] <- subgroups_names[[n]];
   allHRs <- list()

   for (m in 1:4){
      
       if (n==7){ # patient groups with tumor size <= 2cm
           pbcs[[1]] <- pbc1_size2cm;
           pbcs[[2]] <- pbc2_size2cm;
           pbcs[[3]] <- pbc3_size2cm;
           pbcs[[4]] <- pbc4_size2cm;
       }

       else if (n==8 ){ # patient groups with tumor size 2-5cm
           pbcs[[1]] <- pbc1_size2_5cm;
           pbcs[[2]] <- pbc2_size2_5cm;
           pbcs[[3]] <- pbc3_size2_5cm;
           pbcs[[4]] <- pbc4_size2_5cm;         
       }

       else if (n==9 ){  # patient groups with tumor size > 5cm
           pbcs[[1]] <- pbc1_size5cm;
           pbcs[[2]] <- pbc2_size5cm;
           pbcs[[3]] <- pbc3_size5cm;
           pbcs[[4]] <- pbc4_size5cm;       
       }

       else if (n==19 ){ # patient groups with guideline-defined lowand moderate risk
           pbcs[[1]] <- pbc1[(guideline_low_risk ) |(guideline_moderate_risk==1),];
           pbcs[[2]] <- pbc2[(guideline_low_risk ) |(guideline_moderate_risk==1),];
           pbcs[[3]] <- pbc3[(guideline_low_risk ) |(guideline_moderate_risk==1),];
           pbcs[[4]] <- pbc4[(guideline_low_risk ) |(guideline_moderate_risk==1),]; 
       }

       else if (n==20 ){ # patient groups with guideline-defined high risk
           pbcs[[1]] <- pbc1[guideline_high_risk==1,];
           pbcs[[2]] <- pbc2[guideline_high_risk==1,];
           pbcs[[3]] <- pbc3[guideline_high_risk==1,];
           pbcs[[4]] <- pbc4[guideline_high_risk==1,];   
       }

       express <- paste("s_pbc<-subset(pbcs[[m]], ",subgroups[[n]],")")
       eval(parse(text = express) )  
       allHRs[[m]] <- Survival_analysis(s_pbc, s_pbcs_names = s_pbcs_names[[n]], models_names = models_names[[m]] )

   }
   
   boxLabels = c("1", "2", "3", "4")
   df <- data.frame(yAxis =  boxLabels, 
                    HR_value = c(allHRs[[1]]$HR, allHRs[[2]]$HR, allHRs[[3]]$HR, allHRs[[4]]$HR), 
                    HR_ci_lower = c(allHRs[[1]]$HR_ci_lower, allHRs[[2]]$HR_ci_lower,allHRs[[3]]$HR_ci_lower, allHRs[[4]]$HR_ci_lower), 
                    HR_ci_upper = c(allHRs[[1]]$HR_ci_upper, allHRs[[2]]$HR_ci_upper,allHRs[[3]]$HR_ci_upper, allHRs[[4]]$HR_ci_upper))


   scale_x_max = round( max(allHRs[[1]]$HR_ci_upper, allHRs[[2]]$HR_ci_upper, allHRs[[3]]$HR_ci_upper, allHRs[[4]]$HR_ci_upper) ) + 3

   # HR panel drawing, HR panel show the HRs for different prognostic models
   panel[[n]] <- ggplot(df, aes(x = HR_value, y = yAxis,color=boxLabels)) + 
               coord_flip()+
               geom_vline(aes(xintercept = 1), size = 1.0, linetype = "dashed", color = "orange") + 
               geom_errorbarh(aes(xmax = HR_ci_upper, xmin = HR_ci_lower), size = 1.5, height = 0.2, color = "gray50") +
               geom_point(size = 7.5) +
               scale_color_manual(values=c("lightgreen","#E18727FF", "#0072B5FF", "#BC3C29FF")) +  
               scale_x_continuous(breaks = seq(1, scale_x_max, 3), labels = seq(1, scale_x_max, 3),limits = c(1,scale_x_max)  ) +
               annotate(geom = "text", y =0.45, x = allHRs[[1]]$HR +1.4, label = sprintf('%.2f', signif(allHRs[[1]]$HR, digits=4)), size = 6, hjust = 0) + 
               annotate(geom = "text", y =1.35, x = allHRs[[2]]$HR +1.4, label = sprintf('%.2f', signif(allHRs[[2]]$HR, digits=4)), size = 6, hjust = 0) + 
               annotate(geom = "text", y =2.35, x = allHRs[[3]]$HR +1.4, label = sprintf('%.2f', signif(allHRs[[3]]$HR, digits=4)), size = 6, hjust = 0) + 
               annotate(geom = "text", y =3.25, x = allHRs[[4]]$HR +1.4, label = sprintf('%.2f', signif(allHRs[[4]]$HR, digits=4)), size = 6, hjust = 0) + 
               theme_minimal()+
               theme(legend.position="none",
                     legend.text = element_text(size=20),
                     legend.key= element_blank(),
                     axis.line = element_line(colour = "black", size=1.0),
                     axis.title.x=element_text(size=20),
                     axis.title.y=element_text(size=20),
                     axis.text.x = element_blank(),
                     axis.text.y = element_text(size=20),
                     plot.title = element_text(size =20)) +
                labs(x = "HR",
                     y = "Models",
                     title = s_pbcs_names[[n]])

}


panels <- ggpubr::ggarrange(panel[[1]], panel[[2]], panel[[3]], panel[[4]],
                           panel[[5]], panel[[6]], panel[[7]], panel[[8]],
                           panel[[9]], panel[[10]],panel[[11]],panel[[12]],
                           panel[[13]],panel[[14]],panel[[15]],panel[[16]],
                           panel[[17]],panel[[18]],panel[[19]],panel[[20]],
                           nrow = 5, ncol = 4)



# ggsave(panel, file="Figure_S7_b.emf",width=20, height=21)

