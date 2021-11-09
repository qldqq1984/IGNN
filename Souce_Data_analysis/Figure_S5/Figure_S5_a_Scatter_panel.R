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
require_library("survival")
require_library("survminer")
require_library("openxlsx")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))

dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Souce Data/Figure_S5/Figure_S5.xlsx")



# Scatter panel drawing, Scatter plots of significant association between a model prediction score and DFS. Correlation analyses were performed using Pearson correlation
Scatter_panel <- function(Scatter_data, model_score_type){

   gg_theme<-list()
   gg_theme[[1]]<-theme(text=element_text(family="ARL"),
                        panel.grid.major=element_blank(), 
                        panel.grid.minor = element_blank(),
                        panel.background=element_blank(),
                        axis.line = element_line(colour = "black", size=1.5),
                        axis.title.x=element_text(size=60),
                        axis.title.y=element_text(size=60),
                        axis.text.x = element_text(size=60,  margin=margin(10,30,30,10)),
                        axis.text.y = element_text(size=60,  margin=margin(5,5,5,5)),
                        plot.title = element_text(size =60),
                        #legend.position = "right",
                        legend.position = c(0.60,0.20),
                        legend.key= element_blank(),
                        legend.text = element_text(size=60))
   
   panel<-ggscatter(Scatter_data, x = "model_score", y = "DFS" ,color = "orange",size = 3,
         add = "reg.line", conf.int = TRUE,    
         add.params = list(fill = "blue"))+
         scale_x_continuous(limits=c(-3,3), breaks=seq(-3,3,1))+
         gg_theme[[1]]+
         labs(x=model_score_type, y="DFS", title="")
   
   return(panel)
}   


# Training (n=731) 
TACS_data_training <- read.xlsx( Data_file , sheet = "TACS_training_cohort")
Nomogram_data_training <- read.xlsx( Data_file , sheet = "Nomogram_training_cohort")
IGNN_data_training <- read.xlsx( Data_file , sheet = "IGNN_training_cohort")
IGNNE_data_training <- read.xlsx( Data_file , sheet = "IGNNE_training_cohort")
TACS_training_Scatter_panel <- Scatter_panel(TACS_data_training, "TACS1-8 score")
Nomogram_training_Scatter_panel <- Scatter_panel(Nomogram_data_training, "Nomogram score")
IGNN_training_Scatter_panel <- Scatter_panel(IGNN_data_training, "IGNN score")
IGNNE_training_Scatter_panel <- Scatter_panel(IGNNE_data_training, "IGNN-E score")



# Validation (n=264) 
TACS_data_validation <- read.xlsx( Data_file , sheet = "TACS_validation_cohort")
Nomogram_data_validation <- read.xlsx( Data_file , sheet = "Nomogram_validation_cohort")
IGNN_data_validation <- read.xlsx( Data_file , sheet = "IGNN_validation_cohort")
IGNNE_data_validation <- read.xlsx( Data_file , sheet = "IGNNE_validation_cohort")
TACS_validation_Scatter_panel <- Scatter_panel(TACS_data_validation, "TACS1-8 score")
Nomogram_validation_Scatter_panel <- Scatter_panel(Nomogram_data_validation, "Nomogram score")
IGNN_validation_Scatter_panel <- Scatter_panel(IGNN_data_validation, "IGNN score")
IGNNE_validation_Scatter_panel <- Scatter_panel(IGNNE_data_validation, "IGNN-E score")



JPG_training <- ggpubr::ggarrange(TACS_training_Scatter_panel,Nomogram_training_Scatter_panel,IGNN_training_Scatter_panel,IGNNE_training_Scatter_panel , nrow = 2, ncol = 2)
JPG_validation <- ggpubr::ggarrange(TACS_validation_Scatter_panel,Nomogram_validation_Scatter_panel,IGNN_validation_Scatter_panel,IGNNE_validation_Scatter_panel , nrow = 2, ncol = 2)

# ggsave(JPG_training, file="Fig_S5_a_1.tiff",width=28, height=28)
# ggsave(JPG_validation, file="Fig_S5_a_2.tiff",width=28, height=28)
