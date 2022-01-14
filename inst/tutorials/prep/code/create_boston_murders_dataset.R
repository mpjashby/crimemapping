library(tidyverse)

# Source: https://www.bostonglobe.com/metro/2013/07/11/victims-boston-strangler/CwbsZlSNcfwmhSetpqNlhL/story.html
boston_murders <- tribble(
  ~date, ~victim, ~address,
  "1962-06-14", "Anna Slesers", "77 Gainsborough St., Boston",
  "1962-06-28", "Mary Mullen", "1435 Commonwealth Ave., Boston",
  "1962-06-30", "Nina Nichols", "1940 Commonwealth Ave., Boston",
  "1962-06-30", "Helen Blake", "73 Newhall St., Lynn",
  "1962-08-19", "Ida Irga", "7 Grove St., Boston",
  "1962-08-21", "Jane Sullivan", "435 Columbia Road, Boston",
  "1962-12-05", "Sophie Clark", "315 Huntington Ave., Boston",
  "1962-12-31", "Patricia Bissette", "515 Park Drive, Boston",
  "1963-03-06", "Mary Brown", "319 Park Ave., Lawrence",
  "1963-05-06", "Beverly Samans", "4 University Road, Cambridge",
  "1963-09-08", "Evelyn Corbin", "224 Lafayette St., Salem",
  "1963-11-23", "Joann Graff", "54 Essex St., Lawrence",
  "1964-01-04", "Mary Sullivan", "44-A Charles St., Boston",
) %>%
  mutate(victim_address = str_glue("{victim} of {address}")) %>%
  select(date, victim_address) %>%
  write_csv(here::here("inst/extdata/boston_murders.csv"))

tidygeocoder::geocode(boston_murders, address = "address", method = "osm", full_results = TRUE)

get_wd <- getwd()
setwd(here::here("inst/extdata"))
if (file.exists(here::here("inst/extdata/boston_murders.zip"))) {
  file.remove(here::here("inst/extdata/boston_murders.zip"))
}
zip(
  here::here("inst/extdata/boston_murders.zip"),
  "boston_murders.csv"
)
setwd(get_wd)

file.remove(here::here("inst/extdata/boston_murders.csv"))
