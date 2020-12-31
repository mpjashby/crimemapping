# load packages
library(crimedata)
library(writexl)
library(tidyverse)

# load data
crimes <- get_crime_data(
  years = 2019,
  cities = c("Austin", "Fort Worth", "Seattle"),
  type = "core"
)

# create an Excel file of aggravated assault data, with a separate sheet for
# each city
crimes %>%
  filter(offense_code == "13A") %>%
  group_by(city_name) %>%
  select(city_name, date = date_single, longitude, latitude, location_type,
         location_category) %>%
  nest(data = -city_name) %>%
  deframe() %>%
  write_xlsx(here::here("inst/extdata/aggravated_assaults.xlsx"))
