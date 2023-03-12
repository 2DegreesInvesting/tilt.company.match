#' Reports companies that were not matched in the loanbook
#'
#' @param loanbook Loanbook data set
#'
#' @param manually_matched Tibble holding the result of the matching process,
#'   after the user has manually selected and matched the companies in the
#'   loanbook with the tilt data set.
#'
#' @return `not_matched_companies` Tibble holding id and company name of the
#'   companies not matched by the tilt data set.
#'
#' @export
#' library(tibble)
#'
#' loanbook <- tibble(id = 1:2, company_name = letters[id], irrelevant = "xyz")
#' loanbook
#'
#' accepted <- tibble(id = 1:2, accept_match = c(TRUE, FALSE))
#' accepted
#'
#' report_no_matches(loanbook, accepted)
#'
#' # It's rigurous but fails with informative messages:
#' # The names of crucial columns must be as documented.
#' try(report_no_matches(loanbook, tibble(ids = 1, accept_match = TRUE)))
#'
#' # The type of `accept_match` must be as documented.
#' try(report_no_matches(loanbook, tibble(id = 1, accept_match = "TRUE")))
report_no_matches <- function(loanbook, manually_matched) {
  check_crucial_names(loanbook, c("id", "company_name"))
  check_crucial_names(manually_matched, c("id", "accept_match"))
  vctrs::vec_assert(manually_matched$accept_match, logical())

  # Filter first by all the manual successful matches in order to
  # suppress the duplicates caused by the string matching.
  matched <- dplyr::filter(manually_matched, .data$accept_match)

  # TODO: Simplify with `anti_join()`
  dplyr::left_join(loanbook, matched) %>%
    suppressMessages() |>
    dplyr::mutate(
      matched = dplyr::case_when(
        accept_match == TRUE ~ "Matched",
        is.na(accept_match) ~ "Not Matched",
        TRUE ~ "Not Matched"
      )
    ) |>
    dplyr::filter(matched == "Not Matched") %>%
    dplyr::distinct(.data$company_name, .data$id)
}
