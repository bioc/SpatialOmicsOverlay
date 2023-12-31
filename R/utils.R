URL <- "https://external-soa-downloads-p-1.s3.us-west-2.amazonaws.com"
IMAGES <- "mu_brain_image_files.tar.gz"
IMAGEFILE <- "image_files/mu_brain_004.ome.tiff"

#' Print long string in more managable fashion
#' 
#' @description 
#' Print first and last n characters of string in this format: 
#' "### ... ### (x total char)" 
#'
#' @param x long string
#' @param bookend number of characters on either side to print
#' 
#' @return reformatted string
#' 
#' @examples 
#' 
#' start_string <- stringi::stri_rand_strings(n = 1, length = 250)
#' bookendStr(start_string, bookend = 6)
#' 
#' @export
bookendStr <- function(x, bookend = 8){
    if(!is(x,"character")){
        x <- as.character(x)
    }
    if(nchar(x) > bookend*2){
        x <- paste(substr(x = x, start = 1, stop = bookend), "...",
                   substr(x = x, start = nchar(x)-(bookend-1), stop = nchar(x)),
                   paste0("(", nchar(x), " total char)"))
    }
    
    return(x)
}

#' Read lab worksheet into dataframe of annotations 
#' 
#' @param lw lab worksheet file path
#' @param slideName name of slide 
#' 
#' @return df of ROI annotations
#' 
#' @examples 
#' 
#' muBrainLW <- system.file("extdata", "muBrain_LabWorksheet.txt", 
#'                          package = "SpatialOmicsOverlay")
#' 
#' muBrainLW <- readLabWorksheet(muBrainLW, slideName = "D5761 (3)")
#' 
#' @export
readLabWorksheet <- function(lw, slideName){
    if(!file.exists(lw)){
        stop("Lab worksheet path is invalid")
    }
    
    startLine <- grep(readLines(lw), pattern = "^Annotations")
    
    lw <- read.table(lw, header = TRUE, sep = "\t", skip = startLine, 
                     fill = TRUE)
    lw$ROILabel <- gsub("\\W", "", lw$roi)
    
    lw <- lw[lw$slide.name == slideName,]
    
    if(nrow(lw) == 0){
        stop("No ROIs match given slideName")
    }
    
    return(lw)
}


#' Download Mouse Brain OME-TIFF from NanoString's Spatial Organ Atlas
#' 
#' @details https://nanostring.com/products/geomx-digital-spatial-profiler/spatial-organ-atlas/mouse-brain/
#' 
#' @return mouse brain OME-TIFF
#'
#' @importFrom BiocFileCache bfcquery
#' @importFrom BiocFileCache bfcrpath
#' @importFrom BiocFileCache bfcadd
#' @importFrom BiocFileCache bfccache
#' @importFrom BiocFileCache bfcremove
#' 
#' @examples 
#' 
#' image <- downloadMouseBrainImage()
#' 
#' @export
downloadMouseBrainImage <- function(){
    fileURL <- paste(URL, IMAGES, sep = "/")
    
    bfc <- .get_cache()
    rid <- bfcquery(bfc, IMAGEFILE)$rid
    
    if (length(rid) == 0) {
        if(interactive()){
            continue <- readline(prompt = "This function will temporarily download a 13 GB tar file and keep a 4 GB OME-TIFF in BiocFileCache, should we continue? (y/n): ")
        }else{
            continue <- "y"
        }
        
        if(tolower(continue) %in% c("y", "yes", "true")){
            message("Downloading file")
            rid <- names(bfcadd(bfc, IMAGES, fileURL))
            
            message( "Untaring file" )
            untar(bfcrpath(bfc, rids = rid),
                  files = IMAGEFILE,
                  exdir = bfccache(bfc))
            
            bfcremove(x = bfc, rid)
            
            imageFile <- paste(bfccache(bfc), IMAGEFILE, sep = "/")
            
            rid <- names(bfcadd(bfc, rname = basename(IMAGEFILE), 
                                fpath = imageFile))
            
            unlink(dirname(imageFile), recursive = TRUE)
        }else{
            message("Mouse Brain file not downloaded, please provide your own NanoString GeoMx OME-TIFF to use this package")
        }
    }
    
    if(length(rid) >0){
        return(normalizePath(bfcrpath(bfc, rids=rid)))
    }
}

#' get BiocFileCache
#'
#' @importFrom tools R_user_dir
#' @importFrom BiocFileCache BiocFileCache
#' 
#' @return BioFileCache
#' 
#' @noRd
#' 
.get_cache <- function(){
    cache <- R_user_dir("SpatialOmicsOverlay", which="cache")
    
    return(BiocFileCache(cache))
}

