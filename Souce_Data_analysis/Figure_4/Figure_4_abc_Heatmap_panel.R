# library(corrplot)
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
require_library("corrplot")
require_library("openxlsx")




windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))

dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Souce Data/Figure_4/Figure_4.xlsx")


# Analysis of IGN model response using Pearson correlation coefficient 
Pearson_correlation_analysis <- function(model_response_data, data_type, model_response_type){
   if (model_response_type == "TACScoding"){
      model_response  <- model_response_data[,c(2:9)]
   }
   else if (model_response_type == "Gnnlayer1out"){
      model_response  <- model_response_data[,c(10:17)]
   }
   else if (model_response_type == "Gnnlayer2out"){
      model_response  <- model_response_data[,c(18:25)]
   }

   Pearson_cormatrix_original <- cor(t(model_response))
   Pearson_cormatrix_order <- corrMatOrder(Pearson_cormatrix_original, order = "AOE")
   if (data_type == "Tumorsize_2cm" & model_response_type == "Gnnlayer2out"){
      Pearson_cormatrix_order <-c( rev(Pearson_cormatrix_order[c(1:1279)]),  rev(Pearson_cormatrix_order[c(1959:3190)]), rev(Pearson_cormatrix_order[c(1280:1958)])  ) 
   }
   Pearson_cormatrix.AOE <- Pearson_cormatrix_original[Pearson_cormatrix_order, Pearson_cormatrix_order]


   return (Pearson_cormatrix.AOE)
   
}


# Heatmap panel drawing, Heatmap panel show the Heatmap of Pearson correlation matrix of model response 
Heatmap_panel <- function(Pearson_cormatrix){

   col1 <- colorRampPalette(c("#67001F", "#B2182B", "#D6604D", "#F4A582",
                              "#FDDBC7", "#FFFFFF", "#D1E5F0", "#92C5DE",
                              "#4393C3", "#2166AC", "#053061"))

   panel <- corrplot(Pearson_cormatrix,
                 method = "color",
                 order="original",
                 #addCoef.col = "grey",
                 tl.pos="n")
   
   return(panel)
}   



   
# Training (n=731) 
IGNN_response_Training <- read.xlsx( Data_file , sheet = "Model_response_on_Training")
IGNN_response_Training_TACScoding_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_Training, data_type="Training", "TACScoding" )
IGNN_response_Training_TACScoding_Heatmap_panel <- Heatmap_panel(IGNN_response_Training_TACScoding_Pearson_cormatrix)

IGNN_response_Training_Gnnlayer1out_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_Training, data_type="Training","Gnnlayer1out" )
IGNN_response_Training_Gnnlayer1out_Heatmap_panel <- Heatmap_panel(IGNN_response_Training_Gnnlayer1out_Pearson_cormatrix)

sponse_Training_Gnnlayer2out_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_Training, data_type="Training",  "Gnnlayer2out"  )
IGNN_response_Training_Gnnlayer2out_Heatmap_panel <- Heatmap_panel(IGNN_response_Training_Gnnlayer2out_Pearson_cormatrix)


# Validation (n=264) 
IGNN_response_Validation <- read.xlsx( Data_file , sheet = "Model_response_on_Validation")
IGNN_response_Validation_TACScoding_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_Validation, data_type="Validation", "TACScoding" )
IGNN_response_Validation_TACScoding_Heatmap_panel <- Heatmap_panel(IGNN_response_Validation_TACScoding_Pearson_cormatrix)

IGNN_response_Validation_Gnnlayer1out_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_Validation, data_type="Validation", "Gnnlayer1out" )
IGNN_response_Validation_Gnnlayer1out_Heatmap_panel <- Heatmap_panel(IGNN_response_Validation_Gnnlayer1out_Pearson_cormatrix)

IGNN_response_Validation_Gnnlayer2out_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_Validation, data_type="Validation", "Gnnlayer2out"  )
IGNN_response_Validation_Gnnlayer2out_Heatmap_panel <- Heatmap_panel(IGNN_response_Validation_Gnnlayer2out_Pearson_cormatrix)


# Tumor size <= 2cm (n=445) 
IGNN_response_Tumorsize_2cm <- read.xlsx( Data_file , sheet = "Model_response_on_Tumorsize_2cm")
IGNN_response_tumorsize_2cm_TACScoding_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_Tumorsize_2cm, data_type="Tumorsize_2cm", "TACScoding" )
IGNN_response_tumorsize_2cm_TACScoding_Heatmap_panel <- Heatmap_panel(IGNN_response_tumorsize_2cm_TACScoding_Pearson_cormatrix)

IGNN_response_tumorsize_2cm_Gnnlayer1out_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_Tumorsize_2cm, data_type="Tumorsize_2cm",  "Gnnlayer1out"  )
IGNN_response_tumorsize_2cm_Gnnlayer1out_Heatmap_panel <- Heatmap_panel(IGNN_response_tumorsize_2cm_Gnnlayer1out_Pearson_cormatrix)

IGNN_response_tumorsize_2cm_Gnnlayer2out_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_Tumorsize_2cm, data_type="Tumorsize_2cm", "Gnnlayer2out")
IGNN_response_tumorsize_2cm_Gnnlayer2out_Heatmap_panel <- Heatmap_panel(IGNN_response_tumorsize_2cm_Gnnlayer2out_Pearson_cormatrix)




