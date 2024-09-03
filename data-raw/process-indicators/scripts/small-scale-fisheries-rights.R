# process small scale fisheries rights indicator values for each country/region

library(tidyverse)

# load data and filter for countries/regions of interest and year 2020 forward

dat <- read.csv('data-raw/process-indicators/data-downloaded/small-scale-fisheries-rights/protection-of-the-rights-of-small-scale-fisheries.csv') %>%
  filter(Entity %in% c('Mexico', 'Colombia', 'Ecuador', 'Peru', 'Chile', 'Mozambique', 'Papua New Guinea', 'Indonesia', 'Fiji', 'Solomon Islands', 'Tanzania', 'Madagascar') & Year >= 2020)

# rename columns

colnames(dat) <- c('Country', 'Code', 'Year', 'Value')

# rearrange columns so easy to collate with other indicators later

dat <- dat %>%
  mutate(Indicator = 'Small_Scale_Fisheries_Rights') %>%
  relocate('Indicator', .before = 'Value') %>%
  select(-Code)

# save

write.csv(dat, 'data-raw/process-indicators/data-processed/small-scale-fisheries-rights.csv', row.names = F)

