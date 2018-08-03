EyEduDetectFixationsIDT <- function(dispersion.var = 70, 
                                   duration.var = 7){

load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))  

for(participant.counter in 1:length(eyEdu.data$participants)){
  
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

# The warning message "max(y_win, na.rm = T) : 
# no non-missing arguments to max; returning -Inf" will be suppressed

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
  duration.var)
)

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
# participant number within the eyEdu.data.Rda file 
eyEdu.data$participants[[participant.counter]][4] <- list(fixat=fixation.data)
names(eyEdu.data$participants[[participant.counter]])[4]<- "fixation.data"

# Providing some feedback on processing progress.
processed.participant <- names(eyEdu.data$participants[participant.counter])
print(paste("Fixation detection for:",
            processed.participant, 
            "- number", participant.counter, 
            "out of", 
            max(length(eyEdu.data$participants)), sep = " "))
}

save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

return("Done!")
}

