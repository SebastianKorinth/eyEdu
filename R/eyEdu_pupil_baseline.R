EyEduPupilBaseline <- function(poi.choice = "results",
                               baseline.width = 100,
                               data.type  = "interpolated") {


# Loads eyEdu_data    
load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
#### Participant loop ####
for (participant.counter in 1:length(eyEdu.data$participants)) {
    sample.data <- eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
    
    # Checks whether baseline adjustment has been conducted already, 
    # if yes, overwrite existing values
    if ("base.change.raw" %in% colnames(sample.data)) {
      sample.data$base.change.raw <- NULL
    }
    if ("base.change.perc" %in% colnames(sample.data)) {
      sample.data$base.change.perc <- NULL
    }
    if ("trial.scaled" %in% colnames(sample.data)) {
      sample.data$trial.scaled <- NULL
    }
    if ("base.scaled" %in% colnames(sample.data)) {
      sample.data$base.scaled <- NULL
    }
    
    # Creates an empty data frame that will be filled by the trial loop below
    dummy.df <- sample.data
    trial.collect <- data.frame(matrix(ncol = ncol(dummy.df)+ 4, nrow = 0))
    colnames(trial.collect) <- c(colnames(dummy.df), "base.change.raw", "base.change.perc", "trial.scaled","base.scaled")
    rm(dummy.df)
    
#### Trial loop ####
for (trial.counter in 1:max(eyEdu.data$participants[[participant.counter]]$sample.data$trial.index)) {
      
      trial.sample.data <- sample.data[sample.data$trial.index == trial.counter, ]
      row.names(trial.sample.data) <- 1:nrow(trial.sample.data)  
      trial.sample.data$base.change.raw  <-NA
      trial.sample.data$base.change.perc <- NA
      trial.sample.data$trial.scaled <- NA
      trial.sample.data$base.scaled <- NA
      
      # Computes relative change to baseline poi.row.index for the start of the 
      # basline time window
      poi.row.index <-which(trial.sample.data$poi == poi.choice)
      
      # Exception
      # if not enough data points
      if (length(poi.row.index) == 0){
        trial.collect <- rbind(trial.collect, trial.sample.data)
        next
      }
        
      baseline.index <- c(min((poi.row.index) - baseline.width), min((poi.row.index)-1))
     
      # data type: interpolated
      if (data.type == "interpolated"){
        base.line <- mean(trial.sample.data$pupil.interpolated[baseline.index[1]: baseline.index[2]], na.rm = TRUE)
          trial.sample.data$base.change.raw <-  trial.sample.data$pupil.interpolated - base.line
        # Percentage change
        trial.sample.data$base.change.perc <- ((trial.sample.data$pupil.interpolated * 100)/base.line)- 100
        # Scale - the [, 1] is because scale() returns a matrix with its dimensions written into the header
        trial.sample.data$trial.scaled <- scale(trial.sample.data$pupil.interpolated)[, 1]
        trial.sample.data$base.scaled[baseline.index[1]: max(poi.row.index)] <- scale(trial.sample.data$pupil.interpolated[baseline.index[1]: max(poi.row.index)])[, 1]
      }
      
      if (data.type == "filtered"){
        base.line <- mean(trial.sample.data$pupil.filt[baseline.index[1]: baseline.index[2]], na.rm = TRUE)
        trial.sample.data$base.change.raw <-  trial.sample.data$pupil.filt - base.line
        # Percentage change
        trial.sample.data$base.change.perc <- ((trial.sample.data$pupil.filt * 100)/base.line)- 100
        # Scale - the [, 1] is because scale() returns a matrix with its dimensions written into the header 
        trial.sample.data$trial.scaled <- scale(trial.sample.data$pupil.filt)[, 1]
        trial.sample.data$base.scaled[baseline.index[1]: max(poi.row.index)] <- scale(trial.sample.data$pupil.filt[baseline.index[1]: max(poi.row.index)])[, 1]
        
      }
      
      if (data.type == "raw"){
        base.line <- mean(trial.sample.data$pupil.raw[baseline.index[1]: baseline.index[2]], na.rm = TRUE)
        trial.sample.data$base.change.raw <-  trial.sample.data$pupil.raw - base.line
        # Percentage change
        trial.sample.data$base.change.perc <- ((trial.sample.data$pupil.raw * 100)/base.line)- 100
        # Scale- the [, 1] is because scale() returns a matrix with its dimensions written into the header  
        trial.sample.data$trial.scaled <- scale(trial.sample.data$pupil.raw)[, 1]
        trial.sample.data$base.scaled[baseline.index[1]: max(poi.row.index)] <- scale(trial.sample.data$pupil.raw[baseline.index[1]: max(poi.row.index)])[, 1]
        
        
      }
      
      # Writes into data frame that collects each trial 
      trial.collect <- rbind(trial.collect, trial.sample.data)

      } # end trial loop
    
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$base.change.raw <- trial.collect$base.change.raw
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$base.change.perc <- trial.collect$base.change.perc
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$trial.scaled <- trial.collect$trial.scaled
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$base.scaled <- trial.collect$base.scaled
    
    #Providing some feedback on processing progress.
    processed.participant <-
      names(eyEdu.data$participants[participant.counter])
    print(
      paste(
        "Pupil baseline adjustment for: ",
        processed.participant,
        "- number",
        participant.counter,
        "out of",
        max(length(eyEdu.data$participants)),
        sep = " "
      )
    )
    
    
  } # end particpant loop
  
  print("Finished baseline adjustment. Now saving eyEdu data. This might take a while.")
  save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
  } # end function