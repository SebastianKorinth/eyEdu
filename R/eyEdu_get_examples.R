EyEduGetExamples <- function(experiment.type = "reading"){
  
  
if(experiment.type == "reading"){

download.file( url = "http://github.com/SebastianKorinth/exampleDataReadingExperiment/archive/master.zip",
               destfile = "example.zip")

unzip( zipfile = "example.zip" )
file.remove("example.zip")

}
  if(experiment.type == "search"){
    
    download.file( url = "http://github.com/DejanDraschkow/exampleDataSearchExperiment/archive/master.zip",
                   destfile = "example.zip")
    
    unzip( zipfile = "example.zip" )
    file.remove("example.zip")
    
  }
  if(experiment.type == "readEyeLink"){
    - 
    download.file( url = "https://github.com/SPKorinth/EyeLinkPsychoPyExample/archive/refs/heads/main.zip",
                   destfile = "example.zip")
    
    unzip( zipfile = "example.zip" )
    file.remove("example.zip")
    
  }
  
}