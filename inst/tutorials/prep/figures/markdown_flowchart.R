library(Gmisc)

box_markdown <- boxGrob(
  "a Markdown\ndocument",
  x = unit(0.2, "npc"),
  bjust = "right"
)
box_rstudio <- boxGrob("… can be processed\nby RStudio into …")
box_word <- boxGrob(
  "Word",
  x = unit(0.8, "npc"),
  y = unit(0.8, "npc"),
  width = unit(0.15, "npc"),
  bjust = "left"
)
box_pdf <- boxGrob(
  "PDF",
  x = unit(0.8, "npc"),
  y = unit(0.65, "npc"),
  width = unit(0.15, "npc"),
  bjust = "left"
)
box_pp <- boxGrob(
  "PowerPoint",
  x = unit(0.8, "npc"),
  y = unit(0.5, "npc"),
  width = unit(0.15, "npc"),
  bjust = "left"
)
box_web <- boxGrob(
  "web page",
  x = unit(0.8, "npc"),
  y = unit(0.35, "npc"),
  width = unit(0.15, "npc"),
  bjust = "left"
)
box_other <- boxGrob(
  "other formats",
  x = unit(0.8, "npc"),
  y = unit(0.2, "npc"),
  width = unit(0.15, "npc"),
  bjust = "left"
)

arw <- arrow(type = "open")

# create file
png(
  here::here("inst/tutorials/14_writing_reports/images/markdown_flowchart.png"),
  width = 800,
  height = 300,
  units = "px"
)

# create new page
grid::grid.newpage()

# print connections
connectGrob(box_markdown, box_rstudio, type = "horizontal", arrow_obj = arw)
connectGrob(box_rstudio, box_word, type = "Z", arrow_obj = arw)
connectGrob(box_rstudio, box_pdf, type = "Z", arrow_obj = arw)
connectGrob(box_rstudio, box_pp, type = "Z", arrow_obj = arw)
connectGrob(box_rstudio, box_web, type = "Z", arrow_obj = arw)
connectGrob(box_rstudio, box_other, type = "Z", arrow_obj = arw)

# print boxes
box_markdown
box_rstudio
box_word
box_pdf
box_pp
box_web
box_other

# write plot to file
dev.off()
