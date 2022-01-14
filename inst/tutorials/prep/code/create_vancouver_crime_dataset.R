# load packages
library(tidyverse)

# load data
unzip(
  here::here("inst/tutorials/04_hotspots_1/vancouver_crimedata_csv_all_years.zip"),
  exdir = str_glue("{tempdir()}/vancouver_crime_data/")
)

crimes <- read_csv(str_glue("{tempdir()}/vancouver_crime_data/crimedata_csv_all_years.csv"))

crimes %>%
  filter(YEAR %in% 2020, str_detect(TYPE, "Theft")) %>%
  arrange(YEAR, MONTH, DAY, HOUR) %>%
  write_csv(here::here("inst/extdata/vancouver_thefts.csv.gz"))
