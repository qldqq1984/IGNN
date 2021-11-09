# library(corrplot)
# library(openxlsx)
# library(reshape2)
# library(ggplot2)
# library(ggthemes)
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



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))

dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_4/Figure_4.xlsx")



# percentages of TACSs in the clusters  
TACS_percentages_analysis <- function(clusters_data, clusters_info){
   
   Cluster1 <- clusters_data[c(clusters_info$Cluster1_star:clusters_info$Cluster1_end),c(2:9)]
   Cluster1 <- colSums(Cluster1)/(clusters_info$Cluster1_end - clusters_info$Cluster1_star + 1)
   
   Cluster2 <- clusters_data[c(clusters_info$Cluster2_star:clusters_info$Cluster2_end),c(2:9)]
   Cluster2 <- colSums(Cluster2)/(clusters_info$Cluster2_end - clusters_info$Cluster2_star + 1)
   
   Cluster3 <- clusters_data[c(clusters_info$Cluster3_star:clusters_info$Cluster3_end),c(2:9)]
   Cluster3 <- colSums(Cluster3)/(clusters_info$Cluster3_end - clusters_info$Cluster3_star + 1)
   
   dat = rbind(Cluster1,Cluster2,Cluster3)
   
   
   re1 = melt(data = dat,id.vars=c("Cluster"),variable.name="TACS",value.name="T")
   colnames(re1)<-c("Cluster","TACS","Percentage")
   
   return(re1)

}
# 
# 
# # TACS_percentages panel drawing
TACS_percentages_panel <- function(TACS_percentages_results){

   panel<-ggplot(TACS_percentages_results,aes(Cluster,Percentage,fill=TACS))+
      geom_bar(stat="identity",position="fill")+
      theme_wsj(base_size=14,color = "white")+
      scale_fill_economist()+
      coord_flip()

   return(panel)
}
   
# Training (n=731)
Clusters_data_Training <- read.xlsx( Data_file , sheet = "Clusters_withTACS_Training")
Clusters_info_Training <- {}
Clusters_info_Training$Cluster1_star = 1
Clusters_info_Training$Cluster1_end =  2248
Clusters_info_Training$Cluster2_star = 2249
Clusters_info_Training$Cluster2_end = 4279
Clusters_info_Training$Cluster3_star = 4280
Clusters_info_Training$Cluster3_end = 5445
TACS_percentages_results <- TACS_percentages_analysis(clusters_data = Clusters_data_Training, clusters_info = Clusters_info_Training  )
TACS_percentages_Training_panel <- TACS_percentages_panel(TACS_percentages_results)



# # Validation (n=264) 
Clusters_data_Validation <- read.xlsx( Data_file , sheet = "Clusters_withTACS_Validation")
Clusters_info_Validation <- {}
Clusters_info_Validation$Cluster1_star = 1
Clusters_info_Validation$Cluster1_end =  826
Clusters_info_Validation$Cluster2_star = 827
Clusters_info_Validation$Cluster2_end = 1724
Clusters_info_Validation$Cluster3_star = 1725
Clusters_info_Validation$Cluster3_end = 1979
TACS_percentages_results <- TACS_percentages_analysis(clusters_data = Clusters_data_Validation, clusters_info = Clusters_info_Validation  )
TACS_percentages_Validation_panel <- TACS_percentages_panel(TACS_percentages_results)


# Tumor size <= 2cm (n=445)
Clusters_data_Tumorsize_2cm <- read.xlsx( Data_file , sheet = "Clusters_withTACS_Tumorsize_2cm")
Clusters_info_Tumorsize_2cm <- {}
Clusters_info_Tumorsize_2cm$Cluster1_star = 1
Clusters_info_Tumorsize_2cm$Cluster1_end =  1279
Clusters_info_Tumorsize_2cm$Cluster2_star = 1280
Clusters_info_Tumorsize_2cm$Cluster2_end = 2511
Clusters_info_Tumorsize_2cm$Cluster3_star = 2512
Clusters_info_Tumorsize_2cm$Cluster3_end = 3190
TACS_percentages_results <- TACS_percentages_analysis(clusters_data = Clusters_data_Tumorsize_2cm, clusters_info = Clusters_info_Tumorsize_2cm  )
TACS_percentages_Tumorsize_2cm_panel <- TACS_percentages_panel(TACS_percentages_results)



