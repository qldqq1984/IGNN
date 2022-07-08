# library(corrplot)
# library(openxlsx)
# library(reshape2)
# library(ggplot2)
# library(ggthemes)
# library(ggpubr)
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
require_library("ggpubr")
require_library("reshape2")
require_library("openxlsx")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))

dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Source Data/Figure_4/Figure_4.xlsx")



# Spearman Correlation analysis between individual TACSs and TACS score and IGNN score
Spearman_analysis <- function(Spearman_data, model_type){
   
   if (model_type == "TACS1-8") {
      model_score <- Spearman_data$TACS_score
   }
   else if (model_type == "IGNN") {
      model_score <- Spearman_data$IGNN_score
   }
   
   TACS_percentage <- list()
   Spearman_correlation_coefficients <-  array()
   
   for(i in 1:8)
   {
      TACS_percentage[[i]] <- Spearman_data[[2+i]];
      TACS <- TACS_percentage[[i]]
      
      Spearman_correlation_coefficients[i]<- cor(x=TACS,y=model_score,method = c("spearman"))
      
   }

Data<-data.frame(Spearman_correlation_coefficients )
row.names(Data)<-c("TACS1","TACS2","TACS3","TACS4","TACS5","TACS6","TACS7","TACS8")
colnames(Data) <- c("Spearman_score")
Data$GRP <- factor(ifelse(Data$Spearman_score < 0, "-", "+"), levels = c("-", "+"))
Data$name <- rownames(Data)

return (Data)
}


#  Spearman panel drawing
Spearman_panel <- function(Spearman_results){

   panel<-ggbarplot(Spearman_results, x = "name", y = "Spearman_score",
                  fill = "GRP",               # change fill color by mpg_level
                  color = "white",            # Set bar border colors to white
                  palette = c("#BC3C29FF","#0072B5FF"),            # jco journal color palett. see ?ggpar
                  sort.val = "desc",          # Sort the value in descending order
                  sort.by.groups = FALSE,     # Don't sort inside each group
                  x.text.angle = 0,           # Rotate vertically x axis texts
                  xlab = " ",
                  ylab = " ",
                  #ylab = "Spearman's rank correlation coefficient",
                  legend = "none",
                  rotate = TRUE,
                  ggtheme = theme_minimal() )+
      scale_y_continuous(breaks = seq(-0.8, 1.0, 0.2), labels = seq(-0.8, 1.0, 0.2),limits = c(-0.8, 1.0)  ) +
      theme(text=element_text(family="ARL"),
            axis.title.x=element_text(size=30),
            axis.title.y=element_text(size=30),
            #axis.text.x = element_blank(),
            axis.text.x = element_text(size=25),
            axis.text.y = element_text(size=28),
            plot.title = element_text(size =30),
            legend.position = "none",
            legend.key= element_blank(),
            legend.text = element_text(size=30))
   
   return(panel)
}



   
# Spearman Correlation analysis between individual TACSs and TACS score for all 995 patients
Spearman_data <- read.xlsx( Data_file , sheet = "Spearman")
TACS_Spearman_analysis_results <- Spearman_analysis(Spearman_data,  model_type="TACS1-8")
TACS_Spearman_analysis_panel <- Spearman_panel(TACS_Spearman_analysis_results)

# Spearman Correlation analysis between individual TACSs and IGNN score for all 995 patients
IGNN_Spearman_analysis_results <- Spearman_analysis(Spearman_data,  model_type="IGNN")
IGNN_Spearman_analysis_panel <- Spearman_panel(IGNN_Spearman_analysis_results)





