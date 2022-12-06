
server <- function(input, output, session) {
  
  # whole trial plot
  trial.samples.fn <-
    reactive({
      req(input$trial.number)
      req(input$poi.var)
      
      
        if(input$poi.var != "trial"){
          
          
          ##############################

          # raw pupil data
          plot.pupil.raw <- eyEdu.data$participants[[
            input$participant.name]]$sample.data$pupil.raw[eyEdu.data$participants[[
              input$participant.name]]$sample.data$trial.index == input$trial.number & eyEdu.data$participants[[input$participant.name]]$sample.data$poi == input$poi.var]
          # interpolated pupil data
          plot.pupil.intpol <- eyEdu.data$participants[[
            input$participant.name]]$sample.data$pupil.interpolated[eyEdu.data$participants[[
              input$participant.name]]$sample.data$trial.index == input$trial.number & eyEdu.data$participants[[input$participant.name]]$sample.data$poi == input$poi.var]
          # filtered pupil data # pupil.filt
          plot.pupil.filt <- eyEdu.data$participants[[
            input$participant.name]]$sample.data$pupil.filt[eyEdu.data$participants[[
              input$participant.name]]$sample.data$trial.index == input$trial.number & eyEdu.data$participants[[input$participant.name]]$sample.data$poi == input$poi.var]
          
          # if no filtered data available
          if (is.null(plot.pupil.filt)){
            plot.pupil.filt <- 0
          }
          
          # Extracts time line data for participant.nr and trial.nr
          plot.pupil.time <- eyEdu.data$participants[[
            input$participant.name]]$sample.data$poi.time[eyEdu.data$participants[[
              input$participant.name]]$sample.data$trial.index ==  input$trial.number & eyEdu.data$participants[[input$participant.name]]$sample.data$poi == input$poi.var]
          
          # ggplot2 works only with data frames
          plot.pupil.df <- data.frame(plot.pupil.time,
                                      plot.pupil.raw,
                                      plot.pupil.intpol,
                                      plot.pupil.filt)
          
          # subsetting to chosen time scale
          end.point.sample <- as.numeric(suppressWarnings(max((which(
            plot.pupil.df$plot.pupil.time < input$max.time)))))
          
          start.point.sample <- as.numeric(suppressWarnings(which.min(abs(input$min.time -
                                                                            plot.pupil.df$plot.pupil.time ))))
          plot.pupil.df <- plot.pupil.df[start.point.sample:end.point.sample, ]
          
          #########################
         
        }else{
          
          ##############################
          
          
          # raw pupil data
          plot.pupil.raw <- eyEdu.data$participants[[
            input$participant.name]]$sample.data$pupil.raw[eyEdu.data$participants[[
              input$participant.name]]$sample.data$trial.index == input$trial.number]
          # interpolated pupil data
          plot.pupil.intpol <- eyEdu.data$participants[[
            input$participant.name]]$sample.data$pupil.interpolated[eyEdu.data$participants[[
              input$participant.name]]$sample.data$trial.index == input$trial.number]
          # filtered pupil data
          plot.pupil.filt <- eyEdu.data$participants[[
            input$participant.name]]$sample.data$pupil.filt[eyEdu.data$participants[[
              input$participant.name]]$sample.data$trial.index == input$trial.number]
          
          # if no filtered data available
          if (is.null(plot.pupil.filt)){
            plot.pupil.filt <- 0
          }
          
          # Extracts time line data for participant.nr and trial.nr
          plot.pupil.time <- eyEdu.data$participants[[
            input$participant.name]]$sample.data$trial.time[eyEdu.data$participants[[
              input$participant.name]]$sample.data$trial.index ==  input$trial.number]
          
          # ggplot2 works only with data frames
          plot.pupil.df <- data.frame(plot.pupil.time,
                                      plot.pupil.raw,
                                      plot.pupil.intpol,
                                      plot.pupil.filt)
          

          # subsetting to chosen time scale
          end.point.sample <- as.numeric(suppressWarnings(max((which(
            plot.pupil.df$plot.pupil.time < input$max.time)))))
          
          start.point.sample <- as.numeric(suppressWarnings(which.min(abs(input$min.time -
            plot.pupil.df$plot.pupil.time ))))
          plot.pupil.df <- plot.pupil.df[start.point.sample:end.point.sample, ]
          
          
          # to avoid error message, when no filtered data are available
          if (show.intpol.fn() == 0) {
            plot.pupil.df$plot.intpol <- -1
          }
          
          #########################
          
          
          
        }
      
     
      return(plot.pupil.df)
    })


  ##########
  
  output$interaction_numericInput <- renderUI({
    numericInput("trial.number", "Trial index:",
                 1,
                 min = 1,
                 max = suppressWarnings(max(eyEdu.data$participants[[
                   input$participant.name]]$sample.data$trial.index)),
                 step = 1 ) # step doesn't always work for some strange reason (steps of 2)
  })



  #######################

  show.raw.fn <- reactive({if(input$checkbox.raw == TRUE){raw.val <- 1}
    else{raw.val <- 0} })
  show.intpol.fn <- reactive({if(input$checkbox.intpol == TRUE){intpol.val <- 1}
    else{intpol.val <- 0} })
  show.filt.fn <- reactive({if(input$checkbox.filt == TRUE){filt.val <- 1}
    else{filt.val <- 0} })
  set.ymin.fn <- reactive({ req(input$min.y)})
  set.ymax.fn <- reactive({ req(input$max.y)})



###############################################################################
  # renders plot
  output$plot.image <- renderPlot({

    ggplot() +
      # plot raw pupil data
      geom_path(
        aes(
          x = trial.samples.fn()$plot.pupil.time,
          y = trial.samples.fn()$plot.pupil.raw
        ),
        na.rm = TRUE,
        color = "black",
        alpha = show.raw.fn()
      ) +
      # plot interpolated pupil data
      geom_path(
        aes(
          x = trial.samples.fn()$plot.pupil.time,
          y = trial.samples.fn()$plot.pupil.intpol
        ),
        na.rm = TRUE,
        color = "red",
        alpha = show.intpol.fn()
      ) +
      # plot filtered pupil data
      geom_path(
        aes(
          x = trial.samples.fn()$plot.pupil.time,
          y = trial.samples.fn()$plot.pupil.filt
        ),
        na.rm = TRUE,
        color = "blue",
        alpha = show.filt.fn()
      ) +
      labs(x = "time in ms", y = "pupil size") +
      ylim(set.ymin.fn(), set.ymax.fn()) +
      theme_gray() +
      theme(text = element_text(size = 20))
      })

  ###############################################################################
  # ends the session upon botton press
  observeEvent(input$ending, {
    session$close()
  })
  
  # ends the session (in RStudio) if the browser tab is closed
  # removes variables from global environment
  session$onSessionEnded(function() {
    objs <- ls(pos = ".GlobalEnv")
    rm(list = objs[grep("eyEdu.data", objs)], pos = ".GlobalEnv")
    rm(list = objs[grep("scale.var", objs)], pos = ".GlobalEnv")
    stopApp()
  })
}
