# This script creates 10 addresses at random locations in the Cairo governate
# of Egypt, to be used as the apparent addresses of bank fraud offenders. This
# is saved as an internal dataset to be used in tutorial 12 on messy data.

# NOTE: THIS DATASET IS INTERNAL

# Load packages
library(tidygeocoder)
library(sf)
library(tidyverse)

# Get Cairo outline
# Source: https://data.humdata.org/dataset/cod-ab-egy
governates_file <- tempfile(fileext = ".zip")
download.file(
  url = "https://data.humdata.org/dataset/b90d81ba-7c7a-4283-9899-827480d80a79/resource/2d81e588-266e-4ea1-a3ae-402da7ea4a44/download/egy_admbnda_adm1_capmas_20170421.zip",
  destfile = governates_file
)
unzip(governates_file, exdir = tempdir())
cairo <- tempdir() |>
  str_glue("/egy_admbnda_adm1_capmas_20170421.shp") |>
  read_sf() |>
  janitor::clean_names() |>
  filter(adm1_en == "Cairo")

# Create random points in Cairo
# Most Nominatim reverse geocode lookups do not return full addresses, so we
# need a larger number of points to generate enough street addresses
cairo_points <- cairo |>
  st_sample(size = 100, type = "random", exact = TRUE) |>
  st_intersection(cairo) |>
  st_sf() |>
  st_set_geometry("geometry")

# Create random names
# Source of naming rules: https://qr.ae/pvLRJN
cairo_names <- c(
  "Ahmed Hussein Ayman",
  "Mohamed Ali Mohamed",
  "Mahmoud Mostafa Ali",
  "Omar El-Badawi",
  "Tarek Hazim Abdel-Rahman",
  "Youssef Sayyid",
  "Hussein El-Masri",
  "Mariam Abdel Mubarak",
  "Farah Youssef Anwar",
  "Nour El-Seifi"
)

# Reverse geocode approximate addresses
# Some of these will be *very* approximate, but that does not matter because it
# is random addresses we are interested in
cairo_addresses <- cairo_points |>
  st_coordinates() |>
  as_tibble() |>
  reverse_geocode(
    lat = Y,
    long = X,
    full_results = TRUE,
    custom_query = list("accept-language" = "en", "zoom" = 18)
  )

cairo_suspects <- cairo_addresses |>
  # Keep only addresses with house number and street name
  filter(!is.na(road), !is.na(house_number)) |>
  # Keep only first 10 addresses, since that is all we have names for
  slice(1:10) |>
  mutate(
    # Remove postcode and country name
    address = str_remove(address, ", \\d{5}, Egypt$"),
    # Add names
    name = cairo_names,
    # Remove co-ordinates for final row
    across(
      c(osm_lon, osm_lat),
      ~ if_else(row_number() == n(), 0, as.numeric(.))
    )
  ) |>
  select(name, address, lon = osm_lon, lat = osm_lat)

# Save dataset
usethis::use_data(cairo_suspects, overwrite = TRUE, internal = TRUE)
