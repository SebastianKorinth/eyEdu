EyEduAdjustTiming <- function() {
  load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
  for (participant.counter in 1:length(eyEdu.data$participants)) {
    sample.data <- eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
    
    # Initiates empty trial time vector
    trial.time.var <- numeric() 
    poi.time.var <- numeric()
    
    for (trial.counter in 1:max(eyEdu.data$participants[[participant.counter]]$sample.data$trial.index)) {
      
      # Subsets sample data to single trial
      trial.sample.data <- sample.data[sample.data$trial.index == trial.counter, ]
      
      
      # Exception
      # extremely short trials for which no meaningful time adjustment is possible
      # values for trial time and poi time will be set to NA
      if (nrow(trial.sample.data) < 2) {

        # creates vector of NAs with length of trial
        trial.time.temp <-  rep(0, times = nrow(trial.sample.data))
        # Concatenates single trials
        trial.time.var <- c(trial.time.var, trial.time.temp)
        # Same for pois
        trial.sample.data$poi.time <- NA
        poi.time.var <- c(poi.time.var, trial.sample.data$poi.time)
        next
      }
      
      # get trial time and reset it to zero upon trial onset
      trial.time.temp <- trial.sample.data$time - min(trial.sample.data$time)
      
      # POI loop
      poi.table <- names(table(trial.sample.data$poi))
      trial.sample.data$poi.time <- NA
      for (poi.counter in 1:length(poi.table)) {
        poi.row.index <- which(trial.sample.data$poi == poi.table[poi.counter])
        trial.sample.data$poi.time[poi.row.index] <- trial.sample.data$time[poi.row.index] - min(trial.sample.data$time[poi.row.index])
      }
      
        # Concatenates single trials
        trial.time.var <- c(trial.time.var, trial.time.temp)
        poi.time.var <- c(poi.time.var, trial.sample.data$poi.time)

    }  # end trial loop
    
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$trial.time <-
      trial.time.var
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$poi.time <-
      poi.time.var
    
    # Providing some feedback on processing progress.
    processed.participant <-
      names(eyEdu.data$participants[participant.counter])
    print(
      paste(
        "Adjust timing for: ",
        processed.participant,
        "- number",
        participant.counter,
        "out of",
        max(length(eyEdu.data$participants)),
        sep = " "
      )
    )
    
  } # end participant loop
  
  print("Saving data, this might take a while.")
  save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
} # end function
