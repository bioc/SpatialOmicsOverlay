% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/imageManipulation.R
\name{changeColoringIntensity}
\alias{changeColoringIntensity}
\title{Update color intensities for changing to RGB image}
\usage{
changeColoringIntensity(overlay, minInten = NULL, maxInten = NULL, dye)
}
\arguments{
\item{overlay}{SpatialOverlay object}

\item{minInten}{value to change MinIntensity to; NULL indicates no change}

\item{maxInten}{value to change MaxIntensity to; NULL indicates no change}

\item{dye}{which dye to change color, can be from Dye or DisplayName column 
from fluor(overlay)}
}
\value{
SpatialOverlay object with updated fluor data
}
\description{
Update color intensities for changing to RGB image
}
\examples{

muBrain <- readRDS(unzip(system.file("extdata", "muBrainSubset_SpatialOverlay.zip", 
                                    package = "SpatialOmicsOverlay")))

image <- downloadMouseBrainImage()

muBrain <- add4ChannelImage(overlay = muBrain, 
                            ometiff = image, res = 8)

fluor(muBrain)

muBrain <- changeColoringIntensity(overlay = muBrain, 
                                   minInten = 500, 
                                   maxInten = 10000, 
                                   dye = "Cy5")

fluor(muBrain)

}
