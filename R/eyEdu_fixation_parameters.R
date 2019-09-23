EyEduFixationParameters <- function() {
  # Loads eyEdu.data agian for aoi info. Revise!
  load(paste(raw.data.path, "eyEdu_data.Rda", sep = ""))
  # Loads aoi summary data
  load(paste(raw.data.path, "aoi_summary.Rda", sep = ""))
  
  
  if (!file.exists(paste(raw.data.path, "aoi_summary.Rda", sep = ""))) {
    return("There is no aoi summary yet. Please run EyEduGetAoiSummary() first!")
  }
  # Sorts by fixaton index
  aoi.summary <- aoi.summary[order(aoi.summary$fixation.index), ]
  
  # Adds columns for pass, first....
  aoi.summary$pass.index <- 1
  aoi.summary$first.fix <- 0
  aoi.summary$refix <- 0
  aoi.summary$skip<-  0
  aoi.summary$never.fixated <- 0
  aoi.summary$never.fixated[is.na(aoi.summary$fixation.index)] <- 1
  aoi.summary$fixation.index[aoi.summary$never.fixated == 1] <- 0
  aoi.summary$regression.in <- 0
  aoi.summary$regression.out <- 0
  
  # Splits aoi summary by participant and trial (for easier indexing)
  trial.subset <-
    by(aoi.summary, list(
      factor(aoi.summary$stimulus.id),
      factor(aoi.summary$participant.name)
    ), FUN = subset)
  
  # Prepares empty data frame
  aoi.temp.summary <- data.frame(
    stimulus.id = character(),
    aoi.index = numeric(),
    line.aoi.index = numeric(),
    x.left = numeric(),
    x.right = numeric(),
    y.top = numeric(),
    y.bottom = numeric(),
    line.number = numeric(),
    fix.start = numeric(),
    fix.end = numeric(),
    fix.duration = numeric(),
    fix.pos.x = numeric(),
    fix.pos.y = numeric(),
    fixation.index = numeric(),
    trial.index = numeric(),
    aoi.label = character(),
    participant.name = character(),
    participant.nr = numeric(),
    never.fixated = numeric(),
    pass.index = numeric(),
    first.fix = numeric(),
    refix = numeric(),
    skip = numeric(),
    regression.in = numeric(),
    regression.out = numeric(),
    stringsAsFactors = FALSE
  )

 
  # Loops through subsets
  for (trial.subset.index in 1:length(trial.subset)) {
    temp.df <- trial.subset[[trial.subset.index]]
    temp.df <-
      subset(temp.df, !is.na(temp.df$aoi.index)) # removes fixations without aoi
    temp.df$pass.index[temp.df$never.fixated == 1] <- 0
    if (nrow(temp.df) <= 1) {
      next
    }
    
    # Difference of aoi index n to aoi index n-1 is informative as follows:
    # diff = 0: refixation (i.e., no difference in aoi to prior fixation)
    # diff = 1: forward saccade to n + 1
    # diff = -3: backward saccade to n -3, which indicates start of new pass
    temp.df$aoi.diff <-  NA
    temp.df$aoi.diff[2:nrow(temp.df)] <- diff(temp.df$aoi.index)
    # checks, which rows of the temp.df aoi.diff indicate the start of a
    # new pass
    new.pass.row.index <-
      which(temp.df$aoi.diff < 0 & temp.df$fixation.index != 0)
    
    # For each new pass: check the aoi range belonging to a pass (i.e., from
    # the regression into the word from which the new pass started until the
    # word that was not covered by that pass)
    for (pass.counter in new.pass.row.index) {
      row.index.subsequent.fixations <-
        which(temp.df$fixation.index >=
                temp.df$fixation.index[pass.counter])
      aoi.span <- abs(temp.df$aoi.diff[pass.counter])
      aoi.range <- seq(temp.df$aoi.index[pass.counter],
                       temp.df$aoi.index[pass.counter] + aoi.span)
      row.index.aoi.range <-
        which(temp.df$aoi.index %in% aoi.range)
      common.row.index <-
        row.index.aoi.range[which(row.index.aoi.range %in%
                                    row.index.subsequent.fixations)]
      temp.df$pass.index[common.row.index] <-
        temp.df$pass.index[common.row.index] + 1
    } # end loop for pass index
    
    # First fixation, checks whether the fixation index of the current
    # fixation is the minimum fixation index of all fixations on this aoi
    for (row.index in 1:nrow(temp.df)) {
      aoi.index <- temp.df$aoi.index[row.index]
      all.fix.on.aoi <-
        temp.df$fixation.index[temp.df$aoi.index == aoi.index]
      if (min(all.fix.on.aoi) == temp.df$fixation.index[row.index]) {
        temp.df$first.fix[row.index] <- 1
      } else{
        temp.df$first.fix[row.index] <- 0
      }
    } # end of loop for first fix indicator
    
    # Refixation
    temp.df$refix[temp.df$aoi.diff == 0] <- 1
    
    # Regressions (incoming)
    temp.df$regression.in[temp.df$aoi.diff < 0 &
                            temp.df$fixation.index != 0] <- 1
    
    # Regression (outgoing)
    temp.df$regression.out[which(temp.df$regression.in == 1) - 1] <- 1
    
   # Skipped aois (in contrast to aois, which never received a fixation) do
   # not appear in the aoi summary, but can be identified by looking at the
   # aoi.diff parameter. For example, aoi.diff = 6 indicates that five aois
   # were skipped. Additional rows will be attached for these aois. This
   # works well for first pass, but might create incorrect results for
   # higher passes!
   for (row.index in 2:nrow(temp.df)) {
     if (temp.df$aoi.diff[row.index] > 1 &
         temp.df$never.fixated[row.index] != 1) {
       start.aoi <- temp.df$aoi.index[row.index - 1]
       end.aoi <- temp.df$aoi.index[row.index]
       aoi.seq <- seq(from = start.aoi,
                      to = end.aoi,
                      by = 1)
       aoi.seq <- aoi.seq[-1] # removes start aoi
       aoi.seq <- aoi.seq[-length(aoi.seq)] # removes end aoi
       
       for (aoi.to.add in aoi.seq) {
         skipped.aoi <- temp.df[temp.df$aoi.index == aoi.to.add, ]
         skipped.aoi <- skipped.aoi[1, ]
         skipped.aoi[, c(7:12)] <- NA
         # max(temp.df$pass.index[temp.df$aoi.index == aoi.to.add])
         skipped.aoi$pass.index <- temp.df$pass.index[row.index] # this might indicate wrong pass
         skipped.aoi[, c(20:22)] <- 0
         skipped.aoi$skip <- 1
         temp.df <- rbind(temp.df, skipped.aoi)
         rm(skipped.aoi)
       } # end loop for aois to add
     } else {
       next
     }
   } # ende skip loop
    
    temp.df$aoi.diff <- NULL
    aoi.temp.summary <- rbind(aoi.temp.summary, temp.df)
  } # end trial subset loop

  # Cleans up
  rm(
    all.fix.on.aoi,
    aoi.range,
    aoi.index,
    aoi.seq,
    aoi.span,
    aoi.to.add,
    common.row.index,
    end.aoi,
    new.pass.row.index,
    pass.counter,
    row.index,
    row.index.aoi.range,
    row.index.subsequent.fixations,
    start.aoi,
    trial.subset.index,
    trial.subset,
    temp.df
  )
  
  fixation.parameters <- aoi.temp.summary
  rm(aoi.temp.summary)

#### for count measures
fixation.parameters$fixated <- 0
fixation.parameters$fixated[fixation.parameters$fix.duration > 0] <- 1

#### Total fixation time ####
total.fixation.time <- aggregate(
  fixation.parameters$fix.duration,
  by = list(
    fixation.parameters$stimulus.id,
    fixation.parameters$aoi.index,
    fixation.parameters$participant.name
  ),
  FUN = sum,
  na.rm = T
)
total.fixation.time$x[total.fixation.time$x == 0] <- NA
colnames(total.fixation.time)[4] <- "total.fixation.time"


#### Fixation count (over all passes) ####
fixation.count <- aggregate(
  fixation.parameters$fixated,
  by = list(
    fixation.parameters$stimulus.id,
    fixation.parameters$aoi.index,
    fixation.parameters$participant.name
  ),
  FUN = sum,
  na.rm = T
)

colnames(fixation.count)[4] <- "fixation.count"

parameter.summary <- merge(total.fixation.time,
                           fixation.count,
                           by.x = c("Group.1", "Group.2", "Group.3"))
rm(total.fixation.time, fixation.count)

#### Regression in #### 
regression.in <- aggregate(
  fixation.parameters$regression.in,
  by = list(
    fixation.parameters$stimulus.id,
    fixation.parameters$aoi.index,
    fixation.parameters$participant.name
  ),
  FUN = sum,
  na.rm = T
)
colnames(regression.in)[4] <- "regression.in"
regression.in$regression.in[regression.in$regression.in > 0] <- 1

parameter.summary <- merge(parameter.summary,
                           regression.in,
                           by.x = c("Group.1", "Group.2", "Group.3"))
rm(regression.in)

#### Regression out ####
regression.out <- aggregate(
  fixation.parameters$regression.out,
  by = list(
    fixation.parameters$stimulus.id,
    fixation.parameters$aoi.index,
    fixation.parameters$participant.name
  ),
  FUN = sum,
  na.rm = T
) 
colnames(regression.out)[4] <- "regression.out"
regression.out$regression.out[regression.out$regression.out > 0] <- 1
parameter.summary <- merge(parameter.summary, regression.out, 
                           by.x = c("Group.1", "Group.2", "Group.3"))
rm(regression.out)

#### Gaze duration ####
first.pass.subset <- subset(fixation.parameters,
                            fixation.parameters$pass.index <= 1)

gaze.duration <- aggregate(
  first.pass.subset$fix.duration,
  by = list(
    first.pass.subset$stimulus.id,    
    first.pass.subset$aoi.index,
    first.pass.subset$participant.name
  ),
  FUN = sum,
  na.rm = T
)
gaze.duration$x[gaze.duration$x == 0] <- NA
colnames(gaze.duration)[4] <- "gaze.duration"
parameter.summary <- merge(
  parameter.summary,
  gaze.duration,
  by = c("Group.1", "Group.2", "Group.3"),
  all.x = TRUE
)
rm(gaze.duration)

#### First pass fixation count ####
first.pass.fixation.count <- aggregate(
  first.pass.subset$fixated,
  by = list(
    first.pass.subset$stimulus.id,    
    first.pass.subset$aoi.index,
    first.pass.subset$participant.name
  ),
  FUN = sum,
  na.rm = T
)
colnames(first.pass.fixation.count)[4] <- "first.pass.fixation.count"

parameter.summary <- merge(
  parameter.summary,
  first.pass.fixation.count,
  by = c("Group.1", "Group.2", "Group.3"),
  all.x = TRUE
)
rm(first.pass.fixation.count)
rm(first.pass.subset)
#### Skipping ####

parameter.summary$skip <- 0
parameter.summary$skip[parameter.summary$first.pass.fixation.count == 0] <- 1


#### First pass first fixation duration ####
first.pass.subset.first <- subset(
  fixation.parameters,
  fixation.parameters$pass.index == 1 &
    fixation.parameters$first.fix == 1
)
first.pass.first.fixation.duration <-
  aggregate(
    first.pass.subset.first$fix.duration,
    by = list(
      first.pass.subset.first$stimulus.id,
      first.pass.subset.first$aoi.index,
      first.pass.subset.first$participant.name
    ),
    FUN = sum,
    na.rm = T
  )
first.pass.first.fixation.duration$x[first.pass.first.fixation.duration$x == 0] <- NA
colnames(first.pass.first.fixation.duration)[4] <-
  "first.pass.first.fixation.duration"
parameter.summary <- merge(
  parameter.summary,
  first.pass.first.fixation.duration,
  by = c("Group.1", "Group.2", "Group.3"),
  all.x = TRUE
)
rm(first.pass.first.fixation.duration, first.pass.subset.first)

#### First fixation duration (all passes) ####
first.fix <- subset(fixation.parameters,
                      fixation.parameters$first.fix == 1)
first.fix.duration <- aggregate(
  first.fix$fix.duration,
  by = list(
    first.fix$stimulus.id,
    first.fix$aoi.index,
    first.fix$participant.name
  ),
  FUN = sum,
  na.rm = T
) 
first.fix.duration$x[first.fix.duration$x == 0] <- NA
colnames(first.fix.duration)[4] <- "first.fix.duration"
parameter.summary <- merge(
  parameter.summary,
  first.fix.duration,
  by = c("Group.1", "Group.2", "Group.3"),
  all.x = TRUE
)
rm(first.fix.duration, first.fix)


#### Rereading time ####
reread <- subset(fixation.parameters,
                    fixation.parameters$pass.index > 1)
rereading.time <- aggregate(
  reread$fix.duration,
  by = list(
    reread$stimulus.id,
    reread$aoi.index,
    reread$participant.name
  ),
  FUN = sum,
  na.rm = T
)   
colnames(rereading.time)[4] <- "rereading.time"
parameter.summary <- merge(
  parameter.summary,
  rereading.time,
  by = c("Group.1", "Group.2", "Group.3"),
  all.x = TRUE
)
rm(rereading.time, reread)

#### Number of passes ####
pass.count <- aggregate(
  fixation.parameters$pass.index,
  by = list(
    fixation.parameters$stimulus.id,
    fixation.parameters$aoi.index,
    fixation.parameters$participant.name
  ),
  FUN = max,
  na.rm = T
)
colnames(pass.count)[4] <- "pass.count"
parameter.summary <- merge(
  parameter.summary,
  pass.count,
  by = c("Group.1", "Group.2", "Group.3"),
  all.x = TRUE
)
rm(pass.count)




##### 

colnames(parameter.summary)[1:3] <- c("stimulus.id", "aoi.index", "participant.name")


#### Prepares aoi info ####
# stupid way of doing it, but reloads aoi info and prepares 
# it for merging with parameter summary
temp.aoi <- eyEdu.data$aoi.info[[1]]
for (aoi.counter in 2:length(eyEdu.data$aoi.info)) {
  temp.aoi <- rbind(temp.aoi, eyEdu.data$aoi.info[[aoi.counter]])
  }
temp.aoi$stimulus.id <- gsub("^.*_", "", temp.aoi$image.name)

parameter.summary <- merge (parameter.summary, temp.aoi, 
               by = c("stimulus.id", "aoi.index"),
               all = T)
rm(temp.aoi, aoi.counter)    

# Quick fix especially for skips, need revision
parameter.summary$pass.count[parameter.summary$pass.count == 0] <- 1



save(fixation.parameters,
     file = paste(raw.data.path,
                  "fixation_parameters.Rda",
                  sep = ""))
save(parameter.summary, 
     file = paste(raw.data.path,
                  "parameter_summary.Rda",
                  sep = ""))


print("Done!")
} # end function
