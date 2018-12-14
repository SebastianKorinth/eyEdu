EyEduDetectFixationsIDT <- function(dispersion.var = 70, 
                                   duration.var = 7,
                                   use.filtered = FALSE,
                                   participant.list = NULL) {

load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = "")) 

# check whether fixation detection has been executed before, if not
# variables in the participant table will be created that will collect
# information about if and how fixation detection was performed
if(is.null(eyEdu.data$participant.table$fixation.detection)){
  eyEdu.data$participant.table$fixation.detection <- "No"
  eyEdu.data$participant.table$duration.var <- NA
  eyEdu.data$participant.table$dispersion.var <- NA
  eyEdu.data$participant.table$filtered <- NA
}  

# checks whether fixation detection is limited to a subset of participants
# default is all participants  
if(is.null(participant.list)){
  participant.vector <- 1:length(eyEdu.data$participants)
  mismatch.indicator <- FALSE
} 

# for the case that participant numbers were provided to subset participants  
if (is.numeric(participant.list)){
  participant.vector <- eyEdu.data$participant.table$list.entry[
    is.element(eyEdu.data$participant.table$part.nr,participant.list)]
  if(length(participant.vector) != length(participant.list)){
    mismatch.indicator <- TRUE
  } else {mismatch.indicator <- FALSE}
}    

# for the case that participant names were provided to subset participants   
if (is.character(participant.list)){
    participant.vector <- eyEdu.data$participant.table$list.entry[
      is.element(eyEdu.data$participant.table$part.name,participant.list)]
  if(length(participant.vector) != length(participant.list)){
    mismatch.indicator <- TRUE
  } else {mismatch.indicator <- FALSE}
  }    
    
# just for feedback on processing progress 
iteration.counter <- 1  

for(participant.counter in participant.vector){

# Initiates empty data frame 
fixation.data <- data.frame(fix.start = numeric(),
                            fix.end = numeric(), 
                            fix.dur = numeric(), 
                            pos.x = numeric(),
                            pos.y = numeric(),
                            fixation.index = numeric(),
                            trial.index = numeric(),
                            stimulus.id = numeric())  

# For each trial sample data are first extracted, fixation detection is
# conducted, and results are writen into a data frame labeled fixation.data

for(trial.counter in 1:max(eyEdu.data$participants[[
  participant.counter]]$trial.info$trial.index)) {
  
  if(use.filtered == TRUE & is.null(eyEdu.data$participants[[
    participant.counter]]$sample.data$x.filt)){
    return("No filtered data available. Please run EyEduLowPassFilter() or set use.filtered = FALSE")
    
  }

# The warning message "max(y_win, na.rm = T) : 
# no non-missing arguments to max; returning -Inf" will be suppressed

  if (use.filtered == TRUE ) {
    
    fixation.data.temp = suppressWarnings(  emov.idt(eyEdu.data$participants[[
      participant.counter]]$sample.data$time[eyEdu.data$participants[[
        participant.counter]]$sample.data$trial.index==trial.counter], 
      eyEdu.data$participants[[participant.counter]]$sample.data$x.filt[
        eyEdu.data$participants[[
          participant.counter]]$sample.data$trial.index==trial.counter], 
      eyEdu.data$participants[[participant.counter]]$sample.data$y.filt[
        eyEdu.data$participants[[
          participant.counter]]$sample.data$trial.index==trial.counter],
      dispersion.var, 
      duration.var))
    
  } else {
  
  fixation.data.temp = suppressWarnings(  emov.idt(eyEdu.data$participants[[
  participant.counter]]$sample.data$time[eyEdu.data$participants[[
  participant.counter]]$sample.data$trial.index==trial.counter], 
  eyEdu.data$participants[[participant.counter]]$sample.data$rawx[
  eyEdu.data$participants[[
  participant.counter]]$sample.data$trial.index==trial.counter], 
  eyEdu.data$participants[[participant.counter]]$sample.data$rawy[
  eyEdu.data$participants[[
  participant.counter]]$sample.data$trial.index==trial.counter],
  dispersion.var, 
  duration.var))

  }

  
if (nrow(fixation.data.temp) == 0) {
  next
}

colnames(fixation.data.temp)<- c("fix.start", 
                                 "fix.end", "fix.duration", 
                                 "fix.pos.x", "fix.pos.y")

fixation.data.temp$fixation.index <- 1: nrow(fixation.data.temp)
fixation.data.temp$trial.index <- eyEdu.data$participants[[
  participant.counter]]$trial.info$trial.index[trial.counter]
fixation.data.temp$stimulus.id <- eyEdu.data$participants[[
  participant.counter]]$trial.info$stimulus.id[trial.counter]
fixation.data <- rbind(fixation.data, fixation.data.temp)

}

# The data frame fixation.data is written at its position corresponding to the
# list.entry number within the eyEdu.data.Rda file 
eyEdu.data$participants[[participant.counter]][4] <- list(fixat=fixation.data)
names(eyEdu.data$participants[[participant.counter]])[4]<- "fixation.data"

# info about parameters used for fixation detection are written into participant table
eyEdu.data$participant.table$fixation.detection[participant.counter] <- "Yes"
eyEdu.data$participant.table$duration.var[participant.counter] <- duration.var
eyEdu.data$participant.table$dispersion.var[participant.counter] <- dispersion.var
eyEdu.data$participant.table$filtered[participant.counter] <- use.filtered

# Providing some feedback on processing progress.
processed.participant <- names(eyEdu.data$participants[participant.counter])
print(paste("Fixation detection for:",
            processed.participant, 
            "- number", iteration.counter, 
            "out of", 
            length(participant.vector), sep = " "))

iteration.counter <- iteration.counter + 1

}

save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
if(mismatch.indicator == T) {return("There was a mismatch between participant.list and actually processed participants!")}
return("Done!")
}

