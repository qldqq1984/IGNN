# library(glmnet)
# library(foreign)
# library(survminer)
# library(survivalROC)
# library(survival)
set.seed(1)
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
require_library("glmnet")
require_library("foreign")
require_library("survminer")
require_library("survivalROC")
require_library("survival")



# IGNN prognostic  model
IGNN_model <- function(dataset, train=FALSE, cutoff ){

	IGNN_score <- 1.0 * dataset$model_score
	if (train==TRUE){
		roc <- survivalROC(Stime = dataset$DFS, status = dataset$STATUS, marker = IGNN_score, predict.time = 60, method = "KM")
		optimal_cutoff <- roc$cut.values[which.max(roc$TP + (1 - roc$FP))]
	}else{
		optimal_cutoff = cutoff
	}
	IGNN_risk <- ifelse(IGNN_score > optimal_cutoff, 1, 0)
  
 print("IGNN cutoff..............", cutoff)
 print(cutoff)
 
	model = {}
  	model$model_score <- IGNN_score
	model$model_risk = IGNN_risk
	model$cutoff = optimal_cutoff

	return(model)
}



# IGNNE prognostic model 
IGNNE_model <- function(dataset, train=FALSE, cutoff ){
  
  IGNNE_score <- 1.0 * dataset$model_score
  if (train==TRUE){
    roc <- survivalROC(Stime = dataset$DFS, status = dataset$STATUS, marker = IGNNE_score, predict.time = 60, method = "KM")
    optimal_cutoff <- roc$cut.values[which.max(roc$TP + (1 - roc$FP))]
  }else{
    optimal_cutoff = cutoff
  }
  IGNNE_risk <- ifelse(IGNNE_score > optimal_cutoff, 1, 0)
  
  print("IGNNE cutoff..............", cutoff)
  print(cutoff)
  
  model = {}
  model$model_score <- IGNNE_score
  model$model_risk = IGNNE_risk
  model$cutoff = optimal_cutoff
  
  return(model)
}


