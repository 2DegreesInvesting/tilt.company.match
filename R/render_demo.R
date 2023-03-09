#' Render a github_document under inst/demo
#'
#' This function helps gyou show the rendered version of an article to reviewers.
#' This is useful while a PR is open but should remember to delete it before
#' merging it.
#'
#'
#' @param path Path to an .Rmd file. In RStudio you may option-click on the
#' file tab then click "Copy Path".
#'
#' @return Called for its side effect. Returns invisible `path`.
#' @examples
#' render_demo(here::here("README.Rmd"))
#' @noRd
render_demo <- function(path){
  parent <- fs::dir_create(testthat::test_path("demos"))
  rmarkdown::render(
    path,
    output_format = "github_document",
    output_file = fs::path(parent, file_md(path))
  )
  invisible(path)
}

file_md <- function(path) {
  fs::path_ext_set(fs::path_ext_remove(fs::path_file(path)), ".md")
}
