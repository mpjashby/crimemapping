library(lubridate)
library(tidyverse)

temp_dir <- str_glue("{tempdir()}/crime_data2")
temp_file <- tempfile(fileext = ".zip")
# THIS URL WILL NO LONGER WORK AND SHOULD BE REPLACED WITH A NEW ONE FROM
# https://data.police.uk/data/ WITH THE FOLLOWING OPTIONS:
#   * a single calendar year
#   * BTP, CoLP and MPS
#   * crimes only
download.file(
  url = "https://policeuk-data.s3.amazonaws.com/download/8879e5677478641fc1c194161b4f6f792d048be6.zip",
  destfile = temp_file
)
unzip(zipfile = temp_file, exdir = temp_dir)

crimes <- temp_dir %>%
  dir(pattern = ".csv$", full.names = TRUE, recursive = TRUE) %>%
  map_dfr(read_csv)

london_crimes <- crimes %>%
  janitor::clean_names() %>%
  separate(month, into = c("year", "month"), sep = "-", convert = TRUE) %>%
  filter(year == 2021) %>%
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
      str_replace(coll(" (Station)"), " Rail Station"),
    month = month(make_date(month = month), label = TRUE),
    random = runif(n())
  ) %>%
  arrange(month, random) %>%
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
  write_csv(here::here("inst/extdata/london_crimes_2021.csv.gz"))
