#' Get the path to an example file
#'
#' @param file Name of the file.
#'
#' @return A path.
#' @export
#'
#' @examples
#' example_file("demo_loanbook.csv")
#'
#' example_file("demo_tilt.csv")
#'
#' example_file("demo_matched.csv")
example_file <- function(file) {
  system.file("extdata", file, package = "tilt.company.match", mustWork = TRUE)
}
