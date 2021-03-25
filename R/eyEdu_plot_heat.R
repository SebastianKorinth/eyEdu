EyEduPlotHeat <- function(participant.name.list = NA,
                          participant.nr.list = NA,
                          trial.id = NA,
                          alpha.var = 0.5){

  
  load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
  # Prepares empty data frame
  fixations <- data.frame(matrix(NA, nrow = 0, ncol = 2+ length(
    colnames(eyEdu.data$participants[[1]]$fixation.data))) )
  colnames(fixations) <- c(colnames(eyEdu.data$participants[[1]]$fixation.data),
                               "participant.name", "participant.number")
  
  # Participant loop 
  for (participant.counter in 1:length(eyEdu.data$participants)) {
    
    temp.df <- eyEdu.data$participants[[participant.counter]]$fixation.data
    temp.df$participant.name <-   eyEdu.data$participants[[
      participant.counter]]$header.info$participant.name
    temp.df$participant.number <- eyEdu.data$participants[[
      participant.counter]]$header.info$participant.nr
    fixations <- rbind(fixations,temp.df)
  }
  
  rm(temp.df)

  

  # Two options: either a list of participant names or participant numbers can be provided 
  if (is.na(participant.name.list[1]) == TRUE) {
    # use participant number
    fixations <- subset(fixations, subset = fixations$participant.number %in% participant.nr.list)
    
  }else {
    # use participant names; participant number will be ignored
    fixations <- subset(fixations, subset = fixations$participant.name %in% participant.name.list)
  }  

  # Stimulus.id corresponding to background file
  image.list <- list.files(paste(raw.data.path, "images/", sep = ""))
  image.index <- paste("_", trial.id, ".png", sep = "")
  image.name <- image.list[which(grepl(image.index, image.list) == TRUE)][1]
  rm(image.index)
  background.image.file <- paste(raw.data.path, "images/",image.name, sep = "")
  # Loads background image
  background <- readPNG(background.image.file)
  page.width <- dim(background)[2]
  page.height <- dim(background)[1]
  background <- rasterGrob(background, interpolate = T)

  fixations <- subset(fixations, fixations$stimulus.id == trial.id)

  heat.plot <- ggplot(data = fixations, aes(fix.pos.x, fix.pos.y)) + 
   annotation_custom(background,
                     xmin = 0,
                     xmax = page.width,
                     ymin = 0,
                     ymax = -1 * page.height) +
   stat_density_2d(aes(fill = ..density..), geom = "raster", contour = FALSE, na.rm = T) +
   scale_fill_viridis_c(alpha = alpha.var, option = "D") +
   scale_y_reverse(lim = c(page.height, 0), breaks = NULL) + 
   scale_x_continuous(lim = c(0, page.width), breaks = NULL) + 
   labs(x = NULL, y = NULL) + 
   coord_fixed(ratio = 1) +  
   theme(legend.position = "none", plot.margin = unit(c(0, 0, 0, 0), "in")) +
   ggtitle(paste ("Heatmap", "Stimulus ID", trial.id, sep = " ")) +
   theme(plot.title = element_text(hjust = 0.5))

 return(heat.plot)
  
}