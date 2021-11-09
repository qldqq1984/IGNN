# library(ggplot2)
# library(survival)
# library(survminer)
# library(openxlsx)
warnings('off')
options(warn =-1)


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
Data_file = paste0(dir_root,"/Souce Data/Figure_S5/Figure_S5.xlsx")




# Score distribution panel drawing, panel shows the compared model scores for patients with DFS less and more than 5 years
Score_distribution_panel <- function(model1_data, model2_data, model3_data, model4_data){

   DFS1 <- as.numeric(model1_data$DFS);
   Y1 <- as.numeric(model1_data$y);
   score1 <- as.numeric(model1_data$model_score);
   
   DFS2 <- as.numeric(model2_data$DFS);
   Y2 <- as.numeric(model2_data$y);
   score2 <- as.numeric(model2_data$model_score);
   
   DFS3 <- as.numeric(model3_data$DFS);
   Y3 <- as.numeric(model3_data$y);
   score3 <- as.numeric(model3_data$model_score);
   
   DFS4 <- as.numeric(model4_data$DFS);
   Y4 <- as.numeric(model4_data$y);
   score4 <- as.numeric(model4_data$model_score);
   

   Data1 <- data.frame(Score<-score1, model_name <- "TACS1-8", DFS <- ifelse(Y1 ==1, "DFS <= 5 years", "DFS >5 years") )
   names(Data1) = c("Score","model_name","DFS")
   
   Data2 <- data.frame(Score<-score2, model_name <- "Nomogram", DFS <- ifelse(Y2 ==1, "DFS <= 5 years", "DFS >5 years") )
   names(Data2) = c("Score","model_name","DFS")
   
   Data3 <- data.frame(Score<-score3, model_name <- "IGNN", DFS <- ifelse(Y3 ==1, "DFS <= 5 years", "DFS >5 years") )
   names(Data3) = c("Score","model_name","DFS")
   
   Data4 <- data.frame(Score<-score4, model_name <- "IGNN-E", DFS <- ifelse(Y4 ==1, "DFS <= 5 years", "DFS >5 years") )
   names(Data4) = c("Score","model_name","DFS")
   
   Datas <- rbind(Data1,Data2,Data3,Data4)

   gg_theme <- list()
   gg_theme <- theme(text=element_text(family="ARL"),
                          panel.grid.major=element_blank(), 
                          panel.grid.minor = element_blank(),
                          panel.background=element_blank(),
                          axis.line = element_line(colour = "black", size=1.0),
                          axis.title.x= element_blank(),
                          axis.title.y= element_text(size=30),
                          axis.text.x = element_text(size=30,  margin=margin(20,20,20,20)),
                          axis.text.y = element_text(size=30,  margin=margin(10,10,10,10)),
                          axis.ticks.x = element_blank(),
                          plot.title = element_text(size =30),
                          legend.position = "none",
                          legend.key=element_blank(),
                          legend.title=element_text(size=30),
                          legend.text = element_text(size=30)
   )
   

   panel <- ggboxplot(Datas, x="model_name", y="Score", color = "DFS", width = 0.5,
                    palette = c("orangered", "dodgerblue"), add =  c("mean_se", "jitter"),size=1)+
      scale_y_continuous(limits=c(-3,3), breaks=seq(-3,3,1))+
      guides(color=guide_legend(title=NULL))+
      gg_theme +
      annotate(geom = "text", y =3.0, x =0.8, label = expression( paste(italic("p")," < 2¡Á10"^"-16") ), size = 12, hjust = 0) +
      annotate(geom = "text", y =3.0, x =1.8, label = expression( paste(italic("p")," < 2¡Á10"^"-16") ), size = 12, hjust = 0) +
      annotate(geom = "text", y =3.0, x =2.8, label = expression( paste(italic("p")," < 2¡Á10"^"-16") ), size = 12, hjust = 0) +
      annotate(geom = "text", y =3.0, x =3.8, label = expression( paste(italic("p")," < 2¡Á10"^"-16") ), size = 12, hjust = 0) 
   
   return(panel)
}   



# Training (n=731) 
TACS_data_training <- read.xlsx( Data_file , sheet = "TACS_training_cohort")
Nomogram_data_training <- read.xlsx( Data_file , sheet = "Nomogram_training_cohort")
IGNN_data_training <- read.xlsx( Data_file , sheet = "IGNN_training_cohort")
IGNNE_data_training <- read.xlsx( Data_file , sheet = "IGNNE_training_cohort")

# Comparing the distribution of model score on training cohort
Score_distribution_training_panel <- Score_distribution_panel(TACS_data_training, Nomogram_data_training, IGNN_data_training , IGNNE_data_training )


# Validation (n=264) 
TACS_data_validation <- read.xlsx( Data_file , sheet = "TACS_validation_cohort")
Nomogram_data_validation <- read.xlsx( Data_file , sheet = "Nomogram_validation_cohort")
IGNN_data_validation <- read.xlsx( Data_file , sheet = "IGNN_validation_cohort")
IGNNE_data_validation <- read.xlsx( Data_file , sheet = "IGNNE_validation_cohort")

# Comparing the distribution of model score on validation cohort
Score_distribution_validation_panel <- Score_distribution_panel(TACS_data_validation, Nomogram_data_validation, IGNN_data_validation, IGNNE_data_validation )



# ggsave(Score_distribution_training_panel, file="Fig_S5_b_1.tiff",width=15, height=15)
# ggsave(Score_distribution_validation_panel, file="Fig_S5_b_2.tiff",width=15, height=15)







