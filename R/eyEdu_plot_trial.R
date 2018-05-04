
EyEduPlotTrial <- function(participant.nr, 
                          trial.nr,
                          aoi.color = "black",
                          fix.color = "red",
                          sample.color.r = NA,
                          sample.color.l = NA,
                          sample.color = "darkviolet",
                          sample.type = "raw")
{
load(file = "eyEdu_data.Rda") 
  
# Extracts relevant samples
trial.samples <- subset(eyEdu.data$participants[[participant.nr]]$sample.data, 
                          eyEdu.data$participants[[
                            participant.nr]]$sample.data$trial.index == trial.nr) 
# Extractes relevant fixations
trial.fixations <- subset(eyEdu.data$participants[[participant.nr]]$fixation.data,
                            eyEdu.data$participants[[
                              participant.nr]]$fixation.data$trial.index == trial.nr)
  
# Stimulus.id belonging to trial.nr
stimulus.id <- as.numeric(eyEdu.data$participants[[
participant.nr]]$trial.info$stimulus.id[trial.nr])
  
# Index of aoi.info corresponding to stimulus id
aoi.index <- grep(paste("*_", stimulus.id, sep =""),names(eyEdu.data$aoi.info))[1]
  
# Extracts relevant aoi.info
trial.aoi <- eyEdu.data$aoi.info[[aoi.index]]
  
# Stimulus.id corresponding to background file
image.list <- list.files(paste(raw.data.path, "images/", sep = ""))
image.index <- grep(paste("*_", stimulus.id, sep =""),names(eyEdu.data$aoi.info))[1]
background.image.file  <- paste(raw.data.path, "images/",image.list[image.index], sep = "")
  
  
# Loads background image
background <- readPNG(background.image.file)
page.width <- dim(background)[2]
page.height <- dim(background)[1]
background <- rasterGrob(background, interpolate = T)

# Optional: show avg-sample points, raw is default  
if(page.height != eyEdu.data$participant[[participant.nr]]$header.info$display.y[1]) {
  print("Screen dimensions of from experiment info and screenshots do not match.
        Screenshot dims will be used")
}
  
if(sample.type == "raw") {
  
# The plot itself "raw"
trial.plot <- ggplot(trial.samples) + 
 scale_y_reverse(lim = c(page.height, 0), breaks = NULL) + 
 scale_x_continuous(lim = c(0, page.width), breaks = NULL) + 
 annotation_custom(background, xmin = 0, xmax = page.width, ymin = 0, ymax = -1 * page.height) + 
 geom_rect(trial.aoi, mapping = aes(xmin = trial.aoi$x.left, xmax = trial.aoi$x.right, 
                                    ymin = trial.aoi$y.bottom, ymax = trial.aoi$y.top, 
                                    fill = F), color = aoi.color, alpha = 0) +
 geom_path(data = trial.samples, aes(trial.samples$Lrawx,trial.samples$Lrawy), 
        colour = sample.color.l, alpha = 1) +
 geom_path(data = trial.samples, aes(trial.samples$Rrawx,trial.samples$Rrawy), 
           colour = sample.color.r, alpha = 1) + 
 geom_path(data = trial.samples, aes(trial.samples$rawx,trial.samples$rawy), 
           colour = sample.color, alpha = 1) + 
 # geom_path(data = trialFixationData, aes(trialFixationData$x, trialFixationData$y), 
 # colour = SacCol, alpha = 1) + 
 geom_point(data = trial.fixations, aes(trial.fixations$fix.pos.x,trial.fixations$fix.pos.y, 
                                         size = trial.fixations$fix.duration
                                        ), colour = fix.color, alpha = 0.5) + 
 coord_fixed(ratio = 1) +  
 labs(x = NULL, y = NULL) + 
 theme(legend.position = "none", plot.margin = unit(c(0, 0, 0, 0), "in")) +
 ggtitle(paste(eyEdu.data$participants[[participant.nr]]$header.info$participant.name,
               "/ trial:", trial.nr, "/ stimulus:",stimulus.id, sep = " ")) + 
 theme(plot.title = element_text(hjust = 0.5)) 

  } else {
    
# The plot itself avg
trial.plot <- ggplot(trial.samples) + 
 scale_y_reverse(lim = c(page.height, 0), breaks = NULL) + 
 scale_x_continuous(lim = c(0, page.width), breaks = NULL) + 
 annotation_custom(background, xmin = 0, xmax = page.width, ymin = 0, ymax = -1 * page.height) + 
 geom_rect(trial.aoi, mapping = aes(xmin = trial.aoi$x.left, xmax = trial.aoi$x.right, 
                                    ymin = trial.aoi$y.bottom, ymax = trial.aoi$y.top, fill = F
                                    ), color = aoi.color, alpha = 0) +
 geom_path(data = trial.samples, aes(trial.samples$Lavgx,trial.samples$Lavgy), 
           colour = sample.color.l, alpha = 1) + 
 geom_path(data = trial.samples, aes(trial.samples$Ravgx,trial.samples$Ravgy), 
           colour = sample.color.r, alpha = 1) + 
 geom_path(data = trial.samples, aes(trial.samples$avgx,trial.samples$avgy), 
           colour = sample.color, alpha = 1) + 
 # geom_path(data = trialFixationData, aes(trialFixationData$x, trialFixationData$y), 
 # colour = SacCol, alpha = 1) + 
 geom_point(data = trial.fixations, aes(trial.fixations$fix.pos.x,trial.fixations$fix.pos.y, 
                                        size = trial.fixations$fix.duration
                                             ), colour = fix.color, alpha = 0.5) + 
 coord_fixed(ratio = 1) +  
 labs(x = NULL, y = NULL) + 
 theme(legend.position = "none", plot.margin = unit(c(0, 0, 0, 0), "in")) +
 ggtitle(paste(eyEdu.data$participants[[participant.nr]]$header.info$participant.name,
               "trial:", trial.nr, "stimulus:",stimulus.id, sep = " / ")) + 
 theme(plot.title = element_text(hjust = 0.5)) 
}
return(trial.plot)
}
