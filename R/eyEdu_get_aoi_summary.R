EyEduGetAoiSummary <- function() {
  # Loads eyEdu data
  load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  # Prepares empty data frame
  aoi.summary <- data.frame(
    participant.name = character(),
    participant.nr = numeric(),
    stimulus.id = character(),
    aoi.index = numeric(),
    line.aoi.index = numeric(),
    x.left = numeric(),
    x.right = numeric(),
    y.top = numeric(),
    y.bottom = numeric(),
    line.number = numeric(),
    fix.start = numeric(),
    fix.end = numeric(),
    fix.duration = numeric(),
    fix.pos.x = numeric(),
    fix.pos.y = numeric(),
    fixation.index = numeric(),
    trial.index = numeric(),
    aoi.label = character(),
    stringsAsFactors = F
  )
  if (is.null(eyEdu.data$aoi.info)) {
    return("There are no aoi definitions!")
  }
  # Loops through aoi infos
  for (aoi.counter in 1:length(eyEdu.data$aoi.info)) {
    temp.aoi <- eyEdu.data$aoi.info[[aoi.counter]]
    temp.aoi$aoi.label <- NULL
    temp.aoi$line.aoi.index <- NULL
    temp.aoi$line.number <- NULL
    temp.aoi$stimulus.id <- gsub("^.*_", "", temp.aoi$image.name)
    temp.stimulus.id <- temp.aoi$stimulus.id[1]
    temp.aoi$image.name <- NULL
    # Loops through participants
    for (participant.counter in 1:length(eyEdu.data$participants)) {
      temp.fixation <- subset(
        eyEdu.data$participants[[participant.counter]]$fixation.data,
        eyEdu.data$participants[[participant.counter]]$fixation.data$stimulus.id
        == temp.stimulus.id
      )
        temp.merge <- merge(
        temp.aoi,
        temp.fixation,
        by = c("stimulus.id", "aoi.index"),
        all = TRUE
      )
      
      temp.merge$participant.name <- eyEdu.data$participants[[
        participant.counter]]$header.info$participant.name
      temp.merge$participant.nr <- eyEdu.data$participants[[
        participant.counter]]$header.info$participant.nr
      temp.merge$trial.index[is.na(temp.merge$trial.index)] <-
        temp.merge$trial.index[which(!is.na(temp.merge$trial.index))[1]]
      aoi.summary <- rbind(aoi.summary, temp.merge)
    } # end participant loop
    
    # Provides some progress feedback
    print(paste(
      "Creating aoi summary for aoi info file",
      aoi.counter,
      "out of",
      max(length(eyEdu.data$aoi.info)),
      sep = " "
    ))
  } # end of of aoi loop
  
  save(aoi.summary,
       file = paste(raw.data.path, "aoi_summary.Rda", sep = ""))
  print("Done!")
}
  