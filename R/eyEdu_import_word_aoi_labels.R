
EyEduImportWordAoiLabels <- function(extra.aoi = NULL,
                                     sparse.aoi.definition = FALSE){
  
  # loads the eyEdu data frame to which the aoi.files will be added
  load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))  

  if (is.null(eyEdu.data$aoi.info)){
    return("There are no AoIs defined yet! 
           Please run EyEduDefineWordAois() or 
           import existing aoi files with EyEduImportAoIs()!")
  } 
  
  for(aoi.counter in 1: length(eyEdu.data$aoi.info)){
    if(sparse.aoi.definition == TRUE){
    # extracts the stimulus id variable (i.e., the third element of the 
    # image name)
    stim.id.var <- unlist(strsplit(eyEdu.data$aoi.info[[
      aoi.counter]]$image.name[1], "[_]"))[[3]]
    # get the actual stimulus from the trial.info data frame of the first 
    # participant
    stim.index <- which(eyEdu.data$participants[[1]]$trial.info$stimulus.id 
                        == stim.id.var)
    stimulus <- eyEdu.data$participants[[1]]$trial.info$stimulus.message[
      stim.index]
    } else {
      stim.id.var <- unlist(strsplit(eyEdu.data$aoi.info[[
        aoi.counter]]$image.name[1], "[_]"))[[3]]
      participant.id.var <- unlist(strsplit(eyEdu.data$aoi.info[[
        aoi.counter]]$image.name[1], "[_]"))[[1]]
      participant.index <- which(eyEdu.data$participant.table$part.nr 
                                 == participant.id.var)
      stim.index <- which(eyEdu.data$participants[[
        participant.index]]$trial.info$stimulus.id == stim.id.var)
      
      stimulus <- eyEdu.data$participants[[
        participant.index]]$trial.info$stimulus.message[stim.index]
    }
    
    word.vector <- unlist(strsplit(stimulus, " "))
    
    if(!is.null(word.vector)){
    word.vector <- c(word.vector, extra.aoi)
    }
    
    if(length(word.vector) != nrow(eyEdu.data$aoi.info[[aoi.counter]])){
    return("The number of words and AoIs do not match. 
           Interrupted label import. Consider using extra.aoi for patching?")
      }
    
    eyEdu.data$aoi.info[[aoi.counter]]$aoi.label <- word.vector
  }
save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
}

