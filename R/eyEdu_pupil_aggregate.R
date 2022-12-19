EyEduPupilAggregate <- function(data= NULL,
                                measurevar = NULL, 
                                groupvars = NULL, 
                                na.rm=T, 
                                conf.interval=.95) {
  
  # This is not a genuine eyEdu function. When I started to learn R, I have 
  # copy-&-pasted this function somewhere and I do not remember where. Thanks a
  # lot to whoever wrote it! 
  
  library(doBy)
  
  # Handling missing values
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # Collapse the data
  formula <- as.formula(paste(measurevar, paste(groupvars, collapse=" + "), sep=" ~ "))
  datac <- summaryBy(formula, data=data, FUN=c(length2,mean,sd), na.rm=na.rm)
  
  # Rename columns
  names(datac)[ names(datac) == paste(measurevar, ".mean",    sep="") ] <- measurevar
  names(datac)[ names(datac) == paste(measurevar, ".sd",      sep="") ] <- "sd"
  names(datac)[ names(datac) == paste(measurevar, ".length2", sep="") ] <- "N"
  datac$se <- datac$sd / sqrt(datac$N)
  
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}
  