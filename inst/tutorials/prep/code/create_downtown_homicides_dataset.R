library("sf")
library("tidyverse")

# download crime data
download.file(
  "https://www.atlantapd.org/Home/ShowDocument?id=3051",
  destfile = str_glue("{tempdir()}/atlanta_crime.zip")
)

# unzip crime data
unzip(str_glue("{tempdir()}/atlanta_crime.zip"), exdir = tempdir())

# load crime data
crimes <- str_glue("{tempdir()}/COBRA-2009-2019.csv") %>%
  read_csv() %>%
  janitor::clean_names()

# load neighbourhood data
nbhds <- read_sf("https://opendata.arcgis.com/datasets/d6298dee8938464294d3f49d473bcf15_196.geojson") %>%
  janitor::clean_names() %>%
  filter(neighborho == "Castleberry Hill, Downtown")

# get downtown homicides
crimes %>%
  filter(
    ucr_literal == "HOMICIDE",
    occur_date >= as.Date("2019-01-01"),
    neighborhood == "Downtown"
  ) %>%
  mutate(label = str_glue("{location}\n{occur_date} @ {occur_time}")) %>%
  select(report_number, label, longitude, latitude) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326, remove = FALSE) %>%
  write_sf(here::here("inst/tutorials/prep/data/downtown_homicides.gpkg")) %>%
  write_csv(here::here("inst/tutorials/prep/data/downtown_homicides.csv"))
