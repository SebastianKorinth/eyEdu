EyEduBatchPlotTrials <- function(participant.nr.list = NULL,
                                 image.width = 1000,
                                 image.height = 700, 
                                 sparse.aoi.definition = T,
                                 aoi.names.screenshot = T,
                                 aoi.color = "black",
                                 fix.color = "red",
                                 sample.color.r = NA,
                                 sample.color.l = NA,
                                 sample.color = "darkviolet",
                                 show.filtered = FALSE){

load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

# trial plots can be created for selected or for all participants
# if no participant number list is provided the default output
# will be all participants
  
if (is.null(participant.nr.list)) {
  participant.index.vector <- 1:length(eyEdu.data$participants)
}else{
  participant.index.vector <- eyEdu.data$participant.table$part.nr
  participant.index.vector <- eyEdu.data$participant.table$list.entry[
    participant.index.vector %in%  participant.nr.list]
}

  
for(participant.index in participant.index.vector){
  
  # creates a folder in the working directory for each participant
  participant.name <- eyEdu.data$participant.table$part.name[
    eyEdu.data$participant.table$list.entry == participant.index]
  folder.name <- paste(participant.name, " trialPlots", sep = "")
  dir.create(paste(getwd(),"/",folder.name, sep = ""))

  trial.vector <- 1: eyEdu.data$participants[[
    participant.index]]$header.info$trial.count
# some processing feedback
    print(paste("Creating trial plots for:", participant.name, "- number",
              which(participant.index.vector == participant.index), 
              "out of",
              length(participant.index.vector),
              sep = " "))
  
  for(trial.index in trial.vector ){
    
    image.file.name <- paste(getwd(),"/",
                             folder.name,
                             "/trial_",
                             trial.index,
                             ".png",
                             sep = "")

    # opens png device
    png(image.file.name, width = image.width, height = image.height)
    # uses eyEdu plot function
    plot(EyEduPlotTrial(participant.name = participant.name,
                        trial.nr = trial.index,
                        sparse.aoi.definition = sparse.aoi.definition,
                        aoi.names.screenshot = aoi.names.screenshot,
                        aoi.color = aoi.color,
                        fix.color = fix.color,
                        sample.color.r = sample.color.r,
                        sample.color.l = sample.color.l,
                        sample.color = sample.color,
                        show.filtered = show.filtered))    
    
    dev.off()
  }
}
  print("Done!")
}
