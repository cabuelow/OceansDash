## code to prepare internal lazy-loaded sysdata RDA file
library(tidyverse)
library(sf)

# make colour palette -------------------------------------------------
col_pal <- c("#000000","#004949","#009292","#ff6db6","#ffb6db",
             "#490092","#006ddb","#b66dff","#6db6ff","#b6dbff",
             "#920000","#924900","#db6d00","#24ff24","#ffff6d", "#000099", 'grey23')

# read in and wrangle indicator data -------------------------------------------------
indicators <- read.csv(file.path('data-raw', 'indicators.csv')) %>%
  mutate(Region = case_when(Country == 'Alaska' ~ 'Arctic',
                            Country %in% c('Mexico', 'Colombia', 'Ecuador', 'Peru', 'Chile') ~ 'Eastern Pacific',
                            Country %in% c('Madagascar', 'Mozambique', 'Tanzania') ~ 'Southwest Indian Ocean',
                            Country %in% c('Papua New Guinea', 'Indonesia', 'Fiji', 'Solomon Islands') ~ 'Western Pacific'),
         Indicator_category = case_when(Indicator %in% c('Marine_Red_List', 'Marine_Living_Planet', 'Fisheries_Stock_Condition', 'Habitat_Condition', 'Effective_Protection') ~ 'Nature',
                                        Indicator %in% c('Small_Scale_Fisheries_Rights', 'Wealth_Relative_Index', 'Human_Development_Index') ~ 'People',
                                        Indicator %in% c('Habitat_Carbon_Storage', 'Climate_Adaptation_Plans', 'Carbon_Under_Effective_Protection') ~ 'Climate'),
         Units = case_when(Indicator %in% c('Marine_Red_List', 'Marine_Living_Planet', 'Fisheries_Stock_Condition', 'Habitat_Condition', 'Habitat_Carbon_Storage', 'Wealth_Relative_Index') ~ '\n(Standardised value (0 = Low, 100 = High))',
                           Indicator %in% c('Effective_Protection', 'Carbon_Under_Effective_Protection') ~ '\n(Percent protected)',
                           Indicator == 'Small_Scale_Fisheries_Rights' ~ '\n(Implementation level (1 = Low, 5 = High))',
                           Indicator == 'Human_Development_Index' ~ '\n(Standardised value (0 = Low, 1 = High))'),
         Label = gsub("_", " ", Indicator)
         )
indicators$Label <- paste0(indicators$Label, indicators$Units)

# read in target (year 2030) indicator values and make dataframe with baseline (year 2020) indicator values -------------------------------------------------
targets <- read.csv(file.path("data-raw", "indicator-targets_2030.csv")) %>%
  bind_rows(do.call(rbind, rep(list(.), length(unique(2020:2030))-1))) %>% # repeat indicator target values for every year to 2030 so can plot
  mutate(Year = rep(2020:2030, each = length(unique(.$Country))),
         Type = 'Target_2030') %>%
  pivot_longer(-c(Country, Year, Type), names_to = 'Indicator', values_to = 'Value')
baseline <- indicators %>%
  filter(Year <= 2020) %>%
  mutate(Year = 2020) %>%
  select(Country, Year, Indicator, Value) %>%
  pivot_wider(names_from = 'Indicator', values_from = 'Value') %>%
  bind_rows(do.call(rbind, rep(list(.), length(unique(2020:2030))-1))) %>% # repeat indicator baseline values for every year to 2030 so can plot
  mutate(Year = rep(2020:2030, each = length(unique(.$Country))),
         Type = 'Baseline_2030') %>%
  pivot_longer(-c(Country, Year, Type), names_to = 'Indicator', values_to = 'Value')
base_targets <- bind_rows(baseline, targets) # bind into a single data frame

# make extras for widgets, etc -------------------------------------------------
Region <- c('Arctic', rep('Eastern Pacific', 5), rep('Southwest Indian Ocean', 3), rep('Western Pacific',4))
Country <- c('Alaska', 'Mexico', 'Colombia', 'Ecuador', 'Peru', 'Chile', 'Madagascar', 'Mozambique', 'Tanzania', 'Papua New Guinea', 'Indonesia', 'Fiji', 'Solomon Islands')
country_names <- data.frame(number = c(1:length(Country)), country = Country)
region_names <- data.frame(number = c(1:4), region = unique(Region))
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

