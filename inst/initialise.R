# print initial message
message(
  "\n\n-------------------------\n\nCRIME MAPPING MODULE SETUP\n\nThis code ",
  "sets up RStudio for the UCL Crime Mapping module (SECU0005). More ",
  "specifically, it installs R packages that you will need for this module. ",
  "The code may take a few minutes to run and R will print messages for each ",
  "package being installed. If you have any questions, please ask them on the ",
  "module Q&A forum on Moodle at:\n\n    ",
  "https://moodle.ucl.ac.uk/mod/hsuforum/view.php?id=1753357",
  "\n\n(be warned that R may have wrapped this URL by inserting spaces into ",
  "it).\n\n-------------------------\n\n"
)

# download only binary packages
options(install.packages.check.source = "no")

# load packages
message("\nInstalling the tidyverse suite of packages for data science")
install.packages("tidyverse")
message("\nInstalling the crimedata package for accessing crime data")
install.packages("crimedata")
message("\nInstalling the learnr package for interactive tutorials in RStudio")
install.packages("learnr")
message("\nInstalling the remotes package for installing packages from GitHub")
install.packages("remotes")
message("\nInstalling the crimemapping package of crime mapping tutorials")
remotes::install_github("mpjashby/crimemapping")

# print final message
message(
  "\n\n-------------------------\n\nCRIME MAPPING MODULE SETUP COMPLETED\n\n",
  "If any errors occurred during setup, please post the complete error ",
  "message on the module Q&A forum on Moodle at:\n\n    ",
  "https://moodle.ucl.ac.uk/mod/hsuforum/view.php?id=1753357",
  "\n\n(be warned that R may have wrapped this URL by inserting spaces into ",
  "it).\n\n-------------------------\n\n"
)

# restart R to load tutorials into Tutorial tab
if ("rstudioapi" %in% rownames(installed.packages())) {
  rstudioapi::restartSession()
} else {
  message("IMPORTANT! Click 'Session' > 'Restart R' to complete the installation process.\n\n-------------------------\n\n")
}
