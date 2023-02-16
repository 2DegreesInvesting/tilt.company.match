check_missing <- function(data, non_nullable_cols) {
  abort_if_not_complete(data[non_nullable_cols])

  complete <- identical(ncol(keep_missing(data[non_nullable_cols])), 0L)
  if (complete) {
    warn_if_not_complete(data)
  }

  invisible(data)
}

abort_if_not_complete <- function(data) {
  alert_if_not_complete(
    data,
    msg = "Non-nullable columns must not have `NA`s.",
    .f = rlang::abort
  )
  invisible(data)
}

warn_if_not_complete <- function(data) {
  alert_if_not_complete(
    data,
    msg = "Found `NA`s in nullable columns.",
    rlang::warn
  )
  invisible(data)
}

alert_if_not_complete <- function(data, msg, .f = rlang::abort) {
  meets_condition <- unlist(lapply(keep_missing(data), anyNA))
  if (any(meets_condition)) {
    cols <- toString(names(meets_condition[meets_condition]))
    .f(c(msg, x = paste0("Columns to review: ", cols)))
  }
  invisible(data)
}

keep_missing <- function(data) {
  purrr::keep(data, function(x) any(is.na(x)))
}
