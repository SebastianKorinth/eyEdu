EyEduedf2asc <- function(app.path = NA,
                         edf.path = NA,
                         asc.path = NA,
                         add.options = NA) {
  
  if(!dir.exists(asc.path)){
    dir.create(asc.path)
  }
 file.list <- list.files(edf.path,pattern = ".edf", ignore.case = T)
  

    for (file.counter in 1: length(file.list)) {
      conversion.file <- paste(edf.path, file.list[file.counter], sep = "")
      conversion.command <- paste(app.path, 
                                  conversion.file,
                                  add.options,
                                  "-p",
                                  asc.path, 
                                  sep = " ")
      system(conversion.command)
    }
    

} # end function



