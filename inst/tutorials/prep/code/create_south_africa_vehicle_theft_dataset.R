library(httr)
library(readxl)
library(sf)
library(tidyverse)

# Source: https://www.saps.gov.za/services/crimestats.php
crime_file <- tempfile(fileext = ".xlsx")
GET(
  "https://www.saps.gov.za/services/Crime-Statistics-2019_2020.xlsx",
  write_disk(crime_file, overwrite = TRUE),
  timeout(60 * 10)
)

stations <- read_sf("~/Downloads/station_boundaries/Police_bounds.shp") %>%
  janitor::clean_names() %>%
  select(station = compnt_nm) %>%
  st_transform(32734) %>%
  st_centroid()

municipalities <- read_sf("https://opendata.arcgis.com/datasets/27bbdd5b041b4ba6b5707dfed5aa3923_0.geojson") %>%
  janitor::clean_names() %>%
  st_transform(32734) %>%
  select(municipality = municname)

vehicles <- read_tsv(here::here("inst/tutorials/prep/code/sa_municipality_vehicles.tsv")) %>%
  janitor::clean_names() %>%
  mutate(municipality = str_to_upper(municipality)) %>%
  select(municipality, vehicles = yes)

stations_in_mun <- stations %>%
  st_join(municipalities) %>%
  st_drop_geometry() %>%
  mutate(mun_match = str_to_upper(municipality)) %>%
  left_join(vehicles, by = c("mun_match" = "municipality"))

vehicle_theft <- crime_file %>%
  read_excel(sheet = "station data 2020") %>%
  janitor::clean_names() %>%
  pivot_longer(starts_with("x20"), names_to = "year", values_to = "count") %>%
  left_join(stations_in_mun, by = "station") %>%
  mutate(
    crime_category = str_remove(crime_category, " and motorcycle$"),
    province_station = str_replace_all(province_station, "_", " "),
    across(c(province_station, station), str_to_title),
    province_station = recode(
      province_station,
      "Kwazulu Natal" = "Kwazulu-Natal"
    )
  ) %>%
  filter(
    year == "x2018_2019",
    str_detect(crime_category, "\\bvehicle\\b"),
    province_station != station,
    station != "Republic Of South Africa",
    !is.na(vehicles)
  ) %>%
  group_by(province_station, municipality, crime_category) %>%
  summarise(count = sum(count), vehicle = sum(vehicles), .groups = "drop") %>%
  mutate(theft_rate = count / (vehicle / 1000)) %>%
  select(province = province_station, municipality, crime_category, theft_rate) %>%
  write_rds(
    here::here("inst/extdata/south_africa_vehicle_theft.Rds"),
    compress = "gz"
  )

