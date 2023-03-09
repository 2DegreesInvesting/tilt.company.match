#' Render a .Rmd file into a .md file under tests/testthat/demos
#'
#' One use case of this  function is when you are working on a PR and want to
#' share the output of an .Rmd file. Once done would delete the .md file and
#' merge the PR.
#' @noRd
#' @examples
#' render_demo("vignettes/articles/tilt-company-match.Rmd")
render_demo <- function(path) {
  md <- path |>
    fs::path_file() |>
    fs::path_ext_remove() |>
    fs::path_ext_set(".md")

  parent <- fs::dir_create(here::here(testthat::test_path("demos")))
  rmarkdown::render(
    path,
    "md_document",
    output_file = fs::path(parent, md)
  )

  invisible(path)
}
