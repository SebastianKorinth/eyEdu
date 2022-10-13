EyEduAdjustTiming <- function() {
  load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
  for (participant.counter in 1:length(eyEdu.data$participants)) {
    sample.data <- eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
    
    
    for (trial.counter in 1:max(eyEdu.data$participants[[participant.counter]]$sample.data$trial.index)) {
      trial.sample.data <-
        sample.data[sample.data$trial.index == trial.counter, ]
      
      if (nrow(trial.sample.data) < 2) {
        next
      }
      
      # get trial time and reset it to zero upon trial onset
      trial.time.temp <-
        trial.sample.data$time - min(trial.sample.data$time)
      
      # POI loop
      poi.table <- names(table(trial.sample.data$poi))
      trial.sample.data$poi.time <- NA
      for (poi.counter in 1:length(poi.table)) {
        poi.row.index <-
          which(trial.sample.data$poi == poi.table[poi.counter])
        trial.sample.data$poi.time[poi.row.index] <-
          trial.sample.data$time[poi.row.index] - min(trial.sample.data$time[poi.row.index])
      }
      
      
      
      if (trial.counter == 1) {
        trial.time.var <- trial.time.temp
        poi.time.var <- trial.sample.data$poi.time
      } else {
        # Concatenates single trials
        trial.time.var <- c(trial.time.var, trial.time.temp)
        poi.time.var <- c(poi.time.var, trial.sample.data$poi.time)
      }
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
  
  save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
} # end function
