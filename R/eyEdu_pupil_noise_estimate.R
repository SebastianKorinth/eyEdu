EyEduPupilNoiseEstimate <- function(poi.var = "trial",
                                    baseline.var = 0) {
  
  for (participant.counter in 1:length(eyEdu.data$participants)) {
    sample.data <- eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
    
    # Creates an empty data frame
    dummy.df <- eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
    trial.collect <- data.frame(matrix(ncol = ncol(dummy.df)+ 4, nrow = 0))
    colnames(trial.collect) <- c(colnames(dummy.df), "poi.blink.count", "poi.max.blink.length", "poi.sum.zeros", "poi.noise")
    rm(dummy.df)
    
    for (trial.counter in 1:max(eyEdu.data$participants[[participant.counter]]$sample.data$trial.index)) {
      
      # subsetting into single trial
      trial.sample.data <- sample.data[which(sample.data$trial.index == trial.counter), ]

      # Exception
      # trial too short
      
      if(nrow(trial.sample.data) < 10){
        trial.sample.data$poi.blink.count <- NA
        trial.sample.data$poi.max.blink.length <- NA
        trial.sample.data$poi.sum.zeros <- NA
        trial.sample.data$poi.noise <- NA
        trial.collect <- rbind(trial.collect, trial.sample.data)
        next
      }
            
      
      # in the case noise summary is only relevant for specific poi + baseline 
      # periode before
      
      if (poi.var != "trial"){
      
      poi.rows.end <- max(which(trial.sample.data$poi == poi.var))
      poi.rows.start <- min(which(trial.sample.data$poi == poi.var)) - baseline.var
      poi.sample.data <- sample.data[poi.rows.start:poi.rows.end, ]
      
      row.names(poi.sample.data) <- 1:nrow(poi.sample.data)  
      
      # total number of zeros (i.e., blinks or data loss) in poi
      trial.sample.data$poi.sum.zeros <- length(which(poi.sample.data$pupil.raw == 0))
      
      # run length encoding to get the number of blinks and their lengths in the poi
      rle.info <-  rle(poi.sample.data$pupil.raw)
      if (length(rle.info$lengths[which(rle.info$values == 0)]) == 0){
        trial.sample.data$poi.blink.count <- 0
        trial.sample.data$poi.max.blink.length <- 0
      }else{
      trial.sample.data$poi.blink.count <- length(rle.info$lengths[which(rle.info$values == 0)])
      trial.sample.data$poi.max.blink.length <- max(rle.info$lengths[which(rle.info$values == 0)], na.rm = TRUE)
      
      }
      
      } else {
      
        # total number of zeros (i.e., blinks or data loss) in the whole trial
      trial.sample.data$poi.sum.zeros <- length(which(trial.sample.data$pupil.raw == 0))
      
      # run length encoding to get the number of blinks and their lengths per trial
      rle.info <-  rle(trial.sample.data$pupil.raw)
      
      # Exception 
      # trials without any blink
      if (length(rle.info$lengths[which(rle.info$values == 0)]) == 0){
        trial.sample.data$poi.blink.count <- 0
        trial.sample.data$poi.max.blink.length <- 0
      }else{
        
        trial.sample.data$poi.blink.count <- length(rle.info$lengths[which(rle.info$values == 0)])
        trial.sample.data$poi.max.blink.length <- max(rle.info$lengths[which(rle.info$values == 0)], na.rm = TRUE)
      }
      
      trial.sample.data$poi.blink.count <- length(rle.info$lengths[which(rle.info$values == 0)])
      trial.sample.data$poi.max.blink.length <- max(rle.info$lengths[which(rle.info$values == 0)])
      }
      
      trial.sample.data$poi.noise <- poi.var

      trial.collect <- rbind(trial.collect, trial.sample.data)
      
    } # end trial loop
    

    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$poi.blink.count <- trial.collect$poi.blink.count
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$poi.max.blink.length <- trial.collect$poi.max.blink.length
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$poi.sum.zeros <- trial.collect$poi.sum.zeros    
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$poi.noise <- trial.collect$poi.noise   
    
    
    #Providing some feedback on processing progress.
    processed.participant <-
      names(eyEdu.data$participants[participant.counter])
    print(
      paste(
        "Estimating noise in pupil data for: ",
        processed.participant,
        "- number",
        participant.counter,
        "out of",
        max(length(eyEdu.data$participants)),
        sep = " "
      )
    )
    
  
    } # end participant loop
  
  print("Finished noise estimation for pupil data. Now saving eyEdu data. This might take a while.")
  save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
  } # function end
