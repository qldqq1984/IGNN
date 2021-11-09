# library(corrplot)
# library(openxlsx)
# library(reshape2)
# library(ggplot2)
# library(ggthemes)
# library(vegan)
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
require_library("corrplot")
require_library("ggplot2")
require_library("ggthemes")
require_library("reshape2")
require_library("openxlsx")
require_library("vegan")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))

dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_4/Figure_4.xlsx")


# ANOSIM analyse differences between clusters
ANOSIM_analysis <- function(Clusters_data){
   
   Cluster1_data <- subset(Clusters_data, clustertype==1)
   Cluster2_data <- subset(Clusters_data, clustertype==2)
   Cluster3_data <- subset(Clusters_data, clustertype==3)
   
   Clusters <- rbind(Cluster1_data, Cluster2_data, Cluster3_data)
   Clusters_anosim <- anosim(Clusters[ ,c(2:9)], Clusters$clustertype,distance = "euclidean")
   
   return(Clusters_anosim)
}


#  ANOSIM panel drawing
ANOSIM_panel <- function(Clusters_anosim_results){

   plot(Clusters_anosim_results)
   mycol = c(52,619,453,71,134,448,548,655,574,36,544,89,120,131,596,147,576)
   mycol = colors()[mycol]
   par(mar=c(5,5,5,5))
   result = paste("R=",Clusters_anosim_results$statistic,"p=", Clusters_anosim_results$signif)
   panel <- boxplot(Clusters_anosim_results$dis.rank~Clusters_anosim_results$class.vec, outline = FALSE, pch="+", col=mycol, range=1, boxwex=0.5, notch=FALSE, ylab="Bray-Curtis Rank", main="Bray-Curtis Anosim", sub=result)

   return(panel)
}

   
# Training (n=731)
Clusters_data_Training <- read.xlsx( Data_file , sheet = "Cluster_gnnlayer2_Training")
ANOSIM_analysis_Training_results <- ANOSIM_analysis(Clusters_data_Training )
ANOSIM_analysis_Training_panel <- ANOSIM_panel(ANOSIM_analysis_Training_results)


# # Validation (n=264) 
Clusters_data_Validation <- read.xlsx( Data_file , sheet = "Cluster_gnnlayer2_Validation")
ANOSIM_analysis_Validation_results <- ANOSIM_analysis(Clusters_data_Validation )
ANOSIM_analysis_Validation_panel <- ANOSIM_panel(ANOSIM_analysis_Validation_results)


# Tumor size <= 2cm (n=445)
Clusters_data_Tumorsize_2cm <- read.xlsx( Data_file , sheet = "Cluster_gnnlayer2_Tumorsize_2cm")
ANOSIM_analysis_Tumorsize_2cm_results <- ANOSIM_analysis(Clusters_data_Tumorsize_2cm )
ANOSIM_analysis_Tumorsize_2cm_panel <- ANOSIM_panel(ANOSIM_analysis_Tumorsize_2cm_results)



