library(lubridate)
library(slider)
library(tidyverse)

crimes <- crimedata::get_crime_data(
  years = 2010:2019,
  cities = "Chicago",
  type = "core"
)



# Seasonal chart ---------------------------------------------------------------

counts <- crimes %>%
  mutate(
    offence = case_when(
      offense_group == "assault offenses" ~ "assaults",
      offense_code == "22A" ~ "residential burglaries",
      offense_code == "12A" ~ "personal robberies",
      TRUE ~ NA_character_
    ),
    yday = yday(date_single),
    year = year(date_single)
  ) %>%
  filter(!is.na(offence)) %>%
  count(offence, year, yday, name = "count") %>%
  mutate(date = as_date(str_glue("2012 {yday}"), format = "%Y %j"))

counts_chart <- ggplot(counts, aes(date, count, colour = year, group = year)) +
  geom_smooth(
    method = "loess",
    formula = "y ~ x",
    se = FALSE,
    size = 0.5
  ) +
  facet_wrap(vars(offence), ncol = 3, scales = "free_y") +
  scale_x_date(
    date_breaks = "2 months",
    date_labels = "%b",
    sec.axis = dup_axis()
  ) +
  scale_y_continuous(limits = c(0, NA)) +
  scale_colour_gradient(
    breaks = range(counts$year, na.rm = TRUE),
    labels = range(counts$year, na.rm = TRUE),
    low = RColorBrewer::brewer.pal(9, "Blues")[4],
    high = RColorBrewer::brewer.pal(9, "Blues")[9],
    guide = guide_colourbar(reverse = TRUE, ticks = FALSE)
  ) +
  labs(
    title = "Seasonal variation in selected crimes in Chicago",
    subtitle = "police-reported offences",
    x = NULL,
    y = "number of crimes per day",
    caption = "Data from Chicago Police Department"
  ) +
  theme_minimal() +
  theme(
    axis.ticks.y = element_line(colour = "grey80"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.caption = element_text(colour = "grey40"),
    plot.caption.position = "plot",
    plot.title = element_text(
      colour = "grey50",
      face = "bold",
      size = 16,
      margin = margin(b = 9)
    ),
    plot.title.position = "plot",
    strip.placement = "outside"
  )

ggsave(
  filename = here::here("inst/tutorials/16_mapping_time/images/chicago_seasonal_variation.png"),
  plot = counts_chart,
  width = 1200 / 150,
  height = 500 / 150,
  dpi = 300
)



# Weekly chart -----------------------------------------------------------------

weekly_chart <- crimes %>%
  mutate(
    offence = case_when(
      offense_code == "290" ~ "property damage",
      offense_group == "sex offenses" ~ "sexual violence",
      offense_code == "23C" ~ "shoplifting",
      TRUE ~ NA_character_
    ),
    weekday = wday(date_single, label = TRUE, week_start = 1)
  ) %>%
  filter(!is.na(offence), !is.na(weekday)) %>%
  count(offence, weekday, name = "count") %>%
  mutate(
    count = count / (52 * 10),
    weekend = weekday %in% c("Sat", "Sun")
  ) %>%
  ggplot(aes(weekday, count, fill = weekend, label = str_sub(weekday, 1, 2))) +
  geom_col() +
  geom_label(
    aes(y = 0),
    colour = "white",
    # label.padding = unit(0.1, "lines"),
    label.size = NA,
    size = 3.25,
    vjust = 0
  ) +
  facet_wrap(vars(offence), ncol = 3, scales = "free_y") +
  scale_y_continuous(
    labels = scales::comma_format(accuracy = 1),
    expand = c(0, 0)
  ) +
  scale_fill_manual(values = c(RColorBrewer::brewer.pal(9, "Blues")[c(4, 9)])) +
  labs(
    title = "Weekly variation in selected crimes in Chicago",
    subtitle = "police-reported offences",
    x = NULL,
    y = "number of crimes per day",
    caption = "Data from Chicago Police Department"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),
    axis.title.x = element_blank(),
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.caption = element_text(colour = "grey40"),
    plot.caption.position = "plot",
    plot.title = element_text(
      colour = "grey50",
      face = "bold",
      size = 16,
      margin = margin(b = 9)
    ),
    plot.title.position = "plot"
  )

ggsave(
  filename = here::here("inst/tutorials/16_mapping_time/images/chicago_weekly_variation.png"),
  plot = weekly_chart,
  width = 1200 / 150,
  height = 500 / 150,
  dpi = 300
)



# Trend chart ------------------------------------------------------------------

trend_chart <- crimes %>%
  filter(offense_code == "13A", !is.na(date_single)) %>%
  mutate(yearweek = floor_date(as_date(date_single), unit = "week")) %>%
  count(yearweek) %>%
  slice(2:(n() - 1)) %>%
  mutate(rolling_mean = slide_dbl(n, mean, .before = 4, .complete = TRUE)) %>%
  ggplot(aes(x = yearweek, y = n)) +
  geom_point(colour = "grey75", size = 0.75) +
  geom_line(aes(y = rolling_mean), na.rm = TRUE) +
  scale_x_date(date_breaks = "1 year", date_labels = "%e %b\n%Y", expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, NA), expand = c(0, 0), position = "right") +
  labs(
    title = "Trend in aggravated assaults in Chicago",
    subtitle = "points show weekly counts, line shows four-weekly moving average",
    caption = "Data from Chicago Police Department",
    x = NULL,
    y = "weekly count of aggravated assaults"
  ) +
  theme_minimal() +
  theme(
    panel.grid.minor.x = element_blank(),
    plot.caption = element_text(colour = "grey40"),
    plot.caption.position = "plot",
    plot.title = element_text(
      colour = "grey50",
      face = "bold",
      size = 16,
      margin = margin(b = 9)
    ),
  )

ggsave(
  filename = here::here("inst/tutorials/16_mapping_time/images/chicago_assault_trend.png"),
  plot = trend_chart,
  width = 1200 / 150,
  height = 500 / 150,
  dpi = 300
)
