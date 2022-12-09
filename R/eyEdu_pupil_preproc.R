EyEduPupilPreproc <- function(regression.basis = 100,
                              patch.before = 30,
                              patch.after = 30,
                              filt.win.length = 51,
                              mov.win = 4,
                              threshold.var = 600,
                              left.eye = FALSE,
                              span.var = 0.5) {


  # Loads eyEdu_data  
load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
# Function for moving average filter
mov.av.fu <- function(x, filt.win = filt.win.length) {stats::filter(x, rep(1 / filt.win, filt.win), sides = 1)}

##### Participant loop ####
for (participant.counter in 1:length(eyEdu.data$participants)) {
    
    sample.data <- eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
    
    # check, whether interpolation and filtering has been conducted already, 
    # if yes, overwrite existing values
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
    
    # Check, whether noise estimation has been conducted already, 
    # remove if exists
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
    
    # Creates an empty data frame that will collect the data of each trials
    # in the loop below
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

#### Trial loop ####
    for (trial.counter in 1:max(eyEdu.data$participants[[participant.counter]]$sample.data$trial.index)) {
      
      # Extracts pupil data for a single trial
      trial.sample.data <- sample.data[sample.data$trial.index == trial.counter,]
      # Fixes row names for easier indexing
      row.names(trial.sample.data) <- 1:nrow(trial.sample.data)
      
      # Depending on for which eye pupil data are available, chose left or right 
      # computes diff() for the selected raw data, which contains information about
      # pupil change (will be used to detect spikes)
      if (left.eye == TRUE) {
        trial.sample.data$pupil.raw <- trial.sample.data$Lpupil
        # computes difference with lag 1 using left eye pupil data
        trial.sample.data$pupil.diff <- c(0, diff(trial.sample.data$Lpupil))
        trial.sample.data$pupil.interpolated <-
          trial.sample.data$Lpupil
      } else {
        trial.sample.data$pupil.raw <- trial.sample.data$Rpupil
        # computes difference with lag 1 using right eye pupil data
        trial.sample.data$pupil.diff <- c(0, diff(trial.sample.data$Rpupil))
        trial.sample.data$pupil.interpolated <- trial.sample.data$Rpupil
      }
      
      # Prepares empty columns for blink count and filtered data
      trial.sample.data$blink.count <- 0
      trial.sample.data$pupil.filt <- 0
      trial.sample.data$onoffset <- 0
      
      # EXCEPTION 
      # trial too short
      if (nrow(trial.sample.data) < 10) {
        trial.collect <- rbind(trial.collect, trial.sample.data)
        next
      }
      
#### Moving window loop ####
      # Spikes,that is, sudden changes in pupil size are indicated if the sum
      # of values in time window (e.g., mov.win = 4) reaches threshold value 
      # (e.g., threshold.var = 600); negative value indicates blink onset
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
        } # end moving window loop
      
      # Creates temp variables that indicate changes or the lack of it encoded
      # as 0 and 1; computing a lagged difference on these data provides single
      # values indicating the row index of blink onsets (-1) and offsets (1)
      trial.sample.data$zeroOneTemp <- trial.sample.data$pupil.interpolated
      trial.sample.data$zeroOneTemp[which(trial.sample.data$zeroOneTemp > 0)] <- 1
      trial.sample.data$diffTemp <-  c(0, diff(trial.sample.data$zeroOneTemp))
      
      # Exception 
      # no blink
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
      
      # Creates two vectors containing the row indexes for blink on- and offsets
      blink.onsets <- which(trial.sample.data$diffTemp == -1)
      blink.offsets <- which(trial.sample.data$diffTemp == 1)
      
      # Exception 
      # there is only one blink in the trial with an offset outside of the trial
      # boundaries
      if (length(blink.offsets) == 0) {
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
      
      # Exception 
      # trial starts with blink so no onset for first blink 
      # removes the offset for this first blink from blink vector
      if(blink.onsets[1] > blink.offsets[1]){
        blink.offsets <- blink.offsets[-1]
      }
      
      # Exception 
      # trial starts with blink onset too close to trial onset, 
      # so no data points for regression removes this blink from blink vectors 
      # (i.e.,both on- and offset)
      if(blink.onsets[1] - regression.basis <= 0){
        blink.onsets <- blink.onsets[-1]
        blink.offsets <- blink.offsets[-1]
      }
      
      # Exception 
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
      
      # Exception
      # happened that even the second blink is too close to the trial onset
      if(blink.onsets[1] - regression.basis <= 0){
        blink.onsets <- blink.onsets[-1]
        blink.offsets <- blink.offsets[-1]
      }
      
      # Exception
      # happend that even the third blink is too close to the trial onset
      if(blink.onsets[1] - regression.basis <= 0){
        blink.onsets <- blink.onsets[-1]
        blink.offsets <- blink.offsets[-1]
      }
      # Exception
      # happend that even the fourth blink is too close to the trial onset
      if(blink.onsets[1] - regression.basis <= 0){
        blink.onsets <- blink.onsets[-1]
        blink.offsets <- blink.offsets[-1]
      }
      # Exception 
      # trial ends with blink so no offset for last blink 
      # defines last row of trial.sample.data as offset
      if(length(blink.onsets) > length(blink.offsets)){
        blink.offsets <- c(blink.offsets, nrow(trial.sample.data))
      }
      
      # Exception 
      # trial ends with blink offset to close to trial offset, 
      # so no data points for regression removes this blink from blink vectors 
      # (i.e., both on- and offset)
      if(blink.offsets[length(blink.offsets)] + regression.basis > nrow(trial.sample.data)){
        blink.onsets <- blink.onsets[-length(blink.onsets)]
        blink.offsets <- blink.offsets[-length(blink.offsets)]
      }
      
      # Exception 
      # if trial contains only one blink to close to trial offset, which is removed above
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
    
      
      # Removes temp variables
      trial.sample.data$zeroOneTemp <- NULL
      trial.sample.data$diffTemp <- NULL
      
##### Blink loop ####
      for(blink.index in 1:length(blink.onsets)){
        
        # Extracts row index of blink onset
        begin.blink <- blink.onsets[blink.index] 
        
        # EXCEPTION 
        # if the row index for the first blink is too small
        # and does not provide enough data points as the regression.basis
        # for interpolation this blink is not patched
         if (begin.blink < regression.basis + patch.before) {
           begin.blink <- begin.blink
         }else{
          begin.blink <- begin.blink - patch.before
        }
        
        # Extracts row index of blink offset
        end.blink <- blink.offsets[blink.index]
        
        # EXCEPTION 
        # if the row index indicating the end of the last
        # blink is shifted by the patch variable to a row index beyond the highest
        # row index of trial.sample.data; shorten the regression.basis and take
        # what is left or skip this blink
        if (end.blink + regression.basis > nrow(trial.sample.data)) {
          end.blink <- end.blink
        }else{
          end.blink <- end.blink + patch.after
        }
        
        # Writes blink index into the blink.count variable
        trial.sample.data$blink.count[begin.blink : end.blink] <- blink.index
        
        # Widens the time window with pupil size 0 by including patches
        trial.sample.data$pupil.interpolated[begin.blink : end.blink] <- 0
        
          
        # Extracts time and pupil data for the blink period + the time window
        # defined by regression.basis before and after the blink; creates new
        # data frame for each blink
        blink.patched <- data.frame(trial.sample.data$pupil.interpolated[(begin.blink - regression.basis):(end.blink + regression.basis)])
        colnames(blink.patched) <- "pupil"
        # Adds time variable for blink data frame
        blink.patched$time <- trial.sample.data$trial.time[(begin.blink - regression.basis):(end.blink + regression.basis)]
        # Creates new variable in blink data frame that indicates in which time
        # window a blink must be interpolated
        blink.patched$blink <- 0
        blink.patched$blink[(regression.basis + 1):(nrow(blink.patched) - regression.basis)] <- 1
        # Time points defined as blinks in the pupil data must be recoded as missing for the
        # interpolation 
        blink.patched$pupil[(regression.basis + 1):(nrow(blink.patched) - regression.basis)] <- NA

        # EXCEPTION 
        # a blink is immediately followed by another blink 
        zero.index <- which(blink.patched$pupil == 0)
        blink.patched$pupil[zero.index] <- NA
                
        # EXCEPTION 
        # if pupil data are all NA skip this blink
        if(length(which(is.na(blink.patched$pupil))) == nrow(blink.patched)){
          trial.sample.data$pupil.interpolated[which(trial.sample.data$blink.count == blink.index)] <-
            trial.sample.data$pupil.interpolated[which(trial.sample.data$blink.count == blink.index)]
          next
        }
      
        # Estimates a loess model 
        loess.results <- loess(blink.patched$pupil ~ blink.patched$time, span = span.var)
        
        # Defines the time window that must be interpolated
        missing.index <-  blink.patched$time[which(blink.patched$blink == 1)]
        
        # Uses the results provided by predict from the loess model
        blink.patched$predict <- suppressWarnings(predict(loess.results, data.frame(X = missing.index)))
        
        # Writes the interpolated data into the pupil.interpolated variable of trial.sample.data
        suppressWarnings(
        trial.sample.data$pupil.interpolated[which(trial.sample.data$blink.count == blink.index)] <-
          blink.patched$predict[which(blink.patched$blink == 1)]
        )
      } # end blink loop
      
      # filters data using function defined above
      trial.sample.data$pupil.filt <- as.numeric(mov.av.fu(trial.sample.data$pupil.interpolated, filt.win = filt.win.length))
      # the filter above creates missing values, which are patched with pupil.interpolated values
      trial.sample.data$pupil.filt[which(is.na(trial.sample.data$pupil.filt))] <- trial.sample.data$pupil.interpolated[which(is.na(trial.sample.data$pupil.filt))]
      
      # collects interpolated and filtered data for each trial
      trial.collect <- rbind(trial.collect, trial.sample.data)
      
    }# end trial loop
    
    # Writes processed data back into eyEdu.data
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$pupil.raw <-
      trial.collect$pupil.raw 
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$blink.count <-
      trial.collect$blink.count
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$pupil.interpolated <-
      trial.collect$pupil.interpolated
    eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]$pupil.filt <-
      trial.collect$pupil.filt
    
    
    # Provides some feedback on processing progress.
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

print("Saving processed data, this might take a while.")
save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  

  
} # end function
