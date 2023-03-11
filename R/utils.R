#' Report duplicate rows
#'
#' Reports duplicates in `data` on columns `cols`. More specifically, we are
#' interested in this case on the `company_name`, `postcode` and `country`
#' columns. Duplicates are reported via a warning.
#'
#' @param data Tibble holding a result data set.
#' @param cols Vector of columns names on which we want to test if there are
#' duplicates on.
#'
#' @return NULL
#' @export
#' @keywords internal
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
        x = duplicates %>% glue::glue_data("Found for the company {company_name}, postcode: {postcode}, country: {country}"),
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
#' @param manually_matched Tibble holding the result of the matching process,
#'   after the user has manually selected and matched the companies in the
#'   loanbook with the tilt data set.
#'
#' @return `not_matched_companies` Tibble holding id and company name of the
#'   companies not matched by the tilt data set.
#'
#' @export
#' @keywords internal
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

#' Reports duplicates from manual matching outcome
#'
#' Function throws a descriptive error if a company from the loanbook is
#' matched to > 1 company in the tilt db or reverse.
#'
#'
#' @param manually_matched Tibble holding the result of the matching process,
#'   after the user has manually verified and matched the results
#'
#' @return Input `manually_matched`
#' @importFrom rlang .data
#' @export
check_duplicated_relation <- function(manually_matched) {
  suggested_matches <- manually_matched %>%
    dplyr::filter(.data$accept_match)

  duplicates_in_loanbook <- suggested_matches %>%
    dplyr::group_by(.data$id, .data$company_name) %>%
    dplyr::mutate(nrow = dplyr::n()) %>%
    dplyr::filter(nrow > 1)

  if (nrow(duplicates_in_loanbook) > 0) {
    duplicated_companies <- duplicates_in_loanbook %>%
      dplyr::distinct(.data$id, .data$company_name)

    rlang::abort(
      c(
        "Duplicated match of company in loanbook detected.",
        x = duplicated_companies %>% glue::glue_data("Duplicated company name: {company_name}, id: {id}."),
        i = c(
          "Company names where `accept_match` is `TRUE` must be unique by `id`.",
          "Have you ensured that only one tilt-id per loanbook-id is set to `TRUE`?"
        )
      )
    )
  }

  duplicates_in_tilt <- suggested_matches %>%
    dplyr::group_by(.data$id_tilt, .data$company_name_tilt) %>%
    dplyr::mutate(nrow = dplyr::n()) %>%
    dplyr::filter(nrow > 1)

  if (nrow(duplicates_in_tilt) > 0) {
    duplicated_companies <- duplicates_in_tilt %>%
      dplyr::distinct(.data$id_tilt)

    rlang::abort(
      c(
        "Duplicated match of company from tilt db detected.",
        x = duplicated_companies %>% glue::glue_data("Duplicated tilt company name: {company_name_tilt}, tilt id: {id_tilt}."),
        i = c(
          "Have you ensured that each tilt-id is set to `TRUE` for maximum 1 company from the loanbook?"
        )
      )
    )
  }

  rlang::inform(message = "No duplicated matches found in the data.")

  return(invisible(manually_matched))
}

#' Render a .Rmd file into a .md file under tests/testthat/demos
#'
#' One use case of this  function is when you are working on a PR and want to
#' share the output of an .Rmd file. Once done would delete the .md file and
#' merge the PR.
#' @noRd
#' @examples
#' render_demo("vignettes/articles/tilt-company-match.Rmd")
render_demo <- function(path) {
  md <- path |>
    fs::path_file() |>
    fs::path_ext_remove() |>
    fs::path_ext_set(".md")

  parent <- fs::dir_create(here::here(testthat::test_path("demos")))
  rmarkdown::render(
    path,
    "md_document",
    output_file = fs::path(parent, md)
  )

  invisible(path)
}
