EyEduImportBehavioralData <- function(raw.data.path,
                                      selection = c(colnames(behav_dat))){

  (file.list <- list.files(raw.data.path , pattern = "csv", recursive = F))

  behav_dat<- NULL
  for(file in file.list){
    jj <- read.csv(paste(raw.data.path, file, sep = ""), header = T)
    fileName <- gsub(".csv", "", file)
    jj$Participant <- factor(fileName)
    jj$start <- NULL
    jj$trial.index <- 1:nrow(jj)
    jj$participant.nr <- jj$subject_nr
    jj$participant.name <- jj$Participant

    # in case there is no dtplyr package - use plyr solution
    behav_dat <- plyr::rbind.fill(behav_dat, jj)

    # Providing some feedback on processing progress.
    print(paste("The file:", file, "has been imported successfully.", sep = " "))
  }
  # select important variables
  # choose the variables your interested in, by default all are selected
  behav_dat      <- subset(behav_dat, select = selection) #Make your selection

  writeLines("All available files were imported and row-bound.\n Columns are matched by name, and any values that don't match will be filled with NA.")
  #  print("Columns are matched by name, and any values that don't match will be filled with NA")
  return(behav_dat)
}