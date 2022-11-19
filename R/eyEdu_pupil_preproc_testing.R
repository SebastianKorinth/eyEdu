EyEduPupilPreproc <- function(regression.basis = 100,
                              patch.before = 30,
                              patch.after = 30,
                              filt.win.length = 51,
                              mov.win = 4,
                              threshold.var =600,
                              left.eye = FALSE,
                              span.var = 0.5) {
  #
  # debugging only
  # participant.counter = 11
  # trial.counter = 1
  # regression.basis = 100
  # patch.before = 30
  # patch.after = 40
  # filt.win.length = 23
  # mov.win = 4
  # threshold.var = 600
  # left.eye = FALSE
  # span.var = 0.5
  # raw.data.path <-
  #   paste(getwd(), "/example_pupil_DataEyeLink/", sep = "")
  ### debugging end

  
  load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
  # function for moving average filter
  mov.av.fu <- function(x, filt.win = filt.win.length) {
      stats::filter(x, rep(1 / filt.win, filt.win), sides = 1)
    }
  
  
  for (participant.counter in 1:length(eyEdu.data$participants)) {
    ###################################################################################
    ################## extracts sample data for single participant ####################
    ###################################################################################
    
    sample.data <-
      eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
    
    # check, whether interpolation and filtering has been conducted already, overwrite existing values
    if ("pupil.raw" %in% colnames(sample.data)) {
      sample.data$pupil.raw <- NULL
    }
    if ("blink.count" %in% colnames(sample.data)) {
      sample.data$blink.count <- NULL
    }
    if ("pupil.interpolated" %in% colnames(sample.data)) {
      sample.data$pupil.interpolated <- NULL
    }
    if ("pupil.filt" %in% colnames(sample.data)) {
      sample.data$pupil.filt <- NULL
    }
    
    # Check, whether noise estimation has been conducted already, remove if exists
    if ("poi.blink.count" %in% colnames(sample.data)) {
      sample.data$poi.blink.count <- NULL
    }
    if ("poi.max.blink.length" %in% colnames(sample.data)) {
      sample.data$poi.max.blink.length <- NULL
    }
    if ("poi.noise" %in% colnames(sample.data)) {
      sample.data$poi.noise <- NULL
    }
    if ("poi.sum.zeros" %in% colnames(sample.data)) {
      sample.data$poi.sum.zeros <- NULL
    }
    
    
    
    # Creates an empty data frame
    dummy.df <- sample.data
    trial.collect <-
      data.frame(matrix(ncol = ncol(dummy.df) + 6, nrow = 0))
    colnames(trial.collect) <-
      c(
        colnames(dummy.df),
        "pupil.raw",
        "pupil.diff",
        "pupil.interpolated",
        "blink.count",
        "pupil.filt",
        "onoffset")
    rm(dummy.df)
    
    
    for (trial.counter in 1:max(eyEdu.data$participants[[participant.counter]]$sample.data$trial.index)) {
      ###################################################################################
      ################## extracts sample data for single trials ####################
      ###################################################################################
      
      trial.sample.data <-
        sample.data[sample.data$trial.index == trial.counter,]
      row.names(trial.sample.data) <- 1:nrow(trial.sample.data)
      
      
      
      if (left.eye == TRUE) {
        trial.sample.data$pupil.raw <- trial.sample.data$Lpupil
        #trial.sample.data$pupil.raw[which(trial.sample.data$pupil.raw == 0)] <- NA
        # computes difference with lag 1 using left eye pupil data
        trial.sample.data$pupil.diff <-
          c(0, diff(trial.sample.data$Lpupil))
        trial.sample.data$pupil.interpolated <-
          trial.sample.data$Lpupil
      } else {
        trial.sample.data$pupil.raw <- trial.sample.data$Rpupil
        #trial.sample.data$pupil.raw[which(trial.sample.data$pupil.raw == 0)] <- NA
        # computes difference with lag 1 using right eye pupil data
        trial.sample.data$pupil.diff <-
          c(0, diff(trial.sample.data$Rpupil))
        trial.sample.data$pupil.interpolated <-
          trial.sample.data$Rpupil
      }
      
      # prepares empty columns for blink count and filtered data
      trial.sample.data$blink.count <- 0
      trial.sample.data$pupil.filt <- 0
      trial.sample.data$onoffset <- 0
      
      # # # EXCEPTION 
      # trial too short
      if (nrow(trial.sample.data) < 10) {
        trial.collect <- rbind(trial.collect, trial.sample.data)
        next
      }
      
      
    
      
      
      # START ######## Moving window that searches for sudden changes in pupil size
      # Uses a moving window to detect sudden changes in pupil size
      

      for (win.counter in 2:(nrow(trial.sample.data) - mov.win)) {
        time.window <- trial.sample.data$pupil.diff[win.counter:(win.counter + mov.win)]

        # checks whether sum of values in time window lower than threshold.var indicating steep decrease
        if (sum(time.window) < (threshold.var * -1)) {
          trial.sample.data$onoffset[win.counter] <- -1
          trial.sample.data$pupil.interpolated[win.counter] <- 0
        }
        # checks whether sum of values in time window higher than threshold.var  indicating steep increase
        if (sum(time.window) > threshold.var) {
          trial.sample.data$onoffset[win.counter] <- 1
          trial.sample.data$pupil.interpolated[win.counter] <- 0
        }
        }
      
      
  
    # END ######## Moving window that searches for sudden changes in pupil size

      
      trial.sample.data$zeroOneTemp <- trial.sample.data$pupil.interpolated
      trial.sample.data$zeroOneTemp[which(trial.sample.data$zeroOneTemp > 0)] <- 1
      trial.sample.data$diffTemp <-  c(0, diff(trial.sample.data$zeroOneTemp))
      
    
      ### Exception if no blink
      
      if (length(which(trial.sample.data$diffTemp == -1)) == 0){
        trial.sample.data$zeroOneTemp <- NULL
        trial.sample.data$diffTemp <- NULL
        # filters data using function defined above
        trial.sample.data$pupil.filt <- as.numeric(mov.av.fu(trial.sample.data$pupil.interpolated, filt.win = filt.win.length))
        # the filter above creates missing values, which are patched with pupil.interpolated values
        trial.sample.data$pupil.filt[which(is.na(trial.sample.data$pupil.filt))] <- trial.sample.data$pupil.interpolated[which(is.na(trial.sample.data$pupil.filt))]
        # collects interpolated and filtered data for each trial
        trial.collect <- rbind(trial.collect, trial.sample.data)
        next
      }
      
      
      blink.onsets <- which(trial.sample.data$diffTemp == -1)
      blink.offsets <- which(trial.sample.data$diffTemp == 1)
      
      #### Exception trial starts with blink so no onset for first blink 
      # removes the offset for this first blink from blink vector
      if(blink.onsets[1] > blink.offsets[1]){
        blink.offsets <- blink.offsets[-1]
      }
      
      
      #### Exception trial starts with blink onset too close to trial onset, 
      # so no data points for regression 
      # removes this blink from blink vectors (i.e., on and offset)
      if(blink.onsets[1] - regression.basis <= 0){
        blink.onsets <- blink.onsets[-1]
        blink.offsets <- blink.offsets[-1]
      }
      
      # if trial contains only one blink to close to trial onset, which is removed above
      if (length(blink.onsets) == 0) {
        # filters data using function defined above
        trial.sample.data$pupil.filt <- as.numeric(mov.av.fu(trial.sample.data$pupil.interpolated, filt.win = filt.win.length))
        # the filter above creates missing values, which are patched with pupil.interpolated values
        trial.sample.data$pupil.filt[which(is.na(trial.sample.data$pupil.filt))] <- trial.sample.data$pupil.interpolated[which(is.na(trial.sample.data$pupil.filt))]
        trial.sample.data$zeroOneTemp <- NULL
        trial.sample.data$diffTemp <- NULL
        
        # collects interpolated and filtered data for each trial
        trial.collect <- rbind(trial.collect, trial.sample.data)
        next
      }
      
      ### happend that even the second blink is too close to the trial onset
      if(blink.onsets[1] - regression.basis <= 0){
        blink.onsets <- blink.onsets[-1]
        blink.offsets <- blink.offsets[-1]
      }
      
      
      #### Exception trial ends with blink so no offset for last blink 
      # defines last row of trial.sample.data as offset
      if(length(blink.onsets) > length(blink.offsets)){
        blink.offsets <- c(blink.offsets, nrow(trial.sample.data))
      }
      
      
      #### Exception trial ends with blink offset to close to trial offset, 
      # so no data points for regression 
      # removes this blink from blink vectors (i.e., on and offset)
      if(blink.offsets[length(blink.offsets)] + regression.basis > nrow(trial.sample.data)){
        blink.onsets <- blink.onsets[-length(blink.onsets)]
        blink.offsets <- blink.offsets[-length(blink.offsets)]
      }
      
      
      
      
      
      trial.sample.data$zeroOneTemp <- NULL
      trial.sample.data$diffTemp <- NULL
      
      
      
      # START ######## Loop for each blink in trial
      for(blink.index in 1:length(blink.onsets)){
        
        begin.blink <- blink.onsets[blink.index] 
        
        # # # EXCEPTION 
        # if the row index for the first blink is too small
        # and does not provide the "good" data points that regression.basis
        # needs for interpolation this blink is not patched
        
         if (begin.blink < regression.basis + patch.before) {
           begin.blink <- begin.blink
         }else{
          begin.blink <- begin.blink - patch.before
        }
        
        end.blink <- blink.offsets[blink.index]
        

        
        # # # EXCEPTION 
        # if the row index indicating the end of the last
        # blink is shifted by the patch variable to a row index beyond highest
        # row index of trial.sample.data shorten the regression.basis and take
        # what is left or skip this blink
        if (end.blink + regression.basis > nrow(trial.sample.data)) {
          end.blink <- end.blink
        }else{
          end.blink <- end.blink + patch.after
        }
        
        trial.sample.data$blink.count[begin.blink : end.blink] <- blink.index
        
        # Widens the time window with pupil size 0 by including patches
        trial.sample.data$pupil.interpolated[begin.blink : end.blink] <- 0
        
          
                # exctracts time and pupil data for the blink period + the time window
                # defined by regression.basis before and after the blink
                blink.patched <- data.frame(trial.sample.data$pupil.interpolated[(begin.blink - regression.basis):(end.blink + regression.basis)])
                colnames(blink.patched) <- "pupil"
                blink.patched$time <-
                  trial.sample.data$trial.time[(begin.blink - regression.basis):(end.blink + regression.basis)]
                blink.patched$blink <- 0
                blink.patched$blink[(regression.basis + 1):(nrow(blink.patched) -
                                                              regression.basis)] <- 1
                blink.patched$pupil[(regression.basis + 1):(nrow(blink.patched) -
                                                              regression.basis)] <- NA
                
                
                
                # # # EXCEPTION 
                #  for cases in which a blink is immediately followed by another blink
                zero.index <- which(blink.patched$pupil == 0)
                blink.patched$pupil[zero.index] <- NA
                
                
                
                
                if(length(which(is.na(blink.patched$pupil))) == nrow(blink.patched)){
                  trial.sample.data$pupil.interpolated[which(trial.sample.data$blink.count == blink.index)] <-
                    trial.sample.data$pupil.interpolated[which(trial.sample.data$blink.count == blink.index)]
                  next
                }
                
                
                
                # estimates a loess model using the blink.patched data
                loess.results <-
                  loess(blink.patched$pupil ~ blink.patched$time, span = span.var)
                
                
                ### in future maybe option for linear regression?

                
                
                # defines the time window that must be interpolated
                missing.index <-  blink.patched$time[which(blink.patched$blink == 1)]
                
                # # uses the results provided by predict from the loess model
                blink.patched$predict <- suppressWarnings(predict(loess.results, data.frame(X = missing.index)))
                
                
                # writes the interpolated data into the pupil.interpolated variable of trial.sample.data
                trial.sample.data$pupil.interpolated[which(trial.sample.data$blink.count == blink.index)] <-
                  blink.patched$predict[which(blink.patched$blink == 1)]
                
      }
      
      # END ######## loop for each blink
      

      
      # filters data using function defined above
      trial.sample.data$pupil.filt <-
        as.numeric(mov.av.fu(trial.sample.data$pupil.interpolated, filt.win = filt.win.length))
      # the filter above creates missing values, which are patched with pupil.interpolated values
      trial.sample.data$pupil.filt[which(is.na(trial.sample.data$pupil.filt))] <- trial.sample.data$pupil.interpolated[which(is.na(trial.sample.data$pupil.filt))]
      
      # collects interpolated and filtered data for each trial
      trial.collect <- rbind(trial.collect, trial.sample.data)
      
#      trial.sample.data$onoffset <- NULL
      
    }  # end trial loop
    
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$pupil.raw <-
      trial.collect$pupil.raw 
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$blink.count <-
      trial.collect$blink.count
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$pupil.interpolated <-
      trial.collect$pupil.interpolated
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$pupil.filt <-
      trial.collect$pupil.filt
    
    
    #Providing some feedback on processing progress.
    processed.participant <-
      names(eyEdu.data$participants[participant.counter])
    print(
      paste(
        "Preprocessing pupil data for: ",
        processed.participant,
        "- number",
        participant.counter,
        "out of",
        max(length(eyEdu.data$participants)),
        sep = " "
      )
    )
    
    
  }  # end participant loop
  save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
  
} # end function
