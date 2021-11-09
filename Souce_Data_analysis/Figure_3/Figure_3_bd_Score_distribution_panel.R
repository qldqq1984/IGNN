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
Data_file = paste0(dir_root,"/Souce Data/Figure_3/Figure_3.xlsx")



# Score distribution panel drawing, panel shows the compared model scores for patients with DFS less and more than 5 years
Score_distribution_panel <- function(model1_data, model2_data){

   DFS1 <- as.numeric(model1_data$DFS);
   Y1 <- as.numeric(model1_data$y);
   STATUS1 <- as.numeric(model1_data$STATUS);
   score1 <- as.numeric(model1_data$model_score);
   risk1 <- as.numeric(model1_data$model_risk);
   s11<- subset(model1_data, model_risk==0 & DFS<=60 )
   s12<- subset(model1_data, model_risk==0 & DFS>60 )
   s13<- subset(model1_data, model_risk==1 & DFS<=60 )
   s14<- subset(model1_data, model_risk==1 & DFS>60 )
   
   DFS2 <- as.numeric(model2_data$DFS);
   Y2 <- as.numeric(model2_data$y);
   STATUS2 <- as.numeric(model2_data$STATUS);
   score2 <- as.numeric(model2_data$model_score);
   risk2 <- as.numeric(model2_data$model_risk);
   s21<- subset(model2_data, model_risk==0 & DFS<=60 )
   s22<- subset(model2_data, model_risk==0 & DFS>60 )
   s23<- subset(model2_data, model_risk==1 & DFS<=60 )
   s24<- subset(model2_data, model_risk==1 & DFS>60 )   
   
   
   Data1 <- data.frame(Score<-score1, model_name <- "TACS1-8", DFS <- ifelse(Y1 ==1, paste(expression("DFS <= 5 years")), "DFS >5 years") )
   names(Data1) = c("Score","model_name","DFS")
   
   Data2 <- data.frame(Score<-score2, model_name <- "IGNN", DFS <- ifelse(Y2 ==1, paste(expression("DFS <= 5 years")), "DFS >5 years") )
   names(Data2) = c("Score","model_name","DFS")
   
   Datas <- rbind(Data1,Data2)

   gg_theme <- list()
   gg_theme <- theme(text=element_text(family="ARL"),
                          panel.grid.major=element_blank(), 
                          panel.grid.minor = element_blank(),
                          panel.background=element_blank(),
                          axis.line = element_line(colour = "black", size=1.0),
                          #axis.title.x= element_blank(),
                          #axis.title.y= element_blank(),
                          axis.title.x= element_blank(),
                          axis.title.y= element_text(size=60),
                          axis.text.x = element_text(size=60,  margin=margin(20,20,20,20)),
                          axis.text.y = element_text(size=60,  margin=margin(10,10,10,10)),
                          axis.ticks.x = element_blank(),
                          plot.title = element_text(size =60),
                          legend.position = "none",
                          #legend.position = c(0.62,0.12),
                          legend.key=element_blank(),
                          legend.title=element_text(size=60),
                          
                          #legend.text = element_blank()
                          legend.text = element_text(size=60)
   )
   
   panel <- ggboxplot(Datas, x="model_name", y="Score", color = "DFS", width = 0.5, size = 2,
               palette = c("orangered", "dodgerblue"), add =  c("mean_se", "jitter"), error.plot="pointrange")+
               scale_y_continuous(limits=c(-3,3), breaks=seq(-3,3,1))+
               guides(color=guide_legend(title=NULL))+
               gg_theme+
               annotate(geom = "text", y =-2.6, x =0.7, label = expression( paste(italic("p")," < 2¡Á10"^"-16") ), size = 18, hjust = 0) +
               annotate(geom = "text", y =-2.6, x =1.7, label = expression( paste(italic("p")," < 2¡Á10"^"-16") ), size = 18, hjust = 0) 

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

# IGNN Model prediction for the patient groups with Tumor size <= 2cm
TACS_data_tumorsize_2cm <- subset( rbind(TACS_data_training, TACS_data_validation), size<=1)
IGNN_data_tumorsize_2cm <- subset( rbind(IGNN_data_training, IGNN_data_validation), size<=1)


# guideline-defined low/moderate risk (n=626) 
# Comparing the distribution of TACS score and IGN score on patient groups with guideline-defined low/moderate risk
guideline_low_moderate_risk_Score_distribution_panel <- Score_distribution_panel(TACS_data_with_guideline_low_moderate_risk, IGNN_data_with_guideline_low_moderate_risk)


# guideline-defined high risk (n=369) 
# Comparing the distribution of TACS score and IGN score on patient groups with guideline-defined high risk
guideline_high_risk_Score_distribution_panel <- Score_distribution_panel(TACS_data_with_guideline_high_risk, IGNN_data_with_guideline_high_risk)


# Tumor size <= 2cm (n=445) 
# Comparing the distribution of TACS score and IGN score on patient groups with Tumor size <= 2cm
tumorsize_2cm_panel <- Score_distribution_panel(TACS_data_tumorsize_2cm, IGNN_data_tumorsize_2cm)


# ggsave(guideline_low_moderate_risk_Score_distribution_panel, file="Fig_3_b_1.tiff",width=15, height=15)
# ggsave(guideline_high_risk_Score_distribution_panel, file="Fig_3_b_2.tiff",width=15, height=15)
# ggsave(tumorsize_2cm_panel, file="Fig_3_d_1.tiff",width=15, height=15)






