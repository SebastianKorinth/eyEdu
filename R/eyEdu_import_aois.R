
EyEduImportAoIs <- function(append.aois = TRUE,
                            delete.existing.aois = FALSE,
                            screen.align.x = NULL,
                            screen.align.y = NULL){

# loads the eyEdu data frame to which the aoi.files will be added
load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))  

if (file.exists(paste(raw.data.path, "aoiFiles", sep = "")) == F ){
 return("Can't find folder containing aoi files!")
 } 

if (delete.existing.aois == TRUE) {
  eyEdu.data$aoi.info[] <- NULL
}  


# list of aoi.files
aoi.file.list <- list.files(path= paste(raw.data.path, "aoiFiles/", sep = ""),
                            pattern = "\\.txt$")
  
present.aoi.length <- length(eyEdu.data[["aoi.info"]])

if (append.aois == T) {
start.index <- present.aoi.length 
} else {
 start.index <- 0
}

if(!is.null(screen.align.x) ){
  screen.x <- eyEdu.data$participants[[1]]$header.info$display.x
  adjust.x <- (screen.x - screen.align.x)/2
  screen.y <- eyEdu.data$participants[[1]]$header.info$display.y
  adjust.y <- (screen.y - screen.align.y)/2
} else {
  
  adjust.x <- 0
  adjust.y <- 0
} 


for(aoi.file.counter in 1: length(aoi.file.list)) {
temp.df <- read.table(file = paste(raw.data.path, "aoiFiles/", 
                                   aoi.file.list[aoi.file.counter], 
                                   sep = ""), 
                      header = T, sep = " ", stringsAsFactors = F, quote = '')

temp.df$x.left <- temp.df$x.left + adjust.x
temp.df$x.right <- temp.df$x.right + adjust.x
temp.df$y.top <- temp.df$y.top + adjust.y
temp.df$y.bottom <- temp.df$y.bottom + adjust.y


eyEdu.data[["aoi.info"]][[aoi.file.counter + start.index]] <- temp.df
names(eyEdu.data[["aoi.info"]])[[
  aoi.file.counter + start.index]] <- gsub(".txt",
                                           ".png",
                                           aoi.file.list[aoi.file.counter])

# Providing some feedback on processing progress.
processed.aoi.file <- aoi.file.list[aoi.file.counter]
print(paste("Importing aoi file: ",
            processed.aoi.file,
            "- number", aoi.file.counter,
            "out of",
            length(aoi.file.list), sep = " "))



}
save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

}

