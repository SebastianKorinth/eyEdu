EyEduBatchPlotDiagnostics <- function(participant.nr.list = NULL,
                                 image.width = 1000,
                                 image.height = 700, 
                                 sample.length = 2500,
                                 show.filtered = FALSE){
  
  load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
  # diagnostic plots can be created for selected or for all participants
  # if no participant number list is provided as a parameter the default
  # output will be all participants
  
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
    folder.name <- paste(participant.name, " diagnosticPlots", sep = "")
    dir.create(paste(getwd(),"/",folder.name, sep = ""))
    
    trial.vector <- 1: eyEdu.data$participants[[
      participant.index]]$header.info$trial.count
    # some processing feedback
    print(paste("Creating diagnostic plots for:", participant.name, "- number",
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
      # uses eyEdu diagnostic plot function
      plot(EyEduPlotDiagnostics(participant.name = participant.name,
                           trial.nr = trial.index,
                           sample.length = sample.length, 
                           show.filtered = T))

      dev.off()
    }
  }
  print("Done!")
}
