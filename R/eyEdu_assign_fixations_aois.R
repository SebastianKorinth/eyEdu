EyEduAssignFixationsAois <- function(sparse.aoi.definition = TRUE,
                                     aoi.names.screenshot = TRUE){

load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

  if (is.null(eyEdu.data$aoi.info)) {
    return("There are no AoI definitios!")
    }
  
# loops through participants  
for(participant.counter in 1:length(eyEdu.data$participants)){
  
eyEdu.data$participants[[participant.counter]]$fixation.data$aoi.index <- NA
eyEdu.data$participants[[participant.counter]]$fixation.data$aoi.line.index <- NA
eyEdu.data$participants[[participant.counter]]$fixation.data$aoi.label <- NA
# loops through trials 
for(trial.counter in 1:max(eyEdu.data$participants[[participant.counter]]$
                           fixation.data$trial.index)){

trial.subset <- subset(eyEdu.data$participants[[participant.counter]]$
                          fixation.data, 
                        eyEdu.data$participants[[participant.counter]]$
                          fixation.data$trial.index == trial.counter)

if(aoi.names.screenshot == FALSE) {
  
  aoi.set.name <- paste(eyEdu.data$participants[[participant.counter]]$
    trial.info$stimulus.message[trial.counter], ".png", sep = "")
  aoi.info.set <- eyEdu.data$aoi.info[[aoi.set.name]]
  
} else {
    
# chosing the corresponding aoi.info set 
aoi.set.name <- eyEdu.data$participants[[participant.counter]]$
 trial.info$background.image[trial.counter]

if (sparse.aoi.definition == TRUE) {
  # stim.id.only <- unlist(strsplit(aoi.set.name, "_"))[3]
  # aoi.names <- names(eyEdu.data$aoi.info)
  # aoi.info.set <- eyEdu.data$aoi.info[[aoi.names[grep(stim.id.only, aoi.names)[1]]]]
  
  stimulus.id <- trial.subset$stimulus.id[1] 
  aoi.index <- grep(paste("*_", stimulus.id,".png", sep =""), 
                    names(eyEdu.data$aoi.info))[1]
  aoi.info.set <- eyEdu.data$aoi.info[[aoi.index]]
  
  
} else {
aoi.info.set <- eyEdu.data$aoi.info[[aoi.set.name]]
}}

# exception, for instance, if trials are missing 

if(is.null(aoi.info.set)){
  next
  }

# loops through aois  
for(aoi.counter in 1: nrow(aoi.info.set)) {
 write.index <-which(trial.subset$fix.pos.x > aoi.info.set$x.left[aoi.counter] &
                    trial.subset$fix.pos.x < aoi.info.set$x.right[aoi.counter] &
                    trial.subset$fix.pos.y > aoi.info.set$y.top[aoi.counter] & 
                    trial.subset$fix.pos.y < aoi.info.set$y.bottom[aoi.counter])
      
trial.subset$aoi.index[write.index] <- aoi.info.set$aoi.index[aoi.counter] 
trial.subset$aoi.line.index[write.index] <- aoi.info.set$line.number[aoi.counter]
trial.subset$aoi.label[write.index] <- aoi.info.set$aoi.label[aoi.counter]

}  # end aoi.counter
eyEdu.data$participants[[participant.counter]]$
  fixation.data$aoi.index[eyEdu.data$participants[[participant.counter]]$
   fixation.data$trial.index == trial.counter] <- trial.subset$aoi.index

eyEdu.data$participants[[participant.counter]]$
  fixation.data$aoi.line.index[eyEdu.data$participants[[participant.counter]]$
   fixation.data$trial.index == trial.counter] <- trial.subset$aoi.line.index

eyEdu.data$participants[[participant.counter]]$
  fixation.data$aoi.label[eyEdu.data$participants[[participant.counter]]$
     fixation.data$trial.index == trial.counter] <- trial.subset$aoi.label
} # end trial.counter

# Providing some feedback on processing progress.
processed.participant <- names(eyEdu.data$participants[participant.counter])
print(paste("Assigning fixations to AoIs for participant: ",
            processed.participant, 
            "- number", participant.counter, 
            "out of", 
            max(length(eyEdu.data$participants)), sep = " "))
} # end participant.counter
  
save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
return("Done!")  
}
  