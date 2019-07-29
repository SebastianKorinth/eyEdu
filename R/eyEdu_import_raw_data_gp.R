EyEduImportRawDataGP <- function(poi.start = "time_pygaze_start_recording", 
                              poi.end = "time_pygaze_stop_recording",
                              remove.outliers = TRUE){


# List of files that will be processed.
raw.file.list <- list.files(path= raw.data.path, pattern = "\\.tsv$")
log.file.list <- list.files(path= raw.data.path, pattern = "\\.txt$")

# Initializes empty list, which will be filled with participant data and
# an empty list for aoi.info and futur features
eyEdu.data <- list()  
length(eyEdu.data) = 3
names(eyEdu.data) <- c("participant.table","participants","aoi.info")

# Fills first level list with an empty list of length n-participants
eyEdu.data$participants <- list()
length(eyEdu.data$participants) = length(raw.file.list)
names(eyEdu.data$participants) = raw.file.list

# Loops through files 
for(file.counter in 1:length(raw.file.list)) {
eye.mov.data <- read.csv(paste(raw.data.path, raw.file.list[file.counter],
                     sep = ""),sep="\t", header=T, encoding = "UTF-8",
                     strip.white=TRUE, stringsAsFactors=FALSE)

# Fixes rowname order for indexing.
row.names(eye.mov.data) <- 1: nrow(eye.mov.data)

# compatible with eye tribe
colnames(eye.mov.data)[2] <- "time"


message.data <- read.csv(paste(raw.data.path, log.file.list[file.counter],
                           sep = ""),sep="\t", header=T, encoding = "UTF-8",
                     strip.white=TRUE, stringsAsFactors=FALSE)
colnames(message.data) <- "state"

# Splits messages for easier indexing 
message.data$message.1 <- sapply(strsplit(as.character(message.data$state),' '),
                                 "[", 1)
message.data$message.2 <- sapply(strsplit(as.character(message.data$state),' '),
                                 "[", 2)
message.data$message.3 <- sapply(strsplit(as.character(message.data$state),' '),
                                 "[", 3)
message.data$message.4 <- sapply(strsplit(as.character(message.data$state),' '),
                                 "[", 4)
message.data$message.5<- sapply(strsplit(as.character(message.data$message.2),
                                         '_'),"[",1)
message.data$message.6 <- sapply(strsplit(as.character(message.data$message.2),
                                          '_'),"[",2)
message.data$message.7 <- sapply(strsplit(as.character(message.data$message.2),
                                          '_'),"[",3)
message.data$message.8 <- sapply(strsplit(as.character(message.data$message.2),
                                          '_'),"[",4)

# Extracts info about time points for trial start, trial end (or period of 
# interest) and writes these to a new data frame: trial.info

number.of.trials <- length(which(message.data$message.2 == poi.start))
trial.info <- as.data.frame(matrix(ncol = 3, nrow = number.of.trials))
colnames(trial.info) <- c("start.message", "stop.message", "stimulus.message")
trial.info$start.message <- as.numeric(message.data$message.3[which(
  message.data$message.2 == poi.start)])

if (poi.end == "time_pygaze_stop_recording"){
trial.info$stop.message <- as.numeric(message.data$message.3[which(
  message.data$message.2 == poi.end)])
}else{
  trial.info$stop.message <- as.numeric(message.data$message.3[which(
    message.data$message.2 == poi.end)]) + trial.info$start.message
  }

trial.info$stimulus.message <- gsub("var stimulus ", "", 
                                    message.data$state[which(
                                    message.data$message.2 == "stimulus")])
trial.info$stimulus.id <- message.data$message.3[as.numeric(which(
  message.data$message.2 == "stim_id"))]
trial.info$trial.index <- 1:nrow(trial.info)
trial.info$trial.duration <- trial.info$stop.message - trial.info$start.message

participant.nr <- as.numeric((message.data$message.3[which(
  message.data$message.2 == "subject_nr")])[1])

trial.info$background.image <- paste(participant.nr, "_", 
                                     trial.info$trial.index - 1,
                                     "_", trial.info$stimulus.id,
                                     ".png", sep = "")

#### Aligns open sesame time with gaze point time
eye.mov.data$time <-
  ((eye.mov.data$time - eye.mov.data$time[1]) * 1000) + trial.info$start.message[1]


# Loop searches for rownames in eye movement data, wich correspond 
# to time points of start and stop messages. Note, timing of eye movement data 
# (i.e., ~ 17 ms each time point at 60Hz sampling rate) has to be aligned with 
# stimulus and response timing (1 ms accuracy). The nearest eye movement
# sample point corresponding to start and stop messages will be used, which  
# might lead to the loss of single sample points. 
eye.mov.data$trial.index <- 0

for(trial.counter in 1:nrow(trial.info)) {
  start.row <- as.numeric(row.names(eye.mov.data)[which.min(
    abs(eye.mov.data$time - trial.info$start.message[trial.counter]))])
  stop.row <- as.numeric(row.names(eye.mov.data)[which.min(
    abs(eye.mov.data$time - trial.info$stop.message[trial.counter]))])
  eye.mov.data$trial.index[start.row:stop.row] <- trial.counter
}

# Deletes rows that were not asigned to a trial due to differences in sample
# precision (i.e., 17 ms vs. 1 ms).
eye.mov.data <- subset(eye.mov.data, eye.mov.data$trial.index > 0)

# Initialises header information data frame
header.info <- as.data.frame(matrix(ncol = 7 , nrow = 1))
colnames(header.info) <- c("participant.name", 
                           "participant.nr", 
                           "sample.rate",
                           "display.x", 
                           "display.y", 
                           "record.date", 
                           "trial.count")
header.info[1,1] <- gsub(".tsv", "", raw.file.list[file.counter])
header.info[1,2] <- participant.nr
header.info[1,3] <- as.numeric(message.data$message.2[which(
  message.data$message.1 == "samplerate:")])
display.resolution <- message.data$message.3[which(
  message.data$message.2 == "resolution:")]
header.info[1,4] <- as.numeric(unlist(strsplit(display.resolution,"x"))[1])
header.info[1,5] <- as.numeric(unlist(strsplit(display.resolution,"x"))[2])
rm(display.resolution)
header.info[1,6] <- as.character((message.data$message.3[which(
  message.data$message.2 == "datetime")])[1])
header.info[1,7] <- number.of.trials

# Recodes percentage position values to pixel position 
eye.mov.data$rawx <- eye.mov.data$BPOGX * header.info$display.x
eye.mov.data$rawy <- eye.mov.data$BPOGY * header.info$display.y
eye.mov.data$Rrawx <- eye.mov.data$RPOGX * header.info$display.x
eye.mov.data$Rrawy <- eye.mov.data$RPOGY * header.info$display.y
eye.mov.data$Lrawx <- eye.mov.data$LPOGX * header.info$display.x
eye.mov.data$Lrawy <- eye.mov.data$LPOGY * header.info$display.y

if(remove.outliers == TRUE) {
# Recodes negative position values into NA
eye.mov.data$rawx[eye.mov.data$rawx < 0]  <- NA
eye.mov.data$rawy[eye.mov.data$rawy < 0] <- NA
eye.mov.data$Rrawx[eye.mov.data$Rrawx < 0] <- NA
eye.mov.data$Rrawy[eye.mov.data$Rrawy < 0] <- NA
eye.mov.data$Lrawx[eye.mov.data$Lrawx < 0] <- NA
eye.mov.data$Lrawy[eye.mov.data$Lrawy < 0] <- NA
}

# Initialises header information data frame
header.info <- as.data.frame(matrix(ncol = 7 , nrow = 1))
colnames(header.info) <- c("participant.name", 
                           "participant.nr", 
                           "sample.rate",
                           "display.x", 
                           "display.y", 
                           "record.date", 
                           "trial.count")
header.info[1,1] <- gsub(".tsv", "", raw.file.list[file.counter])
header.info[1,2] <- participant.nr
header.info[1,3] <- as.numeric(message.data$message.2[which(
  message.data$message.1 == "samplerate:")])
display.resolution <- message.data$message.3[which(
  message.data$message.2 == "resolution:")]
header.info[1,4] <- as.numeric(unlist(strsplit(display.resolution,"x"))[1])
header.info[1,5] <- as.numeric(unlist(strsplit(display.resolution,"x"))[2])
rm(display.resolution)
header.info[1,6] <- as.character((message.data$message.3[which(
  message.data$message.2 == "datetime")])[1])
header.info[1,7] <- number.of.trials

# Addes header, trial and eye movement data to eyEdu.data list
eyEdu.data$participants[[file.counter]] <- list(header.info = header.info, 
                                  trial.info = trial.info, 
                                  sample.data = eye.mov.data)

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

save(eyEdu.data, file = paste(raw.data.path,"eyEdu_data.Rda", sep = ""))
return("Done!")
}
