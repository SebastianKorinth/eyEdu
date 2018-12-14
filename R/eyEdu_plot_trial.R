
EyEduPlotTrial <- function(participant.nr = NA, 
                          trial.nr,
                          participant.name = NA,
                          aoi.color = "black",
                          fix.color = "red",
                          sample.color.r = NA,
                          sample.color.l = NA,
                          sample.color = "darkviolet",
                          show.filtered = FALSE,
                          sparse.aoi.definition = TRUE)
{
load(file = paste(raw.data.path, "eyEdu_data.Rda", sep = "")) 

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

# Extracts relevant samples
trial.samples <- subset(eyEdu.data$participants[[list.entry.nr]]$sample.data,
                          eyEdu.data$participants[[
                            list.entry.nr]]$sample.data$trial.index 
                        == trial.nr)


# Extractes relevant fixations; if fixation detection was conducted, if not,
# a dummy data frame will be created

if (is.null(eyEdu.data$participants[[list.entry.nr]]$fixation.data)) {
  trial.fixations <- data.frame(fix.start = 0,
                                fix.end = 0,
                                fix.duration = 0,
                                fix.pos.x = -100,
                                fix.pos.y = -1000,
                                fixation.index = 0,
                                trial.index = 0,
                                stimulus.id = 0)
                   
} else {
  trial.fixations <- subset(eyEdu.data$participants[[
    list.entry.nr]]$fixation.data, eyEdu.data$participants[[
      list.entry.nr]]$fixation.data$trial.index == trial.nr)
}

# Stimulus.id belonging to trial.nr
stimulus.id <- as.numeric(eyEdu.data$participants[[
list.entry.nr]]$trial.info$stimulus.id[trial.nr])
  
# Index of aoi.info corresponding to stimulus id, since any given stimulus.id
# most likely appears several times (e.g., different combinations of tria and
# participant) only the first match of all possible matches will be used.

if (is.null(eyEdu.data$aoi.info)) {
  trial.aoi <- data.frame(line.aoi.index = 0,
                          x.left = 0,
                          x.right = 0,
                          y.top = 0,
                          y.bottom = 0,
                          line.number = 0,
                          image.name = NA,
                          aoi.index =0)
  } else {
    # Generates name for relevant aoi file
  aoi.index <- grep(paste("*_", stimulus.id,".png", sep =""), 
                    names(eyEdu.data$aoi.info))[1]
  # Extracts relevant aoi.info
  trial.aoi <- eyEdu.data$aoi.info[[aoi.index]]
    if(is.null(trial.aoi)){
    trial.aoi <- data.frame(line.aoi.index = 0,
                            x.left = 0,
                            x.right = 0,
                            y.top = 0,
                            y.bottom = 0,
                            line.number = 0,
                            image.name = NA,
                            aoi.index =0)
  }
}

if (sparse.aoi.definition == TRUE){
  image.list <- list.files(paste(raw.data.path, "images/", sep = ""))
  stim.id.file.names <- gsub(".*_", "", image.list)
  image.index <- eyEdu.data$participants[[
    list.entry.nr]]$trial.info$background.image[trial.nr]
  stim.id.concat <- gsub(".*_", "", image.index)
  image.index <- image.list[which(stim.id.file.names == stim.id.concat)[1]]
  background.image.file <- paste(raw.data.path, "images/",image.index, sep = "")

} else {
# Stimulus.id corresponding to background file
image.list <- list.files(paste(raw.data.path, "images/", sep = ""))
image.index <- eyEdu.data$participants[[
  list.entry.nr]]$trial.info$background.image[trial.nr]
background.image.file  <- paste(raw.data.path, "images/",image.index, sep = "")

}
# Loads background image
background <- readPNG(background.image.file)
page.width <- dim(background)[2]
page.height <- dim(background)[1]
background <- rasterGrob(background, interpolate = T)

# Error warning if experiment dimension (Open Sesame) differs from screenshot
if(page.height != eyEdu.data$participants[[
  list.entry.nr]]$header.info$display.y[1]) {
  print("Screen dimensions from experiment info and screenshots do not 
match. Screenshot dims will be used")
}

# Optional: show filtered data, raw is default  
if(show.filtered == FALSE) {

# The plot itself "raw"
trial.plot <- ggplot(trial.samples) + 
 scale_y_reverse(lim = c(page.height, 0), breaks = NULL) + 
 scale_x_continuous(lim = c(0, page.width), breaks = NULL) + 
 annotation_custom(background, 
                   xmin = 0, 
                   xmax = page.width, 
                   ymin = 0, 
                   ymax = -1 * page.height) + 
 geom_rect(trial.aoi, mapping = aes(xmin = trial.aoi$x.left, 
                                    xmax = trial.aoi$x.right, 
                                    ymin = trial.aoi$y.bottom, 
                                    ymax = trial.aoi$y.top, 
                                    fill = F), color = aoi.color, alpha = 0) +
 geom_path(data = trial.samples, aes(trial.samples$Lrawx,trial.samples$Lrawy), 
        colour = sample.color.l, alpha = 1, na.rm=TRUE) +
 geom_path(data = trial.samples, aes(trial.samples$Rrawx,trial.samples$Rrawy), 
           colour = sample.color.r, alpha = 1, na.rm=TRUE) + 
 geom_path(data = trial.samples, aes(trial.samples$rawx,trial.samples$rawy), 
           colour = sample.color, alpha = 1, na.rm=TRUE) + 
 geom_point(data = trial.fixations, aes(trial.fixations$fix.pos.x,
                                        trial.fixations$fix.pos.y, 
                                        size = trial.fixations$fix.duration), 
            colour = fix.color, alpha = 0.5, na.rm=TRUE) + 
 coord_fixed(ratio = 1) +  
 labs(x = NULL, y = NULL) + 
 theme(legend.position = "none", plot.margin = unit(c(0, 0, 0, 0), "in")) +
 ggtitle(paste("participant #", eyEdu.data$participants[[
   list.entry.nr]]$header.info$participant.nr, 
   " / ", 
   eyEdu.data$participants[[list.entry.nr]]$header.info$participant.name,
   "/ trial:", 
   trial.nr, 
   "/ stimulus:",
   stimulus.id, sep = " ")) + 
 theme(plot.title = element_text(hjust = 0.5)) 

  } else {
    
    if(is.null(trial.samples$x.filt)){
      return("No filtered data available. Please run EyEduLowPassFilter() or set show.filtered = FALSE")
    }
    
    
# plot for filtered data
trial.plot <- ggplot(trial.samples) + 
 scale_y_reverse(lim = c(page.height, 0), breaks = NULL) + 
 scale_x_continuous(lim = c(0, page.width), breaks = NULL) + 
 annotation_custom(background, 
                   xmin = 0, 
                   xmax = page.width, 
                   ymin = 0, 
                   ymax = -1 * page.height) + 
 geom_rect(trial.aoi, mapping = aes(xmin = trial.aoi$x.left, 
                                    xmax = trial.aoi$x.right, 
                                    ymin = trial.aoi$y.bottom, 
                                    ymax = trial.aoi$y.top, fill = F), 
           color = aoi.color, alpha = 0) +
 geom_path(data = trial.samples, aes(trial.samples$L.x.filt,trial.samples$L.y.filt), 
            colour = sample.color.l, alpha = 1, na.rm=TRUE) + 
 geom_path(data = trial.samples, aes(trial.samples$R.x.filt,trial.samples$R.y.filt), 
            colour = sample.color.r, alpha = 1, na.rm=TRUE) + 
 geom_path(data = trial.samples, aes(trial.samples$x.filt,trial.samples$y.filt), 
           colour = sample.color, alpha = 1, na.rm=TRUE) + 
 geom_point(data = trial.fixations, aes(trial.fixations$fix.pos.x,
                                        trial.fixations$fix.pos.y, 
                                        size = trial.fixations$fix.duration), 
            colour = fix.color, alpha = 0.5, na.rm=TRUE) + 
 coord_fixed(ratio = 1) +  
 labs(x = NULL, y = NULL) + 
 theme(legend.position = "none", plot.margin = unit(c(0, 0, 0, 0), "in")) +
 ggtitle(paste("participant #", 
               eyEdu.data$participants[[
                 list.entry.nr]]$header.info$participant.nr,
               " / ", 
               eyEdu.data$participants[[
                 list.entry.nr]]$header.info$participant.name,
               "/ trial:",
               trial.nr, 
               "/ stimulus:",
               stimulus.id )) + 
 theme(plot.title = element_text(hjust = 0.5)) 
}
return(trial.plot)
}
