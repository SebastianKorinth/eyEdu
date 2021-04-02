EyEdu - A Basic Eye Movement Analysis Package for Educational Purposes
================

### Disclaimer

EyEdu (pronounced "I do!") is not intended to replace existing or commercial software packages for the analysis of eye-tracking data. The development of eyEdu was motivated by the idea that teaching the basics of eye-tracking (e.g., in workshops for undergraduate students) should be as hands-on as possible. With cheap hardware ([EyeTribe](http://theeyetribe.com/theeyetribe.com/about/index.html) - or whatever alternative might hopefully come up soon) and open source software ([R](https://www.r-project.org/), [OpenSesame](https://osdoc.cogsci.nl/), [PyGaze](http://www.pygaze.org/)) available, practically every student can create experiments, collect data and run analyses on her/his own.
The package provides basic functions to import raw eye-tracking data (currently only for EyeTribe), to visualize data, to conduct fixation detection, to create or import area of interest definitions and [several additional functions](#list-of-functions).
Example experiments including real eye movement data can be downloaded and used to run some first analyses (aka playing around). This package is obviously incomplete, full of bugs and might change a lot in the future. If you think that you can make it better, join the team!


### April 2021 +++ NEW +++ NEW +++ NEW +++ NEW +++

DiagnosticViewer is a shiny app that allows browsing through diagnostic plots.

``` r

EyEduDiagnosticViewer()

```
![](README_files/figure-markdown_github/eyEdu-diagnostic-viewer.png)


### March 2021 +++ NEW +++ NEW +++ NEW +++ NEW +++

EyEdu has now a plot function for heat maps, that is, you can combine the fixation data of several participants (or only one) looking at the same stimulus by providing a list of participant numbers or names. 

``` r

EyEduPlotHeat(participant.nr.list = c(1,2,3,4,5), trial.id = 13, alpha.var = 0.7)

### OR

EyEduPlotHeat(participant.name.list = c("Danvers", "Jones", "Parker", "Prince"),
              trial.id = 13,
              alpha.var = 0.7)

```
![](README_files/figure-markdown_github/eyEdu-heat-plot.png)

### Table of content

-   [Installing eyEdu on your computer](#installing-eyedu-on-your-computer)
-   [Examples for reading experiment](#examples-for-reading-experiment)
    -   [Trial plots reading](#trial-plots-reading)
    -   [Diagnostic plots](#diagnostic-plots)
    -   [Area of interest definitions](#area-of-interest-definitions)
    -   [Getting statistics for fixations and areas of interest](#getting-statistics-for-fixations-and-areas-of-interest)
-   [Examples for scene perception experiment](#examples-for-scene-perception-experiment)
    -   [Trial plots scene](#trial-plots-scene)
    -   [Free-hand rectangular area of interest definition](#free-hand-rectangular-area-of-interest-definition)
-   [List of functions](#list-of-functions)
    -   [Downloading example data](#downloading-example-data)
    -   [Importing raw data](#importing-raw-data)
    -   [Low pass filtering](#low-pass-filtering)
    -   [Fixation detection](#fixation-detection)
    -   [Free-hand drawing of areas of interest](#free-hand-drawing-of-areas-of-interest)
    -   [Importing pre-defined areas of interest files](#importing-pre-defined-areas-of-interest-files)
    -   [Automatic definition for areas of interest around words](#automatic-definition-for-areas-of-interest-around-words)
    -   [Exporting aois to text files](#exporting-aois-to-text-files)
    -   [Importing word aoi labels](#importing-word-aoi-labels)
    -   [Trial plots](#trial-plots)
    -   [Diagnostic plots](#diagnostic-plots-1)
    -   [Batch plot trials](#batch-plot-trials)
    -   [Batch plot diagnostics](#batch-plot-diagnostics)
    -   [Assigning fixations to areas of interest](#assigning-fixations-to-areas-of-interest)
    -   [Getting a fixation summary](#getting-a-fixation-summary)

Installing eyEdu on your computer
---------------------------------

EyEdu is not on CRAN, but the development version can be installed from GitHub using the devtools package. To set up eyEdu, copy this bit of code and run in in R Studio:

``` r
  if (!require("devtools")) {
  install.packages("devtools", dependencies = TRUE)}
  devtools::install_github("SebastianKorinth/eyEdu") 
```
You might get the warning that you have to install Rtools, which is a software that builts binaries for your operating system.
For Windows, for example, please go to http://cran.r-project.org/bin/windows/Rtools/, where you can download and install Rtools.

``` r
 library(eyEdu)
```
Linux users: Installing the devtools package is a bit more challenging. You might try the guide provided here:
https://www.digitalocean.com/community/tutorials/how-to-install-r-packages-using-devtools-on-ubuntu-18-04


Examples for reading experiment
-------------------------------

### Trial plots reading

The plot functions allow to show, to hide or to adjust the color for several eye-tracking parameters (right and left eye, fixations, filtered raw data etc.)

``` r
EyEduPlotTrial(participant.name = "Rosa", 
               trial.nr = 1,
               fix.color = "red",
               show.filtered = FALSE,
               sample.color.r = NA,
               sample.color.l = NA,
               sample.color = "blueviolet")
```

![](README_files/figure-markdown_github/eyEdu-trial-plot-a-1.png)

### Diagnostic plots

In order to check the quality of fixation detection in reading experiments - in which the primary movement direction would be on a horizontal line - it is informative to plot the x-position of raw data samples (black line) over a short period of time (e.g., 2500 ms) superimposed by grey shaded areas indicating periods defined as fixations.

``` r
EyEduPlotDiagnostics(participant.name = "Rosa",
                     trial.nr = 1,
                     sample.length = 2500, 
                     show.filtered = TRUE)
```

![](README_files/figure-markdown_github/eyEdu-diagnostic-plot-1.png)

### Area of interest definitions

There are several ways we can define areas of interest (aoi):
a) We might predefine them (i.e., x-y-positions of upper left and lower right corner) and save them in text files. These files can then be imported into the *eyEdu\_data.Rda* file using the [EyEduImportAoIs() function](#importing-pre-defined-areas-of-interest-files)
b) We might draw them free-hand using the [EyEduShinyAoiRectangle() function](#free-hand-drawing-of-areas-of-interest) and import these files into the *eyEdu\_data.Rda* file using the [EyEduImportAoIs() function](#importing-pre-defined-areas-of-interest-files)
c) Or, we might use some magic. The plot below shows the results of the automatic routine implemented in eyEdu that searches for areas of interest around words called [EyEduDefineWordAois()](#automatic-definition-for-areas-of-interest-around-words)

![](README_files/figure-markdown_github/eyEdu-aoi-plot-1.png)

### Getting statistics for fixations and areas of interest

So if we run [fixation detection](#fixation-detection) and define areas of interest using one of the [three options](#area-of-interest-definitions) and maybe also [add some labels to our word aois](#importing-word-aoi-labels) we'll get nice summaries about, which words were fixatated for how often and for how long.

| aoi.label   |  fix.duration|  fix.pos.x|  fix.pos.y|  fixation.index|  trial.index| stimulus.id |
|:------------|-------------:|----------:|----------:|---------------:|------------:|:------------|
| Although    |           250|   110.9472|   508.2146|               1|            1| 5           |
| Although    |           217|   156.0987|   500.5355|               2|            1| 5           |
| Although    |           199|   136.9149|   516.3870|               3|            1| 5           |
| Although    |           416|   138.1482|   511.3717|               4|            1| 5           |
| I           |           316|   202.2452|   512.7392|               5|            1| 5           |
| really      |           133|   262.2427|   512.8373|               6|            1| 5           |
| Although    |           200|   156.3023|   516.0087|               7|            1| 5           |
| really      |           184|   226.8766|   511.5661|               8|            1| 5           |
| NA          |           166|   291.2547|   512.1679|               9|            1| 5           |
| hated       |           199|   350.0094|   516.4874|              10|            1| 5           |
| mathematics |           234|   416.4178|   510.0621|              11|            1| 5           |
| in          |           216|   517.4159|   510.5837|              12|            1| 5           |
| became      |           200|   638.4027|   515.6502|              13|            1| 5           |
| decent      |           183|   755.2209|   505.0073|              14|            1| 5           |
| NA          |           133|   730.9476|   526.6870|              15|            1| 5           |

### Examples for scene perception experiment

### Trial plots scene

``` r
EyEduPlotTrial(participant.nr = 2, 
               trial.nr = 1,
               fix.color = "green",
               show.filtered = FALSE,
               sample.color.r = "red", # Red for right eye
               sample.color.l = "blue", # bLue for left eye
               sample.color = NA)
```

![](README_files/figure-markdown_github/eyEdu-trial-plot-scene-1.png)

### Free-hand rectangular area of interest definition

Especially for scene perception experiments the free-hand drawing of aoi might come in handy. Below a screenshot of the [shiny app](https://github.com/SebastianKorinth/ShinyAoEyeR/):

![](README_files/figure-markdown_github/shiny_screenshot.png)

List of functions:
------------------

### Downloading example data

``` r
EyEduGetExamples() 
# Example 
EyEduGetExamples(experiment.type = "reading") 
```

EyEduGetExamples() is a convenience function to download example data and experiments created with [OpenSesame](https://osdoc.cogsci.nl/) and the [PyGaze plugin](http://www.pygaze.org/). They might serve as templates for your own experiment. Currently, there are only two options available to set for the argument *experiment.type*, which is either *"reading"* or *"search"* (scene perception). The function will download the experiment and data into your current working directory.

### Importing raw data

``` r
EyEduImportEyetribeData() 
EyEduImportGazepointData()
# Example
EyEduImportEyetribeData(poi.start = "start_trial", 
                   poi.end = "response_time_key_finish_reading")
```

EyEduImportEyetribeData() imports raw data, that is, tsv-files recorded using a setup of [EyeTribe](http://theeyetribe.com/theeyetribe.com/about/index.html), [OpenSesame](https://osdoc.cogsci.nl/) and [PyGaze](http://www.pygaze.org/). The functions reads the files for all participants, separates eye movement data from message information, extracts relevant information (e.g., screen dimensions, sample rate etc.) and adds this to one structured file called eyEdu\_data.Rda, which is saved in the same folder as the raw data.
Currently, there are two arguments that can be changed, that is, *poi.start* and *poi.end*. Both arguments denote the messages setting the limits for periods of interest (poi). The default setting - leaving these arguments undefined - is "start\_trial" and "stop\_trial", which imports complete trials.
EyEduImportGazepointData() provides the same function for data collected using a [GazePoint](https://www.gazept.com/) setup.

*Note*: The variable raw.data.path pointing to the folder containing the raw data must currently be defined BEFORE calling the import function:

``` r
# Example path definition to raw example data downloaded into the current working directory
raw.data.path <- paste(getwd(),"/exampleDataSearchExperiment-master/", sep = "")
```

### Low pass filtering

``` r
EyEduLowPassFilter()
# Example 
EyEduLowPassFilter(filter.settings = (rep(1/3, 3))
```

EyEduLowPassFilter(): The idea to low-pass filter data that were recorded with a very low sampling rate (max. 60 Hz with EyeTribe) might sound superfluous. However, carefully applied, it might - for very noisy data - improve the chances to run a meaningful fixation detection. The default *filter.settings* are set to a moving average over three samples *(rep(1/3, 3)*, but can obviously be changed.

### Fixation detection

``` r
EyEduDetectFixationsIDT()
# Example
EyEduDetectFixationsIDT(dispersion.var = 90,
                        duration.var = 6,
                        use.filtered = FALSE,
                        participant.list = c("Rosa", "Friedrich"))
```

EyEduDetectFixationsIDT() uses the [emov package](https://cran.r-project.org/web/packages/emov/README.html) by Simon Schwab and the I-DT algorithm (Salvucci & Goldberg, 2000), which uses dispersion limits to distinguish between fixations and saccades. The following arguments must be provided:
- *dispersion.var* = maximal dispersion allowed (in pixels)
- *duration.var* = minimal fixation duration allowed in number of samples, e.g., 6 samples at 60 Hz results in 6 x 16.67 ms = 100 ms)

Optional arguments are, whether fixation detection should be run on raw (default) or on [low-pass-filtered data](#low-pass-filtering)
- *use.filtered* = TRUE or FALSE

And whether fixation detection - with a given set of parameters (for dispersion, duration and filtering), should be conducted for all participants (default) or just a subset defined in a
- *participant.list* (either participant names or numbers)

### Free-hand drawing of areas of interest

Alternatively see the stand-alone app [ShinyAoEyeR](https://github.com/SebastianKorinth/ShinyAoEyeR/)

``` r
scale.var <- 0.66
EyEduShinyAoiRectangle()
```

EyEduShinyAoiRectangle() starts a shiny app that lets you choose trial images from a drop-down list. For each image, you can draw free-hand rectangular areas of interest, give them a aoi-label and save this set of aois to text files that can then be imported into the eyEdu\_data.Rda data file using the function [EyEduImportAoIs()](#importing-pre-defined-areas-of-interest-files). The variable *scale.var* defines the relative size at which the trial image will be shown in the app. With *scale.var = 1* the image will be presented at its original size and resolution, which might be too large for some monitors.

### Importing pre-defined areas of interest files

``` r
EyEduImportAoIs()
# Example
EyEduImportAoIs(append.aois = FALSE,
                delete.existing.aois = TRUE ,
                screen.align.x = 1024,
                screen.align.y = 768)
```

EyEduImportAoIs() imports text files with pre-defined aoi definitions (x and y positions of the upper left and the lower right corner as well as aoi labels) that should be stored in a folder called "aoiFiles" within the raw data path. The following arguments can be set:
- *append.aois = TRUE or FALSE* whether the imported aois should be added to already existing aoi definitions in the current eyEdu\_data.Rda file
- *delete.existing.aois = TRUE or FALSE* whether existing aoi definitions should be removed before additional aois are imported.
- *screen.align.x* and/or *screen.align.y* lets you adjust aoi definitions that you might have created for images with dimensions smaller than the screen used in the experiment.

As an example: Aoi definitions were made based on an image with the dimension 1024 x 768. If this image was presented with its **original resolution at the center position** of a screen with a resolution of 1920 x 1080, the upper left corner of the image would not correspond to the position 0,0 anymore but to 448,156 on the screen. This is obviously important to match gaze positions on the screen with aoi positions.

### Automatic definition for areas of interest around words

``` r
EyEduDefineWordAois()
# Example
EyEduDefineWordAois(line.margin = 90,
                    character.space.width = 10,
                    inter.word.adjust = 5,
                    sparse.aoi.definition = TRUE)
```

Obviously only suitable in experiments, where texts were presented: Images of texts (e.g., screenshots recorded in the reading example) are segmented into areas of interest representing single words. Values for the following arguments must be provided:
- *line.margin* = the number of pixels above and below a text line. Try to avoid aoi-overlaps between lines in multi-line text presentations.
- *character.space.width* = average number of pixels characterizing a single character width
- *inter.word.adjust* = spaces between words should cover on average the same pixel width as character width, but can be adjusted using this parameter
- *sparse.aoi.definition* = TRUE or FALSE This argument has been added to avoid repeated processing of text images that are in fact identical. Namely, the file naming convention for screen shots in the example experiments follows the convention: participant number\_trial index\_stimulus ID.png (e.g., 2\_50\_44.png). This convention has been implemented - for whenever this might be important - individual screen shots for each and every participant can be created. With *sparse.aoi.definition* set to TRUE, the function will run for a restricted set of images, in which each stimulus ID will appear exactly once.

### Exporting aois to text files

``` r
EyEduExportAoIs()
```

With the EyEduExportAoIs() function aoi definitions - created for instance using the [function that segments text images to find aois around words](#automatic-definition-for-areas-of-interest-around-words) - can be exported into text files. These files will be saved in the folder "aoiFiles" located in the raw data path.

### Importing word aoi labels

``` r
EyEduImportWordAoiLabels()
# Example 
EyEduImportWordAoiLabels(extra.aoi = "end_point" ,
                         sparse.aoi.definition = TRUE)
```

Again, probably only suitable for reading experiments: Labels for aois around each word of a sentence or paragraph can be taken from OpenSesame stimulus messages containing the text that was actually presented during a trial. For this purpose, the number of areas of interest and the number of words per text or sentence should not differ otherwise causing an error message. For cases in which an additional area of interest - such as a fixation point, at which participants have to look to indicate that they finished reading a sentence - an extra aoi label can be defined.

### Trial plots

``` r
EyEduPlotTrial()
# Example
EyEduPlotTrial(participant.name = "Rosa", #alternatively the participant.nr = 2 can be provided
               trial.nr = 2,
               aoi.color = "black",
               fix.color = "yellow",
               sample.color.r = NA,
               sample.color.l = NA,
               sample.color = "red",
               show.filtered = FALSE,
               sparse.aoi.definition = TRUE,
               aoi.names.screenshot = TRUE)
```

The function EyEduPlotTrial() allows the visualization of single trials. Two arguments must be provided, that is, *participant.name* (alternatively *participant.nr*) and *trial.nr*. Additional arguments allow changing the color for each element of the plot (e.g., samples for left or right eye, fixations, areas of interest, background image etc.). By setting a color argument of an element to *NA* it will be hidden in the plot.
The argument *show.filtered* set to *TRUE* will display the samples after [low-pass filtering](#low-pass-filtering). For an explanation of *sparse.aoi.definition* see the last bullet point [here](#automatic-definition-for-areas-of-interest-around-words). The argument *aoi.names.screenshot* defines whether the matching of trials to background images will be based on the screenshot naming convention implemented in the OpenSesame example experiments (i.e., "participant number\_trail number\_stimulus id.png").

### Diagnostic plots

``` r
EyEduPlotDiagnostics()
# Example
EyEduPlotDiagnostics(participant.nr = 2, # alternatively participant.name = "Rosa"
                     trial.nr = 3,
                     sample.length = 2500,
                     show.filtered = FALSE)
```

EyEduPlotDiagnostics() provides a convenient way to [visually inspect whether fixation detection led to meaningful results](#diagnostic-plots) by plotting the x-position of raw data samples (black line) over a short period of time (defined in milliseconds using the argument *sample.length*) superimposed by grey shaded areas indicating periods defined as fixations. This function might only be useful in reading experiments, in which the primary movement direction would be on a horizontal axis
Two arguments, that is, for which participant (*participant.name* or *participant.nr*) and for which trial (*trial.nr*) the plot should be created are mandatory.

### Batch plot trials

``` r
EyEduBatchPlotTrials()
# Example
EyEduBatchPlotTrials(participant.nr.list = c(3,6) ,
                     image.width = 1000,
                     image.height = 700,
                     sparse.aoi.definition = TRUE,
                     aoi.names.screenshot = TRUE,
                     aoi.color = "black",
                     fix.color = "red",
                     sample.color.r = NA,
                     sample.color.l = NA,
                     sample.color = "blue",
                     show.filtered = FALSE)
```

The function EyEduBatchPlotTrials() creates png-images of plots for each trial of one, some or all participants defined in the argument *participant.nr.list*. All arguments, that can be adjusted in the [EyEduTrialPlot() function](#trial-plots) can be used as well. The arguments *image.width* and *image.height* define the dimensions in pixels of the png-images. For each participant a separate folder containing all her/his trial images will be created.
This function might be useful, if visual inspection of many trials is needed and the tedious definition for each trial or participant in [EyEduPlotTrial()](#trial-plots) would take too long.

### Batch plot diagnostics

``` r
EyEduBatchPlotDiagnostics()
# Example
EyEduBatchPlotDiagnostics(participant.nr.list = c(1,3),
                          image.width = 1000,
                          image.height = 700,
                          sample.length = 2500,
                          show.filtered = FALSE)
```

The same rationale as described for [EyEduBatchPlotTrials()](#batch-plot-trials) applies also for EyEduBatchPlotDiagnostics().

### Assigning fixations to areas of interest

``` r
EyEduAssignFixationsAois()
# Example
EyEduAssignFixationsAois(sparse.aoi.definition = ,
                         aoi.names.screenshot = )
```

After areas of interest were either [imported](#importing-pre-defined-areas-of-interest-files) or [automatically defined](#automatic-definition-for-areas-of-interest-around-words) and optionally [labels were added to areas of interest](#importing-word-aoi-labels), fixations can be assigned to these aois. Namely, EyEduAssignFixationsAois() checks for each fixation whether and into which area of interest a fixation belongs and adds this information to the fixation section in the eyEdu\_data.Rda file.

### Getting a fixation summary

``` r
EyEduGetFixationSummary()
```

EyEduGetFixationSummary() extracts fixation information and if [assigned to areas of interest](#assigning-fixations-to-areas-of-interest) also the corresponding aoi information for all participants and trials into one flat data frame *fixation\_summary.Rda*, which is most convenient to perform further statistical analyses.
