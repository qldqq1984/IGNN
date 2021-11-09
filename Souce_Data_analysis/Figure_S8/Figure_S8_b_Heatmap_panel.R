# library(corrplot)
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
require_library("corrplot")
require_library("openxlsx")



windowsFonts(HEL=windowsFont("Helvetica CE 55 Roman"),
             RMN=windowsFont("Times New Roman"),
             ARL=windowsFont("Arial"))


dir_root = dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
Data_file = paste0(dir_root,"/Souce Data/Figure_S8/Figure_S8.xlsx")



# Analysis of IGN model response using Pearson correlation coefficient 
Pearson_correlation_analysis <- function(model_response_data, model_response_type, ROI_range ){
  if (model_response_type == "TACScoding"){
    model_response  <- model_response_data[,c(2:9)]
  }
  else if (model_response_type == "Gnnlayer1out"){
    model_response  <- model_response_data[,c(10:17)]
  }
  else if (model_response_type == "Gnnlayer2out"){
    model_response  <- model_response_data[,c(18:25)]
  }
  model_response  <- model_response [ROI_range,]
  
  Pearson_cormatrix_original <- cor(t(model_response))
  Pearson_cormatrix_order <- corrMatOrder(Pearson_cormatrix_original, order = "FPC")
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
                order="alphabet",
                addCoef.col = "grey",
                tl.pos="n",
                number.cex = 1.6
  )
  
  return(panel)
} 


IGNN_response_validation <- read.xlsx( Data_file , sheet = "IGNN_response_validation")


# Pearson correlation analysis of graph node features for patient1
IGNN_response_patient1_TACScoding_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_validation, ROI_range = c(526:536), "TACScoding" )
IGNN_response_patient1_TACScoding_Heatmap_panel <- Heatmap_panel(IGNN_response_patient1_TACScoding_Pearson_cormatrix)

IGNN_response_patient1_Gnnlayer1out_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_validation, ROI_range = c(526:536), "Gnnlayer1out" )
IGNN_response_patient1_Gnnlayer1out_Heatmap_panel <- Heatmap_panel(IGNN_response_patient1_Gnnlayer1out_Pearson_cormatrix)

IGNN_response_patient1_Gnnlayer2out_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_validation, ROI_range = c(526:536), "Gnnlayer2out" )
IGNN_response_patient1_Gnnlayer2out_Heatmap_panel <- Heatmap_panel(IGNN_response_patient1_Gnnlayer2out_Pearson_cormatrix)


# Pearson correlation analysis of graph node features for patient2
IGNN_response_patient2_TACScoding_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_validation, ROI_range = c(868:876), "TACScoding" )
IGNN_response_patient2_TACScoding_Heatmap_panel <- Heatmap_panel(IGNN_response_patient2_TACScoding_Pearson_cormatrix)

IGNN_response_patient2_Gnnlayer1out_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_validation, ROI_range = c(868:876), "Gnnlayer1out" )
IGNN_response_patient2_Gnnlayer1out_Heatmap_panel <- Heatmap_panel(IGNN_response_patient2_Gnnlayer1out_Pearson_cormatrix)

IGNN_response_patient2_Gnnlayer2out_Pearson_cormatrix <- Pearson_correlation_analysis(IGNN_response_validation, ROI_range = c(868:876), "Gnnlayer2out" )
IGNN_response_patient2_Gnnlayer2out_Heatmap_panel <- Heatmap_panel(IGNN_response_patient2_Gnnlayer2out_Pearson_cormatrix)




