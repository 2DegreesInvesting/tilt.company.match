#' Detect duplicated strings
#'
#' @inheritParams base::paste
#' @export
#' @examples
#' duplicated_paste(c("a", "a"), 1:2)
#' paste(c("a", "a"), 1:2)
#'
#' duplicated_paste(c("a", "a"), c(1, 1))
#' paste(c("a", "a"), c(1, 1))
duplicated_paste <- function(...) {
  duplicated(paste(...))
}
