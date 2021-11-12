# library(ggplot2)
# library(ggpubr)
# library(openxlsx)
options(digits=3)
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
require_library("ggpubr")
require_library("openxlsx")


windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))


dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_S10/Figure_S10.xlsx")

TACS_data <- read.xlsx( Data_file , sheet = "TACS_percentages")


Patients <- factor(TACS_data$y);
Patients <- ifelse(Patients ==1, "DFS <= 5 years", "DFS > 5 years")


TACS1_percentage <- data.frame( percentage = as.numeric(TACS_data$TACS1), Patients , type=c(rep("TACS1", 995)) )
TACS2_percentage <- data.frame( percentage = as.numeric(TACS_data$TACS2), Patients , type=c(rep("TACS2", 995)) )
TACS3_percentage <- data.frame( percentage = as.numeric(TACS_data$TACS3), Patients , type=c(rep("TACS3", 995)) )
TACS4_percentage <- data.frame( percentage = as.numeric(TACS_data$TACS4), Patients , type=c(rep("TACS4", 995)) )
TACS5_percentage <- data.frame( percentage = as.numeric(TACS_data$TACS5), Patients , type=c(rep("TACS5", 995)) )
TACS6_percentage <- data.frame( percentage = as.numeric(TACS_data$TACS6), Patients , type=c(rep("TACS6", 995)) )
TACS7_percentage <- data.frame( percentage = as.numeric(TACS_data$TACS7), Patients , type=c(rep("TACS7", 995)) )
TACS8_percentage <- data.frame( percentage = as.numeric(TACS_data$TACS8), Patients , type=c(rep("TACS8", 995)) )

TACS_patterns_percentage <-  rbind(TACS1_percentage, TACS2_percentage, TACS3_percentage, TACS4_percentage,
                                   TACS5_percentage, TACS6_percentage, TACS7_percentage, TACS8_percentage)


# TACS_patterns_percentage_panel shows differences in percentage of each TACS from patients with DFS over or less than 5 years
TACS_patterns_percentage_panel <- ggline(TACS_patterns_percentage, x="type", y="percentage", 
                                          add = "mean_se", 
                                          color = "Patients", 
                                          #palette = "Set1" ,
                                          palette = c("orangered", "dodgerblue") ,
                                          linetype = 'dashed', 
                                          size = 0.9,
                                          point.size=0.8,
                                          shape = 10 ,
                                          alpha = 0.1)+
                                          rotate_x_text(angle = 0)+
                                  stat_compare_means(aes(group=Patients), 
                                          label = "p.signif",
                                          label.y = c(0.30, 0.12, 0.06, 0.53, 0.20, 0.45, 0.15, 0.12),size=8)+
                                  theme(text=element_text(family="ARL"),
                                          axis.title.x=element_text(size=25),
                                          axis.title.y=element_text(size=25),
                                          axis.text.x = element_text(size=25),
                                          axis.text.y = element_text(size=25),
                                          legend.key= element_blank(),
                                          legend.text = element_text(size=25))+
                                  labs(x = " ", 
                                       y = "Average percentage\n")



# ggsave(JPG, file="Figure_S10_d.emf",width=18, height=7)


