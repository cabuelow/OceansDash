# 1. calculate percentage of mangrove area protected for each country
# 2. calculate percentage of total carbon protected in mangrove for each country

# Data descriptions:
# Name: Global Mangrove Watch (1996 - 2020) Version 3.0 Dataset
# Resolution: 25m
# Year: 1996 - 2020
# Source: https://zenodo.org/records/6894273

library(tidyverse)
library(wdpar)
library(sf)

# set sf to not use S2
sf_use_s2(FALSE)

## calculate total mangrove area
# read country layer
cty <- st_read('data-raw/process-indicators/data-downloaded/effective-protection/targeted_countries_eez_land.gpkg')

# read GMW 2020 mangrove extent, replace with path to new data if needed.
gmw <- st_read('data-raw/process-indicators/data-downloaded/effective-protection/GMW_v3/gmw_v3_2020_vec/gmw_v3_2020_vec.shp')

# get mangrove area for countries
mang <- st_intersection(cty, gmw) %>%
  aggregate(., list(.$UNION), FUN = first) %>%
  st_make_valid()

mang$mangrove_2020_ha <- as.numeric(st_area(mang)/10000)

## calculate percentage of protected mangrove area
# read wdpa
pa <- st_read('data-raw/process-indicators/data-downloaded/effective-protection/wdpa_selected_countries.gpkg')

# protected mangrove
mang_pa <- st_intersection(mang, pa) %>%
  aggregate(., list(.$UNION), FUN = first) %>%
  st_make_valid()

mang_pa$mangrove_pa_2020_ha <- as.numeric(st_area(mang_pa)/10000)

dat <- st_drop_geometry(select(cty, c(UNION))) %>%
  left_join(., st_drop_geometry(select(mang, c(UNION, mangrove_ha))), by = "UNION") %>%
  left_join(., st_drop_geometry(select(mang_pa, c(UNION, mangrove_protected_ha))),
            by = "UNION") %>%
  mutate(across(2:3, ~ case_when(.x %in% NA ~ 0, .default = .x))) %>%
  mutate(mangrove_pa_percentage = mangrove_pa_2020_ha / mangrove_2020_ha *100) %>%
  mutate(across(4, ~ case_when(.x %in% NaN ~ NA, .default = .x)))

write.csv(dat, 'data-raw/process-indicators/data-downloaded/effective-protection/mangrove_protection.csv', row.names = FALSE)

##=== End of code ===##

# ## Cross check GMW data (slightly smaller area than GMWv3)
# gmw_dat <- readxl::read_xlsx("data/GMW_v3/gmw_v3_country_statistics_ha.xlsx",
#                              col_names = TRUE)
# gmw_dat <- filter(gmw_dat, gmw_dat$Name %in% cty$UNION) %>%
#   select(c(Name, `2020`)) %>%
#   rename("gmw2020" = "2020")
#
# check <- left_join(dat, gmw_dat, by = join_by(UNION == Name)) %>%
#   select(c(1:2, 5)) %>%
#   mutate(diff = mangrove_2020_ha - gmw2020)
#
# check
