# get targeted countries' EEZ and land polygon

library(tidyverse)
library(sf)

# read EEZ_land shapefile
# replace path in quote to path of your downloaded eez_land shapefile if needed
eez <- st_read("data-raw/process-indicators/data-downloaded/effective-protection/EEZ_land_union_v3_202003/EEZ_Land_v3_202030.shp")

# names of targeted countries
country <- c("Alaska", "Mexico", "Colombia", "Ecuador", "Peru", 'Chile',
             'Madagascar', 'Mozambique', 'Tanzania', 'Papua New Guinea',
             'Indonesia', 'Fiji', 'Solomon Islands')

# select targeted countries
eez_cty <- eez[eez$UNION %in% country,]

# save file
st_write(eez_cty, 'data-raw/process-indicators/data-downloaded/effective-protection/targeted_countries_eez_land.gpkg', append = FALSE)
