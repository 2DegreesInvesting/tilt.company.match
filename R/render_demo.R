#' Render a .Rmd file into a .md file under tests/testthat/demos
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
