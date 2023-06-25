# link_downloader.R
# Kelsey Pukelis
# 2023-04-17

link <- 'https://www.mass.gov/lists/department-of-transitional-assistance-facts-and-figures'

page <- readLines(link)
head(page)

# use the FTP mirror link provided on the page
mirror <- "ftp://srtm.csi.cgiar.org/SRTM_v41/SRTM_Data_GeoTIFF/"

# read the file listing
pg <- readLines(mirror)

# take a look
head(pg)
## [1] "06-18-09  06:18AM               713075 srtm_01_02.zip"
## [2] "06-18-09  06:18AM               130923 srtm_01_07.zip"
## [3] "06-18-09  06:18AM               130196 srtm_01_12.zip"
## [4] "06-18-09  06:18AM               156642 srtm_01_15.zip"
## [5] "06-18-09  06:18AM               317244 srtm_01_16.zip"
## [6] "06-18-09  06:18AM               160847 srtm_01_17.zip"

# clean it up and make them URLs
fils <- sprintf("%s%s", mirror, sub("^.*srtm", "srtm", pg))

head(fils)
## [1] "ftp://srtm.csi.cgiar.org/SRTM_v41/SRTM_Data_GeoTIFF/srtm_01_02.zip"
## [2] "ftp://srtm.csi.cgiar.org/SRTM_v41/SRTM_Data_GeoTIFF/srtm_01_07.zip"
## [3] "ftp://srtm.csi.cgiar.org/SRTM_v41/SRTM_Data_GeoTIFF/srtm_01_12.zip"
## [4] "ftp://srtm.csi.cgiar.org/SRTM_v41/SRTM_Data_GeoTIFF/srtm_01_15.zip"
## [5] "ftp://srtm.csi.cgiar.org/SRTM_v41/SRTM_Data_GeoTIFF/srtm_01_16.zip"
## [6] "ftp://srtm.csi.cgiar.org/SRTM_v41/SRTM_Data_GeoTIFF/srtm_01_17.zip"

# test download
download.file(fils[1], basename(fils[1]))

# validate it worked before slamming the server (your job)

# do the rest whilst being kind to the mirror server
for (f in fils[-1]) {
  download.file(f, basename(f))
  Sys.sleep(5) # unless you have entitlement issues, space out the downloads by a few seconds
}