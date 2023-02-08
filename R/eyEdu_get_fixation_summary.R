
EyEduGetFixationSummary  <- function(){

load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

fixation.summary <- data.frame(fix.start = numeric(),
                               fix.end = numeric(),
                               fix.duration = numeric(),
                               fix.pos.x = numeric(),
                               fix.pos.y = numeric(),
                               fixation.index = numeric(),
                               trial.index = numeric(),
                               stimulus.id = numeric(),
                               aoi.index = numeric(),
                               aoi.line.index = numeric(),
                               participant.name = character(),
                               participant.nr = character(),
                               stringsAsFactors = F)

for (participant.counter in 1:length(eyEdu.data$participants)) {
  
  participant.name <- eyEdu.data$participants[[
    participant.counter]]$header.info$participant.name
  
  if (is.null(eyEdu.data$participants[[participant.counter]]$fixation.data)){
   print(paste("No fixations found for participant: ", participant.name))
    next
    }

    fixation.data <- eyEdu.data[[
    "participants"]][[participant.counter]][["fixation.data"]]
  fixation.data$participant.name <- participant.name
  fixation.data$participant.nr <- eyEdu.data$participants[[
    participant.counter]]$header.info$participant.nr
  fixation.summary <- rbind(fixation.summary,fixation.data)
  
  
  
  # Providing some feedback on processing progress.
  processed.participant <- names(eyEdu.data$participants[participant.counter])
  print(paste("Adding fixation data of:",
              processed.participant, "to fixation summary", 
              "- number", participant.counter, 
              "out of", 
              max(length(eyEdu.data$participants)), sep = " ")) 
  
  
}

print("Finished creating fixation summary. Saving the file might take a while.")
save(fixation.summary, file = paste(raw.data.path, "fixation_summary.Rda",
                                    sep = ""))
}





