#' Help read an example file
#' @examples
#' read_example("demo_loanbook.csv")
#' @noRd
read_example <- function(file) {
  vroom::vroom(example_file(file), show_col_types = FALSE)
}
