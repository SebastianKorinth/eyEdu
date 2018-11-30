# function to call the shiny app for free hand aoi definition

EyEduShinyAoiRectangle  <- function() {
  appDir <- system.file("shiny-examples", 
                        "eyEduShinyAoiRectangle", 
                        package = "eyEdu")
  if (appDir == "") {
    stop("Could not find the eyEdu directory. Try re-installing eyEdu.", 
         call. = FALSE)
  }
  
  shiny::runApp(appDir, display.mode = "normal", launch.browser = T)
}