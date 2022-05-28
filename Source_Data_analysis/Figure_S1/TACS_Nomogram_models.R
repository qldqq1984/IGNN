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



# TACS prognostic model  
TACS_model <- function(dataset, train=FALSE, model.coef, cutoff ){
	TACS_percentage <- as.matrix(dataset[,c(18:25)])
  	TACS_model_fit <- data.matrix(Surv(dataset$DFS,dataset$STATUS))
  	TACS_model <- glmnet(TACS_percentage, TACS_model_fit, family = "cox", alpha = 0.0)

  	if (train==TRUE){
		TACS_model.coef <- predict(TACS_model,  s= 0.03, type = "coefficients")
  		}else{
    		TACS_model.coef <- model.coef
   	}

	TACS_score <- as.matrix( TACS_percentage[,1] * TACS_model.coef[1] + TACS_percentage[,2] * TACS_model.coef[2] + TACS_percentage[,3] * TACS_model.coef[3] + TACS_percentage[,4] * TACS_model.coef[4] +
                           TACS_percentage[,5] * TACS_model.coef[5] + TACS_percentage[,6] * TACS_model.coef[6] + TACS_percentage[,7] * TACS_model.coef[7] + TACS_percentage[,8] * TACS_model.coef[8] )

	if (train==TRUE){
		roc <- survivalROC(Stime = dataset$DFS, status = dataset$STATUS, marker = TACS_score, predict.time = 60, method = "KM")
		optimal_cutoff <- roc$cut.values[which.max(roc$TP + (1 - roc$FP))]
	}else{
		optimal_cutoff = cutoff
	}
	TACS_risk <- ifelse(TACS_score > optimal_cutoff, 1, 0)
  
	print("TACS cutoff..............", cutoff)
	print(cutoff)
	
	model = {}
	model$model_score <- TACS_score
	model$model_risk = TACS_risk
	model$coef = TACS_model.coef
	model$cutoff = round(optimal_cutoff, 4)

	return(model)
}


# Nomogram prognostic model  
Nomogram_model <- function(dataset, TACS_score, train=FALSE, allcoefs, cutoff ){
	dataset$age <- ifelse(dataset$age  > 50, 1, 0)
  	dataset$age <- factor(dataset$age,labels=c('1','2'))
  	dataset$type <- factor(dataset$type,labels=c('1','2','3','4'))
  	dataset$size <- factor(dataset$size,labels=c('1','2','3'))
  	dataset$lym <- factor(dataset$lym,labels=c('1','2', '3'))
  	dataset$stage <- factor(dataset$stage,labels=c('1','2','3'))
  	dataset$grade <- factor(dataset$grade,labels=c('1','2','3'))
  	dataset$Chemotherapy <- factor(dataset$Chemotherapy,labels=c('1','2'))
  	dataset$Radiation <- factor(dataset$Radiation,labels=c('1','2'))

	coefs = {}
	if (train==TRUE){
		clinical_fcox  <- coxph(Surv(DFS,STATUS) ~ age + type + size + lym + stage + grade + Chemotherapy + Radiation  ,data=dataset)
		clinical_coef = {}
		clinical_coef$age <- c(0.0,clinical_fcox$coefficients[1])
		clinical_coef$type <- c(0.0,clinical_fcox$coefficients[2],clinical_fcox$coefficients[3],clinical_fcox$coefficients[4])
		clinical_coef$size <- c(0.0,clinical_fcox$coefficients[5],clinical_fcox$coefficients[6])
		clinical_coef$lym <- c(0.0,clinical_fcox$coefficients[7],clinical_fcox$coefficients[8])
		clinical_coef$stage <- c(0.0,clinical_fcox$coefficients[9],clinical_fcox$coefficients[10])
		clinical_coef$grade <- c(0.0,clinical_fcox$coefficients[11],clinical_fcox$coefficients[12])
		clinical_coef$Chemotherapy <- c(0.0,clinical_fcox$coefficients[13])
		clinical_coef$Radiation <- c(0.0,clinical_fcox$coefficients[14])
            coefs$clinicalfactor_coef <- clinical_coef
	}else{	
		clinical_coef <- allcoefs$clinicalfactor_coef
	}

	clinical_score <-  as.matrix( clinical_coef$age[dataset$age] + clinical_coef$type[dataset$type] + clinical_coef$size[dataset$size] + clinical_coef$lym[dataset$lym] + clinical_coef$stage[dataset$stage] + clinical_coef$grade[dataset$grade] + clinical_coef$Chemotherapy[dataset$Chemotherapy] + clinical_coef$Radiation[dataset$Radiation] )

	if (train==TRUE){
		fcox <- coxph(Surv(DFS,STATUS) ~ clinical_score + TACS_score ,data = dataset)
		clinical_score_coef <- c(fcox$coefficients[1])
		TACS_score_coef <- c(fcox$coefficients[2])
    coefs$clinical_score_coef <- clinical_score_coef
		coefs$TACS_score_coef <- TACS_score_coef
	}else{
		clinical_score_coef <- allcoefs$clinical_score_coef
		TACS_score_coef <- allcoefs$TACS_score_coef
	}

	Nomogram_score <-  clinical_score_coef*clinical_score + TACS_score_coef*TACS_score

	if (train==TRUE){
		roc <- survivalROC(Stime = dataset$DFS, status = dataset$STATUS, marker = Nomogram_score, predict.time = 60, method = "KM")
		optimal_cutoff <- roc$cut.values[which.max(roc$TP + (1 - roc$FP))]
	}else{
		optimal_cutoff = cutoff
	}
	Nomogram_risk <- ifelse(Nomogram_score >= optimal_cutoff, 1, 0)

	print("Nomogram cutoff..............", cutoff)
	print(cutoff)
	
	model = {}
	model$model_score <- Nomogram_score
	model$model_risk = Nomogram_risk
	model$coefs = coefs
	model$cutoff = round(optimal_cutoff, 4)
       
  return(model)
}





