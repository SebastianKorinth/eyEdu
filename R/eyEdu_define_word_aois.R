
EyEduDefineWordAois <- function(line.margin = 26,
                               character.space.width = 10,
                               inter.word.adjust = 5,
                               sparse = T){

load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

# Defines a path from where to take stimuli images
inpath = paste(raw.data.path, "images/", sep = "")

# Defines the list of files to work on 
file.names <- list.files(path= inpath)

# Reduces the file list in order to avoid redundent aoi definitions
if (sparse == T) {
  
  eyEdu.data$aoi.info <- list()
  temp.file.names <- gsub(".*_", "", file.names)
  file.names <- file.names[duplicated(temp.file.names) == F] 
  length(eyEdu.data$aoi.info) = length(file.names)
  names(eyEdu.data$aoi.info) = file.names

  

  
  
}else{
  
  # Initiates the full list (for all image files) to be filled with aoi.info
  eyEdu.data$aoi.info <- list()
  length(eyEdu.data$aoi.info) = length(file.names)
  names(eyEdu.data$aoi.info) = file.names
  
}



# Loops through image files  
for(file.counter in 1 : length(file.names)){

# Reads file
text.image <- readImage(paste(inpath, file.names[file.counter], sep="/"))
# Reduces image from RGB to grey scale
text.image <-channel(text.image,"gray")
text.image <- text.image@.Data
# Rounds to only 1 = background and 0 = black values 
text.image <- round(text.image) 
# Inverse matrix now 0 = background, 1 = text
text.image <- (text.image -1) * -1 
# Extracts image dimensions
image.width <- nrow(text.image)
image.height <- ncol(text.image)

############### Line borders ###############################

# Collapses pixels row-wise
line.vector <- colSums (text.image, na.rm = FALSE, dims = 1) 
# Recodes into 1 = line, 0 = between lines 
line.vector[line.vector > 1] <- 1 
# Deletes the first element of the vector (should be a 0 = background pixel)
shift.vector <- line.vector[-1] 
# ... and adds it back at the end of the vector
shift.vector[length(line.vector)] <- 0 
# 1 = upper limit of line, -1 lower limit of line
shift.vector <- shift.vector - line.vector 
# Adds some pixels above line
upper.line.limits <- which(shift.vector == 1) - line.margin 
# Adds some pixels below line
lower.line.limits <- which(shift.vector == -1) + line.margin 
rm(shift.vector, line.vector) 
      
############ Word borders ##################################

# Initiates an empty data frame for the AoI information
aoi.info <- data.frame (image.name = character(), 
                        line.number = numeric(), 
                        line.aoi.index = numeric, 
                        x.left = numeric,
                        x.right = numeric,
                        y.top = numeric,
                        y.bottom = numeric)

# Loop that searches for word borders in each line starts here    
for(line.counter in 1 : length(upper.line.limits)){ 
      
# Creates a subset of one line
current.line <- subset(text.image)[,upper.line.limits[line.counter]:
                                     lower.line.limits[line.counter]]
current.line <- rowSums (current.line, na.rm = FALSE, dims = 1)
# Recodes into 1 = line, 0 = between characters 
current.line[current.line > 1] <- 1 

# rle() searches for repeated values; the result is a combined list of the 
# repetion length and its value
line.word.borders <- rle(current.line)
# For easier indexing transformation into data frame
line.word.borders <- data.frame(matrix(unlist(line.word.borders), 
                                       nrow=length(line.word.borders$lengths), 
                                       byrow = F)) 
colnames(line.word.borders) <- c("repetition.length","repetition.value")
line.word.borders$word.border <- NA
  

# Loops through the line.word.borders data frame and marks word borders defined
# as: When the value 0 is repeated more than what is defined as the maximum 
# inter-character space (e.g., 7). This is actually empty-space-detection 
for (word.line.counter in 1: nrow(line.word.borders)){
if(line.word.borders$repetition.length[word.line.counter] > 
   character.space.width & 
   line.word.borders$repetition.value[word.line.counter] == 0 ){
line.word.borders$word.border[word.line.counter] <- 1}
else {line.word.borders$word.border[word.line.counter] <- 0}
}

# Loops through line.word.borders data frame and adds a per-line-word-counter
line.word.borders$line.word.index  <- NA
line.word.borders$line.word.index[1] <- 0
initial.word = 0
for (word.line.counter in 1: nrow(line.word.borders)){

if(line.word.borders$word.border[word.line.counter] == 1) {
initial.word = initial.word + 1} 
else  { initial.word = initial.word}
line.word.borders$line.word.index[word.line.counter] <- initial.word 
}
      
line.aoi <- aggregate(line.word.borders, 
                      by=list(line.word.borders$line.word.index, 
                              line.word.borders$word.border), 
                      FUN=sum, na.rm=TRUE)
      
      
line.aoi <- line.aoi[,1:3]
colnames(line.aoi) <- c("index", "word.space", "length")
space.df <- subset(line.aoi, line.aoi$word.space == 1)
word.df <- subset(line.aoi, line.aoi$word.space == 0)
      
line.aoi <- merge(x = space.df, y = word.df,by = "index", all.x = TRUE)

line.aoi$x.left <- NA
line.aoi$x.right <- NA 
line.aoi$x.left[1] <- line.aoi$length.x[1] 
line.aoi$x.right[1] <- line.aoi$length.x[1] + line.aoi$length.y[1] 

# Loops through areas of interest
for (aoi.counter in 2: nrow(line.aoi)){
line.aoi$x.left[aoi.counter] <- line.aoi$length.x[aoi.counter] + 
  line.aoi$x.right[aoi.counter-1]
line.aoi$x.right[aoi.counter]  <- line.aoi$length.y[aoi.counter] + 
  line.aoi$x.left[aoi.counter]
}
      
line.aoi$x.left <- line.aoi$x.left - inter.word.adjust
line.aoi$x.right <- line.aoi$x.right + inter.word.adjust
line.aoi$y.top <- upper.line.limits[line.counter]
line.aoi$y.bottom <- lower.line.limits[line.counter]  

# Deletes last IA (because it is actually empty)
line.aoi <- line.aoi[-(nrow(line.aoi)),] 
line.aoi$line.number <- line.counter

# Deletes temporary variables
line.aoi <- line.aoi[,-(2:5)]
colnames(line.aoi)[1] <- "line.aoi.index"
line.aoi$image.name <- gsub(".png", "",file.names[file.counter])


# Addes the aoi info for a line to the complete aoi.info data frame for
# an image
aoi.info <- rbind(aoi.info, line.aoi)
}

# Adds an aoi.index for complete text (relevant for multi-line texts only)
aoi.info$aoi.index <- 1: nrow(aoi.info)

# Adds an (empty) column for aoi labels
aoi.info$aoi.label <- NA
  
# Saves aoi.info into the eyEdu.data list 
eyEdu.data$aoi.info[[file.counter]] <- aoi.info
  
# Progress report
processed.file <- file.names[file.counter]
print(paste("Segmenting image:", processed.file, "- number:", 
            file.counter, "out of", length(file.names), sep = " "))
} 
save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = "") ) 
print("Done!")   

}