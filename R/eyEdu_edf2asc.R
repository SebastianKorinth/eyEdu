EyEduEdf2asc <- function(app.path = NA,
                         edf.path = NA,
                         asc.path = NA,
                         add.options = NA,
                         subFolder = TRUE) {
  
  if(!dir.exists(asc.path)){
    dir.create(asc.path)
  }
 file.list <- list.files(edf.path,pattern = ".edf", ignore.case = T, recursive = subFolder)
  

    for (file.counter in 1: length(file.list)) {
      conversion.file <- paste(edf.path, file.list[file.counter], sep = "")
      conversion.command <- paste(app.path, 
                                  conversion.file,
                                  add.options,
                                  "-p",
                                  asc.path, 
                                  sep = " ")
                                  
      if(Sys.info()["sysname"] == "Windows"){
      system2("cmd.exe", input =  conversion.command)}
      else{
      system(conversion.command)
      }                            
      
    }
    

} # end function



