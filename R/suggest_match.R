suggest_match <- function() {
  rmd <- fs::path_package("templates", "1.Rmd", package = "tilt.company.match")
  dir <- withr::local_tempdir()
  withr::local_dir(dir)

  tmp_rmd <- fs::path(dir, fs::path_file(rmd))
  fs::file_copy(rmd, tmp_rmd)
  rmarkdown::render(tmp_rmd, quiet = TRUE)

  out <- read("to_edit.csv")
  out
}

read <- function(...) {
  vroom::vroom(..., show_col_types = FALSE)
}
