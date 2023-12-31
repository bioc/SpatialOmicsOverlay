% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/imageManipulation.R
\name{cropSamples}
\alias{cropSamples}
\title{Crop to zoom in on given ROIs}
\usage{
cropSamples(overlay, sampleIDs, buffer = 0.1, sampsOnly = TRUE)
}
\arguments{
\item{overlay}{SpatialOverlay object}

\item{sampleIDs}{sampleIDs of ROIs to keep in image}

\item{buffer}{percent of new image size to add to each edge as a buffer}

\item{sampsOnly}{should only ROIs with given sampleIDs be in image}
}
\value{
SpatialOverlay object
}
\description{
Crop to zoom in on given ROIs
}
\examples{

muBrain <- readRDS(unzip(system.file("extdata", "muBrainSubset_SpatialOverlay.zip", 
                                    package = "SpatialOmicsOverlay")))

image <- downloadMouseBrainImage()

muBrain <- addImageOmeTiff(overlay = muBrain, 
                           ometiff = image, res = 8)

samps <- sampNames(muBrain)

muBrainCrop <- suppressWarnings(cropSamples(overlay = muBrain, 
                                            sampleIDs = samps, 
                                            sampsOnly = TRUE))

plotSpatialOverlay(overlay = muBrainCrop, scaleBar = FALSE,
                   hiRes = TRUE, legend = FALSE)

}
