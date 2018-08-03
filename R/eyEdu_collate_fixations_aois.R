EyEduCollateFixationsAois <- function(){

load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

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
    
# chosing the corresponding aoi.info set 
aoi.set.name <- eyEdu.data$participants[[participant.counter]]$
 trial.info$background.image[trial.counter]
aoi.info.set <- eyEdu.data$aoi.info[[aoi.set.name]]

if (is.null(aoi.info.set)) {
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
} # end participant.counter
  
save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
}
  