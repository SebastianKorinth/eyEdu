EyEduPlotDiagnostics <- function(participant.nr = NA, 
                                 participant.name = NA, 
                                 trial.nr, 
                                 sample.length = 2000,
                                 show.filtered = FALSE,
                                 show.y.direction = FALSE){


# not sure whether the if statement below is doing, what it is intended to do
# checks if eyEdu.data is loaded already, if not will be loaded
  if(!exists("eyEdu.data")) {
    load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = "")) 
 }

  # Two options: either participant name or participant number can be provided 
  if (is.na(participant.name)) {
    # use participant number
    list.entry.nr <- which(eyEdu.data$participant.table$part.nr 
                           == participant.nr)
    
  }else {
    # use participant name; participant number will be ignored
    list.entry.nr <- which(eyEdu.data$participant.table$part.name 
                           == participant.name)
  }
  
# Exception handler, if fixation detection was not conducted yet    
  if (is.null(eyEdu.data$participants[[list.entry.nr]]$fixation.data)) {
    return(paste("No fixations to display!",
           "Please run fixation detection first: EyEduDetectFixationsIDT()!"))
      }  

  if (show.filtered == TRUE) { 
    
    if(is.null(eyEdu.data$participants[[list.entry.nr]]$sample.data$x.filt)){
      return("No filtered data available. Please run EyEduLowPassFilter() or EyEduSmooth() or
             set show.filtered = FALSE")
    } 
    
    
  
# Extracts sample data for participant.nr and trial.nr
plot.sample.posx <- eyEdu.data$participants[[
  list.entry.nr]]$sample.data$x.filt[eyEdu.data$participants[[
    list.entry.nr]]$sample.data$trial.index == trial.nr]

plot.sample.posy <- eyEdu.data$participants[[
  list.entry.nr]]$sample.data$y.filt[eyEdu.data$participants[[
    list.entry.nr]]$sample.data$trial.index == trial.nr]

  }else {
    # Extracts sample data for participant.nr and trial.nr
    plot.sample.posx <- eyEdu.data$participants[[
      list.entry.nr]]$sample.data$rawx[eyEdu.data$participants[[
        list.entry.nr]]$sample.data$trial.index == trial.nr]
    
    plot.sample.posy <- eyEdu.data$participants[[
      list.entry.nr]]$sample.data$rawy[eyEdu.data$participants[[
        list.entry.nr]]$sample.data$trial.index == trial.nr]
    
}

# Extracts time line data for participant.nr and trial.nr
plot.sample.time <- eyEdu.data$participants[[
  list.entry.nr]]$sample.data$time[eyEdu.data$participants[[
    list.entry.nr]]$sample.data$trial.index == trial.nr]

# Zero aligning time scale
set.zero.var <- plot.sample.time[1]
plot.sample.time <- plot.sample.time - set.zero.var

# ggplot2 works only with data frames 
plot.sample.df <- data.frame(plot.sample.time, plot.sample.posx, plot.sample.posy)

# Defines the row index, which corresponds to the highest time point below 
# the sample length
end.point.sample <- as.numeric(max((which(
  plot.sample.df$plot.sample.time < sample.length))))

# Extractes fixation data for participant.nr and trial.nr
plot.fixation.posx <- eyEdu.data$participants[[
  list.entry.nr]]$fixation.data$fix.pos.x[eyEdu.data$participants[[
    list.entry.nr]]$fixation.data$trial.index == trial.nr]

plot.fixation.posy <- eyEdu.data$participants[[
  list.entry.nr]]$fixation.data$fix.pos.y[eyEdu.data$participants[[
    list.entry.nr]]$fixation.data$trial.index == trial.nr]

plot.fixation.start.time <- eyEdu.data$participants[[
  list.entry.nr]]$fixation.data$fix.start[eyEdu.data$participants[[
    list.entry.nr]]$fixation.data$trial.index == trial.nr] - set.zero.var

plot.fixation.stop.time <- eyEdu.data$participants[[
  list.entry.nr]]$fixation.data$fix.end[eyEdu.data$participants[[
    list.entry.nr]]$fixation.data$trial.index == trial.nr] - set.zero.var  

# ggplot2 works just with data frames   
plot.fixation.df <- data.frame(plot.fixation.start.time, 
                               plot.fixation.stop.time, 
                               plot.fixation.posx,
                               plot.fixation.posy)

# Defines the row index, which corresponds to the highest time point below 
# the sample.length
end.point.fixation <- as.numeric(max(which(
  plot.fixation.df$plot.fixation.stop.time < sample.length)))


# The plots 
if(show.y.direction == FALSE){

diagnostic.plot <- suppressWarnings(ggplot() +
geom_path(data= plot.sample.df[1:end.point.sample,],mapping = aes(
  x=plot.sample.df$plot.sample.time[1:end.point.sample], 
  y=plot.sample.df$plot.sample.posx[1:end.point.sample]),na.rm=TRUE) +
  
geom_rect(data=plot.fixation.df[1:end.point.fixation,], mapping=aes(
  xmin=plot.fixation.df$plot.fixation.start.time[1:end.point.fixation], 
  xmax=plot.fixation.df$plot.fixation.stop.time[1:end.point.fixation], 
  ymin=0, ymax=max(plot.sample.df$plot.sample.posx[1:end.point.sample],
                   na.rm = TRUE) +20), 
  color='cornflowerblue', alpha=0.2) +
  
labs(title = paste("participant #", 
                   eyEdu.data$participants[[
                     list.entry.nr]]$header.info$participant.nr, " / ",
                   eyEdu.data$participants[[
                     list.entry.nr]]$header.info$participant.name, 
                     "/ trial:", trial.nr), x="time in ms",
                     y="x direction pixels") +
theme(plot.title = element_text(hjust = 0.5)))


}else{
  
  # quick fix, I know that it is ugly
  max.y = max(max(plot.sample.df$plot.sample.posy[1:end.point.sample], na.rm = T),
  (max(plot.sample.df$plot.sample.posx[1:end.point.sample], na.rm = T)))
  
  diagnostic.plot <- suppressWarnings(ggplot() +
                                        geom_path(data= plot.sample.df[1:end.point.sample,],mapping = aes(
                                          x=plot.sample.df$plot.sample.time[1:end.point.sample], 
                                          y=plot.sample.df$plot.sample.posx[1:end.point.sample]),na.rm=TRUE) +
                                        geom_path(data= plot.sample.df[1:end.point.sample,],mapping = aes(
                                          x=plot.sample.df$plot.sample.time[1:end.point.sample], 
                                          y=plot.sample.df$plot.sample.posy[1:end.point.sample]),na.rm=TRUE, color = "red") +                                       
                                        geom_rect(data=plot.fixation.df[1:end.point.fixation,], mapping=aes(
                                          xmin=plot.fixation.df$plot.fixation.start.time[1:end.point.fixation], 
                                          xmax=plot.fixation.df$plot.fixation.stop.time[1:end.point.fixation], 
                                          ymin=0, ymax=max.y +20), 
                                          color='cornflowerblue', alpha=0.2) +
                                        
                                        labs(title = paste("participant #", 
                                                           eyEdu.data$participants[[
                                                             list.entry.nr]]$header.info$participant.nr, " / ",
                                                           eyEdu.data$participants[[
                                                             list.entry.nr]]$header.info$participant.name, 
                                                           "/ trial:", trial.nr), x="time in ms",
                                             y="x and y direction pixels") +
                                        theme(plot.title = element_text(hjust = 0.5)))
  
  
}

return(diagnostic.plot)

}
