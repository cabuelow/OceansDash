# combine processed indicators into a final master dataframe and export for upload to dashboard application

library(tidyverse)

# read in processed data and combine into single, master data frame
fils <- list.files('data-raw/process-indicators/data-processed/', full.names = T)
master_df <- do.call(bind_rows, lapply(fils, read.csv))

# export to correct location for loading into dashboard application

master_df <- write.csv(master_df, 'data-raw/indicators.csv', row.names = F)

