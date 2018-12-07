EyEduLowPassFilter <- function(filter.settings = rep(1/3, 3)) {

load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))  

for(participant.counter in 1:length(eyEdu.data$participants)){
  
  sample.data <- eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
  x.filt <- NA
  y.filt <- NA
  for(trial.counter in 1:max(eyEdu.data$participants[[
    participant.counter]]$trial.info$trial.index)) {  
  
    trial.sample.data <- sample.data[sample.data$trial.index == trial.counter,]
    x.filt.temp <- as.numeric(filter(trial.sample.data$rawx, filter.settings))
    y.filt.temp <- as.numeric(filter(trial.sample.data$rawy, filter.settings))
    
    x.filt <- c(x.filt, x.filt.temp)
    y.filt <- c(y.filt, y.filt.temp)
  }  # end trial loop
  
  # deletes the first NA that was used to initiate an empty vector
  x.filt <- x.filt[-1]
  y.filt <- y.filt[-1]
  
  eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$x.filt <- x.filt
  eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$y.filt <- y.filt
  
  
  # Providing some feedback on processing progress.
  processed.participant <- names(eyEdu.data$participants[participant.counter])
  print(paste("Low-pass filtering: ",
              processed.participant, 
              "- number", participant.counter, 
              "out of", 
              max(length(eyEdu.data$participants)), sep = " ")) 
  
} # end participant loop
  
  save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
} # end function

