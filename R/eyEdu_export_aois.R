
EyEduExportAoIs <- function(){

  
# loads the eyEdu data frame from which the aoi definitions will be extracted
load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  
  
  
if (file.exists(paste(raw.data.path, "aoiFiles", sep = "")) == F ){
 dir.create(paste(raw.data.path, "aoiFiles", sep = ""))
 } 
  

for(aoi.file.counter in 1: length(eyEdu.data$aoi.info)) {
 
  file.name.var <- gsub(".png", ".txt",names(eyEdu.data$aoi.info[aoi.file.counter])) 
  
  write.table(eyEdu.data$aoi.info[[aoi.file.counter]],
              file = paste(raw.data.path,"aoiFiles/", file.name.var, sep = ""),
              quote = F,
              row.names = F)
  
  # Providing some feedback on processing progress.
  processed.aoi.file <- names(eyEdu.data$aoi.info[aoi.file.counter])
  print(paste("Exporting aoi file:",
              aoi.file.counter, 
              "- number", aoi.file.counter, 
              "out of", 
              max(length(eyEdu.data$aoi.info)), sep = " "))
}
}

