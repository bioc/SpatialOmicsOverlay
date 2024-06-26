#' Read in \code{\linkS4class{SpatialOverlay}} from tiff file and annotations
#' 
#' @description Create an instance of class \code{\linkS4class{SpatialOverlay}} 
#' by reading data from OME-TIFF and annotation sheet.
#' 
#' @param ometiff path to OME-TIFF 
#' @param annots path to annotation file: can be labWorksheet, DA excel file, or 
#'                 delimted file
#' @param slideName name of slide
#' @param image should image be extracted from OME-TIFF
#' @param res resolution of image 
#'              1 = largest, higher number = smaller
#'              This value will affect the coordinates of the overlays. 
#'              res = 2, resolution is 1/2 the size as the raw image
#'              res = 3, resolution is 1/4 the size as the raw image
#'              res = 4, resolution is 1/8 the size as the raw image 
#'              resolution = 1/2^(res-1)   
#' @param saveFile should xml & image be saved, file is saved in working  
#'                     directory with same name as OME-TIFF 
#' @param outline returned coordinates only contain outlinearies, 
#'                   will not work for segmented ROIs
#' @param ... additional parameters for `readLabWorksheet` like `roiCol` and `slideCol`
#' @param segCol additional parameter for `annotMatching` if default search doesn't work. 
#'                For default search, set to NULL
#' 
#' @return \code{\linkS4class{SpatialOverlay}} of slide
#' 
#' @examples
#' 
#' muBrain_GxT <- readRDS(unzip(system.file("extdata", "muBrain_GxT.zip", 
#'                          package = "SpatialOmicsOverlay")))
#' 
#' image <- downloadMouseBrainImage()
#' 
#' muBrain <- readSpatialOverlay(ometiff = image, annots = muBrain_GxT[,1:5], 
#'                               slideName = "D5761 (3)", image = TRUE, res = 8, 
#'                               saveFile = FALSE, outline = FALSE)
#' 
#' @importFrom readxl read_xlsx
#' @importFrom data.table fread
#' @importFrom GeomxTools sData
#' 
#' @seealso \code{\link{SpatialOverlay-class}}
#' 
#' @export 
#' 

readSpatialOverlay <- function(ometiff, annots, slideName, image = FALSE, 
                               res = NULL, saveFile = FALSE, outline = TRUE, ...,
                               segCol = NULL){
    labWorksheet <- FALSE
    if(is(annots,"NanoStringGeoMxSet")){
        annots <- sData(annots)
        annots <- annots[annots$`slide name` == slideName,]
        
        if(nrow(annots) == 0){
            stop("No ROIs match given slideName")
        }
        
        annots$Sample_ID <- gsub(".dcc", "", rownames(annots))
        
        labWorksheet <- TRUE
        colnames(annots)[colnames(annots) == "roi"] <- "ROILabel"
    }else if(endsWith(tolower(annots), "_labworksheet.txt")){
        annots <- readLabWorksheet(lw = annots, slideName = slideName, ...)
        labWorksheet <- TRUE
    }else if(endsWith(annots, ".xlsx")){
        annots <- readxl::read_xlsx(annots, sheet = "SegmentProperties")
    }else{
        annots <- as.data.frame(data.table::fread(file = annots))
    }
    
    if(image == TRUE & is.null(res)){
        warning("No res was given so default res of 6 will be used")
        res <- 6
    }
    
    message("Extracting XML")
    xml <- xmlExtraction(ometiff = ometiff, saveFile = saveFile)
    
    message("Parsing XML - scan metadata")
    scan_metadata <- parseScanMetadata(omexml = xml)
    
    message("Parsing XML - overlay data")
    AOIattrs <- parseOverlayAttrs(omexml = xml, annots = annots, 
                                  labworksheet = labWorksheet, segCol = segCol)
    
    if(any(meta(AOIattrs)$Segmentation == "Segmented")){
        scan_metadata[["Segmentation"]] <- "Segmented"
    }else{
        scan_metadata[["Segmentation"]] <- "Geometric"
    }
    
    so <- SpatialOverlay(slideName = slideName, 
                         scanMetadata = scan_metadata, 
                         overlayData = AOIattrs, 
                         workflow = list(labWorksheet=labWorksheet,
                                         outline=outline,
                                         scaled=FALSE),
                         image = list(filePath = NULL,
                                      imagePointer = NULL,
                                      resolution = NULL))
    
    if(image == TRUE){
        message("Adding Image")
        so <- addImageOmeTiff(overlay = so, ometiff = ometiff, res = res, 
                              scanMeta = scan_metadata, saveFile = saveFile)
        so <- cropTissue(overlay = so)
    }else{
        message("Generating Coordinates")
        so <- createCoordFile(overlay = so, outline = outline)
    }
    
    return(so)
}

