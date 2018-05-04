###############################################################################
###############################################################################
################ Example Analysis for Reading Experiment ######################
###############################################################################
###############################################################################



###############################################################################
# Currently eyEdu can only be used if devtools are properly set on your system.
# If this is the case install_github will download and install eyEdu.
library(devtools)
install_github("SebastianKorinth/eyEdu")
library(eyEdu)

###############################################################################
# EyEdu relies on several libraries. The EyEduCheckPackages() function checks
# whether all necessary libraries are available - if not - they will be installed
# and all necessary libraries will be loaded.
EyEduCheckPackages()

###############################################################################
# The function EyEduGetExamples() will download a zip-file from github
# containing example data files - and the openSesame-experiments used to
# collect these data. The file will be unzipped and saved in the current
# working directory.
EyEduGetExamples(experiment.type = "reading")

###############################################################################
# Some eyEdu functions require the argument raw.data.path, which is the path
# where raw data are stored. If you used the example reading experiment,
# this will be:
raw.data.path <- "exampleDataReadingExperiment-master/"
# potential pitfall: Make sure the path ends with a forward slash!
# potential pitfall: Check that you use forward slashes (Windows issue)

###############################################################################
# EyEduImportRawData reads raw data (.tsv files), seperates eye movement from
# message information extracts relevant information (e.g., screen dimensions,
# sample rate etc.) and adds this to file called eyEdu_data.Rda. Optional
# arguments allow defining time windows within a trial (e.g., poi.end = "...".
EyEduImportRawData(raw.data.path,poi.end = "response_time_key_finish_reading")

###############################################################################
# Fixation detection: This function uses the emov library by Simon Schwab
# and its I-DT algorith (Salvucci & Goldberg, 2000), which uses dispersion
# limits to distinguish between fixations and saccades.
EyEduDetectFixationsIDT(raw.data.path, dispersion.var = 90,duration.var = 6)

###############################################################################
# EyEduPlotDiagnostics() plots the eye-tracker samples of a given length
# (e.g., 2500 ms) overlayed by fixations. This provides a first impression of
# how well fixation detection worked
EyEduPlotDiagnostics(participant.nr = 5,trial.nr = 1,sample.length = 2500)

###############################################################################
# For reading experiments only!
# The EyEduDefineWordAois() function parses screenshots of reading experiments
# into areas of interes (aoi)
EyEduDefineWordAois(raw.data.path = raw.data.path,line.margin = 27)

###############################################################################
# EyEduPlotTrial(). Several arguments allow to show or hide the left, the
# right or the average sample position etc.
EyEduPlotTrial(participant.nr = 1,
               trial.nr = 1 ,
               fix.color = "red",
               sample.color.l = "blue",
               sample.color.r = "red",
               sample.color = NA)

###############################################################################
# EyEduCollateFixationsAois() assignes fixations to areas of interest
EyEduCollateFixationsAois()

###############################################################################
# EyEduGetFixationSummary() collects the fixation information of all
# participants and summarizes it into one data frame.
EyEduGetFixationSummary()




