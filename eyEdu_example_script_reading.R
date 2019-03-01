


library(devtools)
install_github("SebastianKorinth/eyEdu")
library(eyEdu)


# ########################################################################
# EyEdu relies on several libraries. The EyEduCheckPackages() function checks
# whether all necessary libraries are available - if not - they will be installed
# and all necessary libraries will be loaded. Run only once!
EyEduCheckPackages()


#######################################################################
# The function EyEduGetExamples() wil download a zip-file from github
# containing example data files - and the openSesame-experiments used to
# collect these data. The file will be unzipped and saved in the current
# working directory. Currently there are two options for "example.type"
# As the name suggests "reading" downloads example data from a single
# line sentence reading experiment and the OpenSesame experiment itself too.
# The option "search" downloads a visual object search experiment with
# example data.
EyEduGetExamples(experiment.type = "reading")


########################################################################
# Some eyEdu functions require the argument raw.data.path, which is the path,
# where raw data are stored. If you used the example reading experiment,
# this will be:
raw.data.path <- paste(getwd(),"/exampleDataReadingExperiment-master/", sep = "")
# potential pitfall: Please provide absolut path (relative paths might not work)
# potential pitfall: Make sure the path ends with a forward slash!
# potential pitfall: Check that you use forward shlashes (Windows issue)

########################################################################
# EyEduImportRawData reads raw data (.tsv files), seperates eye movement from
# message information extracts relevant information (e.g., screen dimensions,
# sample rate etc.) and adds this to file called eyEdu_data.Rda. Optional
# arguments allow defining time windows within a trial (e.g., poi.end = "...".
EyEduImportRawData(poi.end = "response_time_key_finish_reading")


################################
# for very noisy data low pass filtering might help
EyEduLowPassFilter(filter.settings = rep(1/3, 3))

###############
EyEduShowParticipantTable()


########################################################################
# Fixation detection: This function uses the emov library by Simon Schwab
# and its I-DT algorith (Salvucci & Goldberg, 2000), which uses dispersion
# limits to distinguish between fixations and saccades.
EyEduDetectFixationsIDT(dispersion.var = 90,
                        duration.var = 6,
                        use.filtered = F,
                        participant.list = c(2,5))

########################################################################
# EyEduPlotDiagnostics() plots the eye-tracker samples over given length
# (e.g., 2500 ms) overlayed by fixations. This provides a first impression of
# how well fixation detection worked
EyEduPlotDiagnostics(participant.nr = 5,trial.nr = 2,sample.length = 2500)

########################################################################
# For reading experiments only!
# The EyEduDefineWordAois() function parses screenshots of reading experiments
# into areas of interes (aoi)
EyEduDefineWordAois(line.margin = 70,sparse = T)

########################################################################
# EyEduPlotTrial(). Several arguments allow to show or hide the left, the
# right or the average sample position etc.
EyEduPlotTrial(participant.nr = 5, trial.nr = 2,
               show.filtered = F,
               sample.color.r = NA,
               sample.color.l = NA,
               sample.color = "blueviolet",
               aoi.names.screenshot = T)
# another example that uses participant name instead of number
EyEduPlotTrial(participant.name = "karl",
               trial.nr = 7,
               fix.color = "green" )


# for reading experiments only assigns aoi labels from stimulus message info
EyEduImportWordAoiLabels(sparse.aoi.definition = T,extra.aoi = "end_point")


########################################################################
# EyEduAssignFixationsAois() assignes fixations to areas of interest
EyEduAssignFixationsAois()

#######################################################################
# EyEduGetFixationSummary() collects the fixation information of all participants
# and summarizes it into one data frame
EyEduGetFixationSummary()

#######################################################################
# shiny app that allows to "draw" and label freehand areas of interest
scale.var <- 0.66
EyEduShinyAoiRectangle()

#######################################################################
# EyEduGetFixationSummary() collects the fixation information of all participants
# and summarizes it into one data frame
EyEduImportAoIs(append.aois = T)


#####################################################################
# for clicking through lots of trials quickly, image of trial plots can be
# created using batch
EyEduBatchPlotTrials(participant.nr.list <- c(1,5,8),
                     fix.color = "green",
                     sample.color.r = "red",
                     sample.color.l = "blue", sample.color = NA)


