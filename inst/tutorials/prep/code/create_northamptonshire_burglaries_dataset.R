library(tidyverse)

# Load crime data
data_dir <- str_glue("{tempdir()}/crime_data")
unzip(
  zipfile = here::here("inst/tutorials/prep/code/northamptonshire_crimes_2020.zip"),
  exdir = data_dir
)
burglary <- data_dir %>%
  dir(pattern = ".csv", full.names = TRUE, recursive = TRUE) %>%
  map_dfr(read_csv) %>%
  janitor::clean_names() %>%
  mutate(district = str_remove(lsoa_name, "\\s\\w{4}$")) %>%
  filter(
    crime_type == "Burglary",
    district %in% c(
      "Corby", "Daventry", "East Northamptonshire", "Kettering", "Northampton",
      "South Northamptonshire", "Wellingborough"
    )
  ) %>%
  select(district, lsoa = lsoa_name) %>%
  count(district, lsoa, name = "count") %>%
  write_rds(here::here("inst/extdata/northants_burglary.rds"), compress = "gz")
