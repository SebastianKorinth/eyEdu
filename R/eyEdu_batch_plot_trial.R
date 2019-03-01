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

if (is.null(participant.nr.list)) {
  participant.index.vector <- 1:length(eyEdu.data$participants)
}else{
  participant.index.vector <- eyEdu.data$participant.table$part.nr
  participant.index.vector <- eyEdu.data$participant.table$list.entry[participant.index.vector %in%  participant.nr.list]
}

for(participant.index in participant.index.vector){
  
  # creates a folder in the working directory for each participant
  folder.name <- eyEdu.data$participant.table$part.name[eyEdu.data$participant.table$list.entry == participant.index]
  dir.create(paste(getwd(),"/",folder.name, sep = ""))

  trial.vector <- 1: eyEdu.data$participants[[participant.index]]$header.info$trial.count
  print(paste("Trial plots will be created for:", folder.name, sep = " "))
  for(trial.index in trial.vector ){
    
    image.file.name <- paste(getwd(),"/",
                             folder.name,
                             "/trial_",
                             trial.index,
                             ".png",
                             sep = "")
    
    png(image.file.name, width = image.width, height = image.height)
    
    plot(EyEduPlotTrial(participant.name = folder.name,
                        trial.nr = trial.index,
                        sparse.aoi.definition = sparse.aoi.definition,
                        aoi.names.screenshot = aoi.names.screenshot,
                        aoi.color = aoi.color,
                        fix.color = fix.color,
                        sample.color.r = sample.color.r,
                        sample.color.l = sample.color.l,
                        sample.color = sample.color,
                        show.filtered = FALSE))
    
    dev.off()
  }# end trial loop
  
} # end participant loop
 
  
}
