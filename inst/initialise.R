# print initial message
message(
  "\n\n-------------------------\n\n",
  "CRIME MAPPING COURSE SETUP\n\n",
  "This code sets up RStudio for the UCL Crime Mapping module (SECU0005). More\n",
  "specifically, it installs R packages that you will need for this module. The\n",
  "code may take a few minutes to run and R will print messages for each\n",
  "package being installed. If you have any questions, please ask them on the\n",
  "module Q&A forum on Moodle at:\n\n",
  "    https://moodle.ucl.ac.uk/mod/hsuforum/view.php?id=1753357\n\n",
  "(be warned that R may have wrapped this URL by inserting spaces into it).\n\n",
  "Another message will appear when the process is complete.\n\n",
  "-------------------------\n\n"
)

# install packages
# {ggspatial} uses {rosm} to download OSM map tiles and {rosm} needs {raster} to
# render them, but {rosm} only Suggests {raster} rather than Importing it. If
# {raster} is not installed on a user's machine, {learnr} will not install it
# when loading the tutorial because {learnr} only installs Imported packages.
# By installing {raster} explicitly, we avoid the code in the tutorials failing.
invisible(lapply(
  c("tidyverse", "crimedata", "learnr", "remotes", "raster"),
  function (x) {
    if (x %in% installed.packages()) {
      message(paste("package", x, "already installed"))
    } else {
      install.packages(x, verbose = FALSE)
    }
  }
))
remotes::install_github("mpjashby/crimemapping", upgrade = "always")

# print final message
message(
  "\n\n-------------------------\n\n",
  "CRIME MAPPING COURSE SETUP COMPLETED\n\n",
  "If any errors or warnings occurred during setup, please post the complete \n",
  "error message on the module Q&A forum on Moodle at:\n\n",
  "    https://moodle.ucl.ac.uk/mod/hsuforum/view.php?id=1753357\n\n",
  "(be warned that R may have wrapped this URL by inserting spaces into it).\n\n",
  "-------------------------\n\n"
)

# restart R to load tutorials into Tutorial tab
if ("rstudioapi" %in% rownames(installed.packages())) {
  rstudioapi::restartSession()
} else {
  message(
    "IMPORTANT! Click 'Session' > 'Restart R' to complete the installation ",
    "process.\n\n-------------------------\n\n"
    )
}
