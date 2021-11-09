# library(ggplot2)
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
require_library("openxlsx")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))


dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Souce Data/Figure_S10/Figure_S10.xlsx")


# TACS distribution panel drawing, TACS_distribution_panel shows the distribution characteristics of the TACS1-8 in 995 patients
TACS_distribution_panel <-function(TACS_pattern, TACS_id){
  
  panel <- ggplot(TACS_pattern, aes( x = TACS ) ) +
    geom_histogram(position="identity", alpha=1,fill="steelblue")+
    theme(text=element_text(family="ARL"),
          panel.grid.minor = element_blank(),
          axis.line = element_blank(),
          axis.title.x= element_text(size=20),
          axis.title.y= element_text(size=20),
          axis.text.x = element_text(size=19),
          axis.text.y = element_text(size=19),
          plot.title = element_text(size =18),
          legend.key=element_blank(),
          legend.text = element_text(size=18))+
    labs(x = paste0("\nPercentage of TACS",TACS_id), 
         y = "Sample size\n")
  return(panel)
}


TACS_data <- read.xlsx( Data_file , sheet = "TACS_percentages")

TACS1_pattern <- data.frame(TACS = TACS_data$TACS1)
TACS2_pattern <- data.frame(TACS = TACS_data$TACS2)
TACS3_pattern <- data.frame(TACS = TACS_data$TACS3)
TACS4_pattern <- data.frame(TACS = TACS_data$TACS4)
TACS5_pattern <- data.frame(TACS = TACS_data$TACS5)
TACS6_pattern <- data.frame(TACS = TACS_data$TACS6)
TACS7_pattern <- data.frame(TACS = TACS_data$TACS7)
TACS8_pattern <- data.frame(TACS = TACS_data$TACS8)

TACS1_distribution_panel <- TACS_distribution_panel(TACS1_pattern, 1)
TACS2_distribution_panel <- TACS_distribution_panel(TACS2_pattern, 2)
TACS3_distribution_panel <- TACS_distribution_panel(TACS3_pattern, 3)
TACS4_distribution_panel <- TACS_distribution_panel(TACS4_pattern, 4)
TACS5_distribution_panel <- TACS_distribution_panel(TACS5_pattern, 5)
TACS6_distribution_panel <- TACS_distribution_panel(TACS6_pattern, 6)
TACS7_distribution_panel <- TACS_distribution_panel(TACS7_pattern, 7)
TACS8_distribution_panel <- TACS_distribution_panel(TACS8_pattern, 8)


# ggsave(TACS1_distribution_panel, file="Figure_S10_a_1.emf",width=6, height=3.5)
# ggsave(TACS2_distribution_panel, file="Figure_S10_a_2.emf",width=6, height=3.5)
# ggsave(TACS3_distribution_panel, file="Figure_S10_a_3.emf",width=6, height=3.5)
# ggsave(TACS4_distribution_panel, file="Figure_S10_a_4.emf",width=6, height=3.5)
# ggsave(TACS5_distribution_panel, file="Figure_S10_a_5.emf",width=6, height=3.5)
# ggsave(TACS6_distribution_panel, file="Figure_S10_a_6.emf",width=6, height=3.5)
# ggsave(TACS7_distribution_panel, file="Figure_S10_a_7.emf",width=6, height=3.5)
# ggsave(TACS8_distribution_panel, file="Figure_S10_a_8.emf",width=6, height=3.5)




