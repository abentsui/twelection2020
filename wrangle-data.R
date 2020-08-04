library(tidyverse)
polldata <- read_csv("data/ElectionPolling2020_Mod.csv")
polldata <- polldata %>%
  mutate(spread = green - blue,
         startdate = as.Date(startdate, "%d/%m/%Y"),
         enddate = as.Date(enddate, "%d/%m/%Y"))
save(polldata, file = "rda/polldata.rda")