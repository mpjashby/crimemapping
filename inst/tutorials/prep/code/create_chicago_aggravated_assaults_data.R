library(sf)
library(tidyverse)

# Source: https://data.cityofchicago.org/Public-Safety/Boundaries-Police-Beats-current-/aerh-rz74
chicago_districts <- read_sf("https://data.cityofchicago.org/api/geospatial/aerh-rz74?method=export&format=GeoJSON") %>%
  st_transform(26916) %>%
  group_by(district) %>%
  summarise() %>%
  mutate(district = parse_number(district))

assaults <- crimedata::get_crime_data(
  years = 2010:2019,
  cities = "Chicago",
  type = "core"
) %>%
  filter(offense_code == "13A", !is.na(date_single)) %>%
  select(date = date_single, location_category, longitude, latitude)

assaults %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326, remove = FALSE) %>%
  st_transform(26916) %>%
  st_join(chicago_districts) %>%
  st_drop_geometry() %>%
  drop_na(everything()) %>%
  write_csv("inst/extdata/chicago_aggravated_assaults.csv.gz")
