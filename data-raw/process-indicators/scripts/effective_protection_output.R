# To compile effective protection data from each habitat

library(tidyverse)

# read processed data
mangrove <- read.csv('data-raw/process-indicators/data-downloaded/effective-protection/mangrove_protection.csv')
coral <- read.csv('data-raw/process-indicators/data-downloaded/effective-protection/coral_protection.csv')
marsh <- read.csv('data-raw/process-indicators/data-downloaded/effective-protection/marsh_protection.csv')

# join table
output <- left_join(mangrove, coral, by = "UNION") %>%
  left_join(marsh, by = "UNION")

# save output data
write.csv(output, "data-raw/process-indicators/data-processed/effective_protection.csv", row.names = FALSE)
