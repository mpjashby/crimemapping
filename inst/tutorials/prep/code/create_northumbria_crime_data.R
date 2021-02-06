library(janitor)
library(readxl)
library(sf)
library(writexl)
library(tidyverse)



# ASB data ---------------------------------------------------------------------

# police.uk crime data is hidden behind a web form, so we have to download 2020
# crime data for Northumbria manually and then process the downloaded ZIP file
crimes_dir <- tempdir()
unzip("inst/tutorials/prep/code/northumbria_asb_2020.zip", exdir = crimes_dir)

northumbria_asb <- crimes_dir %>%
  dir(pattern = ".csv$", full.names = TRUE, recursive = TRUE) %>%
  map_dfr(read_csv, col_types = cols()) %>%
  clean_names() %>%
  filter(crime_type == "Anti-social behaviour") %>%
  select(month, longitude, latitude, location, crime_type) %>%
  mutate(
    location = str_remove(location, "On or near "),
    month = as.Date(str_glue("{month}-01"))
  ) %>%
  write_tsv("inst/extdata/northumbria_asb_2020.tab")



# Local authority boundaries ---------------------------------------------------

districts <- read_sf("https://opendata.arcgis.com/datasets/3b374840ce1b4160b85b8146b610cd0c_0.geojson", quiet = FALSE) %>%
  clean_names() %>%
  select(objectid, district = lad20nm, geometry) %>%
  filter(district %in% c("Newcastle upon Tyne", "Gateshead", "North Tyneside",
                         "South Tyneside", "Sunderland", "Northumberland"))

# write_sf silently returns a data.frame, so we run this outside the pipeline
write_sf(districts, "inst/extdata/nortumbria_districts.geojson", overwrite = TRUE)



# Local authority ward boundaries ----------------------------------------------

wards <- read_sf("https://opendata.arcgis.com/datasets/bf1a23cfe83f4da9844e7f34e4824d03_0.geojson", quiet = FALSE) %>%
  clean_names() %>%
  select(ward_code = wd19cd, ward_name = wd19nm, geometry)

# the geometries of wards and districts don't always quite match across layers,
# so to prevent extra wards being selected we instead join on the centroids of
# wards and then use the resulting data to filter the original dataset
ward_districts <- wards %>%
  # transform to British National Grid both because st_centroid() doesn't work
  # well with lat/lon data and to make things slightly more complicated for the
  # students doing the exercise
  st_transform(27700) %>%
  st_centroid() %>%
  st_join(select(st_transform(districts, 27700), district)) %>%
  filter(!is.na(district)) %>%
  st_set_geometry(NULL) %>%
  select(-ward_name) %>%
  right_join(wards, by = "ward_code") %>%
  filter(!is.na(district)) %>%
  select(ward_code, ward_name, geometry)

write_sf(ward_districts, "inst/extdata/northumbria_wards.gpkg")



# Ward population data ---------------------------------------------------------

pop_dir <- tempdir()
download.file(
  "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/wardlevelmidyearpopulationestimatesexperimental/mid2019sape22dt8a/sape22dt8amid2019ward2019on2019and2020lasyoaestimatesunformatted.zip",
  str_glue("{pop_dir}/ward_populations.zip")
)
unzip(str_glue("{pop_dir}/ward_populations.zip"), exdir = pop_dir)

pop_dir %>%
  dir(pattern = ".xlsx$", full.names = TRUE) %>%
  read_excel(sheet = "Mid-2019 Persons", skip = 3) %>%
  clean_names() %>%
  filter(
    la_name_2019_boundaries %in% c(
      "Newcastle upon Tyne", "Gateshead", "North Tyneside", "South Tyneside",
      "Sunderland", "Northumberland"
    )
  ) %>%
  select(gss_code = ward_code_1, ward = ward_name_1, population = all_ages) %>%
  write_xlsx(
    "inst/extdata/northumbria_ward_population.xlsx",
    format_headers = FALSE
  )

