#' Update tutorials
#'
#' This function updates the crime mapping tutorials.
#'
#' @param ... Further arguments passed to \code{\link[remotes]{install_github}}.
#'
#' @export

update <- function(...) {

  rlang::inform(
    c(
      "UPDATING CRIME MAPPING COURSE",
      "*" = paste("Current version is ", utils::packageVersion("crimemapping")),
      "*" = "R will now update the Crime Mapping course tutorials. This may take a few minutes."
    ),
    use_cli_format = TRUE
  )

  # Download package file
  package_file <- tempfile(fileext = ".zip")
  rlang::inform("Downloading the package file ...", use_cli_format = TRUE)
  package_response <- httr::GET(
    "https://github.com/mpjashby/crimemapping/archive/refs/heads/main.zip",
    httr::timeout(600),
    httr::write_disk(package_file),
    httr::progress()
  )

  # Check download
  httr::stop_for_status(package_response)
  rlang::inform("Package file downloaded successfully", use_cli_format = TRUE)

  # Install package
  rlang::inform(
    c(
      "Attempting to install package",
      "*" = "If you are asked whether you want to update any other packages, choose to 'update CRAN packages only'.",
      "*" = "If you are asked 'Do you want to install from sources the package which needs compilation?', choose 'no'.",
      "*" = "Another message will appear when the process is complete.",
      "!" = "IF YOU ARE ASKED TO RESTART R, PLEASE DO SO"
    ),
    use_cli_format = TRUE
  )
  remotes::install_local(package_file, upgrade = "always", ...)

  rlang::inform(
    c(
      "!" = "If the installation was successful, the line above will say 'DONE (crimemapping)'."
    ),
    use_cli_format = TRUE
  )

}
