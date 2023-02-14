#' Report missing
#'
#' Function that reports number of missing values per columns found in the data
#' and throw error if missing are around on `not_nullable_cols`.
#'
#' @param data Tibble holding a result data set.
#' @param not_nullable_cols A character vector holding names of columns on which
#'   NAs are not allowed.
#'
#'
#' @return Input `data` invisibly.
#' @export
report_missings <- function(data, not_nullable_cols = c("id", "company_name")) {
  missings_per_col <- purrr::map_df(data, function(x) sum(is.na(x)))

  has_missings <- rowSums(missings_per_col)
  not_nullable_cols_w_missings <- not_nullable_cols %>%
    purrr::map(function(x) {
      nas_in_col <- missings_per_col %>%
        dplyr::pull(!!rlang::sym(x))
      if (nas_in_col > 0) {
        return(x)
      }
    }) %>%
    unlist()

  if (has_missings) {
    cat("Reporting missings on the dataset", "\n")
    purrr::iwalk(as.list(missings_per_col), function(n_na, name) {
      if (n_na > 0) {
        cat("Counted", n_na, "missings on column", name, "\n")
      }
    })
    cat("\n\n")

    if (!is.null(not_nullable_cols_w_missings)) {

      affected_cols <- paste(not_nullable_cols_w_missings, collapse = ", ")
      rlang::abort(
        c(
          "Missings detected on the data set.",
          x = "We expect no NAs in the tilt or loanbook data set.",
          i = glue::glue("Please remove cases with missings on the following colums:", {affected_cols})
        )
      )
    }
  } else {
    rlang::inform(
      message = "No missings values found in the data."
    )
  }

  return(invisible(data))
}
