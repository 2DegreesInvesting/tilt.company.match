#' Detect duplicated strings
#'
#' @inheritDotParams base::paste
#' @return  A logical vector of the same length as the longest vector passed to
#'   `...`.
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
