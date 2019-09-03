EyEduQcExAoi = function(){
  
# Loads eyEdu data
  load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))  

 # The function calculates for each participant and trial the
 # percentage of fixations that fall outside any area of interes.
 # This info is then added to the trial info and can be used 
 # for exluding noisy trials (i.e., bad calibrations leading to
 # incorrect fixation position measures)
  
# Start participant loop    
  for (participant.counter in 1:length(eyEdu.data$participants)){
    
    # Exception handler no fixation detected
    if (is.null(eyEdu.data$participants[[participant.counter]]$fixation.data)){
      print(paste("No fixations detected yet!"))
      next
    }
    
    # Execption handler fixations not yet assigned to aois
    
    # Exception handler
    if (is.null(eyEdu.data$participants[[participant.counter]]$fixation.data$aoi.index)){
      print(paste("Aois were not yet assigned to fixations!"))
      next
    }
  
  eyEdu.data$participants[[participant.counter]]$trial.info$qc.ex.aoi = NA

# Start trial loop    
    for (trial.counter in 1:max(eyEdu.data$participants[[
      participant.counter]]$trial.info$trial.index)){
      eyEdu.data$participants[[participant.counter]]$trial.info$qc.ex.aoi[
        eyEdu.data$participants[[
        participant.counter]]$trial.info$trial.index == trial.counter] = 
        
        mean(is.na(eyEdu.data$participants[[
          participant.counter]]$fixation.data$aoi.index[
          eyEdu.data$participants[[
          participant.counter]]$fixation.data$trial.index == trial.counter]))

    } # End trial loop
  } # End participant loop
  save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  print("Done!")
}
