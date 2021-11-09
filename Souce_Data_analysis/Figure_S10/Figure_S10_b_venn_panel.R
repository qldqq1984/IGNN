# library(UpSetR)
# library(dplyr)
# library(tidyr)
# rm(list=ls())
# require(cowplot)
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
require_library("UpSetR")
require_library("dplyr")
require_library("tidyr")
require_library("cowplot")
require_library("openxlsx")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))


dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Souce Data/Figure_S10/Figure_S10.xlsx")

TACS_data <- read.xlsx( Data_file , sheet = "TACS_percentages")

TACS1<-TACS_data$TACS1
TACS2<-TACS_data$TACS2
TACS3<-TACS_data$TACS3
TACS4<-TACS_data$TACS4
TACS5<-TACS_data$TACS5
TACS6<-TACS_data$TACS6
TACS7<-TACS_data$TACS7
TACS8<-TACS_data$TACS8

TACS_patterns <- data.frame(TACS1,TACS2,TACS3,TACS4,TACS5,TACS6,TACS7,TACS8)
TACS_patterns[TACS_patterns==0]<- 0
TACS_patterns[TACS_patterns>0]<- 1


# Venn panel shows the size distribution of samples with multiple specific TACS patterns
Venn_panel<-upset(TACS_patterns, 
                   nsets = 8, 
                   number.angles = 0, 
                   point.size = 2,
                   line.size = 1,
                   mainbar.y.label = " ",  #"Number of samples sharing the same TACS patterns",
                   sets.x.label = " ",     #"Number of samples with the specific TACS patterns",
                   main.bar.color = "steelblue",
                   sets.bar.color = "steelblue",
                   shade.color = "steelblue",
                   scale.sets = "identity",
                   text.scale = c(1.5, 1.5, 1.5, 1.5, 1.5, 1.5)
                   ) 





