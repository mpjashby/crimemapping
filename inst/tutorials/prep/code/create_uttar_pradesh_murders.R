library(sf)
library(tidyverse)

# District names vary across sources due to transliteration



# Crime data -------------------------------------------------------------------

# data from https://data.gov.in/resources/district-wise-crime-under-various-sections-indian-penal-code-ipc-crimes-during-2014
up_crime <- read_csv("~/Downloads/archive/crime/01_District_wise_crimes_committed_IPC_2014.csv") %>%
  janitor::clean_names() %>%
  select(state = states_u_ts, district, murder) %>%
  mutate(across(c(state, district), str_to_title)) %>%
  filter(state == "Uttar Pradesh", !district %in% c("Total", "G. R. P.")) %>%
  mutate(district = recode(
    district,
    # "Ambedkar Nagar" = "Ambedkarnagar",
    "Badaun" = "Budaun",
    # "Barabanki" = "Bara Banki",
    "Bulandshahar" = "Bulandshahr",
    "Chandoli" = "Chandauli",
    "Fatehgarh" = "Farrukhabad",
    "Gautambudh Nagar" = "Gautam Buddha Nagar",
    "Khiri" = "Lakhimpur Kheri",
    "Kushi Nagar" = "Kushinagar",
    "Raibareilly" = "Rae Bareli",
    "Sant Kabirnagar" = "Sant Kabir Nagar",
    "Sidharthnagar" = "Siddharth Nagar",
    "St.ravidasnagar" = "Sant Ravi Das Nagar(Bhadohi)"
  )) %>%
  write_csv("inst/extdata/uttar_pradesh_murders.csv")



# District boundaries ----------------------------------------------------------

# data from https://github.com/HindustanTimesLabs/shapefiles/tree/master/state_ut/uttarpradesh/district
up_districts <- read_sf("https://github.com/HindustanTimesLabs/shapefiles/raw/master/state_ut/uttarpradesh/district/uttarpradesh_district.json") %>%
  select(state = state, district_name = district) %>%
  mutate(across(c(state, district_name), str_to_title)) %>%
  mutate(district_name = recode(
    district_name,
    "Mahamaya Nagar" = "Hathras"
  )) %>%
  write_sf("inst/extdata/uttar_pradesh_districts.gpkg")

# data from https://censusindia.gov.in/2011census/population_enumeration.html
pop_file <- tempfile(".xlsx")
download.file("http://censusindia.gov.in/pca/DDW_PCA0000_2011_Indiastatedist.xlsx", pop_file)
up_pop <- readxl::read_excel(pop_file) %>%
  janitor::clean_names() %>%
  filter(level == "DISTRICT", tru == "Total") %>%
  select(district = name, people = tot_p)

left_join(up_crime, up_pop)



# Population data --------------------------------------------------------------

remotes::install_github("crubba/htmltab")

up_pop <- htmltab::htmltab("https://en.wikipedia.org/wiki/List_of_districts_of_Uttar_Pradesh", 3)

up_pop %>%
  janitor::clean_names() %>%
  as_tibble() %>%
  mutate(
    across(c(population, area, density_km), parse_number),
    district = recode(
      district,
      "Badaun" = "Budaun",
      "Bagpat" = "Baghpat",
      "Chandauli (Varanasi Dehat)" = "Chandauli",
      "Sant Ravidas Nagar" = "Sant Ravi Das Nagar(Bhadohi)",
      "Shravasti" = "Shrawasti",
      "Siddharthnagar" = "Siddharth Nagar",
      "Varanasi (Kashi)" = "Varanasi"
    )
  ) %>%
  write_csv("inst/extdata/uttar_pradesh_population.csv")
