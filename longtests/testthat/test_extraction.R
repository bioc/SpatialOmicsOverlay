tifFile <- downloadMouseBrainImage()

testthat::test_that("Error when xml path doesn't exist",{
    #Spec 1. The function only works with valid ometiff file.  
    expect_error(xmlExtraction("fakeFilePath.ome.tiff"),
                 regexp = "ometiff file does not exist")
})

xml <- xmlExtraction(ometiff = tifFile, saveFile = TRUE)
xmlFile <- gsub(tifFile, pattern = "tiff", replacement = "xml")

testthat::test_that("returned list is correct",{
    #Spec 2. The function returns a valid list with the expected names.
    expect_true(class(xml) == "list")
    expect_true(length(xml) > 0)
    expect_true(all(names(xml) %in% c("Plate", "Screen", "Instrument", "Image", 
                                      "StructuredAnnotations", "ROI", ".attrs")))
    expect_true(length(which(names(xml) == "ROI")) > 1)
    
    #Spec 3. The function saves xml file in expected location, if desired.
    expect_true(file.exists(xmlFile))
})

unlink(xmlFile)

xml <- xmlExtraction(ometiff = tifFile, saveFile = FALSE)

testthat::test_that("no file saved",{
    #Spec 4. The function doesn't save file when not asked. 
    expect_false(file.exists(xmlFile))
})

fullSizeX <- 32768
fullSizeY <- 32768

scanMeta <- parseScanMetadata(xml)

testthat::test_that("correct image gets extracted", {
    #Spec 1. The function only extracts valid res layers.
    expect_error(imageExtraction(ometiff = tifFile, res = 9),
                 regexp = "valid res integers for this image must be between")
    #Spec 2. The function extracts expected res layer.
    for(i in 5:8){
        image <- imageExtraction(ometiff = tifFile, res = i, scanMeta = scanMeta)
        expect_true(class(image) == "magick-image")
        expect_true(image_info(image)$width == fullSizeX/2^(i-1))
        expect_true(image_info(image)$height == fullSizeY/2^(i-1))
    }
})

testthat::test_that("saved images are as expected",{
    #Spec 3. The function saves file in expected location and in correct & 
    #           valid fileType.
    #tiff
    image <- imageExtraction(ometiff = tifFile, res = 8, scanMeta = scanMeta, 
                             saveFile = T, fileType = "tiff")
    imageFile <- gsub(".ome.tiff", ".tiff", tifFile)
    expect_true(file.exists(imageFile))
    unlink(imageFile)
    
    #png
    image <- imageExtraction(ometiff = tifFile, res = 8, scanMeta = scanMeta, 
                             saveFile = T, fileType = "png")
    imageFile <- gsub(".ome.tiff", ".png", tifFile)
    expect_true(file.exists(imageFile))
    unlink(imageFile)
    
    #jpg
    image <- imageExtraction(ometiff = tifFile, res = 8, scanMeta = scanMeta, 
                             saveFile = T, fileType = "jpg")
    imageFile <- gsub(".ome.tiff", ".jpeg", tifFile)
    expect_true(file.exists(imageFile))
    unlink(imageFile)
    
    #jpeg
    image <- imageExtraction(ometiff = tifFile, res = 8, scanMeta = scanMeta, 
                             saveFile = T, fileType = "jpeg")
    imageFile <- gsub(".ome.tiff", ".jpeg", tifFile)
    expect_true(file.exists(imageFile))
    unlink(imageFile)
    
    expect_error(imageExtraction(ometiff = tifFile, res = 8, scanMeta = scanMeta, 
                                 saveFile = T, fileType = "fakeFile"),
                 regexp = "fileType not valid")
})

testthat::test_that("checkValidRes is correct",{
    #Spec 1. The function returns expected value.
    expect_true(checkValidRes(tifFile) == 8)
})    
