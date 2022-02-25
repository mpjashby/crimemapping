library(httr)
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
  filter(crime_type == "Possession of weapons") %>%
  select(-crime_type, -district) %>%
  write_sf("inst/extdata/nottinghamshire_weapons.gpkg")

notts_crime %>%
  filter(
    district == "Nottingham",
    crime_type == "Possession of weapons"
  ) %>%
  select(-crime_type, -district) %>%
  write_sf("inst/extdata/nottingham_weapons.gpkg")

notts_crime %>%
  filter(
    district == "Nottingham",
    crime_type == "Burglary"
  ) %>%
  select(-crime_type, -district) %>%
  write_csv("inst/extdata/nottingham_burglaries.csv.gz")

notts_crime %>%
  filter(
    district == "Nottingham",
    crime_type == "Violence and sexual offences"
  ) %>%
  select(-crime_type, -district) %>%
  write_csv("inst/extdata/nottingham_violence.csv.gz")

notts_crime %>%
  filter(
    district == "Nottingham",
    crime_type == "Robbery"
  ) %>%
  select(-crime_type, -district) %>%
  write_csv("inst/extdata/nottingham_robberies.csv.gz")

read_sf("https://opendata.arcgis.com/datasets/1d78d47c87df4212b79fe2323aae8e08_0.geojson") %>%
  select(district_code = lad19cd, district_name = lad19nm) %>%
  filter(district_name %in% c(
    "Ashfield", "Bassetlaw", "Broxtowe", "Gedling", "Mansfield",
    "Newark and Sherwood", "Nottingham", "Rushcliffe"
  )) %>%
  write_sf("inst/extdata/nottinghamshire_districts.gpkg")

GET(
  "https://opendata.arcgis.com/datasets/c32bab8c7ff64201bbaccf0db0fd4647_0.zip",
  write_disk(str_glue("{tempdir()}/wards.zip"), overwrite = TRUE),
  timeout(60 * 30)
)
dir.create(str_glue("{tempdir()}/wards"))
unzip(str_glue("{tempdir()}/wards.zip"), exdir = str_glue("{tempdir()}/wards"))
tempdir() %>%
  str_glue("/wards/Wards_(December_2019)_Boundaries_EW_BFC.shp") %>%
  read_sf() %>%
  filter(wd19cd %in% c(
    "E05012270", "E05012271", "E05012272", "E05012273", "E05012274",
    "E05012275", "E05012276", "E05012277", "E05012278", "E05012279",
    "E05012280", "E05012281", "E05012282", "E05012283", "E05012284",
    "E05012285", "E05012286", "E05012287", "E05012288", "E05012289"
  )) %>%
  select(ward_code = wd19cd, ward_name = wd19nm) %>%
  write_sf("inst/extdata/nottingham_wards.gpkg")


