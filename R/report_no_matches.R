#' Reports companies that were not matched in the loanbook
#'
#' @param loanbook Loanbook data set
#'
#' @param manually_matched Tibble holding the result of the matching process, after the
#'   user has manually selected and matched the companies in the loanbook with
#'   the tilt data set.
#'
#' @return `not_matched_companies` Tibble holding id and company name of the companies
#' not matched by the tilt data set.
#'
#' @export
report_no_matches <- function(loanbook, manually_matched) {
  force(loanbook)
  force(manually_matched)
  # Filter first by all the manual successful matches in order to
  # suppress the duplicates caused by the string matching.
  matched <- manually_matched %>%
    dplyr::filter(.data$accept_match == TRUE)

  coverage <- dplyr::left_join(loanbook, matched) %>%
    dplyr::mutate(
      matched = dplyr::case_when(
        accept_match == TRUE ~ "Matched",
        is.na(accept_match) ~ "Not Matched",
        TRUE ~ "Not Matched"
      )
    )

  not_matched_companies <- coverage %>%
    dplyr::filter(matched == "Not Matched") %>%
    dplyr::distinct(.data$company_name, .data$id)

  if (nrow(not_matched_companies > 0)) {
    rlang::inform(
      c(
        "Companies not matched in the loanbook by the tilt data set:",
        x = not_matched_companies %>%
          glue::glue_data("{company_name}"),
        i = "Did you match these companies manually correctly ?"
      )
    )
  }

  return(not_matched_companies)
}
