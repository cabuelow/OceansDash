# To calculate tidal marsh area and protected area

# Data descriptions:
# Name: Global tidal marshes 2020 dataset
# Year: 2020
# Resolution: 10m
# Source: https://zenodo.org/records/8420753

library(tidyverse)
library(terra)
library(exactextractr)
library(sf)

# # change terra's temporary folder to store large temporary files
# # set this path to a folder in your computer if needed
# temp <- "e:/KC/temp" 
# terraOptions(tempdir = temp)

# set sf to not use S2
sf_use_s2(FALSE)

# read tidal marsh spatial data, replace with path to new data if needed.
fils <- list.files("data/tidal_marsh_v2_6/Final_Rasters/", 
                   full.names = TRUE, pattern = "_marsh_")

marsh_rast <- lapply(fils, rast)

## get tidal march area
# read country layer
cty <- vect('temp/targeted_countries_eez_land.gpkg')

# function to extract tiles' area 
getvalue <- function(x, y) { # x is spatVector, y is list of raster files 
  
  # get extent of tif for intersecting with cty
  extent <- sapply(y, ext) # extract extent
  ext_vect <- sapply(extent, vect, crs = crs(x)) # convert extent to a list of SpatVector
  names(ext_vect) <- 1:length(y)# naming list by using raster list sequence number
  
  dat <- data.frame(UNION = NA, area = NA)
  
  for (i in 1:nrow(x)) {
    
    x_i <- x[i,]
    
    # to generate an index for rast files that intersect with x_i
    test <- ext_vect[sapply(ext_vect, is.related, x_i, relation = "intersects") == TRUE]  
    index <- as.numeric(names(test))
    # select rast
    if (length(test) > 0) {
      
      rast_i <- y[index]
      
      results <- list()
      
      for (j in 1:length(rast_i)) {
        rast_j <- rast_i[[j]]
        cell <- cellSize(rast_j, unit = "ha", mask = TRUE, overwrite = TRUE, todisk = TRUE)
        area <- exact_extract(cell, st_as_sf((x_i)), "sum", max_cells_in_memory = 3e+08)
        
        results[[j]] <- area
      }
      
      dat[i,1] <- x_i$UNION
      dat[i,2] <- sum(unlist(results), na.rm = TRUE)
      
    }else{
      dat[i,1] <- x_i$UNION
      dat[i,2] <- NA
    }
  }
  return(dat)
}

marsh_area <- getvalue(cty, marsh_rast)
colnames(marsh_area)[2] <- "marsh_2020_ha"

## save data
dat <- read.csv('output/effective_protection.csv')

dat <- left_join(dat, marsh_area, by = "UNION")

write.csv(dat,'output/effective_protection.csv', rownames = FALSE)

## get protected area
# read wdpa layer
cty_pa <- vect('temp/selected_countries_protected_area.gpkg')

# get area of protected tidal marsh
marsh_pa <- getvalue(cty_pa, marsh_rast)
colnames(marsh_pa)[2] <- "marsh_pa_2020_ha"

## calculate percentage protected
marsh <- left_join(marsh_area, marsh_pa, by = "UNION") %>% 
  mutate(across(2:3, ~ case_when(.x %in% NA ~ 0, .default = .x))) %>%
  mutate(marsh_pa_percentage = marsh_pa_2020_ha / marsh_2020_ha) %>% 
  mutate(across(4, ~ case_when(.x %in% NaN ~ NA, .default = .x))) 


## save data
write.csv(marsh,'temp/marsh_protection.csv', row.names = FALSE)

##=== End of code ==##

# ## Cross check data (data not available for country with < 10km2 tidal marsh)
# table_S6 <- read.csv("data/tidal_marsh_v2_6/Table_S6.csv") %>% 
#   select(-3) %>% 
#   filter(., table_S6$ï..Country.or.Territory %in% cty$UNION)
# 
# check <- left_join(marsh, table_S6, by = join_by("UNION" == "ï..Country.or.Territory"))
