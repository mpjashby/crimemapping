library(sf)
library(tidyverse)

dir.create(str_glue("{tempdir()}/notts_crime"))
unzip(
  zipfile = "inst/tutorials/prep/code/nottinghamshire_crimes_2020.zip",
  exdir = str_glue("{tempdir()}/notts_crime")
)
notts_crime <- str_glue("{tempdir()}/notts_crime") %>%
  dir(pattern = ".csv", full.names = TRUE, recursive = TRUE) %>%
  map_dfr(read_csv) %>%
  janitor::clean_names() %>%
  mutate(
    district = str_extract(lsoa_name, "^\\w+"),
    location = str_remove(location, "On or near "),
    month = as.Date(str_glue("{month}-01"))
  ) %>%
  select(month, crime_type, district, longitude, latitude) %>%
  remove_missing(vars = c("longitude", "latitude"), na.rm = TRUE) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326, remove = FALSE)

notts_crime %>%
  filter(crime_type == "Criminal damage and arson") %>%
  select(-crime_type, -district) %>%
  write_sf("inst/extdata/nottinghamshire_damage.gpkg")

notts_crime %>%
  filter(
    district == "Nottingham",
    crime_type == "Criminal damage and arson"
  ) %>%
  select(-crime_type, -district) %>%
  write_sf("inst/extdata/nottingham_damage.gpkg")

notts_crime %>%
  filter(
    district == "Nottingham",
    crime_type == "Possession of weapons"
  ) %>%
  select(-crime_type, -district) %>%
  write_sf("inst/extdata/nottingham_weapons.gpkg")

read_sf("https://opendata.arcgis.com/datasets/1d78d47c87df4212b79fe2323aae8e08_0.geojson") %>%
  select(district_code = lad19cd, district_name = lad19nm) %>%
  filter(district_name %in% c(
    "Ashfield", "Bassetlaw", "Broxtowe", "Gedling", "Mansfield",
    "Newark and Sherwood", "Nottingham", "Rushcliffe"
  )) %>%
  write_sf("inst/extdata/nottinghamshire_districts.gpkg")
