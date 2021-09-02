
EyEduGetSampleSummary  <- function(){

load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

for (participant.counter in 1:length(eyEdu.data$participants)) {
  
  sample.df <- eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
  
  sample.df$participant.name <- eyEdu.data$participants[[
    participant.counter]]$header.info$participant.name

  sample.df$participant.nr <- eyEdu.data$participants[[
    participant.counter]]$header.info$participant.nr
  
  if(participant.counter == 1)
  {
    sample.summary <- sample.df
  }
  
  else{
    sample.summary <- rbind(sample.summary,sample.df)
  }
  # Providing some feedback on processing progress.
  processed.participant <- names(eyEdu.data$participants[participant.counter])
  print(paste("Adding data of:",
              processed.participant, "to sample summary", 
              "- number", participant.counter, 
              "out of", 
              max(length(eyEdu.data$participants)), sep = " ")) 
  
}
save(sample.summary, file = paste(raw.data.path, "sample_summary.Rda",
                                    sep = ""))
}

