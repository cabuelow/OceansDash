# To calculate Wealth Relative Index for each country
# from inverted Gridded Relative Deprivation Index (GRDI)

# Data descriptions:
# Name: Global Gridded Relative Deprivation Index (GRDI), v1 (2010–2020)
# Resolution: 30 arc-second (~1 km)
# Value: 0 - 100
# Year: Not reported. Using input data from 2010–2020
# Source: https://sedac.ciesin.columbia.edu/data/set/povmap-grdi-v1

library(tidyverse)
library(sf)
library(exactextractr)

# set sf to not use S2
sf_use_s2(FALSE)

# read GRDI data, replace with path to new data if needed.
grdi <- rast("data-raw/process-indicators/data-downloaded/GRDI_v1/povmap-grdi-v1-geotiff/povmap-grdi-v1.tif")

# read country layer
cty <- st_read('data-raw/process-indicators/data-downloaded/targeted_countries_eez_land.gpkg')

# extract tiles' values for HDI
results <- list()

for (i in 1:nrow(cty)) {

  cty_i <- cty[i,]

  value <- exact_extract(grdi, cty_i, c('mean'))
  results[[i]] <- value
  names(results)[i] <- cty_i$UNION
}

dat <- bind_rows(results, .id = "UNION") %>%
  pivot_longer(., cols = everything(), names_to = "Country", values_to = "GRDI") %>%
  mutate(Value = 100 - GRDI) %>% # invert the score to calculate a wealth rather than deprivation index
  select(-GRDI) %>%
  mutate(Year = 2020,
         Indicator = 'Wealth_Relative_Index')

write.csv(dat, "data-raw/process-indicators/data-processed/Wealth Relative Index.csv", row.names = FALSE)
