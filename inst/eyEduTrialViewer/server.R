
server <- function(input, output, session) {
  

# background image  
  trial.image.fn <- reactive({
    
    req(input$trial.number)
    image.list <- list.files(paste(raw.data.path, "images/", sep = ""))
    stim.id.file.names <- gsub(".*_", "", image.list)
    image.index <- eyEdu.data$participants[[
      input$participant.name]]$trial.info$background.image[input$trial.number]
    stim.id.concat <- gsub(".*_", "", image.index)
    image.index <- image.list[which(stim.id.file.names == stim.id.concat)[1]]
    background.image.file <- paste(raw.data.path, "images/",image.index, sep = "")
    
    return(background.image.file)
    
    
  })
  
  # subset participant and trial
  trial.samples.fn <-
    reactive({
      subset(eyEdu.data$participants[[input$participant.name]]$sample.data,
             trial.index == input$trial.number)
    })
  

  ### subset fixations (by participant and trial index)
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
    
  })
    
  output$interaction_numericInput <- renderUI({
    numericInput("trial.number", "Trial index:",
                 1,
                 min = 1, 
                 max = max(eyEdu.data$participants[[
                   input$participant.name]]$sample.data$trial.index))
  })
  

  ########## aoi sets ############
  trial.aoi.fn <- reactive({
  
    stimulus.id <- eyEdu.data$participants[[
      input$participant.name]]$trial.info$stimulus.id[input$trial.number] 
    
    # Generates name for relevant aoi file
    trial.aoi.index <- grep(paste("*_", stimulus.id,".png", sep =""), 
                      names(eyEdu.data$aoi.info))[1]
    # Extracts relevant aoi.info
    trial.aoi <- eyEdu.data$aoi.info[[trial.aoi.index]]
    if(is.null(trial.aoi)){
      trial.aoi <- data.frame(line.aoi.index = 0,
                              x.left = 0,
                              x.right = 0,
                              y.top = 0,
                              y.bottom = 0,
                              line.number = 0,
                              image.name = NA,
                              aoi.index =0)}
    

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
  show.aoi.fn <- reactive({if(input$checkbox.aoi == TRUE){aoi.val <- "black"}
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
                       size = trial.fixaxtions.fn()$fix.duration), 
                   colour = "green", alpha = show.fix.fn(), na.rm=TRUE) + 
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
# ends the app upon botton press  
  observeEvent(input$ending, {

    stopApp()
  }) 

# ends the session (in RStudio) if the browser tab is closed

session$onSessionEnded(function() {

    rm(eyEdu.data)

  })

#session$onSessionEnded(stopApp)

}
