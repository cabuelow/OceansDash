## code to prepare internal lazy-loaded sysdata RDA file
library(tidyverse)
library(sf)

# make colour palette -------------------------------------------------
col_pal <- c("#000000","#004949","#009292","#ff6db6","#ffb6db",
             "#490092","#006ddb","#b66dff","#6db6ff","#b6dbff",
             "#920000","#924900","#db6d00","#24ff24","#ffff6d", "#000099", 'grey23')

# read in and wrangle data -------------------------------------------------
indicators <- read.csv(file.path('data-raw', 'indicators.csv'))
base_targets <- read.csv(file.path("data-raw", "base_targets.csv"))

# make extras for widgets, etc -------------------------------------------------
Region <- c('Arctic', rep('Eastern Pacific', 5), rep('Southwest Indian Ocean', 3), rep('Western Pacific',4))
Country <- c('Alaska', 'Mexico', 'Colombia', 'Ecuador', 'Peru', 'Chile', 'Madagascar', 'Mozambique', 'Tanzania', 'Papua New Guinea', 'Indonesia', 'Fiji', 'Solomon Islands')
country_names <- data.frame(number = c(1:length(Country)), country = Country)
region_names <- data.frame(number = c(1:4), region = unique(indicators$Region))
indnames <- data.frame(text = c("Small Scale Fisheries Rights", "Wealth Relative Index", "Human Development Index", "Marine Red List", "Marine Living Planet", "Fisheries Stock Condition", "Habitat Condition", "Effective Protection", "Climate Adaptation Plans", "Habitat Carbon Storage", "Carbon Under Effective Protection"), ind = c("Small_Scale_Fisheries_Rights", "Wealth_Relative_Index", "Human_Development_Index", "Marine_Red_List", "Marine_Living_Planet", "Fisheries_Stock_Condition", "Habitat_Condition", "Effective_Protection", "Climate_Adaptation_Plans", "Habitat_Carbon_Storage", "Carbon_Under_Effective_Protection"))

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
                  country_names,
                  region_names,
                  indnames,
                  overwrite = TRUE, internal = T)

