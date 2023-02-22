#' Duplicated paste
#'
#' `duplicated_paste` check for duplicates on multiple rows / columns.
#'
#' @param ... Typically columns of a data set, e.g. company_name and postcode.
#' @return A vector of booleans: TRUE if the value is a duplicate, FALSE if not.
#' @export

duplicated_paste <- function(...) {
  duplicated(paste(...))
}
