
EyEduGetFixationSummary  <- function(){

load("eyEdu_data.Rda")

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
                               participant.id = character(),
                               stringsAsFactors = F)

for (participant.counter in 1:length(eyEdu.data$participants)) {
  
  participant.name <- eyEdu.data$participants[[participant.counter]]$header.info$participant.name
  fixation.data <- eyEdu.data[["participants"]][[participant.counter]][["fixation.data"]]
  fixation.data$participant.id <- participant.name
  fixation.summary <- rbind(fixation.summary,fixation.data)
  
}

save(fixation.summary, file = "fixation_summary.Rda")

}



EyEduGetFixationSummary  <- function(){

load("eyEdu_data.Rda")

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
                               participant.id = character(),
                               stringsAsFactors = F)

for (participant.counter in 1:length(eyEdu.data$participants)) {
  
  participant.name <- eyEdu.data$participants[[participant.counter]]$header.info$participant.name
  fixation.data <- eyEdu.data[["participants"]][[participant.counter]][["fixation.data"]]
  fixation.data$participant.id <- participant.name
  fixation.summary <- rbind(fixation.summary,fixation.data)
  
}

save(fixation.summary, file = "fixation_summary.Rda")

}


