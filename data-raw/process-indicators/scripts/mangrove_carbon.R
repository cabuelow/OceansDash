# To calculate total carbon and protected carbon in mangrove

# Data descriptions:
# Name: Global Mangrove Distribution, Aboveground Biomass, and Canopy Height (AGB)
# Resolution: 30m
# Year: 2000
# Unit: Mg ha-1
# Source: https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1665
#
# Name: Global mangrove soil carbon data set (SOC)
# Resolution: 30m
# Soil depth: 0-100cm
# Year: 2020
# Unit: t/ha
# Source: https://zenodo.org/records/7729492

library(tidyverse)
library(terra)
library(sf)
library(exactextractr)

# set sf to not use S2
sf_use_s2(FALSE)

# set terra's temporary folder
#
temp <- "data-raw/process-indicators/data-downloaded/temp"
terraOptions(tempdir = temp)

# load function for extracting tiles' values
source("data-raw/process-indicators/scripts/functions.R")

# read country pa polygons
cty_pa <- vect('data-raw/process-indicators/data-downloaded/effective-protection/selected_countries_protected_area.gpkg')

# read country non-pa polygons
cty_non_pa <- vect("data-raw/process-indicators/data-downloaded/effective-protection/cty_non_pa.gpkg")

## calculate average above ground biomass (AGB)
# read AGB data, replace with path to new data if needed.
fils <- list.files("data-raw/process-indicators/data-downloaded/effective-protection/Simard 2019 Mangrove ABG Height/data/",
                   full.names = TRUE, pattern = "_agb_")

agb_rast <- lapply(fils, rast)

# extract average AGB in protected area
agb_pa <- getvalue(cty_pa, agb_rast) %>%
  pivot_longer(., cols = everything(), names_to = "UNION",
               values_to = "mean_agb_pa")

# extract average AGB in non-protected area
agb_non_pa <- getvalue(cty_non_pa, agb_rast) %>%
  pivot_longer(., cols = everything(), names_to = "UNION",
               values_to = "mean_agb_non_pa")

## calculate average soil organic carbon (SOC)
# read SOC data, replace with path to new data if needed.
fils <- list.files("data-raw/process-indicators/data-downloaded/effective-protection/SOC-Maxwell-2023/mangroves_tiles_SOC_predictions_2020/tt_final/",
                   full.names = TRUE, recursive = TRUE,
                   pattern = "soc.tha_mangroves.typology_m_30m_s0..100cm_2020_global")
soc_rast <- lapply(fils, rast)

# extract average SOC in protected area
soc_pa <- getvalue(cty_pa, soc_rast) %>%
  pivot_longer(., cols = everything(), names_to = "UNION",
               values_to = "mean_soc_pa")

# extract average SOC in non-protected area
soc_non_pa <- getvalue(cty_non_pa, soc_rast) %>%
  pivot_longer(., cols = everything(), names_to = "UNION",
               values_to = "mean_soc_non_pa")

## calculate AGB and SOC for countries
# get mangrove extent
dat <- read.csv('data-raw/process-indicators/data-processed/effective_protection.csv') %>%
  select(c(UNION, mangrove_2020_ha, mangrove_pa_2020_ha))

# join all data and calculate total carbon
dat <- left_join(dat, agb_pa, by = "UNION") %>%
  left_join(agb_non_pa, by = "UNION") %>%
  left_join(soc_pa, by = "UNION") %>%
  left_join(soc_non_pa, by = "UNION") %>%
  mutate(mangrove_pa_agb_Mg = mean_agb_pa * mangrove_pa_2020_ha,
         mangrove_non_pa_agb_Mg = mean_agb_non_pa * (mangrove_2020_ha - mangrove_pa_2020_ha),
         mangrove_agb_Mg = mangrove_pa_agb_Mg + mangrove_non_pa_agb_Mg,
         mangrove_pa_agb_percentage = mangrove_pa_agb_Mg / mangrove_agb_Mg * 100,
         mangrove_pa_soc_t = mean_soc_pa * mangrove_pa_2020_ha,
         mangrove_non_pa_soc_t = mean_soc_non_pa * (mangrove_2020_ha - mangrove_pa_2020_ha),
         mangrove_soc_t = mangrove_pa_soc_t + mangrove_non_pa_soc_t,
         mangrove_pa_soc_percentage = mangrove_pa_soc_t / mangrove_soc_t * 100) %>%
  select(c(UNION, mangrove_agb_Mg, mangrove_pa_agb_Mg, mangrove_pa_agb_percentage ,
             mangrove_soc_t, mangrove_pa_soc_t, mangrove_pa_soc_percentage)) %>%
  mutate(across(!ends_with("percentage"), function(x) ifelse(is.na(x), 0, x)))

write.csv(dat, 'data-raw/process-indicators/data-processed/protected mangrove carbon.csv', row.names = FALSE)
