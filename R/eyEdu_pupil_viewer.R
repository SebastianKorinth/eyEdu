EyEduPupilViewer  <- function(scale.var = 0.55) {
  assign("scale.var", scale.var, envir = .GlobalEnv)
  appDir <- system.file("eyEduPupilViewer", package = "eyEdu")
  
  if (appDir == "") {
    stop("Could not find the eyEdu directory. Try re-installing eyEdu.", 
         call. = FALSE)
  }
  
  shiny::runApp(appDir, display.mode = "normal", launch.browser = TRUE)
}
