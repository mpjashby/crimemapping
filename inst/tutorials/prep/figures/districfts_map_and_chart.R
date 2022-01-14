library(ggmap)
library(patchwork)
library(sf)
library(tidyverse)

# Load crime data
data_dir <- str_glue("{tempdir()}/crime_data")
unzip(
  zipfile = here::here("inst/tutorials/prep/code/northamptonshire_crimes_2020.zip"),
  exdir = data_dir
)
violence <- data_dir %>%
  dir(pattern = ".csv", full.names = TRUE, recursive = TRUE) %>%
  map_dfr(read_csv) %>%
  janitor::clean_names() %>%
  filter(crime_type == "Violence and sexual offences") %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# Load boundary data
districts <- read_sf("https://opendata.arcgis.com/datasets/0e07a8196454415eab18c40a54dfbbef_0.geojson") %>%
  janitor::clean_names() %>%
  filter(lad19nm %in% c(
    "South Northamptonshire", "Northampton", "Daventry", "Wellingborough",
    "Kettering", "Corby", "East Northamptonshire"
  )) %>%
  select(lad19nm, geometry)

# Calculate violence counts at district level
violence_counts <- violence %>%
  st_join(districts) %>%
  st_drop_geometry() %>%
  count(lad19nm) %>%
  drop_na() %>%
  right_join(districts, by = "lad19nm") %>%
  st_as_sf() %>%
  mutate(hjust = ifelse(n == max(n), 1, 0))

# Create map
violence_map <- violence_counts %>%
  st_bbox() %>%
  set_names(c("left", "bottom", "right", "top")) %>%
  get_stamenmap(maptype = "toner-lite") %>%
  ggmap() +
  geom_sf(aes(fill = n), data = violence_counts, inherit.aes = FALSE, alpha = 0.8) +
  geom_sf_text(
    aes(label = str_replace_all(lad19nm, "\\s", "\n")),
    data = violence_counts,
    inherit.aes = FALSE,
    colour = "grey20",
    lineheight = 0.9,
    size = 2.5
  ) +
  scale_fill_distiller(
    palette = "Oranges",
    labels = scales::comma_format(),
    limits = c(0, NA),
    direction = 1,
    guide = guide_colorbar(title.position = "top", barwidth = unit(0.25, "npc"))
  ) +
  labs(
    fill = "number of violent and sexual offences"
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    legend.position = "bottom"
    # legend.background = element_rect(colour = NA, fill = rgb(1, 1, 1, 0.9)),
    # legend.direction = "horizontal",
    # legend.justification = c(1, 0),
    # legend.position = c(1, 0)
  )

# Create bar chart
violence_chart <- violence_counts %>%
  mutate(lad19nm = fct_reorder(str_replace_all(lad19nm, "\\s", "\n"), n)) %>%
  ggplot(aes(n, lad19nm)) +
  geom_col(fill = "orange3") +
  geom_label(
    aes(label = scales::comma(n), fill = as_factor(hjust), hjust = hjust),
    label.size = NA,
    size = 2.5
  ) +
  scale_x_continuous(labels = scales::comma_format(), expand = c(0, 0)) +
  scale_fill_manual(values = c(`1` = "orange3", `0` = "white")) +
  labs(
    x = "number of violent and sexual offences",
    y = NULL
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank()
  )

violence_combined <- violence_map + violence_chart + plot_annotation(
  title = "Violent and sexual offences in Northamptonshire, 2020",
  caption = "Contains public sector information licensed under the Open Government Licence v3.0."
)

ggsave(
  filename = here::here("inst/tutorials/15_no_maps/images/map_vs_bar_chart.png"),
  plot = violence_combined,
  width = 1200 / 150,
  height = 800 / 150,
  dpi = 300
)
