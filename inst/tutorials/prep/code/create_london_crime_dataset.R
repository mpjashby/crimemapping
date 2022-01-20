library(lubridate)
library(tidyverse)

temp_dir <- str_glue("{tempdir()}/crime_data2")
unzip(
  zipfile = here::here("inst/tutorials/prep/code/london_crime_data_raw.zip"),
  exdir = temp_dir
)

crimes <- temp_dir %>%
  dir(pattern = ".csv$", full.names = TRUE, recursive = TRUE) %>%
  map_dfr(read_csv)

london_crimes <- crimes %>%
  janitor::clean_names() %>%
  separate(month, into = c("year", "month"), sep = "-", convert = TRUE) %>%
  filter(year == 2020) %>%
  mutate(
    across(c(longitude, latitude), round, digits = 4),
    borough = str_remove(str_remove(lsoa_name, "\\s\\w{4}$"), " upon Thames$"),
    crime_type = recode(
      str_to_lower(crime_type),
      "criminal damage and arson" = "criminal damage/arson",
      "possession of weapons" = "weapon possession",
      "theft from the person" = "theft from person",
      "violence and sexual offences" = "violent/sexual offence",
      "other crime" = "other"
    ),
    location = location %>%
      str_remove("^On or near ") %>%
      str_replace(coll(" (Dlr)"), " DLR Station") %>%
      str_replace(coll(" (Lu Station)"), " LU Station") %>%
      str_replace(coll(" (Station)"), " Rail Station")
  ) %>%
  filter(
    borough %in% c(
      "Westminster", "Tower Hamlets", "Camden", "Southwark", "Lambeth",
      "Newham", "Hackney", "Ealing", "Croydon", "Haringey", "Brent", "Barnet",
      "Hillingdon", "Islington", "Enfield", "Lewisham", "Greenwich", "Hounslow",
      "Wandsworth", "Waltham Forest", "Bromley", "Redbridge",
      "Kensington and Chelsea", "Hammersmith and Fulham",
      "Barking and Dagenham", "Havering", "Harrow", "Bexley", "Merton",
      "Sutton", "Richmond", "Kingston", "City of London"
    )
  ) %>%
  select(
    month, type = crime_type, location, lsoa = lsoa_code, borough, longitude,
    latitude
  ) %>%
  write_csv(here::here("inst/extdata/london_crimes_2020.csv.gz"))
