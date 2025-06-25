
EyEduImportHDF5 <- function(poi.start = NA,
                            poi.end = NA,
                            hdf5.path = "data/",
                            message.dict = NA,
                            participant.id.var = "subj_nr",
                            remove.outliers = FALSE,
                            python.correction = TRUE,
                            eye.sides = "B",
                            include.samples = TRUE,
                            msg.label = "msg_",
                            stimulus.tag = NA, #"stim_label"
                            stimulus.id.tag = "onset_sentence",
                            back.tag = "back_sentence") {
  

  # List of files that will be processed.
  raw.file.list <- list.files(path = paste(raw.data.path, hdf5.path, sep = ""), 
                              pattern = "\\.hdf5$",
                              ignore.case = T)
  
  # Initializes empty list, which will be filled with participant data and
  # an empty list for aoi.info and futur features
  eyEdu.data <- list()  
  length(eyEdu.data) = 3
  names(eyEdu.data) <- c("participant.table","participants","aoi.info")
  
  # Fills first level list with an empty list of length n-participants
  eyEdu.data$participants <- list()
  length(eyEdu.data$participants) = length(raw.file.list)
  names(eyEdu.data$participants) = sapply(strsplit(as.character(raw.file.list),'_'),"[", 1) #raw.file.list
  
  if (python.correction == TRUE) {
    py.cor.var = 1
  } else {
    py.cor.var = 0
  }
  
  
  # Loops through files 
  for (file.counter in 1:length(raw.file.list)) {
    
    # open file connection
    file.h5 <- H5File$new(filename = paste0(raw.data.path, hdf5.path, 
                                            raw.file.list[file.counter]),
                          mode = "r+")
    
    
    ### Import eye movement and sample data  
    
    if (include.samples == FALSE) {
      eye.mov.data <- data.frame(matrix(data = NA, nrow = 1, ncol = 11))
      colnames(eye.mov.data) <- c(
        "time",
        "Lrawx",
        "Lrawy",
        "Lpupil",
        "Rrawx",
        "Rrawy",
        "Rpupil",
        "avgx",
        "avgy",
        "rawx",
        "rawy"
      )
    } else {
      eye.mov.data <- file.h5[["data_collection/events/eyetracker/GazepointSampleEvent"]][]
      
      eye.mov.data <- eye.mov.data[,c("time", 
                                      "left_gaze_x",
                                      "left_gaze_y",
                                      "left_pupil_measure2",
                                      "right_gaze_x",
                                      "right_gaze_y",
                                      "right_pupil_measure2"
                                      )]
      colnames(eye.mov.data) <- c("time","Lrawx", "Lrawy","Lpupil","Rrawx", "Rrawy","Rpupil")
      
      
      # computes average of left and right eye
      eye.mov.data$avgx <- (eye.mov.data$Lrawx + eye.mov.data$Rrawx) / 2
      eye.mov.data$avgy <- (eye.mov.data$Lrawy + eye.mov.data$Rrawy) / 2
      eye.mov.data$rawx <- eye.mov.data$Rrawx
      eye.mov.data$rawy <- eye.mov.data$Rrawy
      
      if (remove.outliers == TRUE) {
        # Re-codes negative position values into NA
        eye.mov.data$Rrawx[eye.mov.data$Rrawx < 0]  <- NA
        eye.mov.data$Rrawy[eye.mov.data$Rrawy < 0] <- NA
      }
      
      # Fixes row name order for indexing.
      row.names(eye.mov.data) <- 1 : nrow(eye.mov.data)
      
    }
    
    # converts raw gaze positions into pixel coordinates 
    # this needs some serious rewrite <- add option for unit conversion
    eye.mov.data$Rrawx <- (eye.mov.data$Rrawx + 0.8888888) * (1920/1.7777777)
    eye.mov.data$Rrawy <- (eye.mov.data$Rrawy + 0.5) * 1080   
    # reverse y axis
    eye.mov.data$Rrawy <- abs(eye.mov.data$Rrawy - 1080)

    eye.mov.data$Lrawx <- (eye.mov.data$Lrawx + 0.8888888) * (1920/1.7777777)
    eye.mov.data$Lrawy <- (eye.mov.data$Lrawy + 0.5) * 1080
    # reverse y axis
    eye.mov.data$Lrawy <- abs(eye.mov.data$Lrawy - 1080)    
    

    ### Import message data
    message.data <- file.h5[["data_collection/events/experiment/MessageEvent"]][]
    
    # choose only self set messages in case calibration message etc were also collected
    message.data <- message.data[grepl("^msg_", message.data$text, ignore.case = TRUE),]
    rownames(message.data) <- 1 : nrow(message.data)
    
    message.data <- message.data[,c("time", "text")]
    message.data$message <- gsub("msg_", "", message.data$text)
    message.data$message.label <- sapply(strsplit(as.character(message.data$message),' '),"[", 1) 
    message.data$message.index <- suppressWarnings(as.numeric(sapply(strsplit(as.character(message.data$message),' '),"[", 2)))     
    
    if(is.na(poi.start)){
      poi.start = message.dict$trial[1]
      poi.end = message.dict$trial[2]
      poi.count = length(message.dict) *2
      message.couple <- c("start.message", "stop.message")
      for (i in 2:length(message.dict)) {
        message.couple <- append(message.couple, message.dict[i][[1]])
      }
    }else{
      poi.count = 2
      message.couple <- c("start.message", "stop.message")
    }
    
    # Extracts info about time points for trial start, trial end (or period of 
    # interest) and writes these to a new data frame: trial.info
    number.of.trials <- length(message.data$time[which(message.data$message.label == poi.start)])
    
    trial.info <- as.data.frame(matrix(ncol = poi.count, nrow = number.of.trials))
    colnames(trial.info) <-  message.couple
    
    trial.info$start.message <- as.numeric(message.data$time[which(
      message.data$message.label == poi.start)])
    
    trial.info$stop.message <- as.numeric(message.data$time[which(
      message.data$message.label == poi.end)])
    
    
    if (ncol(trial.info) > 3) {
      for (col.index in 3:ncol(trial.info)) {
        trial.info[col.index] <- as.numeric(message.data$time[which(
          message.data$message.label == colnames(trial.info)[col.index])])
      }
    }
    
    trial.info$trial.index <- 1:nrow(trial.info)
    trial.info$trial.duration <- trial.info$stop.message - trial.info$start.message
    
    # temp fix for stimulus id
    trial.info$stimulus.id <- message.data$message.index[which(message.data$message.label == stimulus.id.tag)]
    
    if(is.na(stimulus.tag)){
      trial.info$stimulus.message <- NA
      #trial.info$stimulus.id <- trial.info$trial.index
    } else {
      
      temp.stim <- message.data[which(message.data$message.label == stimulus.tag),"message"]
      temp.stim <- gsub(paste0(stimulus.tag, " "), "",temp.stim)
      trial.info$stimulus.message <- temp.stim
      #trial.info$stimulus.id <- trial.info$stimulus.message
    }

    

    if(is.na(participant.id.var)){
      participant.nr <- strsplit(raw.file.list[file.counter],'_')[[1]][1]
    }else{
      participant.nr <- message.data$message[which(message.data$message.label == participant.id.var)][1]
      participant.nr <- gsub(paste0(participant.id.var, " "), "", participant.nr)
      }

    temp.index <- grepl(back.tag, message.data$message.label, ignore.case = TRUE)
    
    if(length(which(temp.index == TRUE)) == 0) {
      trial.info$background.image <- paste(participant.nr, "_",
                                           trial.info$trial.index - py.cor.var,
                                           "_", trial.info$stimulus.id,
                                           ".png", sep = "")

    } else {
      trial.info$background.image <- message.data$message.label[temp.index]
      trial.info$background.image <- gsub("back_","",trial.info$background.image)
      trial.info$background.image <- paste0(trial.info$background.image, ".png")
    }
    

    
    # Loop searches for rownames in eye movement data, which correspond 
    # to time points of start and stop messages. Note, timing of eye movement data 
    # (i.e., ~ 2 ms each time point at 500Hz sampling rate) has to be aligned with 
    # stimulus and response timing (1 ms accuracy). The nearest eye movement
    # sample point corresponding to start and stop messages will be used
    eye.mov.data$trial.index <- 0
    
    if(include.samples == TRUE) {
      for(trial.counter in 1:nrow(trial.info)) {
        start.row <-  which.min(
          abs(eye.mov.data$time - trial.info$start.message[trial.counter]))
        stop.row <-  which.min(
          abs(eye.mov.data$time - trial.info$stop.message[trial.counter]))
        eye.mov.data$trial.index[start.row:stop.row] <- trial.counter
      }
      
      # Adds additional POI info to sample data
      if (length(message.dict) >1){
        eye.mov.data$poi <- NA
        
        for(trial.counter in 1:nrow(trial.info)) {
          
          for(poi.counter in 2:length(message.dict)) {
            poi.name <- names(message.dict[poi.counter])
            
            col.index.start <- which(colnames(trial.info) == message.dict[[poi.counter]][1])
            col.index.stop <- which(colnames(trial.info) == message.dict[[poi.counter]][2])  
            
            start.row <-  which.min(
              abs(eye.mov.data$time - trial.info[trial.counter, col.index.start]))
            stop.row <-  which.min(
              abs(eye.mov.data$time - trial.info[trial.counter, col.index.stop, trial.counter]))
            eye.mov.data$poi[start.row:stop.row]<- poi.name
          }
          
        }
      }
      
      # Deletes rows that were not assigned to a trial due to differences in sample
      # precision (i.e., 2 ms vs. 1 ms) or because ...
      eye.mov.data <- subset(eye.mov.data, eye.mov.data$trial.index > 0)
    }
    
    
    fixation.data <- file.h5[["data_collection/events/eyetracker/FixationEndEvent"]][]
    
    # only one eye
    fixation.data <- fixation.data[which(fixation.data$eye == 21),]
    
    # just a guess!!!! time is for fixation end, thus minus duration should give
    # fixation start
    fixation.data <- fixation.data[, c("time",
                                       "duration",
                                       "average_gaze_x",
                                       "average_gaze_y")]
    fixation.data$fix.start <- fixation.data$time - fixation.data$duration
    
    colnames(fixation.data) <- c("fix.end", "fix.duration", "fix.pos.x", "fix.pos.y", "fix.start")
    
    fixation.data <- fixation.data[,c("fix.start", "fix.end", "fix.duration", "fix.pos.x", "fix.pos.y")]
    
    # converts raw gaze positions into pixel coordinates 
    # this needs some serious rewrite <- add option for unit conversion
    fixation.data$fix.pos.x <- (fixation.data$fix.pos.x + 1) * (1920/2)
    fixation.data$fix.pos.y <- ((fixation.data$fix.pos.y + 1) * (1080/2))
    #fixation.data$fix.pos.y <- abs(fixation.data$fix.pos.y - 1080)
    
    
    
    fixation.data$trial.index <- 0
    fixation.data$stimulus.id <- NA
    
    
    
    
    for(trial.counter in 1:nrow(trial.info)) {
      start.row <-  which.min(
        abs(fixation.data$fix.start - trial.info$start.message[trial.counter]))
      stop.row <-  which.min(
        abs(fixation.data$fix.start - trial.info$stop.message[trial.counter]))
      fixation.data$trial.index[start.row:stop.row]<- trial.counter
      fixation.data$stimulus.id[start.row:stop.row]<- trial.info$stimulus.id[trial.counter]
    }
    
    fixation.data <- subset(fixation.data, fixation.data$trial.index > 0)
    
    # why would I want to delete fixation start and stop info?
    #fixation.data <- fixation.data[,-c(1,2)]
    
    fixation.data$fixation.index <- NA
    for(trial.counter in 1:nrow(trial.info)){
      row.index <- which(fixation.data$trial.index == trial.counter)
      fixation.data$fixation.index[row.index] <- 1:length(row.index)
    }
    
    # Adds additional POI info to fixation data
    if (length(message.dict) > 1) {
      fixation.data$poi <- NA
      
      for (trial.counter in 1:nrow(trial.info)) {
        
        for (poi.counter in 2:length(message.dict)) {
          poi.name <- names(message.dict[poi.counter])
          
          col.index.start <- which(colnames(trial.info) == message.dict[[poi.counter]][1])
          col.index.stop <- which(colnames(trial.info) == message.dict[[poi.counter]][2])  
          
          start.row <-  which.min(
            abs(fixation.data$fix.start - trial.info[trial.counter, col.index.start]))
          stop.row <-  which.min(
            abs(fixation.data$fix.end - trial.info[trial.counter, col.index.stop, trial.counter]))
          fixation.data$poi[start.row:stop.row] <- poi.name
        }
        
      }
    }
    
    
    # Initializes header information data frame
    header.info <- as.data.frame(matrix(ncol = 7 , nrow = 1))
    colnames(header.info) <- c("participant.name", 
                               "participant.nr", 
                               "sample.rate",
                               "display.x", 
                               "display.y", 
                               "record.date", 
                               "trial.count")
    
    

    header.info[1,1] <- strsplit(raw.file.list[file.counter],'_')[[1]][1]
    header.info[1,2] <- participant.nr
    
    #round(1/mean(diff(eye.mov.data$time)), digits = 0)
    header.info[1,3] <- ceiling(1/mean(diff(eye.mov.data$time),na.rm = T))
    
    
    
    # take display coordinates from message, other option might be to take from screenshots
    coords <- message.data$message[which(message.data$message.label == "dsp_dims")]
    coords <- gsub("dsp_dims ", "", coords)
    coords <- gsub("\\[|\\]", "", coords)
    
    #coords.x <- strsplit(coords,' ')[[1]][1]
    header.info[1,4] <- as.numeric(strsplit(coords,' ')[[1]][1])
    header.info[1,5] <- as.numeric(strsplit(coords,' ')[[1]][2])
    
    
    
    # header.info[1,6] <- as.character((message.data$message.3[which(
    #   message.data$message.2 == "datetime")])[1])
    header.info[1,7] <- number.of.trials
    
    # Addes header, trial and eye movement data to eyEdu.data list
    eyEdu.data$participants[[file.counter]] <- list(header.info = header.info, 
                                                    trial.info = trial.info, 
                                                    sample.data = eye.mov.data,
                                                    fixation.data = fixation.data)
    
    # must reset poi.start otherwise if statement in line...
    if(length(message.dict) > 1){
      poi.start = NA
    }
    
    # Progress report
    processed.file <- raw.file.list[file.counter]
    print(paste("Importing file:", processed.file, "- number",
                file.counter, "out of",
                length(eyEdu.data$participants), sep = " "))
  }
  
  # creates a participant table and adds it to the eyEdu.data file
  participant.table <- data.frame(matrix(NA, nrow = length(names(
    eyEdu.data$participants)), ncol = 3))
  colnames(participant.table) <- c("list.entry", "part.name", "part.nr")
  
  for(list.entry.number  in 1 :length(names(eyEdu.data$participants))) {
    participant.table$list.entry[list.entry.number] <- list.entry.number
    participant.table$part.name[list.entry.number] <-  eyEdu.data$participants[[
      list.entry.number]]$header.info$participant.name
    participant.table$part.nr[list.entry.number] <-  eyEdu.data$participants[[
      list.entry.number]]$header.info$participant.nr
  }
  eyEdu.data$participant.table <- participant.table
  
  print("Saving data to eyEdu_data.Rda, this might take a while.")
  save(eyEdu.data, file = paste(raw.data.path,"eyEdu_data.Rda", sep = ""))
  
  
  
  return("Done!")
}


################


