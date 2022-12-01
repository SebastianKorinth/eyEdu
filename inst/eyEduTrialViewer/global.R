library(png)
library(ggplot2)
library(grid)   

load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))


# The shinyApp would display an error if it would not find background images
# Below we create an images folder and a placeholder background image with 
# width and height defined by two values that must be provided by the function
# that calls the shiny app
if (!dir.exists(paste(raw.data.path,"images/", sep = ""))){
  
  # Creates folder
  dir.create(paste(raw.data.path,"images/", sep = ""))
  # Creates placeholder image
  png(filename = paste(raw.data.path,"images/placeholder.png", sep = ""), 
      width = background.x, 
      height = background.y,
      units = "px", 
      pointsize = 6, 
      bg = "grey")
  par(mar = c(0, 0, 0, 0))
  plot(x = 0:500, y = 0:500, ann = F,bty = "n",type = "n",
       xaxt = "n", yaxt = "n")
  text(x = 250,y = 250,"No background images found! \n 
     Attention: The plot dimension might be incorrect. \n 
     To fix this, either provide background png-files in the images folder, \n
     or delete the images folder and provide correct plot dimensions through \n
     background.x = pixels and background.y = pixels in the function that calls \n
     the eyEdu Trial Viewer shiny app.", cex=5)
  dev.off()
  }


initial.background.file <- list.files(paste(raw.data.path,"images/", sep = ""))[1]
initial.background.file <- readPNG((paste(raw.data.path,"images/", initial.background.file, sep = "")))
page.width <- dim(initial.background.file)[2]
page.height <- dim(initial.background.file)[1]


### provided by function that calls the Shiny app
# scale.var = 0.55
# aoi.color = "red"
# aoi.names.screenshot = T
# fix.size.scale = 10
# background.x = 1680
# background.y = 1050