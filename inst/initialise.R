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

# load packages
install.packages(
  c("tidyverse", "crimedata", "learnr", "remotes")
  verbose = FALSE
)
remotes::install_github(
  "mpjashby/crimemapping",
  upgrade = "always"
)

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
