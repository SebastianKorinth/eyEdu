
EyEduGetSampleSummary  <- function(interim.save = FALSE,
                                   poi.var = "trial",
                                   baseline.var = 0){

load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

for (participant.counter in 1:length(eyEdu.data$participants)) {
  
  if(interim.save == TRUE & participant.counter > 1){
    load(paste0(raw.data.path, "sample_summary.Rda"))
  }
  
  
  
  sample.df <- eyEdu.data[["participants"]][[participant.counter]][["sample.data"]]
  
  sample.df$participant.name <- eyEdu.data$participants[[
    participant.counter]]$header.info$participant.name

  sample.df$participant.nr <- eyEdu.data$participants[[
    participant.counter]]$header.info$participant.nr
  
  
  ### Guessing sample rate
  sample.length <- round(mean(diff(sample.df$time[1:20])),digits = 0)
  
  
  # Sample summary restricted to poi + baseline
  if(poi.var != "trial"){
    
    # Gets the start indexes of the poi
    start.row.poi <- which(sample.df$poi == poi.var & sample.df$poi.time == 0)
    # Start indexes of baseline
    start.row.base <- start.row.poi - baseline.var
    # Creates one vector from start and end indexes 
    baseline.indexes <- unlist(Map(':',start.row.base, start.row.poi))
    
    base.poi.time <- seq(from = 0, by = sample.length, length.out = (baseline.var + 1))
    base.poi.time <- rev(base.poi.time *-1)
    base.poi.time <- rep(base.poi.time, times = length(start.row.base))
    
    sample.df$poi.time[baseline.indexes] <- base.poi.time
    
    # temporary variable that will be used for subsetting
    sample.df$temp.var <- 0
    # mark all rows belonging to poi
    sample.df$temp.var[which(sample.df$poi == poi.var)] <- 1
    # mark all rows belonging to baseline
    sample.df$temp.var[baseline.indexes] <- 1
    
    
    sample.df <- subset(sample.df, sample.df$temp.var == 1)
    sample.df$temp.var <- NULL
  }

  if(participant.counter == 1)
  {
    sample.summary <- sample.df
  }
  
  else{
    
    
    if (ncol(sample.df) != ncol(sample.summary)) {
      print(paste0("mismatch column number for ", sample.df$participant.name[1]))
      next
    } else {
      sample.summary <- rbind(sample.summary,sample.df)
    }
    
  }
  # Providing some feedback on processing progress.
  processed.participant <- names(eyEdu.data$participants[participant.counter])
  print(paste("Adding data of:",
              processed.participant, "to sample summary", 
              "- number", participant.counter, 
              "out of", 
              max(length(eyEdu.data$participants)), sep = " ")) 
  
  if(interim.save == TRUE){
    save(sample.summary, file = paste(raw.data.path, "sample_summary.Rda", sep = ""))
  }
  
}
  if(interim.save !=TRUE){
save(sample.summary, file = paste(raw.data.path, "sample_summary.Rda",
                                    sep = ""))
  }
}

