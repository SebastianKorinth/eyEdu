EyEduGetExamples <- function(experiment.type = "reading"){
  
  
if(experiment.type == "reading"){

download.file( url = "https://github.com/SebastianKorinth/exampleDataReadingExperiment/archive/master.zip",
               destfile = "example.zip")

unzip( zipfile = "example.zip" )
file.remove("example.zip")

}
}