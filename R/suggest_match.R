#' Given a loanbook and tilt datasets returns a dataset with suggested matches
#'
#' @param loanbook Path to a .csv file with your `loanbook` data.
#' @param tilt Path to a .csv file with 2DII's `tilt` data.
#' @param eligibility_threshold Eligibility threshold.
#' @param suggestion_threshold Suggestion threshold.
#'
#' @return A dataframe with suggested matching candidates.
#' @export
#'
#' @examples
#' library(vroom)
#' loanbook <- vroom(example_file("demo_loanbook.csv"), show_col_types = FALSE)
#' tilt <- vroom(example_file("demo_tilt.csv"), show_col_types = FALSE)
#'
#' suggest_match(loanbook, tilt)
suggest_match <- function(loanbook,
                          tilt,
                          eligibility_threshold = 0.75,
                          suggestion_threshold = 0.9) {
  loanbook_alias <- loanbook %>% mutate(company_alias = to_alias(.data$company_name))
  # TODO: We can pre-compute this before we send the tilt dataset
  tilt_alias <- tilt %>% mutate(company_alias = to_alias(.data$company_name))

  # TODO: Ignore grouping if reading and matching line by line
  lacks_none <- loanbook_alias %>%
    filter(!is.na(.data$postcode) & !is.na(.data$country)) %>%
    left_join(
      tilt_alias,
      by = c("country", "postcode"),
      suffix = c("", "_tilt"),
      multiple = "all"
    )

  lacks_postcode <- loanbook_alias %>%
    filter(is.na(.data$postcode) & !is.na(.data$country)) %>%
    left_join(
      tilt_alias,
      by = c("country"),
      suffix = c("", "_tilt"),
      multiple = "all"
    )

  lacks_country <- loanbook_alias %>%
    filter(!is.na(.data$postcode) & is.na(.data$country)) %>%
    left_join(tilt_alias, by = c("postcode"), suffix = c("", "_tilt"))

  lacks_both <- loanbook_alias %>%
    filter(is.na(.data$postcode) & is.na(.data$country)) %>%
    mutate(postcode = "join_helper") %>%
    inner_join(
      dplyr::mutate(tilt_alias, postcode = "join_helper"),
      by = c("postcode"),
      suffix = c("", "_tilt"),
      multiple = "all"
    ) %>%
    mutate(postcode = NA_character_)

  candidates <- bind_rows(lacks_none, lacks_postcode, lacks_country, lacks_both)

  okay_candidates <- candidates %>%
    # Other parameters may perform best. See `?stringdist::stringsim`
    mutate(similarity = stringsim(
      .data$company_alias, .data$company_alias_tilt,
      # Good to compare human typed text that might have typos.
      method = "jw",
      p = 0.1
    )) %>%
    # Arrange matching candidates from more to less similar
    arrange(id, -.data$similarity)

  best_candidates <- okay_candidates %>%
    filter(.data$similarity > eligibility_threshold | is.na(.data$similarity))

  unmatched <- anti_join(
    okay_candidates %>% distinct(id, .data$company_name),
    best_candidates %>% distinct(id, .data$company_name)
  )

  candidates_suggest_match <- best_candidates %>%
    # - It's the highest among all other candidates.
    group_by(id) %>%
    filter(.data$similarity == max(.data$similarity)) %>%
    # - It's above the threshold.
    filter(.data$similarity > suggestion_threshold) %>%
    # - It's the only such highest value in the group defined by a combination of
    # `company_name` x `postcode` -- to avoid duplicates.
    mutate(duplicates = any(duplicated_paste(.data$company_name, .data$postcode))) %>%
    filter(!.data$duplicates) %>%
    select("id", "id_tilt") %>%
    mutate(suggest_match = TRUE) %>%
    ungroup()

  to_edit <- best_candidates %>%
    left_join(candidates_suggest_match, by = c("id", "id_tilt")) %>%
    mutate(accept_match = NA)

  to_edit
}

#' Checks your `loanbook` is as we expect
#'
#' @param loanbook Your `loanbook` dataset.
#'
#' @return Called for it's side effects. Returns `loanbook` invisibly.
#' @export
#'
#' @examples
#' library(vroom)
#'
#' loanbook <- vroom(example_file("demo_loanbook.csv"), show_col_types = FALSE)
#' check_loanbook(loanbook)
check_loanbook <- function(loanbook) {
  expected <- c("id", "company_name", "postcode", "country")
  loanbook %>% check_crucial_names(expected)

  has_no_duplicates <- identical(anyDuplicated(loanbook$id), 0L)
  stopifnot(has_no_duplicates)

  best_without_duplicates <- c("company_name", "postcode", "country")
  report_duplicates(loanbook, best_without_duplicates)

  non_nullable <- c("id", "company_name")
  loanbook %>% abort_if_incomplete(non_nullable)

  invisible(loanbook)
}
