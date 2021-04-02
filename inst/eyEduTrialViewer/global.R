library(png)
library(ggplot2)
library(grid)   

load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

initial.background.file <- list.files(paste(raw.data.path,"images/", sep = ""))[1]
initial.background.file <- readPNG((paste(raw.data.path,"images/", initial.background.file, sep = "")))
page.width <- dim(initial.background.file)[2]
page.height <- dim(initial.background.file)[1]
scale.var = 0.55
aoi.names.screenshot <<- aoi.names.screenshot

