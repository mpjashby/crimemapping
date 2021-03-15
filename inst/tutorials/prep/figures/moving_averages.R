library(tidyverse)

ma <- tibble(
  period = rep(2:5, times = 4),
  week = rep(1:4, each = 4)
) %>%
  mutate(period = period + (week  -1), included = TRUE) %>%
  complete(period, week, fill = list(included = FALSE)) %>%
  add_row(period = 1, week = 1:4, included = FALSE) %>%
  add_row(period = 9, week = 1:4, included = FALSE) %>%
  arrange(week, period) %>%
  group_by(week) %>%
  mutate(
    last = (lead(included) != included & !is.na(lead(included)) & included == TRUE) | (included == TRUE & row_number() == n())
  ) %>%
  ungroup()

ggplot(ma) +
  geom_point(aes(period, week, fill = included, size = last), shape = 21) +
  geom_line(aes(period, week, group = week), data = filter(ma, included), show.legend = FALSE) +
  annotate("curve", x = 7.55, y = 4.5, xend = 8, yend = 4.1, curvature = -0.35, arrow = arrow(length = unit(0.5, "lines"))) +
  annotate("text", x = 7.5, y = 4.5, hjust = 1, label = "week for which the moving\naverage is calculated", lineheight = 0.9) +
  annotate("curve", x = 6.05, y = 3.5, xend = 6.5, yend = 3.95, curvature = 0.35, arrow = arrow(length = unit(0.5, "lines"))) +
  annotate("text", x = 6, y = 3.5, hjust = 1, label = "the 'window' of weeks included\nin the moving average calculation", lineheight = 0.9) +
  scale_x_continuous(n.breaks = 10) +
  scale_y_continuous(minor_breaks = NULL, expand = c(0.05, 0.1)) +
  scale_fill_manual(
    values = c(`TRUE` = "black", `FALSE` = "white")
  ) +
  scale_size_manual(
    values = c(`TRUE` = 3, `FALSE` = 1)
  ) +
  labs(
    title = "How moving averages are calculated",
    x = "week"
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_blank(),
    axis.title.y = element_blank(),
    legend.position = "none",
    legend.title = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
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
  filename = here::here("inst/tutorials/16_mapping_time/images/moving_averages.png"),
  width = 1200 / 150,
  height = 500 / 150,
  dpi = 300
)
