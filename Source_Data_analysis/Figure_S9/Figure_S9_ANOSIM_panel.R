# library(risksetROC)
# library(survival)
# library(timeROC)
# library(ggplot2)
# library(plotROC)
# require(cowplot)
# library(pheatmap) 
# library(corrplot)
# library(reshape2)
# library(openxlsx)
# library(vegan)
warnings('off')
options(warn =-1)
options(digits=3)


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
require_library("reshape2")
require_library("corrplot")
require_library("pheatmap")
require_library("cowplot")
require_library("ggplot2")
require_library("vegan")
require_library("openxlsx")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))


dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_S9/Figure_S9.xlsx")


# ANOSIM analyse differences between regions
ANOSIM_panel <- function(Compared_region1,Compared_region2){
  
  Compared_regions <- rbind(Compared_region1,Compared_region2)
  Clusters.anosim <- anosim(Compared_regions[ ,c(1:8)], Compared_regions$clustertype,distance = "euclidean")
  plot(Clusters.anosim)
  mycol=c(52,619,453,71,134,448,548,655,574,36,544,89,120,131,596,147,576)
  mycol=colors()[mycol]
  par(mar=c(5,5,5,5))
  
  result=paste("R=",Clusters.anosim$statistic,"p=", Clusters.anosim$signif)
  panel <- boxplot(Clusters.anosim$dis.rank~Clusters.anosim$class.vec, outline = FALSE, pch="+", col=mycol, range=1, boxwex=0.5, notch=FALSE, ylab="Bray-Curtis Rank", main="Bray-Curtis Anosim", sub=result)

  return(panel)  
}  

#####################################
IGNN_response_training <-  read.xlsx( Data_file , sheet = "Model_response_on_Training")
IGNN_response_validation <-  read.xlsx( Data_file , sheet = "Model_response_on_Validation")
IGNN_response_all <- rbind(IGNN_response_training, IGNN_response_validation)

IGNN_response_training_clusters <- read.xlsx( Data_file , sheet = "Cluster_gnnlayer2_Training")
IGNN_response_validation_clusters <- read.xlsx( Data_file , sheet = "Cluster_gnnlayer2_Validation")
IGNN_response_clusters <- rbind(IGNN_response_training_clusters, IGNN_response_validation_clusters )


ROIs_with_TACS2_gnnlayer2out <- IGNN_response_all[ which(IGNN_response_all$TACS2==1), c(18:25) ]
ROIs_with_TACS3_gnnlayer2out <- IGNN_response_all[ which(IGNN_response_all$TACS3==1), c(18:25) ]
ROIs_with_TACS7_gnnlayer2out <- IGNN_response_all[ which(IGNN_response_all$TACS7==1), c(18:25) ]
ROIs_with_TACS8_gnnlayer2out <- IGNN_response_all[ which(IGNN_response_all$TACS8==1), c(18:25) ]


Cluster1_gnnlayer2out <- subset(IGNN_response_clusters[,c(2:10)], clustertype == 1 )
Cluster2_gnnlayer2out <- subset(IGNN_response_clusters[,c(2:10)], clustertype == 2 )
Cluster3_gnnlayer2out <- subset(IGNN_response_clusters[,c(2:10)], clustertype == 3 )




Compared_region1 <- ROIs_with_TACS2_gnnlayer2out
Compared_region1$clustertype <- 2
Compared_region2 <- Cluster2_gnnlayer2out
Compared_region2$clustertype <- 22

ROIs_with_TACS2_vs_Cluster2 <- ANOSIM_panel(Compared_region1,Compared_region2)











