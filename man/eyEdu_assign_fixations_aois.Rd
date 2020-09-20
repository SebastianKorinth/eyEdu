\name{EyEduAssignFixationsAois}
\alias{EyEduAssignFixationsAois}

\title{
Assigning fixations to areas of interest
}
\description{

After areas of interest were either imported or automatically defined and (optionally) labels were added to areas of interest, fixations can be assigned to these aois. Namely, EyEduAssignFixationsAois() checks for each fixation whether and into which area of interest a fixation belongs and adds this information to the fixation section in the eyEdu_data.Rda file.
}
\usage{
EyEduAssignFixationsAois(sparse.aoi.definition = ...,
                         aoi.names.screenshot = ...)
}

\arguments{
  \item{"..."}{
sparse.aoi.definition = ...,  TRUE or FALSE
aoi.names.screenshot = ..., TRUE or FALSE

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

Sebastian Korinth
}

\note{

}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
EyEduAssignFixationsAois(sparse.aoi.definition = TRUE,
                         aoi.names.screenshot = TRUE)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
