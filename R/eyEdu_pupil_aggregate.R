EyEduPupilAggregate <- function(sample.summary = NULL,
                                pupil.var = NULL, 
                                group.vars = NULL, 
                                na.rm = TRUE, 
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
  formula <- as.formula(paste(pupil.var, paste(group.vars, collapse=" + "), sep=" ~ "))
  sample.aggregated <- summaryBy(formula, data=sample.summary, FUN=c(length2,mean,sd), na.rm=na.rm)
  
  # Rename columns
  names(sample.aggregated)[ names(sample.aggregated) == paste(pupil.var, ".mean",    sep="") ] <- paste0(pupil.var, ".mean")
  names(sample.aggregated)[ names(sample.aggregated) == paste(pupil.var, ".sd",      sep="") ] <- "sd"
  names(sample.aggregated)[ names(sample.aggregated) == paste(pupil.var, ".length2", sep="") ] <- "N"
  sample.aggregated$se <- sample.aggregated$sd / sqrt(sample.aggregated$N)
  
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, sample.aggregated$N-1)
  sample.aggregated$ci <- sample.aggregated$se * ciMult
  
  save(sample.aggregated, file = paste(raw.data.path, "sample_aggregated.Rda", sep = ""))
}
  