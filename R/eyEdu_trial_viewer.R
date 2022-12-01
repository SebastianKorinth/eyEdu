EyEduTrialViewer  <- function(aoi.names.screenshot = TRUE,
                              aoi.color = "red",
                              scale.var = 0.55,
                              fix.size.scale = 10,
                              sparse.aoi.definition = TRUE,
                              background.x = 1680,
                              background.y = 1050) {
  
  assign("aoi.names.screenshot", aoi.names.screenshot, envir = .GlobalEnv)
  assign("aoi.color", aoi.color, envir = .GlobalEnv)
  assign("scale.var", scale.var, envir = .GlobalEnv)
  assign("fix.size.scale", fix.size.scale, envir = .GlobalEnv)
  assign("sparse.aoi.definition", sparse.aoi.definition, envir = .GlobalEnv)
  assign("background.x", background.x, envir = .GlobalEnv)
  assign("background.y", background.y, envir = .GlobalEnv)
  
  appDir <- system.file("eyEduTrialViewer", package = "eyEdu")
  
  if (appDir == "") {
    stop("Could not find the eyEdu directory. Try re-installing eyEdu.", 
         call. = FALSE)
  }
  
  shiny::runApp(appDir, display.mode = "normal", launch.browser = TRUE)
}
