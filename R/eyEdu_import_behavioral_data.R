
EyEduImportBehavioralData <- function(var.selection = NULL){
  
# Exception handler
  if (is.null(var.selection)){
    return("There are no response variables defined yet. 
           Please provide variable names for instance var.selection")
    }  

load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
file.list <- list.files(raw.data.path , pattern = "*.csv", recursive = F)

# Start file loop
for(file.counter in 1: length(file.list)){
response.data.temp <- read.csv(paste(raw.data.path, 
                                     file.list[file.counter], sep = ""),
                               stringsAsFactors=FALSE)

participant.name <- gsub(".csv", "", file.list[file.counter])
participant.name <- paste(participant.name, ".tsv", sep = "")

# Start loop for each variable name provided in var.selection
var.index <- NULL
for(var.counter in 1: length(var.selection)){
  var.index.temp <- which(
    colnames(response.data.temp) == var.selection[var.counter])
  var.index <- c(var.index, var.index.temp)
}

# Reduces response data frame to variables provided in var.selection
response.data.temp <- response.data.temp[,var.index]

# Copies response data into trial info of participants 
participant.index <- which(names(eyEdu.data$participants) == participant.name)
eyEdu.data$participants[[participant.index]]$trial.info <- cbind(
  eyEdu.data$participants[[participant.index]]$trial.info, response.data.temp)

# Providing some feedback on progress.
processed.file <- file.list[file.counter]
print(paste("Importing response data for:",
            processed.file, 
            "- number", file.counter, 
            "out of", 
            length(file.list), sep = " ")) 
} # End file loop
save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
print("Done!")
}




