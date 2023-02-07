EyEduImportEyeLinkData <- function(poi.start = NA, 
                              poi.end = NA,
                              asc.path = NA,
                              message.dict = NA,
                              participant.id.var ="subject_nr",
                              remove.outliers = TRUE,
                              python.correction = FALSE,
                              eye.sides = "R",
                              include.samples = FALSE){

# List of files that will be processed.
raw.file.list <- list.files(path= paste(raw.data.path, asc.path, sep = ""), 
                            pattern = "\\.asc$",
                            ignore.case = T)

# Initializes empty list, which will be filled with participant data and
# an empty list for aoi.info and futur features
eyEdu.data <- list()  
length(eyEdu.data) = 3
names(eyEdu.data) <- c("participant.table","participants","aoi.info")

# Fills first level list with an empty list of length n-participants
eyEdu.data$participants <- list()
length(eyEdu.data$participants) = length(raw.file.list)
names(eyEdu.data$participants) = raw.file.list

if (python.correction == TRUE){
  py.cor.var = 1
} else {
  py.cor.var = 0
}


# Loops through files 
for(file.counter in 1:length(raw.file.list)) {
  
### Import eye movement and sample data  
  
if(include.samples == FALSE){
  eye.mov.data <- data.frame(matrix(data = NA, nrow = 1, ncol = 11))
  colnames(eye.mov.data) <- c("time","Lrawx", "Lrawy","Lpupil","Rrawx", "Rrawy","Rpupil", "avgx", "avgy", "rawx", "rawy")
} else {
raw.data <- read.csv(paste(raw.data.path,asc.path, raw.file.list[file.counter],
                     sep = ""),sep="", header = F, encoding = "UTF-8",
                     strip.white=T, stringsAsFactors=FALSE)
colnames(raw.data)[1] <- "temp"


eye.mov.data <- raw.data[which(grepl("[[:digit:]]", raw.data$temp) == TRUE),]
eye.mov.data[1:ncol(eye.mov.data)] <- suppressWarnings(sapply(eye.mov.data[1:ncol(eye.mov.data)],as.numeric))


if(eye.sides == "R"){
  colnames(eye.mov.data)[1:4] <- c("time","Rrawx", "Rrawy","Rpupil")
}

if(eye.sides == "L"){
  colnames(eye.mov.data)[1:4] <- c("time","Lrawx", "Lrawy","Lpupil")
}

if(eye.sides == "B"){
  colnames(eye.mov.data)[1:7] <- c("time","Lrawx", "Lrawy","Lpupil","Rrawx", "Rrawy","Rpupil")
}


empty.columns <- sapply(eye.mov.data, function(x)all(is.na(x)))
eye.mov.data <- eye.mov.data[,-(which(empty.columns == TRUE))]

if(remove.outliers == TRUE) {
  # Re-codes negative position values into NA
  eye.mov.data$Rrawx[eye.mov.data$Rrawx < 0]  <- NA
  eye.mov.data$Rrawy[eye.mov.data$Rrawy < 0] <- NA
}

# experimental only, need more example data to adjust function (e.g., for both eyes, left eye only etc.)
### debug ###
eye.mov.data$avgx <- eye.mov.data$Rrawx
eye.mov.data$avgy <- eye.mov.data$Rrawy
eye.mov.data$rawx <- eye.mov.data$Rrawx
eye.mov.data$rawy <- eye.mov.data$Rrawy
eye.mov.data$Ravgx <- eye.mov.data$Rrawx
eye.mov.data$Ravgy <- eye.mov.data$Rrawy
eye.mov.data$Lavgx <- eye.mov.data$Lrawx
eye.mov.data$Lavgy <- eye.mov.data$Lrawy
eye.mov.data$Lrawx <- eye.mov.data$Lrawx
eye.mov.data$Lrawy <- eye.mov.data$Lrawy

# Fixes row name order for indexing.
row.names(eye.mov.data) <- 1: nrow(eye.mov.data)

}

### Import message data
raw.data <- read.csv(paste(raw.data.path,asc.path, raw.file.list[file.counter],
                           sep = ""),sep=" ", header = F, encoding = "UTF-8",
                     strip.white=T, stringsAsFactors=FALSE)
colnames(raw.data)[1] <- "time"

message.data <- raw.data[which(grepl("MSG", raw.data$time) == TRUE),]
message.data$time <- gsub("MSG", "", message.data$time)
message.data$time <- as.numeric(message.data$time)
colnames(message.data)[2:ncol(message.data)] <- paste("message.", 1:(ncol(message.data)-1), sep = "")
rownames(message.data) <- 1: nrow(message.data)


if(is.na(poi.start)){
  poi.start = message.dict$trial[1]
  poi.end = message.dict$trial[2]
  poi.count = length(message.dict) *2
  message.couple <- c("start.message", "stop.message")
  for(i in 2:length(message.dict)){
    message.couple <- append(message.couple, message.dict[i][[1]])
  }
}else{
  poi.count = 2
  message.couple <- c("start.message", "stop.message")
}

# Extracts info about time points for trial start, trial end (or period of 
# interest) and writes these to a new data frame: trial.info
number.of.trials <- length(message.data$time[which(
  message.data$message.1 == poi.start)])

trial.info <- as.data.frame(matrix(ncol = poi.count, nrow = number.of.trials))
colnames(trial.info) <-  message.couple

trial.info$start.message <- as.numeric(message.data$time[which(
  message.data$message.1 == poi.start)])

trial.info$stop.message <- as.numeric(message.data$time[which(
  message.data$message.1 == poi.end)])


if(ncol(trial.info) > 3){
for(col.index in 3:ncol(trial.info)){
  trial.info[col.index] <- as.numeric(message.data$time[which(
    message.data$message.1 == colnames(trial.info)[col.index])])
}
}

trial.info$trial.index <- 1:nrow(trial.info)
trial.info$trial.duration <- trial.info$stop.message - trial.info$start.message


temp.message <- message.data[which(message.data$message.1 == "stimulus"), 3:ncol(message.data)]

# if(nrow(temp.message) < 1){
  trial.info$stimulus.message <- NA 
# } else {
#   empty.columns <- sapply(temp.message, function(x)all(is.na(x)))
#   temp.message <- temp.message[,-(which(empty.columns == TRUE))]
#   trial.info$stimulus.message <- apply(temp.message[ , 1:ncol(temp.message) ] , 1 , paste , collapse = " " )
#   trial.info$stimulus.message <-trimws(trial.info$stimulus.message,which = "right")  
# }

# trial.info$stimulus.id <- as.numeric(message.data$message.2[which(
#   message.data$message.1 == poi.start)])

trial.info$stimulus.id <- trial.info$trial.index

if(is.na(participant.id.var)){
  participant.nr <- gsub(".asc", "", raw.file.list[file.counter], ignore.case = T)
}else{
  participant.nr <- message.data$message.2[which(message.data$message.1 == participant.id.var)][1]
}




trial.info$background.image <- paste(participant.nr, "_", 
                                     trial.info$trial.index - py.cor.var,
                                     "_", trial.info$stimulus.id,
                                     ".png", sep = "")



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
eye.mov.data$trial.index[start.row:stop.row]<- trial.counter
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


#### Import fixations
raw.data <- read.csv(paste(raw.data.path,asc.path, raw.file.list[file.counter],
                           sep = ""),sep="", header = F, encoding = "UTF-8",
                     strip.white=T, stringsAsFactors=FALSE)
colnames(raw.data)[1] <- "temp"

fixation.data <- raw.data[which(grepl("EFIX", raw.data$temp) == TRUE),]


if(eye.sides == "R"){
  # subsets fixation to only include fixations from the right eye
  fixation.data <- subset(fixation.data, fixation.data$V2 == "R")
  colnames(fixation.data)[3:7] <- c("fix.start", "fix.end", "fix.dur", "fix.pos.x", "fix.pos.y")
}


if(eye.sides == "L"){
  # subsets fixation to only include fixations from the left eye
  fixation.data <- subset(fixation.data, fixation.data$V2 == "L")
  colnames(fixation.data)[3:7] <- c("fix.start", "fix.end", "fix.dur", "fix.pos.x", "fix.pos.y")
}


fixation.data[3:ncol(fixation.data)] <- suppressWarnings(sapply(fixation.data[3:ncol(fixation.data)],as.numeric))
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
## for debugging only ### 
empty.columns <- sapply(fixation.data, function(x)all(is.na(x)))
fixation.data <- fixation.data[,-(which(empty.columns == TRUE))]

fixation.data <- fixation.data[,-c(1,2)]

fixation.data$fixation.index <- NA
for(trial.counter in 1:nrow(trial.info)){
  row.index <- which(fixation.data$trial.index == trial.counter)
  fixation.data$fixation.index[row.index] <- 1:length(row.index)
}

# Adds additional POI info to fixation data
if (length(message.dict) >1){
  fixation.data$poi <- NA
  
  for(trial.counter in 1:nrow(trial.info)) {
    
    for(poi.counter in 2:length(message.dict)) {
      poi.name <- names(message.dict[poi.counter])
      
      col.index.start <- which(colnames(trial.info) == message.dict[[poi.counter]][1])
      col.index.stop <- which(colnames(trial.info) == message.dict[[poi.counter]][2])  
      
      start.row <-  which.min(
        abs(fixation.data$fix.start - trial.info[trial.counter, col.index.start]))
      stop.row <-  which.min(
        abs(fixation.data$fix.end - trial.info[trial.counter, col.index.stop, trial.counter]))
      fixation.data$poi[start.row:stop.row]<- poi.name
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
header.info[1,1] <- gsub(".asc", "", raw.file.list[file.counter])
header.info[1,2] <- participant.nr
header.info[1,3] <- as.numeric(message.data$message.4[which(
  message.data$message.1 == "!MODE")[1]])

# The display dimension are set for python (start counting a 0), hence, a 1 is added 
header.info[1,4] <- as.numeric(message.data$message.4[which(message.data$message.1 == "DISPLAY_COORDS")]) + 1
header.info[1,5] <- as.numeric(message.data$message.5[which(message.data$message.1 == "DISPLAY_COORDS")]) + 1

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
