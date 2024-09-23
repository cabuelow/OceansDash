# To calculate total carbon and protected carbon in salt marsh

# Data descriptions:
# Name:Global soil organic carbon in tidal marshes version 1
# Resolution: 30m
# Soil depth: 0-30cm; 30-100cm
# Year: 2020
# Unit: Mg C ha-1
# Source: https://zenodo.org/records/10940066

library(tidyverse)
library(terra)
library(sf)
library(exactextractr)

# set sf to not use S2
sf_use_s2(FALSE)

# set terra's temporary folder
#
temp <- "data-raw/process-indicators/data-downloaded/effective-protection/temp"
terraOptions(tempdir = temp)

# load function for extracting tiles' values
source("data-raw/process-indicators/scripts/functions.R")

# read country pa polygons
cty_pa <- vect('data-raw/process-indicators/data-downloaded/effective-protection/selected_countries_protected_area.gpkg')

# read country non-pa polygons
cty_non_pa <- vect("data-raw/process-indicators/data-downloaded/effective-protection/cty_non_pa.gpkg")

## calculate average soil organic carbon (SOC) 0-30cm
# read salt marsh SOC 0-30cm data, replace with path to new data if needed.
fils <- list.files("data-raw/process-indicators/data-downloaded/effective-protection/tidal_marsh_SOC-Maxwell-2024/pred0/pred0",
                   full.names = TRUE, pattern = "pred0")

soc0_rast <- lapply(fils, rast)

# extract average SOC in protected area
soc0_pa <- getvalue(cty_pa, soc0_rast) %>%
  pivot_longer(., cols = everything(), names_to = "UNION",
                        values_to = "mean_soc0_pa")

# extract average SOC in non-protected area
soc0_non_pa <- getvalue(cty_non_pa, soc0_rast) %>%
  pivot_longer(., cols = everything(), names_to = "UNION",
               values_to = "mean_soc0_non_pa")

## calculate average soil organic carbon (SOC) 30-100cm
# read SOC 30-100cm data, replace with path to new data if needed.
fils <- list.files("data-raw/process-indicators/data-downloaded/effective-protection/tidal_marsh_SOC-Maxwell-2024/pred30/pred30",
                   full.names = TRUE, recursive = TRUE,
                   pattern = "pred30")

soc30_rast <- lapply(fils, rast)

# extract average SOC in protected area
soc30_pa <- getvalue(cty_pa, soc30_rast) %>%
  pivot_longer(., cols = everything(), names_to = "UNION",
                        values_to = "mean_soc30_pa")


# extract average SOC in non-protected area
soc30_non_pa <- getvalue(cty_non_pa, soc30_rast) %>%
  pivot_longer(., cols = everything(), names_to = "UNION",
                         values_to = "mean_soc30_non_pa")

## calculate total SOC for countries
# get tidal marsh extent
dat <- read.csv('data-raw/process-indicators/data-processed/effective_protection.csv') %>%
  select(c(UNION, marsh_pa_2020_ha, marsh_2020_ha))

# join all data and calculate total carbon
dat <- left_join(dat, soc0_pa, by = "UNION") %>%
  left_join(soc0_non_pa, by = "UNION") %>%
  left_join(soc30_pa, by = "UNION") %>%
  left_join(soc30_non_pa, by = "UNION") %>%
  mutate(marsh_pa_soc0_t = mean_soc0_pa * marsh_pa_2020_ha,
         marsh_non_pa_soc0_t = mean_soc0_non_pa * (marsh_2020_ha - marsh_pa_2020_ha),
         marsh_soc0_t = marsh_pa_soc0_t + marsh_non_pa_soc0_t,
         marsh_pa_soc0_percentage = marsh_pa_soc0_t / marsh_soc0_t * 100,
         marsh_pa_soc30_t = mean_soc30_pa * marsh_pa_2020_ha,
         marsh_non_pa_soc30_t = mean_soc30_non_pa * (marsh_2020_ha - marsh_pa_2020_ha),
         marsh_soc30_t = marsh_pa_soc30_t + marsh_non_pa_soc30_t,
         marsh_pa_soc30_percentage = marsh_pa_soc30_t / marsh_soc30_t * 100) %>%
  select(c(UNION, marsh_soc0_t, marsh_pa_soc0_t, marsh_pa_soc0_percentage,
           marsh_soc30_t, marsh_pa_soc30_t, marsh_pa_soc30_percentage)) %>%
  mutate(across(ends_with("_t"), function(x) ifelse(is.na(x), 0, x)))

write.csv(dat, 'data-raw/process-indicators/data-processed/protected tidal marsh carbon.csv', row.names = FALSE)
