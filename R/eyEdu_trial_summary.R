EyEduTrialSummary  <- function(){
  
  load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

  # Prepares empty data frame
  trial.summary <- data.frame(matrix(NA, nrow = 0, ncol = 1+ length(
    colnames(eyEdu.data$participants[[1]]$trial.info))) )
  colnames(trial.summary) <- c(colnames(eyEdu.data$participants[[1]]$trial.info),
                               "participant.name")

  # Participant loop 
  for (participant.counter in 1:length(eyEdu.data$participants)) {
  
    temp.df <- eyEdu.data$participants[[participant.counter]]$trial.info
    temp.df$participant.name <-   eyEdu.data$participants[[
      participant.counter]]$header.info$participant.name
    trial.summary <- rbind(trial.summary,temp.df)
    }
  save(trial.summary, file = paste(raw.data.path, "trial_summary.Rda",
                                      sep = ""))
  
}
  