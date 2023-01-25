# First install {rlang} so that we can use it for messages
install.packages("rlang")

# Print initial message
rlang::inform(
  c(
    "CRIME MAPPING COURSE SETUP",
    "*" = "This code sets up RStudio for the UCL Crime Mapping module (SECU0005). More specifically, it installs some R packages that you will need for this module.",
    "*" = "The code may take a few minutes to run and R will print messages for each package being installed.",
    "*" = "If you have any questions, please ask them on the module Q&A forum on Moodle at https://moodle.ucl.ac.uk/mod/hsuforum/view.php?id=4439091"
  ),
  use_cli_format = TRUE
)

# Install packages
# {ggspatial} uses {rosm} to download OSM map tiles and {rosm} needs {raster} to
# render them, but {rosm} only Suggests {raster} rather than Importing it. If
# {raster} is not installed on a user's machine, {learnr} will not install it
# when loading the tutorial because {learnr} only installs Imported packages.
# By installing {raster} explicitly, we avoid the code in the tutorials failing.
invisible(lapply(
  c("tidyverse", "learnr", "remotes", "raster"),
  install.packages(x, verbose = FALSE)
))
remotes::install_github("mpjashby/crimemapping", upgrade = "always")

# Print final message
rlang::inform(
  c(
    "CRIME MAPPING COURSE SETUP FINISHED",
    "*" = "If any errors or warnings occurred during setup, please post the complete error message on the module Q&A forum on Moodle at https://moodle.ucl.ac.uk/mod/hsuforum/view.php?id=4439091"
  ),
  use_cli_format = TRUE
)

# Restart R to load tutorials into Tutorial tab
if ("rstudioapi" %in% rownames(installed.packages())) {
  rstudioapi::restartSession()
} else {
  rlang::inform(
    c(
      "IMPORTANT",
      "Click 'Session' > 'Restart R' to complete the installation process."
    ),
    use_cli_format = TRUE
  )
}
