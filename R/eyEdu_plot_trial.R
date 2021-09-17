EyEduPlotTrial <- function(participant.nr = NA, 
                          trial.nr = NA,
                          participant.name = NA,
                          aoi.color = "black",
                          fix.color = "red",
                          sample.color.r = NA,
                          sample.color.l = NA,
                          sample.color = "darkviolet",
                          show.filtered = FALSE,
                          sparse.aoi.definition = TRUE,
                          poi.name = NA,
                          aoi.names.screenshot = TRUE,
                          fix.size.scale = 4){

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

# Stimulus.id belonging to trial.nr
stimulus.id <- as.numeric(eyEdu.data$participants[[
    list.entry.nr]]$trial.info$stimulus.id[trial.nr])  
  
  
############# samples #################
# Extracts relevant samples
trial.samples <- subset(eyEdu.data$participants[[list.entry.nr]]$sample.data,
                          eyEdu.data$participants[[
                            list.entry.nr]]$sample.data$trial.index 
                        == trial.nr)

if(nrow(trial.samples) < 1){
  trial.samples[1:3,] <- 0
  trial.samples$poi <- poi.name
}

if(!is.na(poi.name)){
  trial.samples <- subset(trial.samples, poi == poi.name)
 }

############# fixations #################
# Extractes relevant fixations if fixation detection was conducted; if not,
# a dummy data frame will be created

if (is.null(eyEdu.data$participants[[list.entry.nr]]$fixation.data)) {
  trial.fixations <- data.frame(fix.start = 0,
                                fix.end = 0,
                                fix.dur = 0,
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

if(!is.na(poi.name)){
  trial.fixations <- subset(trial.fixations, poi == poi.name)
}


########## aoi sets ############
if(aoi.names.screenshot == F) {
  
  # Generates name for relevant aoi file taken from stimulus message instead of screenshot
  aoi.stimulus.message <- eyEdu.data$participants[[list.entry.nr]]$trial.info$stimulus.message[
    eyEdu.data$participants[[list.entry.nr]]$trial.info$trial.index == trial.nr]
  aoi.stimulus.message <- paste(aoi.stimulus.message,".png", sep ="")
  
  # Extracts relevant aoi.info
  trial.aoi <- eyEdu.data$aoi.info[[aoi.stimulus.message]]
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

if (aoi.names.screenshot == T & sparse.aoi.definition == T) {
  # Index of aoi.info corresponding to stimulus id, since any given stimulus.id
  # most likely appears several times (e.g., different combinations of trial and
  # participant) only the first match of all possible matches will be used.
  
  # Generates name for relevant aoi file
  aoi.index <- grep(paste("*_", stimulus.id, ".png", sep = ""),
                    names(eyEdu.data$aoi.info))[1]
  # Extracts relevant aoi.info
  trial.aoi <- eyEdu.data$aoi.info[[aoi.index]]
  if (is.null(trial.aoi)) {
    trial.aoi <- data.frame(
      line.aoi.index = 0,
      x.left = 0,
      x.right = 0,
      y.top = 0,
      y.bottom = 0,
      line.number = 0,
      image.name = NA,
      aoi.index = 0)
  }
}
#}

if (aoi.names.screenshot == T & sparse.aoi.definition == F) {
  
    # Grabs aoi file name directly
    aoi.index <- eyEdu.data$participants[[list.entry.nr]]$trial.info$background.image[trial.nr]
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
#}

##### background image #####
if (sparse.aoi.definition == TRUE){
  image.list <- list.files(paste(raw.data.path, "images/", sep = ""))
  stim.id.file.names <- gsub(".*_", "", image.list)
  image.index <- eyEdu.data$participants[[
    list.entry.nr]]$trial.info$background.image[trial.nr]
  stim.id.concat <- gsub(".*_", "", image.index)
  image.index <- image.list[which(stim.id.file.names == stim.id.concat)[1]]
  background.image.file <- paste(raw.data.path, "images/",image.index, sep = "")
} 

if (sparse.aoi.definition == FALSE){ 

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


######## plots #########
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
 geom_rect(trial.aoi, mapping = aes(xmin = x.left, 
                                    xmax = x.right, 
                                    ymin = y.bottom, 
                                    ymax = y.top, 
                                    fill = F), color = aoi.color, alpha = 0) +
 geom_path(data = trial.samples, aes(Lrawx,Lrawy), 
        colour = sample.color.l, alpha = 1, na.rm=TRUE) +
 geom_path(data = trial.samples, aes(Rrawx,Rrawy), 
           colour = sample.color.r, alpha = 1, na.rm=TRUE) + 
 geom_path(data = trial.samples, aes(rawx,rawy), 
           colour = sample.color, alpha = 1, na.rm=TRUE) + 
 geom_point(data = trial.fixations, aes(fix.pos.x,
                                        fix.pos.y, 
                                        size = fix.dur), 
            colour = fix.color, alpha = 0.5, na.rm=TRUE) + 
 scale_size_continuous(range = c(1, fix.size.scale)) +
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
 geom_rect(trial.aoi, mapping = aes(xmin = x.left, 
                                    xmax = x.right, 
                                    ymin = y.bottom, 
                                    ymax = y.top, fill = F), 
           color = aoi.color, alpha = 0) +
 geom_path(data = trial.samples, aes(L.x.filt,L.y.filt), 
            colour = sample.color.l, alpha = 1, na.rm=TRUE) + 
 geom_path(data = trial.samples, aes(R.x.filt,R.y.filt), 
            colour = sample.color.r, alpha = 1, na.rm=TRUE) + 
 geom_path(data = trial.samples, aes(x.filt,y.filt), 
           colour = sample.color, alpha = 1, na.rm=TRUE) + 
 geom_point(data = trial.fixations, aes(fix.pos.x,
                                        fix.pos.y, 
                                        size = fix.dur), 
            colour = fix.color, alpha = 0.5, na.rm=TRUE) + 
 scale_size_continuous(range = c(1, fix.size.scale)) +
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
