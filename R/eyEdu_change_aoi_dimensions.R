EyEduChangeAoiDimensions <- function(aoi.label = NULL,
                               aoi.x.left = NULL,
                               aoi.x.right = NULL,
                               aoi.y.top = NULL,
                               aoi.y.bottom = NULL){

  load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))

for(aoi.set.counter in 1: length(eyEdu.data$aoi.info)){
  eyEdu.data$aoi.info[[aoi.set.counter]]$x.left[
    eyEdu.data$aoi.info[[aoi.set.counter]]$aoi.label == aoi.label] <- aoi.x.left
  eyEdu.data$aoi.info[[aoi.set.counter]]$x.right[
    eyEdu.data$aoi.info[[aoi.set.counter]]$aoi.label == aoi.label] <- aoi.x.right
  eyEdu.data$aoi.info[[aoi.set.counter]]$y.top[
    eyEdu.data$aoi.info[[aoi.set.counter]]$aoi.label == aoi.label] <- aoi.y.top
  eyEdu.data$aoi.info[[aoi.set.counter]]$y.bottom[
    eyEdu.data$aoi.info[[aoi.set.counter]]$aoi.label == aoi.label] <- aoi.y.bottom
 }

save(eyEdu.data, file = paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
print("Done!")
}