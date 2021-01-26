library(lubridate)
library(tidyverse)

read_csv("inst/tutorials/prep/code/NYPD_Shooting_Incident_Data__Historic_.csv") %>%
  janitor::clean_names() %>%
  mutate(occur_date = mdy(occur_date)) %>%
  filter(occur_date >= ymd("2019-01-01"), boro == "BRONX") %>%
  select(incident_key, occur_date, murder = statistical_murder_flag, longitude, latitude) %>%
  write_csv("inst/extdata/bronx_shootings.csv")

