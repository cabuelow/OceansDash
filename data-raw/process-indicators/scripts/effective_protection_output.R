# To compile effective protection data from each habitat

library(tidyverse)

# read processed data
mangrove <- read.csv('data-raw/process-indicators/data-downloaded/effective-protection/mangrove_protection.csv')
coral <- read.csv('data-raw/process-indicators/data-downloaded/effective-protection/coral_protection.csv')
marsh <- read.csv('data-raw/process-indicators/data-downloaded/effective-protection/marsh_protection.csv')

mangrove_carbon <- read.csv('data-raw/process-indicators/data-downloaded/effective-protection/protected mangrove carbon.csv')
marsh_carbon <- read.csv('data-raw/process-indicators/data-downloaded/effective-protection/protected tidal marsh carbon.csv')

# effective protection
# join tables
output <- left_join(mangrove, coral, by = "UNION") %>%
  left_join(marsh, by = "UNION") %>%
  mutate(total_habitat = mangrove_2020_ha + coral_2018_20_ha + marsh_2020_ha,
         total_protected_habitat = mangrove_pa_2020_ha + coral_pa_2018_20_ha + marsh_pa_2020_ha) %>%
  mutate(Effective_Protection = total_protected_habitat/total_habitat) %>%
  select(UNION, Effective_Protection) %>%
  mutate(Year = 2020) %>%
  pivot_longer(Effective_Protection, names_to = 'Indicator', values_to = 'Value') %>%
  rename(Country = UNION) %>%
  mutate(Value = Value *100) # convert to percentage rather than proportion

# save output data
write.csv(output, "data-raw/process-indicators/data-processed/effective_protection.csv", row.names = FALSE)

# effective carbon protection
# join tables
output2 <- left_join(mangrove_carbon, marsh_carbon, by = "UNION") %>%
  mutate(total_carbon_Mg = total_mangrove_carbon_Mg + total_marsh_soc_t, # megagrams (Mg) and metric tonnes (t) are equivalent
         total_protected_carbon_Mg = total_mangrove_carbon_pa_Mg + total_marsh_pa_soc_t) %>%
  mutate(Carbon_Under_Effective_Protection = total_protected_carbon_Mg/total_carbon_Mg) %>%
  select(UNION, Carbon_Under_Effective_Protection) %>%
  mutate(Year = 2020) %>%
  pivot_longer(Carbon_Under_Effective_Protection, names_to = 'Indicator', values_to = 'Value') %>%
  rename(Country = UNION) %>%
  mutate(Value = Value *100) # convert to percentage rather than proportion

# save output data
write.csv(output2, "data-raw/process-indicators/data-processed/effective_carbon_protection.csv", row.names = FALSE)
