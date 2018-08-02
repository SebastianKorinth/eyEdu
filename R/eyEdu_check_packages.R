


EyEduCheckPackages <- function(){


if (!require("EBImage")) {
  source("https://bioconductor.org/biocLite.R")
  biocLite("EBImage")
  library(EBImage)
}

  if (!require("png")) {
    install.packages("png", dependencies = TRUE)
    library(png)
  }
  
  if (!require("shiny")) {
    install.packages("shiny", dependencies = TRUE)
    library(shiny)
  }
  
  if (!require("ggplot2")) {
    install.packages("ggplot2", dependencies = TRUE)
    library(ggplot2)
  }
  
if (!require("grid")) {
  install.packages("grid", dependencies = TRUE)
  library(grid)
}

  if (!require("emov")) {
    install.packages("emov", dependencies = TRUE)
    library(emov)
  }
  
if (!require("reshape2")) {
    install.packages("reshape2", dependencies = TRUE)
    library(reshape2)
  }  
  
  
}


