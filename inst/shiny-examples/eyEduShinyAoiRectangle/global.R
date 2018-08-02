library(png) # for opening png files

### gets the path right
image.path <- paste(getwd(),"/", raw.data.path, sep = "")

# reads the first image from the folder, which is used to set plot dimensions
# for all images + also needed to calculate pixel-click-location
one.image = list.files(paste(image.path, "images/", sep = ""))[1]
one.image.dimension <- dim(readPNG(paste(image.path, "images/",one.image, sep = "")))

dim.x <- one.image.dimension[2]
dim.y <- one.image.dimension[1]

# allows scaling of the plot shown within the shiny app
# depends on individual screen size, adjust scale.var to enlarge or to decrease
# if scale.var = 1 100 %
scale.var = 0.65
plot.dim.width <- paste(as.integer(dim.x * scale.var),"px", sep = "")
plot.dim.height <- paste(as.integer(dim.y * scale.var),"px", sep = "")

# creates folder in which the AoI files will be saved
dir.create(paste(image.path,"aoiFiles", sep = ""), showWarnings = F)


