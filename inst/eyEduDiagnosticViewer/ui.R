

shinyUI(fluidPage(
  # title    
  headerPanel("eyEduDiagnosticViewer"),  
  # side bar  
  sidebarPanel(
      
      selectInput("participant.name", "Participant name:", 
                  choices = names(eyEdu.data$participants)), 
      
      numericInput("sample.length", "Sample length", 2000, 
                   min = 100, max = 10000, step = 50),
      
    # interactive input to adjust maximal number of available trials
      
    uiOutput("interaction_numericInput"),
    
    checkboxInput("checkbox.y", "show y axis", value = TRUE),  
    checkboxInput("checkbox.raw", "show raw data", value = TRUE),
    checkboxInput("checkbox.filt", "show filtered data", value = FALSE),
    
    width = 4


    
    
  ),
  
  # main panel    
  mainPanel(
  

      plotOutput("plot.image",
               width = 800 * scale.var,
               height = 600 * scale.var))
)
)
