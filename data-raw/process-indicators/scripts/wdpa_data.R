# get wdpa layer for targeted countries

library(tidyverse)
library(wdpar)
library(sf)

# set sf to not use S2 to avoid geometry errors with older spatial data files
sf_use_s2(FALSE)

# check what is the latest version of data available
wdpa_latest_version()

# Download latest wdpa data
pa <- wdpa_fetch("global", wait = TRUE, download_dir = "data-raw/process-indicators/data-downloaded/effective-protection/WDPA/")

## Filter pa that intersects with targeted countries and clean data
# read countries' EEZ file
cty <- st_read('data-raw/process-indicators/data-downloaded/targeted_countries_eez_land.gpkg')

# filter data and keep PA's that present as points
pa_cty <- filter(pa, lengths(st_intersects(pa, cty)) > 0 |
  st_geometry_type(pa) == "MULTIPOINT")

# clean data, remove overlapping
pa_cty <- wdpa_clean(pa_cty, geometry_precision = 10000)

# transform to 4326 and resolve dateline issues
pa_cty2 <- pa_cty%>%
  st_transform(., st_crs(cty)) %>%
  st_make_valid() %>%
  st_wrap_dateline() %>%
  st_make_valid()

# # save file
# st_write(pa_cty2, 'data-raw/process-indicators/data-downloaded/effective-protection/wdpa_selected_countries.gpkg', append = FALSE)

## Clip cleaned pa layer to country layer
cty_pa <- st_intersection(cty, pa_cty2) %>%
  aggregate(., list(.$UNION), FUN = first) %>%
  st_make_valid() %>%
  select(., -1)
# remove lines created during clipping
cty_pa<- st_collection_extract(cty_pa, "POLYGON") %>%
  aggregate(., list(.$UNION), FUN = dplyr::first) %>%
  select(., -1)

# save file
st_write(cty_pa, 'data-raw/process-indicators/data-downloaded/selected_countries_protected_area.gpkg', append = FALSE)

## create country non-pa polygons
cty_pa_u <- st_union(cty_pa)
cty_non_pa <- st_difference(cty, cty_pa_u)
  st_make_valid() %>%
  select(`UNION`)

# save file
st_write(cty_non_pa, "data-raw/process-indicators/data-downloaded/effective-protection/cty_non_pa.gpkg", append = FALSE)
