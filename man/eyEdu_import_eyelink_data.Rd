\name{EyEduImportEyeLinkData}
\alias{EyEduImportEyeLinkData}

\title{
Import function for EyeLink data (previously converted into ascii format)
}
\description{
This is an experimental version (lots of ugly patches) that allows an import of EyeLink data, which were converted into ascii format before (see EyEduEdf2asc).

}
\usage{
EyEduImportEyeLinkData(poi.start = ...,
                        poi.end = ...,
                        asc.path = ...,
                        message.dict = ...,
                        remove.outliers = ...,
                        eye.sides = ...)

}

\arguments{
  \item{"poi.start"}{character string, message that denotes the beginning of a period of interest (poi)}
  
  \item{"poi.end"}{character string, message that denotes the end of a period of interest}
  
  \item{"message.dict"}{list, instead of a single period of insterest defined by "poi.start" "poi.end", several pois can be defined per trial. Attention, pois cannot overlap! For details on how to format the message.dict see the details section below.}

  \item{"remove.outliers"}{logical, if true sample values smaller than 0 will be recoded into NAs }
  
  \item{"eye.sides"}{character string, "R" for right eye, "L" for left eye, "B" for both eyes}

}

\details{
%%  ~~ If necessary, more details than the description above ~~
A message dictionary that allows several periods of interest per trial should provide first a label for the whole trial (e.g., "trial" followed by a start and a stop message defining the whole trial period). The trial can be further subdivided into shorter pois. Again the user will have to provide a label as well as start and stop messages per poi.

Example:
my.messages <- list(trial = c("start_trial","stop_trial"),
                    sentence = c("start_sentence","stop_sentence"),
                    question = c("start_question", "stop_question"))


}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~

}
\author{

Sebastian Korinth
}

\note{

}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{

# Example for an import of data that will be subdivided into periods of interest defined in "my.messages"
EyEduImportEyeLinkData(message.dict = my.messages,
                       asc.path = "edfData/",
                       remove.outliers = T)

                       
# Example for a single poi per trial defined by "poi.start" and "poi.end":
EyEduImportEyeLinkData(poi.start = "start_trial",
                       poi.end = "stop_trial"  
                       asc.path = "ascData/",
                       remove.outliers = TRUE,
                       eye.sides = "R")
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
