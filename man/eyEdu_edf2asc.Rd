\name{EyEduEdf2asc}
\alias{EyEduEdf2asc}

\title{
Converting SR-Research edf-files into asci file format
}
\description{
This is a convenience function that merely calls SR-Research's conversion program via R and not via the console or terminal. SR-Research's Eyelink Development Kit/API must be downloaded from their website (support forum) and installed. 

The path to where the software has been installed must be provided as a function argument (see usage below). 

}
\usage{
EyEduedf2asc(app.path = ..., 
             edf.path = ...,
             asc.path = ...,
             add.options = ...) 
}

\arguments{
  \item{"app.path"}{character string, providing the path to the directory where SR-Research's edf2asc program has been installed}
  
  \item{"edf.path"}{character string, providing the path to the directory, where the edf files are stored}
  
  \item{"asc.path"}{character string, providing the path to the directory, where the converted ascii files should be saved to}

  \item{"add.options"}{there is a long list of additional options that can be looked up at SR-Research's support forum (e.g., "-l" ouput data only for left eye)}

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
Link to the SR-Research Forum website. 

https://www.sr-support.com/

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

EyEduedf2asc(app.path = "/Applications/Eyelink/EDF_Access_API/Example/edf2asc", 
             edf.path = "exampleStudy/edfData/",
             asc.path = "exampleStudy/ascData/",
             add.options = "-input -y") 

The added option "-input" denotes that the output will contain samples.
The added option "-y" denotes that existing ascii-files will be overwritten.

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
