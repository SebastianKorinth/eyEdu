
library(png)
library(ggplot2)
library(shiny)
library(grid)

# for debugging only
# raw.data.path <- "/Users/sebastian/Dropbox/eyEdu/eyeDu working version/exampleDataReadingExperiment-master/"


load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
scale.var = 0.9