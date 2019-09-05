EyEduSmooth <- function() {
  
  load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))  
  
  for(participant.counter in 1:length(eyEdu.data$participants)){
    
    sample.data <- eyEdu.data[["participants"]][[participant.counter]][[
    "sample.data"]]
    x.filt <- NA
    y.filt <- NA
    R.x.filt <- NA
    R.y.filt <- NA
    L.x.filt <- NA
    L.y.filt <- NA
    
    for(trial.counter in 1:max(eyEdu.data$participants[[
      participant.counter]]$trial.info$trial.index)) {  
      
      trial.sample.data <- sample.data[sample.data$trial.index == trial.counter,]

      # Extracts sample data 
      x.filt.temp <- trial.sample.data$rawx
      y.filt.temp <- trial.sample.data$rawy
      R.x.filt.temp <- trial.sample.data$Rrawx
      R.y.filt.temp <- trial.sample.data$Rrawy
      L.x.filt.temp <- trial.sample.data$Lrawx
      L.y.filt.temp <- trial.sample.data$Lrawy
      
      # Replaces NA with zero, otherwise smoothing would not work
      x.filt.temp[is.na(x.filt.temp)] <- 0
      y.filt.temp[is.na(y.filt.temp)] <- 0
      R.x.filt.temp[is.na(R.x.filt.temp)] <- 0
      R.y.filt.temp[is.na(R.y.filt.temp)] <- 0
      L.x.filt.temp[is.na(L.x.filt.temp)] <- 0
      L.y.filt.temp[is.na(L.y.filt.temp)] <- 0
      
      # Applies smooth()
      x.filt.temp <- smooth(x.filt.temp)
      y.filt.temp <- smooth(y.filt.temp)
      R.x.filt.temp <- smooth(R.x.filt.temp)
      R.y.filt.temp <- smooth(R.y.filt.temp)
      L.x.filt.temp <- smooth(L.x.filt.temp)
      L.y.filt.temp <- smooth(L.y.filt.temp)
      
      # Puts NAs back
      x.filt.temp[x.filt.temp == 0 ] <- NA
      y.filt.temp[y.filt.temp == 0] <- NA
      R.x.filt.temp[R.x.filt.temp == 0] <- NA
      R.y.filt.temp[R.y.filt.temp == 0] <- NA
      L.x.filt.temp[L.x.filt.temp == 0] <- NA
      L.y.filt.temp[L.y.filt.temp == 0] <- NA
      
      # Concatenates single trials
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
    print(paste("Smoothing: ",
                processed.participant, 
                "- number", participant.counter, 
                "out of", 
                max(length(eyEdu.data$participants)), sep = " ")) 
    
  } # end participant loop
  
  save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
} # end function

