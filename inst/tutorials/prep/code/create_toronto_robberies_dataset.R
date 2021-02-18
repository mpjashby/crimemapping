library(sf)
library(tidyverse)

robberies <- read_sf("https://opendata.arcgis.com/datasets/29d23aa157a64c17bbb4848c4305a069_0.geojson") %>%
  janitor::clean_names()

robberies %>%
  filter(
    offence %in% c(
      "Robbery With Weapon",
      "Robbery - Purse Snatch",
      "Robbery - Delivery Person",
      "Robbery - Swarming",
      "Robbery - Mugging"
    ),
    occurrenceyear %in% 2014:2019,
    division == "D52"
  ) %>%
  mutate(
    occurrencedate = lubridate::as_date(occurrencedate),
    offence = str_to_lower(str_remove(offence, "Robbery - ")),
    premisetype = str_to_lower(premisetype)
  ) %>%
  arrange(occurrencedate, event_unique_id) %>%
  select(occurrencedate, offence, premisetype) %>%
  write_sf("inst/extdata/toronto_robberies.gpkg")
