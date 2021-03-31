# function to call the shiny app for free hand aoi definition

EyEduDiagnosticViewer  <- function() {
  appDir <- system.file("eyEduDiagnosticViewer",
                        package = "eyEdu")
  if (appDir == "") {
    stop("Could not find the eyEdu directory. Try re-installing eyEdu.",
         call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal", launch.browser = TRUE)
}
