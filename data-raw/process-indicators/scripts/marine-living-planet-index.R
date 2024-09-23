# process marine living planet index indicator values for each country/region
# we use {rlpi} to calculate the index - if not already installed use the below commented out code to install {rlpi}
# install.packages("devtools")
# library(devtools)
# install_github("Zoological-Society-of-London/rlpi", dependencies=TRUE)

library(rlpi)
library(tidyverse)
library(sf)
library(tmap)
sf_use_s2(FALSE)
tmap_mode('view')

# load data
# TODO: make sure to update the pathfile name so loading the most recently downloaded data

dat <- read.csv('data-raw/process-indicators/data-downloaded/marine-living-planet-index/LPD2022_public/LPD2022_public.csv', na.strings = 'NULL')
eez <- st_read(file.path('data-raw', 'EEZ_Land_v3_202030_sub.gpkg')) %>%
  filter(UNION == 'Alaska') # get Alaska's EEZ

# turn into a spatial dataframe

dat.sf <- dat %>%
  drop_na(Longitude, Latitude) %>% # remove rows without coordinates
  st_as_sf(coords = c('Longitude', 'Latitude'), crs = 4326)
qtm(dat.sf[,1]) + qtm(eez) # map it

# identify records in Alaska's EEZ

dat.alaska <- dat.sf %>%
  st_intersection(eez)
qtm(dat.alaska[,1]) # map it

# filter full dataset for marine species only and for countries/regions of interest (note there are no records for Madagascar)

datsub <- dat.sf %>%
  filter(System == 'Marine' & Country %in% c('Mexico', 'Colombia', 'Ecuador', 'Peru', 'Chile', 'Mozambique', 'Papua New Guinea', 'Indonesia', 'Fiji', 'Solomon Islands', 'Tanzania, United Republic Of', "Madagascar") | System == 'Marine' & ID %in% dat.alaska$ID)
qtm(datsub[,1]) # map it

# calculate the LPI for marine species in each country, i.e. average rate of change in marine population sizes between 1970 and 2021
# Note: weightings not used ('use_weightings=0' - so treating taxonomic groups equally at one level, and biogeographic realms equally at the next)

countries <- unique(datsub$Country)

out <- list() # for storing results for each country
for(i in 1:length(countries)){
# create infile to calculate index
create_infile(filter(st_drop_geometry(datsub), Country == countries[i]), name = 'data-raw/process-indicators/data-downloaded/marine-living-planet-index/LPD2022_public/LPD2022_public_marine', start_col_name = "X1950", end_col_name = "X2020")
  # calculate index value for each yer
mlpi <- LPIMain('data-raw/process-indicators/data-downloaded/marine-living-planet-index/LPD2022_public/LPD2022_public_marine_infile.txt', REF_YEAR = 1970, PLOT_MAX = 2020, BOOT_STRAP_SIZE = 100, VERBOSE=FALSE)
mlpi$Year <- rownames(mlpi)
out[[i]] <- data.frame(Country = countries[i], Marine_Living_Planet = filter(mlpi, Year == 2020))
}

# bind indicators for each country into a dataframe and rename columns so easy to collate with other indicators later

final_out <- do.call(rbind, out) %>%
  mutate(Indicator = 'Marine_Living_Planet') %>%
  rename(Year = Marine_Living_Planet.Year, Value = Marine_Living_Planet.LPI_final) %>%
  select(Country, Year, Indicator, Value)

# save

write.csv(final_out, 'data-raw/process-indicators/data-processed/marine-living-planet-index.csv', row.names = F)
