#' Suggest matching companies in a `loanbook` and `tilt` datasets
#'
#' This function suggests that a company in your `loanbook` is the same as a
#' company in the `tilt` dataset when the `similarity` between their names meets
#' all of these conditions:
#' * It's the highest among all other candidates.
#' * It's above the value set in the argument `suggestion_threshold`.
#' * It's the only such highest value in the group defined by a combination of
#' `company_name` x `postcode` -- to avoid duplicates.
#'
#' This function calculates the similarity between a standardized alias of the
#' `company_name` from the `loanbook` and `tilt` datasets. The standardized
#' alias makes real matches more likely by applying common best practices in
#' names matching. Complete similarity corresponds to `1`, and complete
#' dissimilarity corresponds to `0`.
#'
#' The columns `postcode` and `country` affect the quality of the matches and
#' the amount of manual-validation work ahead:
#' * If your `loanbook` has both `postcode` and `country` we match companies in
#' that specific `postcode` and that specific `country`. You will likely match
#' companies that are really the same (true positives) because it's unlikely
#' that two companies with similar name will be located close to each other.
#' This will cost you the minimum amount of manual-validation work ahead.
#' * If your `loanbook` lacks `postcode` but has `country` we match companies in
#' that specific `country` but across every `postcode`. You will possibly match
#' companies that are not really the same (false positives) but happen to have a
#' similar name and are located in the same `country`. This will cost you
#' additional manual-validation work ahead.
#' * If your `loanbook` has `postcode` but lacks `country` we match companies with
#' the same `postcode` but  across every `country`. You will possibly match
#' companies that are not really the same (false positives) but happen to have a
#' similar name and the same
#' postcode. This will cost you additional manual-validation work ahead.
#' * If your `loanbook` lacks both `postcode` and `country` we match companies
#' across the entire dataset.  You will most likely match companies that are not
#' really the same (false positives). This will cost you the greatest amount of
#' additional manual-validation work ahead.
#'
#' @param loanbook A `loanbook` dataframe like [demo_loanbook].
#' @param tilt A `tilt` dataframe like [demo_tilt].
#' @param eligibility_threshold Minimum value of `similarity` to keep a
#'   candidate match. Values under it are most likely false positives and thus
#'   dropped. This drastically reduce the number of candidates you'll need to
#'   validate manually. We believe this benefit outweighs the potential loss of
#'   a few true positives.
#' @param suggestion_threshold Value of `similarity` above which a match may be
#'   suggested.
#'
#' @return A dataframe with columns from the `loanbook` and `tilt` datasets and
#'   additional columns `similarity`, `suggest_match` and `accept_match`. For
#'   each company in the `loanbook` matching candidates are arranged by
#'   descending `similarity`.
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
    ) |>
    suppressMessages()

  lacks_postcode <- loanbook_alias %>%
    filter(is.na(.data$postcode) & !is.na(.data$country)) %>%
    left_join(
      tilt_alias,
      by = c("country"),
      suffix = c("", "_tilt"),
      multiple = "all"
    ) %>%
    suppressMessages()

  lacks_country <- loanbook_alias %>%
    filter(!is.na(.data$postcode) & is.na(.data$country)) %>%
    left_join(tilt_alias, by = c("postcode"), suffix = c("", "_tilt")) %>%
    suppressMessages()

  lacks_both <- loanbook_alias %>%
    filter(is.na(.data$postcode) & is.na(.data$country)) %>%
    mutate(postcode = "join_helper") %>%
    inner_join(
      dplyr::mutate(tilt_alias, postcode = "join_helper"),
      by = c("postcode"),
      suffix = c("", "_tilt"),
      multiple = "all"
    ) %>%
    suppressMessages() %>%
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
  # FIXME: Dead code?
  unmatched <- anti_join(
    okay_candidates %>% distinct(id, .data$company_name),
    best_candidates %>% distinct(id, .data$company_name)
  ) %>%
    suppressMessages()

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
    suppressMessages() %>%
    mutate(accept_match = NA)

  to_edit
}

#' Checks your `loanbook` is as we expect
#'
#' @param loanbook A `loanbook` dataframe like [demo_loanbook].
#'
#' @return Called for it's side effects. Returns `loanbook` invisibly.
#' @export
#'
#' @examples
#' library(vroom)
#' library(dplyr, warn.conflicts = FALSE)
#'
#' loanbook <- vroom(example_file("demo_loanbook.csv"), show_col_types = FALSE)
#' check_loanbook(loanbook)
#'
#' # Do you have the expected columns?
#' bad_name <- rename(loanbook, ids = id)
#' try(check_loanbook(bad_name))
#'
#' # Do you have any duplicates in the column `id`?
#' bad_id <- bind_rows(loanbook, slice(loanbook, 1))
#' try(check_loanbook(bad_id))
#'
#' # Do you have missing values (`NA`s) in non-nullable columns?
#' # styler: off
#' missing_id <- tribble(
#'   ~id,            ~company_name, ~postcode,  ~country, ~misc_info,
#'    NA, "John Meier's Groceries",   "55555", "germany",        "Y",
#'    11, "John Meier's Groceries",   "55555",  "norway",        "Y"
#' )
#' # styler: on
#' try(check_loanbook(missing_id))
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
