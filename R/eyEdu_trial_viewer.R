EyEduTrialViewer  <- function(aoi.names.screenshot = TRUE,
                              aoi.color = "red",
                              scale.var = 0.55,
                              fix.size.scale = 10) {
  
  assign("aoi.names.screenshot", aoi.names.screenshot, envir = .GlobalEnv)
  assign("aoi.color", aoi.color, envir = .GlobalEnv)
  assign("scale.var", scale.var, envir = .GlobalEnv)
  assign("fix.size.scale = 10", scale.var, envir = .GlobalEnv)
  
  appDir <- system.file("eyEduTrialViewer", package = "eyEdu")
  
  if (appDir == "") {
    stop("Could not find the eyEdu directory. Try re-installing eyEdu.", 
         call. = FALSE)
  }
  
  shiny::runApp(appDir, display.mode = "normal", launch.browser = TRUE)
}
