#' Report missing
#'
#' Function that reports number of missing values per columns found in the data set.
#'
#' @param data Tibble holding a result data set.
#'
#'
#' @return Input `data`.
#' @export
report_missings <- function(data) {
  missings_per_col <- purrr::map_df(data, function(x) sum(is.na(x)))

  has_missings <- rowSums(missings_per_col)

  if (has_missings) {
    cat("Reporting missings on the dataset", "\n")
    purrr::iwalk(as.list(missings_per_col), function(n_na, name) {
      if (n_na > 0) {
        cat("Counted", n_na, "missings on column", name, "\n")
      }
    })
    cat("\n\n")

    rlang::abort(
      c(
        "Missings detected on the data set.",
        x = glue::glue("We expect no NAs in the tilt or loanbook data set."),
        i = "Please check the columns that have missing information."
      )
    )
  } else {
    rlang::inform(
      message = "No missings values found in the data."
    )
  }

  return(invisible(data))
}

#' Report duplicate rows
#'
#' Reports duplicates in `data` on columns `cols`. More specifically, we are
#' interested in this case on the `company_name`, `zip` and `country` columns.
#' Duplicates are reported via a warning.
#'
#' @param data Tibble holding a result data set.
#' @param cols Vector of columns names on which we want to test if there are
#' duplicates on.
#'
#' @return NULL
#' @export
report_duplicates <- function(data, cols) {
  duplicates <- data %>%
    dplyr::group_by(!!!rlang::syms(cols)) %>%
    dplyr::filter(dplyr::n() > 1) %>%
    dplyr::select(!!!rlang::syms(cols)) %>%
    dplyr::distinct_all()

  if (nrow(duplicates) > 0) {
    rlang::inform(
      c(
        paste0("Found duplicate(s) on columns ", paste(cols, collapse = ", "), " of the data set."),
        x = duplicates %>% glue::glue_data("Found for the company {company_name}, zip: {zip}, country: {country}"),
        i = "Please check if these duplicates are intended and have an unique id."
      )
    )
  }

  return(invisible())
}

#' Reports companies that were not matched in the loanbook
#'
#' @param loanbook Loanbook data set
#'
#' @param manually_matched Tibble holding the result of the matching process, after the
#'   user has manually selected and matched the companies in the loanbook with
#'   the tiltdata set.
#'
#' @return `not_matched_companies` Tibble holding id and company name of the companies
#' not matched by the tilt data set.
#'
#' @export
report_no_matches <- function(loanbook, manually_matched) {

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

#' Reports duplicates id on manual matched errors
#'
#'
#' @param manually_matched Tibble holding the result of the matching process, after the
#'   user has manually verified and matched the results
#'
#' @return Input `manually_matched`
#' @importFrom rlang .data
#' @export
check_duplicated_score <- function(manually_matched) {
  numbers_duplicates <- manually_matched %>%
    dplyr::filter(.data$accept_match) %>%
    dplyr::group_by(.data$id, .data$company_name) %>%
    dplyr::mutate(nrow = dplyr::n())

  duplicates <- numbers_duplicates %>%
    dplyr::filter(nrow > 1)

  if (nrow(duplicates) > 1) {
    duplicated_companies <- duplicates %>%
      dplyr::distinct(.data$id, .data$company_name)

    rlang::abort(
      c(
        "Duplicated score detected on the data set.",
        x = duplicated_companies %>% glue::glue_data("Duplicated company name: {company_name}, id: {id}."),
        i = c(
          "Company names where `accept_match` is `TRUE` must be unique by `id`.",
          "Have you ensured that only one tilt-name per loanbook-name is set to `TRUE`?"
        )
      )
    )
  } else {
    rlang::inform(
      message = "There is no duplicated matches found in the data."
    )
    return(invisible(manually_matched))
  }
}
