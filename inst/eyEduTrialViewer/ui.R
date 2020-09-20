

shinyUI(fluidPage(
  # title    
  headerPanel("eyEduViewer"),  

  # side bar  
  sidebarPanel(
   
      selectInput("participant.name", "Participant name:", 
                  choices = names(eyEdu.data$participants)), 
      
    # interactive input to adjust maximal number of available trials
      
      uiOutput("interaction_numericInput"),
      

    checkboxInput("checkbox.raw", "raw", value = TRUE),
    checkboxInput("checkbox.filt", "filtered", value = FALSE),
    checkboxInput("checkbox.fix", "fixations", value = TRUE),    
    checkboxInput("checkbox.raw.r", "raw right", value = FALSE),
    checkboxInput("checkbox.raw.l", "raw left", value = FALSE),
    checkboxInput("checkbox.aoi", "aoi", value = TRUE),
    actionButton("ending","Done"),
    width = 3

  ),
  
  # main panel    
  mainPanel(
    textOutput("text_out"),
    plotOutput("plot.image",
               width = page.width * scale.var,
               height = page.height * scale.var))
)
)
