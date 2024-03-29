
server <- function(input, output, session) {
  

# background image  
  trial.image.fn <- reactive({
    
    req(input$trial.number)
    
    if (sparse.aoi.definition == TRUE){
    image.list <- list.files(paste(raw.data.path, "images/", sep = ""))
    
    if(image.list[1] == "placeholder.png"){
      background.image.file = paste(raw.data.path,"images/placeholder.png", sep = "")
    } else {



    stim.id.file.names <- gsub(".*_", "", image.list)
    image.index <- eyEdu.data$participants[[
      input$participant.name]]$trial.info$background.image[input$trial.number]
    stim.id.concat <- gsub(".*_", "", image.index)
    image.index <- image.list[which(stim.id.file.names == stim.id.concat)[1]]
    background.image.file <- paste(raw.data.path, "images/",image.index, sep = "")}

    
    }else{
    image.list <- list.files(paste(raw.data.path, "images/", sep = ""))
    if(image.list[1] == "placeholder.png"){
      background.image.file = paste(raw.data.path,"images/placeholder.png", sep = "")
    } else {


    image.index <- eyEdu.data$participants[[
      input$participant.name]]$trial.info$background.image[input$trial.number]
    background.image.file  <- paste(raw.data.path, "images/",image.index, sep = "")}
    }
    
    
    return(background.image.file)
    
    
  })
  
  # subset sample data for participant and trial (and poi)
  trial.samples.fn <-
    reactive({
      trial.samples <- subset(eyEdu.data$participants[[input$participant.name]]$sample.data,
             trial.index == input$trial.number)
      if(nrow(trial.samples) < 1){
        trial.samples[1:3,] <- 0
        trial.samples$poi <- input$poi.name
      }
      
      if(input$poi.name != "trial"){
        trial.samples <- subset(trial.samples, poi == input$poi.name)
      }
      
      return(trial.samples)
    })
  

  ### subset fixations by participant and trial index (and poi))
  trial.fixaxtions.fn <- reactive({
    if (is.null(eyEdu.data$participants[[input$participant.name]]$fixation.data)) {
      trial.fixations <- data.frame(
        fix.start = 0,
        fix.end = 0,
        fix.duration = 0,
        fix.pos.x = -100,
        fix.pos.y = -1000,
        fixation.index = 0,
        trial.index = 0,
        stimulus.id = 0
      )
      
    } else {
      trial.fixations <- subset(
        eyEdu.data$participants[[input$participant.name]]$fixation.data,
        eyEdu.data$participants[[
          input$participant.name]]$fixation.data$trial.index == input$trial.number
      )
    }
    
    if(input$poi.name != "trial"){
      trial.fixations <- subset(trial.fixations, poi == input$poi.name)
    }
    return(trial.fixations)
  })
    
  output$interaction_numericInput <- renderUI({
    numericInput("trial.number", "Trial index:",
                 1,
                 min = 1, 
                 max = max(eyEdu.data$participants[[
                   input$participant.name]]$fixation.data$trial.index))
  })
  

  ########## aoi sets ############
  trial.aoi.fn <- reactive({
    
    stimulus.id <- eyEdu.data$participants[[
      input$participant.name]]$trial.info$stimulus.id[input$trial.number] 
    
    
    if(aoi.names.screenshot == FALSE) {
      aoi.stimulus.message <- eyEdu.data$participants[[
        input$participant.name]]$trial.info$stimulus.message[input$trial.number] 
      aoi.stimulus.message <- paste(aoi.stimulus.message,".png", sep ="")
      print(aoi.stimulus.message)
      trial.aoi <- eyEdu.data$aoi.info[[aoi.stimulus.message]]
    } 
    
    if(aoi.names.screenshot == TRUE & sparse.aoi.definition == TRUE) {
      # Generates name for relevant aoi file
      trial.aoi.index <- grep(paste("*_", stimulus.id,".png", sep =""), 
                              names(eyEdu.data$aoi.info))[1]
      # Extracts relevant aoi.info
      trial.aoi <- eyEdu.data$aoi.info[[trial.aoi.index]]}
    
    if(aoi.names.screenshot == TRUE & sparse.aoi.definition == FALSE) {
      # Grabs the name for the relevant aoi file directly
      trial.aoi.index <- eyEdu.data$participants[[
        input$participant.name]]$trial.info$background.image[input$trial.number]
      # Extracts relevant aoi.info
      trial.aoi <- eyEdu.data$aoi.info[[trial.aoi.index]]}
    
    
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
    

    return(trial.aoi)
  
  
  })
  


  
  
  #######################

  show.raw.fn <- reactive({if(input$checkbox.raw == TRUE){raw.val <- 1}
    else{raw.val <- 0} }) 
  show.raw.r.fn <- reactive({if(input$checkbox.raw.r == TRUE){raw.val.r <- 1}
    else{raw.val.r <- 0} }) 
  show.raw.l.fn <- reactive({if(input$checkbox.raw.l == TRUE){raw.val.l <- 1}
    else{raw.l.val <- 0} }) 
  show.filt.fn <- reactive({if(input$checkbox.filt == TRUE){filt.val <- 1}
    else{raw..val <- 0} }) 
  show.fix.fn <- reactive({if(input$checkbox.fix == TRUE){fix.val <- 0.5}
    else{fix.val <- 0} }) 
  show.aoi.fn <- reactive({if(input$checkbox.aoi == TRUE){aoi.val <- aoi.color}
    else{aoi.val <- NA} }) 


###############################################################################    
# renders plot
  output$plot.image <- renderPlot({ 
      ggplot() +
        scale_y_reverse(lim = c(page.height, 0), breaks = NULL) + 
        scale_x_continuous(lim = c(0, page.width), breaks = NULL) + 
        annotation_custom(rasterGrob(readPNG(trial.image.fn()), interpolate = T),
                          xmin = 0,
                          xmax = page.width,
                          ymin = 0,
                          ymax = -1 * page.height) +
        geom_path(aes(trial.samples.fn()$rawx,trial.samples.fn()$rawy), 
                  colour = "blue", alpha = show.raw.fn(), na.rm=TRUE) + 
        geom_path(aes(trial.samples.fn()$x.filt,trial.samples.fn()$y.filt), 
                colour = "red", alpha = show.filt.fn(), na.rm=TRUE) +
        geom_path(aes(trial.samples.fn()$Lrawx,trial.samples.fn()$Lrawy), 
                  colour = "blue", alpha = show.raw.l.fn(), na.rm=TRUE) +
        geom_path(aes(trial.samples.fn()$Rrawx,trial.samples.fn()$Rrawy), 
                  colour = "red", alpha = show.raw.r.fn(), na.rm=TRUE) + 
        geom_point(aes(trial.fixaxtions.fn()$fix.pos.x,
                       trial.fixaxtions.fn()$fix.pos.y,
                       size = trial.fixaxtions.fn()$fix.dur), 
                   colour = "green", alpha = show.fix.fn(), na.rm=TRUE) + 
        scale_size_continuous(range = c(1, fix.size.scale)) +
        geom_rect(aes(xmin = trial.aoi.fn()$x.left,
                      xmax = trial.aoi.fn()$x.right,
                      ymin = trial.aoi.fn()$y.bottom,
                      ymax = trial.aoi.fn()$y.top),
                      fill = NA,
                      color = show.aoi.fn()) +
        coord_fixed(ratio = 1) +
        labs(x = NULL, y = NULL) + 
        theme(legend.position = "none", plot.margin = unit(c(0, 0, 0, 0), "in"))
    })
  ###############################################################################    
  # # ends the app upon botton press
  observeEvent(input$ending, {
    session$close()
  })
  
  # ends the session (in RStudio) if the browser tab is closed
  # removes variables from global env
  session$onSessionEnded(function() {
    objs <- ls(pos = ".GlobalEnv")
    rm(list = objs[grep("eyEdu.data", objs)], pos = ".GlobalEnv")
    rm(list = objs[grep("scale.var", objs)], pos = ".GlobalEnv")
    rm(list = objs[grep("fix.size.scale", objs)], pos = ".GlobalEnv")
    rm(list = objs[grep("aoi.color", objs)], pos = ".GlobalEnv")
    rm(list = objs[grep("initial.background.file", objs)], pos = ".GlobalEnv")
    rm(list = objs[grep("page.width", objs)], pos = ".GlobalEnv")
    rm(list = objs[grep("page.height", objs)], pos = ".GlobalEnv")
    rm(list = objs[grep("aoi.names.screenshot", objs)], pos = ".GlobalEnv")
    rm(list = objs[grep("sparse.aoi.definition", objs)], pos = ".GlobalEnv")
    rm(list = objs[grep("background.x", objs)], pos = ".GlobalEnv")
    rm(list = objs[grep("background.y", objs)], pos = ".GlobalEnv")
    
    stopApp()
  })

}
