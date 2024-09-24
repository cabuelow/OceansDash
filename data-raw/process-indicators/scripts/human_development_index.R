# To calculate Human Development Index for each country

# Data descriptions:
# Name: Gridded global datasets for Gross Domestic Product and Human Development Index over 1990-2015
# Resolution: 5 arc-min
# Value: 0 - 1
# Year: 1990–2015 anually
# Source: https://datadryad.org/stash/dataset/doi:10.5061/dryad.dk1j0

library(tidyverse)
library(sf)
library(exactextractr)

# set sf to not use S2
sf_use_s2(FALSE)

# read HDI 2015 data, replace with path to new data if needed.
hdi <- rast("data-raw/process-indicators/data-downloaded/HDI/doi_10_5061_dryad_dk1j0__v20200213/HDI_1990_2015_v2.nc")
hdi <- hdi$HDI_26

# read country layer
cty <- st_read('data-raw/process-indicators/data-downloaded/targeted_countries_eez_land.gpkg')

# extract tiles' values for HDI
results <- list()

for (i in 1:nrow(cty)) {

  cty_i <- cty[i,]

  value <- exact_extract(hdi, cty_i, c('mean'))
  results[[i]] <- value
  names(results)[i] <- cty_i$UNION
}

dat <- bind_rows(results, .id = "UNION") %>%
  pivot_longer(., cols = everything(), names_to = "Country", values_to = "Value") %>%
  mutate(Year = 2015,
         Indicator = 'Human_Development_Index')

write.csv(dat, "data-raw/process-indicators/data-processed/Human Development Index.csv", row.names = FALSE)
