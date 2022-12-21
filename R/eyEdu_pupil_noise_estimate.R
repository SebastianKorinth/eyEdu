EyEduPupilNoiseEstimate <- function(poi.var = "trial",
                                    baseline.var = 0) {
  
  
  # Loads eyEdu_data    
  load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
  for (participant.counter in 1:length(eyEdu.data$participants)) {
    sample.data <- eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
    
    # Creates an empty data frame
    dummy.df <- eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
    trial.collect <- data.frame(matrix(ncol = ncol(dummy.df)+ 6, nrow = 0))
    colnames(trial.collect) <- c(colnames(dummy.df), 
                                 "noise.blink.count", 
                                 "noise.max.blink.length", 
                                 "noise.count.zeros.original", 
                                 "noise.count.zeros.remain", 
                                 "noise.count.nas",
                                 "noise.sd")
    rm(dummy.df)
    
    for (trial.counter in 1:max(eyEdu.data$participants[[participant.counter]]$sample.data$trial.index)) {
      
      # sub-setting into single trial
      trial.sample.data <- sample.data[which(sample.data$trial.index == trial.counter), ]

      # Exception
      # trial too short
      
      if(nrow(trial.sample.data) < 10){
        trial.sample.data$noise.blink.count <- NA
        trial.sample.data$noise.max.blink.length <- NA
        trial.sample.data$noise.count.zeros.original <- NA
        trial.sample.data$noise.count.zeros.remain <- NA
        trial.sample.data$noise.count.nas <- NA
        trial.sample.data$noise.sd <- NA
        trial.sample.data$poi.noise <- poi.var
        trial.collect <- rbind(trial.collect, trial.sample.data)
        next
      }
            
      
 
      ##########################################################################  
      ############### Noise estimate for poi + baseline ########################
      ##########################################################################  
      
      
      if (poi.var != "trial"){
      
      poi.rows.end <- max(which(trial.sample.data$poi == poi.var))
      poi.rows.start <- min(which(trial.sample.data$poi == poi.var)) - baseline.var
      poi.sample.data <- trial.sample.data[poi.rows.start:poi.rows.end, ]
      row.names(poi.sample.data) <- 1:nrow(poi.sample.data)  
      
      # total number of zeros (i.e., blinks or data loss) in poi before preprocessing
      trial.sample.data$noise.count.zeros.original <- length(which(poi.sample.data$pupil.raw == 0))
      
      # number of zeros that couldn't be corrected (e.g., too close to trial onset or offset)
      trial.sample.data$noise.count.zeros.remain <- length(which(poi.sample.data$pupil.interpolated <= 0))
      
      # number of nas possibly created during preprocessing (e.g., two blinks too close)
      trial.sample.data$noise.count.nas <- length(which(is.na(poi.sample.data$pupil.interpolated)))
      
      
      trial.sample.data$noise.sd  <- sd(poi.sample.data$pupil.interpolated,na.rm = TRUE)
      
      # run length encoding to get the number of blinks and their lengths in the poi
      rle.info <-  rle(poi.sample.data$pupil.raw)
      if (length(rle.info$lengths[which(rle.info$values == 0)]) == 0){
        trial.sample.data$noise.blink.count <- 0
        trial.sample.data$noise.max.blink.length <- 0
      }else{
      trial.sample.data$noise.blink.count <- length(rle.info$lengths[which(rle.info$values == 0)])
      trial.sample.data$noise.max.blink.length <- max(rle.info$lengths[which(rle.info$values == 0)], na.rm = TRUE)
      
      }
      
      } else {
      
      ##########################################################################  
      ############### Noise estimate for complete trial ########################
      ##########################################################################  
        
      # total number of zeros (i.e., blinks or data loss) in the whole trial before preprocessing
      trial.sample.data$noise.count.zeros.original <- length(which(trial.sample.data$pupil.raw == 0))
      # number of zeros that couldn't be corrected (e.g., too close to trial onset or offset)
      trial.sample.data$noise.count.zeros.remain <- length(which(trial.sample.data$pupil.interpolated <= 0))
      # number of nas possibly created during preprocessing (e.g., two blinks too close)
      trial.sample.data$noise.count.nas <- length(which(is.na(trial.sample.data$pupil.interpolated)))
      
      # run length encoding to get the number of blinks and their lengths per trial
      rle.info <-  rle(trial.sample.data$pupil.raw)
      
      # Exception 
      # trials without any blink
      if (length(rle.info$lengths[which(rle.info$values == 0)]) == 0){
        trial.sample.data$noise.blink.count <- 0
        trial.sample.data$noise.max.blink.length <- 0
      }else{
        
        trial.sample.data$noise.blink.count <- length(rle.info$lengths[which(rle.info$values == 0)])
        trial.sample.data$noise.max.blink.length <- max(rle.info$lengths[which(rle.info$values == 0)], na.rm = TRUE)
      }
      
      trial.sample.data$noise.sd  <- sd(trial.sample.data$pupil.interpolated,na.rm = TRUE)
      }
      
      trial.sample.data$poi.noise <- poi.var

      trial.collect <- rbind(trial.collect, trial.sample.data)
      
    } # end trial loop
    

    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$noise.blink.count <- trial.collect$noise.blink.count
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$noise.max.blink.length <- trial.collect$noise.max.blink.length
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$noise.count.zeros.original <- trial.collect$noise.count.zeros.original    
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$noise.count.zeros.remain <- trial.collect$noise.count.zeros.remain   
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$noise.count.nas <- trial.collect$noise.count.nas
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$noise.sd <- trial.collect$noise.sd
    

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
