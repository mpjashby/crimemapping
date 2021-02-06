library(writexl)
library(sf)
library(tidyverse)

# police boundaries from https://www.data.qld.gov.au/dataset/qps-divisions/resource/fa6a7917-43de-4036-a704-25f545c24093
temp_dir <- str_glue("{tempdir()}/qld_boundaries/")
dir.create(temp_dir)
download.file(
  "http://open-crime-data.s3-ap-southeast-2.amazonaws.com/document/QPS_DIVISIONS.zip",
  str_glue("{temp_dir}/boundaries.zip")
)
unzip(str_glue("{temp_dir}/boundaries.zip"), exdir = temp_dir)
qld_boundaries <- str_glue("{temp_dir}/QPS_DIVISIONS.shp") %>%
  read_sf() %>%
  janitor::clean_names() %>%
  select(division = name) %>%
  mutate(division = str_to_title(division)) %>%
  # merge Highfields into Toowoomba since the 2016 maps in the population
  # reports show that they were a combined Toowoomba division at that point
  mutate(division = recode(
    division,
    "Highfields" = "Toowoomba",
    "Logan Village Yarrabilba" = "Jimboomba",
    "Seaforth" = "Marian"
  )) %>%
  group_by(division) %>%
  summarise() %>%
  write_sf("inst/extdata/qld_police_divisions.gpkg")

# crime counts and rates from https://www.police.qld.gov.au/maps-and-statistics
read_csv("https://open-crime-data.s3-ap-southeast-2.amazonaws.com/Crime%20Statistics/division_Reported_Offences_Number.csv") %>%
  janitor::clean_names() %>%
  mutate(
    date = parse_date(month_year, format = "%b%y"),
    year = lubridate::year(date),
    # merge Highfields into Toowoomba since the 2016 maps in the population
    # reports show that they were a combined Toowoomba division at that point
    division = recode(
      division,
      "Highfields" = "Toowoomba",
      "Logan Village Yarrabilba" = "Jimboomba",
      "Seaforth" = "Marian"
    )
  ) %>%
  select(division, year, stalking) %>%
  group_by(division, year) %>%
  summarise_all(sum) %>%
  write_xlsx("inst/extdata/qld_stalking.xlsx", format_headers = FALSE)

# population data from various documents called 'POLSIS Profiles: Resident' on
# the Queensland Government website at
# https://www.qld.gov.au/search?query=polis+profiles+resident&num_ranks=10&tiers=off&collection=qld-gov
qld_pop <- read_delim(
  "inst/tutorials/prep/code/qld_police_district_pop_raw.tab",
  delim = "\t",
  col_names = c("division", "population", "change")
) %>%
  separate(col = "population", into = c("pop2007", "pop2012", "pop2017"), convert = TRUE) %>%
  select(police_division = division, population = pop2017) %>%
  # merge Landsborough division population into that for Beerwah, since
  # Landsborough isn't in the boundary data or the crime data, and looking at
  # the map it appears that Landsborough is covered by Beerwah division
  mutate(police_division = ifelse(police_division == "Landsborough", "Beerwah", police_division)) %>%
  group_by(police_division) %>%
  summarise_all(sum) %>%
  write_csv("inst/extdata/qld_population.csv.gz")


temp_file <- tempfile(fileext = ".xlsx")
download.file(
  url = "https://github.com/mpjashby/crimemapping/raw/main/inst/extdata/qld_stalking.xlsx",
  destfile = temp_file,
  mode = "wb"
)
readxl::excel_sheets(temp_file)
