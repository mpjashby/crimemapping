#' Update tutorials
#'
#' This function updates the crime mapping tutorials.
#'
#' @param ... Further arguments passed to \code{\link[remotes]{install_github}}.
#'
#' @export

update <- function (...) {

  message(
    "\n\n--------------------------------------------------------------------------------\n\n",
    "UPDATING CRIME MAPPING COURSE\n\n",
    "R will now update the Crime Mapping course tutorials. This may take\n",
    "a few minutes. If you are asked whether you want to update any other\n",
    "packages, choose to 'update CRAN packages only'. If you are asked\n",
    "'Do you want to install from sources the package which needs \n",
    "compilation?', choose 'no'.\n\n",
    "Another message will appear when the process is complete.\n\n",
    "IF YOU ARE ASKED TO RESTART R, PLEASE DO SO\n\n",
    "--------------------------------------------------------------------------------\n\n"
  )

  remotes::install_github("mpjashby/crimemapping", upgrade = "always", ...)

  message(
    "\n\n--------------------------------------------------------------------------------\n\n",
    "CRIME MAPPING COURSE UPDATE COMPLETED\n\n",
    "--------------------------------------------------------------------------------\n\n"
  )

}
