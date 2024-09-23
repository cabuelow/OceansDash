# Calculate area and protected area for coral reef

# Data descriptions:
# Name: Allen Coral Atlas (ACA) - Geomorphic Zonation and Benthic Habitat - v2.0
# Resolution: 5m
# Year: Composite of satellite images from 2018 - 2020
# Source: https://developers.google.com/earth-engine/datasets/catalog/ACA_reef_habitat_v2_0

# load library
library(tidyverse)
library(sf)
library(terra)
library(exactextractr)

# set sf to not use S2
sf_use_s2(FALSE)

# set terra's temporary folder
# Replace the path in quotes with path to a temporary folder in your computer
temp <- "data-raw/process-indicators/data-downloaded/temp"
terraOptions(tempdir = temp)

## read coral raster file

# read 5m resolution data as raster, replace with path to new data if needed.
fils <- list.files("data-raw/process-indicators/data-downloaded/effective-protection/global-coral-reefs-cell-reports-sub/",
                   full.names = TRUE, pattern = "_5m")

coral_5m_rast <- lapply(fils, rast)
names(coral_5m_rast)

# read country layer
cty <- vect('data-raw/process-indicators/data-downloaded/targeted_countries_eez_land.gpkg')
# exclude countries that have no coral
cty <- cty[!cty$UNION %in% c("Chile", "Alaska", "Peru", "Ecuador"),]

# function to extract coral area from 5m resolution raster (see code at bottom for 1km extraction)
getvalue <- function(x, y) { # x is country spatVector, y is list of raster files

  df <- data.frame(UNION = NA, area = NA)

  for (i in 1:nrow(x)) {

    x_i <- x[i,]

    index <- grep(x_i$UNION, sapply(y, sources))

    rast_i <- y[index]

    results <- list()

    for (j in 1:length(rast_i)) {
      rast_j <- rast_i[[j]]
      cell <- cellSize(rast_j, unit = "ha", mask = TRUE, overwrite = TRUE, todisk = TRUE, filename = "data-raw/process-indicators/data-downloaded/temp/c_cell.tif")
      area <- exact_extract(cell, st_as_sf((x_i)), "sum", max_cells_in_memory = 3e+08)

      results[[j]] <- area
    }
    df[i,1] <- x_i$UNION
    df[i,2] <- sum(unlist(results), na.rm = TRUE)
  }

  return(df)
}

coral_area <- getvalue(cty, coral_5m_rast)
colnames(coral_area)[2] <- "coral_2018_20_ha"


## get protected area

# read countries' pa layer
cty_pa <- vect('data-raw/process-indicators/data-downloaded/effective-protection/selected_countries_protected_area.gpkg')
# exclude countries that have no coral
cty_pa <- cty_pa[!cty_pa$UNION %in% c("Chile", "Alaska", "Peru", "Ecuador"),]

# get area of protected salt marsh
coral_pa_area <- getvalue(cty_pa, coral_5m_rast)
colnames(coral_pa_area)[2] <- "coral_pa_2018_20_ha"

## calculate percentage protected
coral <- left_join(coral_area, coral_pa_area, by = "UNION") %>%
  mutate(across(2:3, ~ case_when(.x %in% NA ~ 0, .default = .x))) %>%
  mutate(coral_pa_percentage = coral_pa_2018_20_ha / coral_2018_20_ha * 100) %>%
  mutate(across(4, ~ case_when(.x %in% NaN ~ NA, .default = .x)))

## validate data
coral_dbf <- read.csv("data-raw/process-indicators/data-downloaded/effective-protection/coral_dbf_data.csv")
coral_dbf <- left_join(coral, coral_dbf, by = "UNION")
coral_dbf

## save data
write.csv(coral, 'data-raw/process-indicators/data-downloaded/effective-protection/coral_protection.csv', row.names = FALSE)


### End of main code ###

# ## Old code to process data using 1km resolution ####
#
# # read 1km resolution data
# fils <- list.files("data/global-coral-reefs-cell-reports-sub/",
#                    full.names = TRUE, pattern = "1km")
#
# coral_1km_rast <- lapply(fils, rast)
#
# # function to extract tiles' area from 1km resolution raster
# getvalue <- function(x, y) { # x is spatVector, y is list of raster files
#
#   # get extent of tif for intersecting with cty
#   extent <- sapply(y, ext) # extract extent
#   ext_vect <- sapply(extent, vect, crs = crs(x)) # convert extent to a list of SpatVector
#   names(ext_vect) <- 1:length(y)# naming list by using raster list sequence number
#
#   df <- data.frame(UNION = NA, area = NA)
#
#   for (i in 1:nrow(x)) {
#
#     x_i <- x[i,]
#
#     # to generate an index for rast files that intersect with x_i
#     test <- ext_vect[sapply(ext_vect, is.related, x_i, relation = "intersects") == TRUE]
#     index <- as.numeric(names(test))
#     # select rast
#     if (length(test) > 0) {
#       rast_i <- vrt(fils[index], paste0(temp, "/coral.vrt"), overwrite = T) # select and merge if multiple
#       rast_i <- rast_i$coral_3 # select coral extent layer
#
#       rast_mask <- crop(rast_i, x_i, mask = TRUE) %>%
#         subst(., 0, NA)
#
#       if (!is.na(minmax(rast_mask)["max",])) {
#
#         cell <- cellSize(rast_mask, unit = "ha", mask = TRUE, overwrite = TRUE)
#
#         # exactextractr
#         a <- exact_extract(cell, st_as_sf(x_i))[[1]]
#         area <- sum(a$value * a$coverage_fraction, na.rm = TRUE)
#
#         df[i,1] <- x_i$UNION
#         df[i,2] <- area
#       }else{
#         df[i,1] <- x_i$UNION
#         df[i,2] <- NA
#       }
#     }
#   }
#   return(df)
# }
#
# coral_area <- getvalue(cty, coral_1km_rast)
# colnames(coral_area)[2] <- "coral_2018_20_ha"
