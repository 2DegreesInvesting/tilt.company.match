#' Aborts when data has missing values on non-nullable columns
#'
#' @param data Tibble holding a result data set.
#' @param non_nullable_cols A character vector holding names of columns on which
#'   `NA`s are not allowed.
#'
#' @return Input `data` invisibly.
#' @export
#'
#' @examples
#' data <- tibble::tibble(x = NA, y = 1, z = NA)
#'
#' # With NA in nullable columns returns data invisibly
#' data %>% abort_if_incomplete(non_nullable_cols = "y")
#' out <- data %>% abort_if_incomplete(non_nullable_cols = "y")
#' identical(out, data)
#'
#' # With NA in one nullable column, alerts the column to review as an error
#' data %>%
#'   abort_if_incomplete(non_nullable_cols = c("x", "y")) %>%
#'   try()
#'
#' # By default, it takes all columns as non-nullable
#' data %>%
#'   abort_if_incomplete() %>%
#'   try()
#' @keywords internal
abort_if_incomplete <- function(data, non_nullable_cols = names(data)) {
  incomplete <- select_incomplete(data[non_nullable_cols])
  if (any(incomplete)) {
    cols <- toString(names(incomplete[incomplete]))
    rlang::abort(c(
      "Non-nullable columns must not have `NA`s.",
      x = paste0("Columns to review: ", cols)
    ))
  }
  invisible(data)
}

select_incomplete <- function(data) {
  missing <- purrr::keep(data, function(x) any(is.na(x)))
  unlist(lapply(missing, anyNA))
}
