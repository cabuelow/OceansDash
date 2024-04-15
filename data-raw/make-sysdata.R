## code to prepare internal lazy-loaded sysdata
library(tidyverse)
library(sf)

# make colour palette -------------------------------------------------
col_pal <- c("#000000","#004949","#009292","#ff6db6","#ffb6db",
             "#490092","#006ddb","#b66dff","#6db6ff","#b6dbff",
             "#920000","#924900","#db6d00","#24ff24","#ffff6d", 'grey23')

# read in and wrangle data -------------------------------------------------
indicators <- read.csv(file.path('data-raw', 'indicators.csv'))
base_targets <- read.csv(file.path("data-raw", "base_targets.csv"))

# make extras for widgets, etc -------------------------------------------------
Region <- c('Arctic', rep('Eastern Pacific', 5), rep('Southwest Indian Ocean', 3), rep('Western Pacific',4))
Country <- c('Alaska', 'Mexico', 'Colombia', 'Ecuador', 'Peru', 'Chile', 'Madagascar', 'Mozambique', 'Tanzania', 'Papua New Guinea', 'Indonesia', 'Fiji', 'Solomon Islands')
Countrylist <- 1:length(Country)
names(Countrylist) <- Country
country_names <- data.frame(number = c(1:length(Country)), country = Country)
region_names <- data.frame(number = c(1:4), region = unique(indicators$Region))
ppl_indnames <- data.frame(number = c(1:3), ind = c("Small_Scale_Fisheries_Rights", "Wealth_Relative_Index", "Human_Development_Index"))

# read in and wrangle spatial data -------------------------------------------------
#World <- st_read(file.path('data-raw', 'world.gpkg')) |> mutate(name = as.character(name)) |> mutate(name = ifelse(name == 'United States', 'Alaska', name)) |> mutate(name = ifelse(name == 'Solomon Is.', 'Solomon Islands', name)) |> filter(name != 'Antarctica')
regions <- st_read(file.path('data-raw', 'EEZ_Land_v3_202030_sub_regions.gpkg'))
eez <- st_read(file.path('data-raw', 'EEZ_Land_v3_202030_sub.gpkg'))

# add data to sysdata.rda -------------------------------------------------
usethis::use_data(indicators,
                  base_targets,
                  eez,
                  regions,
                  col_pal,
                  Countrylist,
                  country_names,
                  region_names,
                  ppl_indnames,
                  overwrite = TRUE, internal = T)

