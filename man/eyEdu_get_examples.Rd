\name{EyEduGetExamples}
\alias{EyEduGetExamples}

\title{
Download Example Data for eyEdu
}
\description{

The function EyEduGetExamples() wil download a zip-file from github
containing example data files - and the openSesame-experiments used to
collect these data. The file will be unzipped and saved in the current
working directory.
}
\usage{
EyEduGetExamples(experiment.type = "...")
}

\arguments{
  \item{"..."}{
kind of eye-tracking experiment, either "reading" or "search"

}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
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

Sebastian Korinth & Dejan Draschkow
}
\note{
Check whether you have set your working directory properly. Example data will be
downloaded and unzipped into the current working directory - getwd().
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
EyEduGetExamples(experiment.type = "reading")

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
