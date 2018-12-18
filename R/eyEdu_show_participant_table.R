EyEduShowParticipantTable <- function(){
 
  load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  return(eyEdu.data$participant.table)
}