

shinyUI(fluidPage(
  # title    
  headerPanel("eyEdu PupilViewer"),  
  # side bar  
  sidebarPanel(
      
      h5("Select data", align = "center"),
    
      selectInput("participant.name", "Participant name:", 
                  choices = names(eyEdu.data$participants),
                  selected = names(eyEdu.data$participants)[1],
                  multiple = FALSE), 
      
      # potential problem: takes conditions from first participants only
      selectInput("poi.var", "Period of interest:", 
                  choices = c("trial", names(table(eyEdu.data$participants[[1]]$sample.data$poi))),
                  selected = "trial", 
                  multiple = FALSE), 
      # interactive input to adjust maximal number of available trials
      uiOutput("interaction_numericInput"),
      
      # checkboxes for different data representations
      checkboxInput("checkbox.raw", span("show raw pupil data", style = "color:black"), value = TRUE),  
      checkboxInput("checkbox.intpol", span("show interpolated data", style = "color:red"), value = TRUE),
      checkboxInput("checkbox.filt", span("show filtered data", style = "color:blue"), value = FALSE),
      
      h5("Time scale", align = "center"),
      
      numericInput("min.time", "Time min:", 0, 
                   min = 0, max = 100000, step = 50),
      
      numericInput("max.time", "Time max:", 100000, 
                   min = 100, max = 100000, step = 50),
      
      h5("Scale Y axis", align = "center"),
      
      numericInput("max.y", "y-axis max:", 10000, 
                   min = 100, max = 100000, step = 50),
      
      numericInput("min.y", "y-axis min:", 0, 
                   min = -100000, max = 100000, step = 50),
      


    actionButton("ending","Quit"),

    width = 4
  ),
  
  # main panel    
  mainPanel(
     plotOutput("plot.image",
               width = 800 * scale.var,
               height = 600 * scale.var))
)
)
