# Code to download coral reef extent data

# Coral extent are composite of satellite images from 2018 - 2020
# source https://developers.google.com/earth-engine/datasets/catalog/ACA_reef_habitat_v2_0

# load library
library(rgeedim)
library(terra)
library(sf)
library(tidyverse)

# authenticate access to Google Earth Engine via a registered account on GEE
gd_authenticate(auth_mode = "notebook")
gd_initialize()

# read targeted country polygons
cty <- st_read('data-raw/process-indicators/data-downloaded/effective-protection/targeted_countries_eez_land.gpkg')

# exclude countries that have no coral
cty <- cty[!cty$UNION %in% c("Chile", "Alaska", "Peru", "Ecuador"),]

# split Fiji into two features to avoid downloading issue for polygons crossing dateline
fji <- cty[cty$UNION == "Fiji",] %>%
  st_cast(., "POLYGON") %>%
  mutate(n = 1:n()) %>%
  mutate(UNION = paste(UNION, n, sep = "_")) %>%
  select(-ncol(.))

# join Fiji back to country shape file
cty <- filter(cty, !cty$UNION == "Fiji") %>%
  rbind(., fji)

# read country polygons as SpatVector
cty <- vect(cty)

## download data from GEE based on bounding box of country's polygon
for (i in 1:nrow(cty)) {
  # select 1 country
  cty_i <- cty[i,]
  # get bounding box
  bbox <- gd_bbox(cty_i)
  # download raster tiles and save to path
  gd_download(
    gd_image_from_id('ACA/reef_habitat/v2_0'), # replace this path if new data was available
    filename = paste0('data-raw/process-indicators/data-downloaded/effective-protection/global-coral-reefs-cell-reports-sub/', cty_i$UNION, '_5m.tif'),
    region = bbox,
    bands = list("reef_mask"), # download just reef extent layer
    dtype = "uint8",
    crs = "EPSG:4326",
    resampling = "bilinear",
    scale = 5, # scale=5: request ~5m resolution
    overwrite = TRUE,
    silent = FALSE,
    composite = FALSE
  )
}

#==== Code ends here ====#

# ## Test download using Guam as an example
# # create cropping bbox
# guam_bbox <- ext(144.5459130419339, 145.04441768060576, 13.207122370818427, 13.678610948044705)
# guam <- vect(guam_bbox, crs="+proj=longlat +datum=WGS84")
#
# # read downloaded Guam 5m raster
# x <- rast("data/global-coral-reefs-cell-reports-sub/guam.tif")
# # 5m raster was downloaded with "region = gd_bbox(guam)" in the download setting
#
# # read 1km raster file
# fils <- list.files("data/global-coral-reefs-cell-reports-sub/",
#                    full.names = TRUE, pattern = "1km")
# coral_1km_rast <- lapply(fils, rast)
#
# # crop raster to Guam bbox
# guam_coral_1km <- crop(coral_1km_rast[[1]], guam, mask = TRUE) %>%
#   subst(., 0, NA)
#
# guam_5m <- crop(x, guam, mask = TRUE)
#
# ## visualise resolution difference
# plot(guam_coral_1km)
# plot(guam_5m)

