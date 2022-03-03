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

# Download base map
base_map <- violence_counts %>%
  st_bbox() %>%
  set_names(c("left", "bottom", "right", "top")) %>%
  get_stamenmap(maptype = "toner-lines")

# Create map
violence_map <- ggmap(base_map) +
  geom_sf(aes(fill = n), data = violence_counts, inherit.aes = FALSE, alpha = 0.8) +
  geom_sf_label(
    aes(label = str_replace_all(lad19nm, "\\s", "\n")),
    data = violence_counts,
    inherit.aes = FALSE,
    alpha = 0.7,
    colour = "grey20",
    label.size = NA,
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
  theme_void() +
  theme(legend.position = "bottom")

# Create small reference map
reference_map <- ggmap(base_map) +
  # Add a 50% white mask to reduce the visibility of the base map
  annotate(
    "rect",
    xmin = -Inf,
    xmax = Inf,
    ymin = -Inf,
    ymax = Inf,
    alpha = 0.5,
    fill = "white"
  ) +
  geom_sf(
    data = districts,
    inherit.aes = FALSE,
    alpha = 0.8,
    colour = "grey50",
    fill = NA
  ) +
  geom_sf_label(
    aes(label = str_replace_all(str_to_upper(lad19nm), "\\s", "\n")),
    data = violence_counts,
    inherit.aes = FALSE,
    alpha = 0.7,
    fontface = "bold",
    label.size = NA,
    lineheight = 0.9,
    size = 2
  ) +
  theme_void() +
  theme(
    legend.position = "none",
    panel.border = element_rect(colour = "grey50", fill = NA)
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

# Create violence map and chart combo
violence_combined <- violence_map + violence_chart + plot_annotation(
  title = "Violent and sexual offences in Northamptonshire, 2020",
  caption = "Contains public sector information licensed under the Open Government Licence v3.0."
)

# Save violence map and chart combo
ggsave(
  filename = here::here("inst/tutorials/15_no_maps/images/map_vs_bar_chart.png"),
  plot = violence_combined,
  width = 1200 / 150,
  height = 800 / 150,
  dpi = 300
)

# Create chart with reference map
chart_reference <-
  # reference_map +
  violence_chart +
  inset_element(
    reference_map,
    top = 0.7,
    right = unit(1, "npc"),
    bottom = 0,
    left = 0.5
  ) +
  # plot_layout(widths = c(1, 2)) +
  plot_annotation(
    title = "Violent and sexual offences in Northamptonshire, 2020",
    caption = "Contains public sector information licensed under the Open Government Licence v3.0."
  )

# Save chart with reference map
ggsave(
  filename = here::here("inst/tutorials/15_no_maps/images/bar_chart_ref_map.png"),
  plot = chart_reference,
  width = 1200 / 150,
  height = 800 / 150,
  dpi = 300
)

