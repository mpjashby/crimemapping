library(httr)
library(sf)
library(tidyverse)

saps_dir <- str_glue("{tempdir()}/saps")
dir.create(saps_dir)

# Source: https://data.openup.org.za/dataset/police-station-coordinates-r6kb-f76c
GET(
  "https://data.openup.org.za/dataset/7754e31a-2fa6-4462-94c0-87bbdb52e1a6/resource/87d86162-bc0c-40fd-b39c-cf7519afe582/download/r6kb-f76c.zip",
  write_disk(str_glue("{saps_dir}/stations.zip"), overwrite = TRUE)
)
unzip(str_glue("{saps_dir}/stations.zip"), exdir = saps_dir)
file.remove(str_glue("{saps_dir}/stations.zip"))

saps_dir %>%
  dir(pattern = ".shp$", full.names = TRUE) %>%
  pluck(1) %>%
  read_sf() %>%
  select(station = compnt_nm, geometry) %>%
  mutate(station = str_to_title(station)) %>%
  write_sf(str_glue("{saps_dir}/stations.shp"))

zip(
  here::here("inst/extdata/saps_stations.zip"),
  dir(saps_dir, pattern = "^stations", full.names = TRUE)
)
