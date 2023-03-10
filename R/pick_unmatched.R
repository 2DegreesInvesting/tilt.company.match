#' Pick unmatched `id` and `company_name` from a loanbook
#'
#' @param loanbook A data frame with columns `id` and `company_name`.
#' @param accepted A data frame with columns `id` and `accept_match` (of type
#'   logical).
#'
#' @return A data frame with columns `id` and `company_name` reflecting the
#'   `looanbook` rows that don't match the `accepted` data frame.
#' @export
#'
#' @examples
#' library(tibble)
#'
#' loanbook <- tibble(id = 1:2, company_name = letters[id], irrelevant = "xyz")
#' loanbook
#'
#' accepted <- tibble(id = 1:2, accept_match = c(TRUE, FALSE))
#' accepted
#'
#' pick_unmatched(loanbook, accepted)
#'
#' # It's rigurous but fails with informative messages:
#' # The names of crucial columns must be as documented.
#' try(pick_unmatched(loanbook, tibble(ids = 1, accept_match = TRUE)))
#'
#' # The type of `accept_match` must be as documented.
#' try(pick_unmatched(loanbook, tibble(id = 1, accept_match = "TRUE")))
pick_unmatched <- function(loanbook, accepted) {
  check_crucial_names(loanbook, c("id", "company_name"))
  check_crucial_names(accepted, c("id", "accept_match"))
  vctrs::vec_assert(accepted$accept_match, logical())

  .y <- select(accepted, "id", "accept_match")
  .x <- select(loanbook, "id", "company_name")
  anti_join(.x, filter(.y, .data$accept_match), by = "id")
}
