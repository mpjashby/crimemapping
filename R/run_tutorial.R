#' Run tutorial
#'
#' This function runs a crime mapping tutorial.
#'
#' @param name Name of the tutorial to be loaded
#'
#' @export


tutorial <- function(name = NULL) {

  learnr::run_tutorial(name = name, package = "crimemapping")

}
