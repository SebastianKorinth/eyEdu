
server <- function(input, output, session) {

  # subset samples participant and trial
  trial.samples.fn <-
    reactive({
      req(input$trial.number)
        plot.sample.posx <- eyEdu.data$participants[[
        input$participant.name]]$sample.data$rawx[eyEdu.data$participants[[
          input$participant.name]]$sample.data$trial.index == input$trial.number]

        plot.sample.posy <- eyEdu.data$participants[[
          input$participant.name]]$sample.data$rawy[eyEdu.data$participants[[
            input$participant.name]]$sample.data$trial.index == input$trial.number]

        plot.sample.posx.filt <- eyEdu.data$participants[[
          input$participant.name]]$sample.data$x.filt[eyEdu.data$participants[[
            input$participant.name]]$sample.data$trial.index == input$trial.number]
        
        if (is.null(plot.sample.posx.filt)){
          plot.sample.posx.filt <- 0
        }
        if (is.null(plot.sample.posy.filt)){
          plot.sample.posy.filt <- 0
        }

        plot.sample.posy.filt <- eyEdu.data$participants[[
          input$participant.name]]$sample.data$y.filt[eyEdu.data$participants[[
            input$participant.name]]$sample.data$trial.index == input$trial.number]


      # Extracts time line data for participant.nr and trial.nr
      plot.sample.time <- eyEdu.data$participants[[
        input$participant.name]]$sample.data$time[eyEdu.data$participants[[
          input$participant.name]]$sample.data$trial.index ==  input$trial.number]
      # Zero aligning time scale
      set.zero.var <- plot.sample.time[1]
      plot.sample.time <- plot.sample.time - set.zero.var

      # ggplot2 works only with data frames
      plot.sample.df <- data.frame(plot.sample.time,
                                   plot.sample.posx,
                                   plot.sample.posy,
                                   plot.sample.posx.filt,
                                   plot.sample.posy.filt)

      # Defines the row index, which corresponds to the highest time point below
      # the sample length
      end.point.sample <- as.numeric(suppressWarnings(max((which(
        plot.sample.df$plot.sample.time < input$sample.length)))))
      plot.sample.df <- plot.sample.df[1:end.point.sample, ]

      if (show.y.axis.fn() == 0) {
        plot.sample.df$plot.sample.posy.filt <- -1
        plot.sample.df$plot.sample.posy <- -1

      }

      return(plot.sample.df)
    })


  # subset fixations (by participant and trial index)
  trial.fixaxtions.fn <- reactive({
    # Extractes fixation data for participant.nr and trial.nr
    plot.fixation.posx <- eyEdu.data$participants[[
      input$participant.name]]$fixation.data$fix.pos.x[eyEdu.data$participants[[
        input$participant.name]]$fixation.data$trial.index ==  input$trial.number]

    # Extracts time line data for participant.nr and trial.nr
    plot.sample.time <- eyEdu.data$participants[[
      input$participant.name]]$sample.data$time[eyEdu.data$participants[[
        input$participant.name]]$sample.data$trial.index ==  input$trial.number]
    # Zero aligning time scale
    set.zero.var <- plot.sample.time[1]
    plot.sample.time <- plot.sample.time - set.zero.var

    plot.fixation.start.time <- eyEdu.data$participants[[
      input$participant.name]]$fixation.data$fix.start[eyEdu.data$participants[[
        input$participant.name]]$fixation.data$trial.index == input$trial.number] - set.zero.var

    plot.fixation.stop.time <- eyEdu.data$participants[[
      input$participant.name]]$fixation.data$fix.end[eyEdu.data$participants[[
        input$participant.name]]$fixation.data$trial.index == input$trial.number] - set.zero.var

    # ggplot2 works just with data frames
    plot.fixation.df <- data.frame(plot.fixation.start.time,
                                   plot.fixation.stop.time,
                                   plot.fixation.posx)

    # Defines the row index, which corresponds to the highest time point below
    # the sample.length
    end.point.fixation <- as.numeric(max(which(
      plot.fixation.df$plot.fixation.stop.time < input$sample.length)))

    plot.fixation.df <- plot.fixation.df[1:end.point.fixation,]
    return(plot.fixation.df)


    })

  output$interaction_numericInput <- renderUI({
    numericInput("trial.number", "Trial index:",
                 1,
                 min = 1,
                 max = suppressWarnings(max(eyEdu.data$participants[[
                   input$participant.name]]$sample.data$trial.index)),
                 step = 1 )# step doesn't always work for some strange reason (steps of 2)
  })







  #######################

  show.y.axis.fn <- reactive({if(input$checkbox.y == TRUE){y.axis <- 1}
    else{y.axis <- 0} })
  show.raw.fn <- reactive({if(input$checkbox.raw == TRUE){raw.val <- 1}
    else{raw.val <- 0} })
  show.filt.fn <- reactive({if(input$checkbox.filt == TRUE){filt.val <- 1}
    else{filt.val <- 0} })



###############################################################################
  # renders plot
  output$plot.image <- renderPlot({

    ggplot() +
      # plot x raw
      geom_path(
        aes(
          x = trial.samples.fn()$plot.sample.time,
          y = trial.samples.fn()$plot.sample.posx
        ),
        na.rm = TRUE,
        color = "blue",
        alpha = show.raw.fn()
      ) +
      # plot y raw
      geom_path(
        aes(
          x = trial.samples.fn()$plot.sample.time,
          y = trial.samples.fn()$plot.sample.posy
        ),
        na.rm = TRUE,
        color = "red",
        alpha = show.raw.fn()
      ) +
      # plot x filtered
      geom_path(
        aes(
          x = trial.samples.fn()$plot.sample.time,
          y = trial.samples.fn()$plot.sample.posx.filt
        ),
        na.rm = TRUE,
        color = "blue",
        alpha = show.filt.fn()
      ) +
      # plot y filtered
      geom_path(
        aes(
          x = trial.samples.fn()$plot.sample.time,
          y = trial.samples.fn()$plot.sample.posy.filt
        ),
        na.rm = TRUE,
        color = "red",
        alpha = show.filt.fn()
      ) +
      geom_rect(aes(xmin = trial.fixaxtions.fn()$plot.fixation.start.time,
                    xmax = trial.fixaxtions.fn()$plot.fixation.stop.time,
                    ymin = 0,
                    ymax = max(trial.samples.fn()$plot.sample.posx,
                               trial.samples.fn()$plot.sample.posy,
                               na.rm = TRUE) + 20),
                    color = 'grey', alpha = 0.2) +
      labs(x = "time in ms", y = "pixels") +
      theme_gray()
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
