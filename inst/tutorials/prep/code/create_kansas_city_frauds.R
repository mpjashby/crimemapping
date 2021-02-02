library(crimedata)
library(lubridate)
library(tidyverse)

kcmo_crime <- get_crime_data(years = 2015, cities = "Kansas City", type = "core")

kcmo_crime %>%
  filter(
    as_date(date_single) == ymd("2015-02-14"),
    offense_group == "fraud offenses (except counterfeiting/forgery and bad checks)"
  ) %>%
  select(uid, offense_code, offense_type, date = date_single, longitude, latitude) %>%
  write_csv("inst/extdata/kansas_city_frauds.csv.gz")
