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
#' @keywords internal
report_no_matches <- function(loanbook, manually_matched) {
  force(loanbook)
  force(manually_matched)

  loanbook |>
    check_crucial_names(c("id", "company_name"))
  manually_matched |>
    check_crucial_names(c("id", "accept_match"))

  # Filter first by all the manual successful matches in order to
  # suppress the duplicates caused by the string matching.
  matched <- manually_matched %>%
    dplyr::filter(.data$accept_match == TRUE)

  coverage <- dplyr::left_join(loanbook, matched) %>%
    dplyr::mutate(
      matched = dplyr::case_when(
        accept_match == TRUE ~ "Matched",
        is.na(accept_match) ~ "Not Matched",
        TRUE ~ "Not Matched"  # TODO: Use .default instead
      )
    )

  not_matched_companies <- coverage %>%
    dplyr::filter(matched == "Not Matched") %>%
    # We no longer use the `matched` column so we may not create it and instead
    # use `is.na(accept_match)` directly
    dplyr::distinct(.data$company_name, .data$id)

  if (nrow(not_matched_companies > 0)) {
    # FIXME: Throw a warning instead (rename to `warn_unmatched()`). This way
    # its easier to test the warning from messages like "joining by ..."
    rlang::inform(
      c(
        "Companies not matched in the loanbook by the tilt data set:",
        x = not_matched_companies %>%
          glue::glue_data("{company_name}"),
        i = "Did you match these companies manually correctly ?"
      )
    )
  }
  # FIXME: This function is called for its side effects so it should return
  # the first argumet
  return(not_matched_companies)
}
