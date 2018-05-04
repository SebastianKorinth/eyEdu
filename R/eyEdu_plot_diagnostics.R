EyEduPlotDiagnostics <- function(participant.nr, 
                                trial.nr, 
                                sample.length = 2000){

load(file = "eyEdu_data.Rda")  

# Extracts sample data for participant.nr and trial.nr
plot.sample.posx <- eyEdu.data$participants[[
  participant.nr]]$sample.data$rawx[eyEdu.data$participants[[
    participant.nr]]$sample.data$trial.index == trial.nr]

# Extracts time line data for participant.nr and trial.nr
plot.sample.time <- eyEdu.data$participants[[
  participant.nr]]$sample.data$time[eyEdu.data$participants[[
    participant.nr]]$sample.data$trial.index == trial.nr]

# Zero aligning time scale
set.zero.var <- plot.sample.time[1]
plot.sample.time <- plot.sample.time - set.zero.var

# ggplot2 works only with data frames 
plot.sample.df <- data.frame(plot.sample.time, plot.sample.posx)

# Defines the row index, which corresponds to the highest time point below 
# the sample length
end.point.sample <- as.numeric(max((which(
  plot.sample.df$plot.sample.time < sample.length))))

# Extractes fixation data for participant.nr and trial.nr
plot.fixation.posx <- eyEdu.data$participants[[
  participant.nr]]$fixation.data$fix.pos.x[eyEdu.data$participants[[
    participant.nr]]$fixation.data$trial.index == trial.nr]

plot.fixation.start.time <- eyEdu.data$participants[[
  participant.nr]]$fixation.data$fix.start[eyEdu.data$participants[[
    participant.nr]]$fixation.data$trial.index == trial.nr] - set.zero.var

plot.fixation.stop.time <- eyEdu.data$participants[[
  participant.nr]]$fixation.data$fix.end[eyEdu.data$participants[[
    participant.nr]]$fixation.data$trial.index == trial.nr] - set.zero.var  

# ggplot2 works just with data frames   
plot.fixation.df <- data.frame(plot.fixation.start.time, 
                               plot.fixation.stop.time, 
                               plot.fixation.posx)

# Defines the row index, which corresponds to the highest time point below 
# the sample.length
end.point.fixation <- as.numeric(max(which(
  plot.fixation.df$plot.fixation.stop.time < sample.length)))


# The plot itself
diagnostic.plot <- ggplot() +
geom_path(data= plot.sample.df[1:end.point.sample,],mapping = aes(
  x=plot.sample.df$plot.sample.time[1:end.point.sample], 
  y=plot.sample.df$plot.sample.posx[1:end.point.sample])) +
  
geom_rect(data=plot.fixation.df[1:end.point.fixation,], mapping=aes(
  xmin=plot.fixation.df$plot.fixation.start.time[1:end.point.fixation], 
  xmax=plot.fixation.df$plot.fixation.stop.time[1:end.point.fixation], 
  ymin=0, ymax=max(plot.sample.df$plot.sample.posx[1:end.point.sample],
                   na.rm = TRUE) +20), 
  color='grey', alpha=0.2) +
  
labs(title = paste("diagnostic plot:", 
                   eyEdu.data$participants[[
                     participant.nr]]$header.info$participant.name, 
                     "/ trial:", trial.nr), x="time in ms",
                     y="x direction pixels") +
theme(plot.title = element_text(hjust = 0.5))

return(diagnostic.plot)

}
