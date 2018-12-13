EyEduLowPassFilter <- function(filter.settings = rep(1/3, 3)) {

load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))  

for(participant.counter in 1:length(eyEdu.data$participants)){
  
  sample.data <- eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
  x.filt <- NA
  y.filt <- NA
  R.x.filt <- NA
  R.y.filt <- NA
  L.x.filt <- NA
  L.y.filt <- NA
  
  for(trial.counter in 1:max(eyEdu.data$participants[[
    participant.counter]]$trial.info$trial.index)) {  
  
    trial.sample.data <- sample.data[sample.data$trial.index == trial.counter,]
    x.filt.temp <- as.numeric(filter(trial.sample.data$rawx, filter.settings))
    y.filt.temp <- as.numeric(filter(trial.sample.data$rawy, filter.settings))
    R.x.filt.temp <- as.numeric(filter(trial.sample.data$Rrawx, filter.settings))
    R.y.filt.temp <- as.numeric(filter(trial.sample.data$Rrawy, filter.settings))
    L.x.filt.temp <- as.numeric(filter(trial.sample.data$Lrawx, filter.settings))
    L.y.filt.temp <- as.numeric(filter(trial.sample.data$Lrawy, filter.settings))
    
    x.filt <- c(x.filt, x.filt.temp)
    y.filt <- c(y.filt, y.filt.temp)
    R.x.filt <- c(R.x.filt, R.x.filt.temp)
    R.y.filt <- c(R.y.filt, R.y.filt.temp)
    L.x.filt <- c(L.x.filt, L.x.filt.temp)
    L.y.filt <- c(L.y.filt, L.y.filt.temp)
    
    
  }  # end trial loop
  
  # deletes the first NA that was used to initiate an empty vector
  x.filt <- x.filt[-1]
  y.filt <- y.filt[-1]
  R.x.filt <- R.x.filt[-1]
  R.y.filt <- R.y.filt[-1]
  L.x.filt <- L.x.filt[-1]
  L.y.filt <- L.y.filt[-1]
  
  eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$x.filt <- x.filt
  eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$y.filt <- y.filt
  eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$R.x.filt <- R.x.filt
  eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$R.y.filt <- R.y.filt
  eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$L.x.filt <- L.x.filt
  eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$L.y.filt <- L.y.filt
  
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

