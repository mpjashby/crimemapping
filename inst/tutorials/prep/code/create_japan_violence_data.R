library(rvest)
library(tabulizer)
library(tidyverse)

# !! THIS FUNCTION WILL OPEN A VIEWER WINDOW FOR SELECTING AN AREA ON THE PAGE
# locate_areas(
#   file = "http://www.stat.go.jp/english/data/nenkan/pdf/yhyou28.pdf",
#   pages = 2
# )

pdf <- extract_areas(
  file = "http://www.stat.go.jp/english/data/nenkan/pdf/yhyou28.pdf",
  pages = 2
)

crime <- pdf %>%
  chuck() %>%
  as.data.frame() %>%
  as_tibble(.name_repair = "minimal") %>%
  set_names(c(
    "pref_number", "blank", "prefecture", "total_homicide_robbery_arson_rape",
    "violence_larceny", "intellectual", "moral_cleared_arrestees", "final"
  )) %>%
  select(-pref_number, -blank, -final) %>%
  separate(
    total_homicide_robbery_arson_rape,
    into = c("total", "homicide", "robbery", "arson", "rape"),
    sep = "\\s"
  ) %>%
  separate(violence_larceny, into = c("violence", "larceny"), sep = "\\s") %>%
  separate(
    moral_cleared_arrestees,
    into = c("moral", "cleared", "arrestees"),
    sep = "\\s"
  ) %>%
  mutate(across(-prefecture, parse_number)) %>%
  select(prefecture, homicide, robbery, rape, violence)

read_csv("~/Downloads/REGION_ECONOM_10032021171830889.csv", guess_max = 100000) %>%
  janitor::clean_names() %>%
  filter(
    measure == "National currency per head, current prices",
    str_detect(unit, "Yen"),
    year == 2012
  )

gdp <- read_html("https://en.wikipedia.org/wiki/List_of_Japanese_prefectures_by_GDP_per_capita") %>%
  html_node(".wikitable") %>%
  html_table() %>%
  as_tibble() %>%
  janitor::clean_names() %>%
  select(prefecture, gdp_per_capita = x2014_gdp_per_capitain_jp) %>%
  mutate(gdp_per_capita = parse_number(gdp_per_capita))

crime_data <- crime %>%
  mutate(prefecture = recode(prefecture, "Gumma" = "Gunma")) %>%
  full_join(gdp, by = "prefecture") %>%
  filter(prefecture != "Japan")

write_rds(
  crime_data,
  file = here::here("inst/extdata/japan_violence_counts.rds"),
  compress = "gz"
)
