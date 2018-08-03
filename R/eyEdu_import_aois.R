
EyEduImportAoIs <- function(append.aois = T){

# list of aoi.files
aoi.file.list <- list.files(path= paste(raw.data.path, "aoiFiles/", sep = ""), pattern = "\\.txt$")
  
# loads the eyEdu data frame to which the aoi.files will be added
load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))


present.aoi.length <- length(eyEdu.data[["aoi.info"]])

if (append.aois == T) {
start.index <- present.aoi.length 
} 
else {
 start.index <- 1
}


for(aoi.file.counter in 1: length(aoi.file.list)) {
temp.df <- read.table(file = paste(raw.data.path, "aoiFiles/", 
                                   aoi.file.list[aoi.file.counter], 
                                   sep = ""), 
                      header = T, sep = " ", stringsAsFactors = F)

eyEdu.data[["aoi.info"]][[aoi.file.counter + start.index]] <- temp.df
names(eyEdu.data[["aoi.info"]])[[aoi.file.counter + start.index]] <- gsub(".txt", 
                                                            ".png",
                                                            aoi.file.list[aoi.file.counter])

rm(temp.df)

save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

}
}
