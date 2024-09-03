# process ocean health index indicator values for each country/region

library(tidyverse)

# load data and filter for indicators, countries/regions of interest and year 2020 forward

dat <- read.csv('data-raw/process-indicators/data-downloaded/ocean-health-index/ohi_scores-26_08_2024.csv') %>%
  filter(long_goal %in% c("Fisheries (subgoal)", "Habitat (subgoal)", "Species condition (subgoal)", "Carbon storage"), region_name %in% c('Mexico', 'Colombia', 'Ecuador', 'Peru', 'Chile', 'Mozambique', 'Papua New Guinea', 'Indonesia', 'Fiji', 'Solomon Islands', 'Tanzania', 'Madagascar') & scenario >= 2020)

# rename columns so easy to collate with other indicators later

dat <- dat %>%
mutate(Indicator = 'Marine_Living_Planet') %>%
  mutate(Indicator = case_when(long_goal == 'Carbon storage' ~ 'Habitat_Carbon_Storage',
                               long_goal == 'Fisheries (subgoal)' ~ 'Fisheries_Stock_Condition',
                               long_goal == 'Habitat (subgoal)' ~ 'Habitat_Condition',
                               long_goal == 'Species condition (subgoal)' ~ 'Marine_Red_List')) %>%
  rename(Country = region_name, Year = scenario, Value = value) %>%
  select(Country, Year, Indicator, Value)

# save

write.csv(dat, 'data-raw/process-indicators/data-processed/ocean-health-index.csv', row.names = F)
