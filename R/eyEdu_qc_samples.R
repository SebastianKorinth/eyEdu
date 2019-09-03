
EyEduQcSamples = function(){
  
  # Loads eyEdu data
  load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))  
  
 # The function calculates for each participant and trial the
 # percentage of NAs within the raw samples. This info is then 
 # added to the trial info and can be used for exluding noisy 
 # trials (i.e., lots of blinks or tracker loss)
 
  # Start participant loop    
  for (participant.counter in 1:length(eyEdu.data$participants)){
    
    eyEdu.data$participants[[participant.counter]]$trial.info$qc.samples = NA
    
    # Start trial loop    
    for (trial.counter in 1:max(eyEdu.data$participants[[
      participant.counter]]$trial.info$trial.index)){
      eyEdu.data$participants[[participant.counter]]$trial.info$qc.samples[
        eyEdu.data$participants[[
        participant.counter]]$trial.info$trial.index == trial.counter] = mean(
          is.na( eyEdu.data$participants[[
            participant.counter]]$sample.data$rawx[eyEdu.data$participants[[
            participant.counter]]$sample.data$trial.index == trial.counter]))  

        } # End trial loop
  } # End participant loop
  save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  print("Done!")
}