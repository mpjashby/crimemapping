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
  select(occurrencedate, offence, premisetype, lon = long, lat) %>%
  write_sf("inst/extdata/toronto_robberies.gpkg")



# Create downtown Toronto KSI collisions for LSA assessment
sf::read_sf("https://opendata.arcgis.com/datasets/cf76fac0660f458e9c216b1cb0809734_0.geojson") %>%
  janitor::clean_names() %>%
  filter(year %in% 2014:2019, division %in% 51:53) %>%
  select(date, time, lon = longitude, lat = latitude, location_type = loccoord, type = acclass) %>%
  mutate(
    date = lubridate::as_date(date),
    time = str_pad(time, width = 4, side = "left", pad = "0"),
    across(where(is.character), str_to_lower)
  ) %>%
  sf::write_sf("inst/extdata/toronto_downtown_collisions.gpkg")
