"
Title: Temperature to TIF

Author:   Tom Zeising
Project:  Master Thesis
_____________________________________________________________________________

What?   Translates Temperature HDF into TIF files.
        Files are saved in ~/01_thesis/04_dataset_generation/03_intermediate_data/04_precipitation/01_tif

Modules needed: - ncdf4  (package for netcdf manipulation)
                - gdalUtils (package to translate HDF to TIF)
                - rgdal  (package for geospatial analysis)
                - here
_____________________________________________________________________________
Possible Errors: - gdalUtils::gdal_translate or gdalUtils::get_subdatasets returns 
                   error => GDAL (32bit) must be installed in system! 
                 - After installation of Geo Da Software, gdalUtils refused to work
                   => deinstallation and using gdalUtils::gdal_setInstallation(rescan)
                      fixes the problem.

-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
Additional notes: (None)

_____________________________________________________________________________
"
## Preparation for relative paths ----
#setwd("E:/02_master/01_thesis/04_dataset_generation/01_code")
setwd('../')
getwd()

# Specify all needed packages and install if not already done ----
packages_needed <- c("ncdf4", "raster", "rgdal", "here","gdalUtils","maptools")                                      
not_installed <- packages_needed[!(packages_needed %in% installed.packages()[ , "Package"])]

install.packages("devtools")
devtools:::install_github("gearslaboratory/gdalUtils")

if(length(not_installed)) install.packages(not_installed)
print(paste(length(not_installed), "packages had to be installed."))
invisible(lapply(packages_needed, library, character.only = TRUE))

# Set relative paths and read in files ----
temp_data <- here("02_raw_data", "05_temperature")
shape_file <- here("02_raw_data", "00_shapefiles", "03_border_clipped", "_2_degrees_clipped.shp")
saving <- here("03_intermediate_data","05_temperature","01_tif", "01_raw_tif")
saving2 <- here("03_intermediate_data","05_temperature","01_tif")

sds <- gdalUtils::get_subdatasets("C:/Users/ECHO TECH/Desktop/R/tutorial/02_raw_data/05_temperature/file.hdf")
sds

files <- list.files(temp_data, pattern = "*.hdf$")
#files <- dir(pattern = ".hdf")
files

# Extract daytime temperature ----
filename_d <- substr(files,1,nchar(files)-4)
filename_d <- paste0(saving,"/temp_day_",filename_d, ".tif")
filename_d

files_use <- paste0(temp_data,"/",files)
files_use
i <- 1
for (i in 1:264){
  sds <- get_subdatasets(files_use[i])
  print(filename_d[i])
  gdal_translate(sds[1], dst_dataset = filename_d[i])
}

# Extract nighttime temperature ----
filename_n <- substr(files,1,nchar(files)-4)
filename_n <- paste0(saving,"/temp_night_",filename_n, ".tif")
filename_n
i <- 1
for (i in 1:264){
  sds <- get_subdatasets(files_use[i])
  print(filename_n[i])
  gdal_translate(sds[6], dst_dataset = filename_n[i])
}

# Clip and resample TIFs ----

# Read all necessary files
tif_files <- list.files(saving, pattern = "*.tif$")
poly <- readShapePoly(shape_file)


for (file in tif_files){
  
  file_n_path <- paste0(saving, "/", file)
  # Crop data to shapefile extent
  print("Creating raster file")
  r <- raster(file_n_path )
  e <- extent(poly) 
  print("Cropping raster data")
  r_cropped <- crop(r, e)
  
  # Up-sample raster for exact zonal statistics
  r_cropped <- disaggregate(r_cropped, fact=10, method = "")
  # Check dimensions
  dim(r_cropped)
  
  # Define file name for geoTIFFs
  filename <- substr(file,1,nchar(file)-4)
  print(filename)
  data_save <- paste0(saving2,"/",filename,"_cropped.tif")
  
  # Save raster as geoTIFF
  writeRaster(r_cropped, data_save, "GTiff", overwrite=TRUE)
}


