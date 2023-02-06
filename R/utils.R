#' Assign an additional name to an entity
#'
#' * `to_alias()` takes any character vector and creates an alias by
#' transforming the input (a) to lower case; (b) to latin-ascii characters; and
#' (c) to standard abbreviations of ownership types. Commonly, the inputs are
#' values from the columns `name_direct_loantaker` or `name_ultimate_parent`
#' of a loanbook dataset, or from the column `name_company` of an asset-level
#' dataset.
#' * `from_name_to_alias()` outputs a table giving default strings used to
#' convert from a name to its alias. You may amend this table and pass it to
#' `to_alias()` via the `from_to` argument.
#'
#' @section Assigning aliases:
#' The transformation process used to compare names between loanbook and tilt
#' datasets applies best practices commonly used in name matching algorithms:
#' * Remove special characters.
#' * Replace language specific characters.
#' * Abbreviate certain names to reduce their importance in the matching.
#' * Spell out numbers to increase their importance.
#'
#' @author person(given = "Evgeny", family = "Petrovsky", role = c("aut",
#'   "ctr"))
#'
#' Adapted from: https://github.com/RMI-PACTA/r2dii.match/blob/main/R/to_alias.R
#'
#' @source [r2dii.match](https://cran.r-project.org/package=r2dii.match) version 0.1.3.
#'
#' @param x Character string, commonly from the columns `name_direct_loantaker`
#'   or `name_ultimate_parent` of a loanbook dataset, or from the column
#'   `name_company` of an asset-level dataset.
#' @param from_to A data frame with replacement rules to be applied, contains
#'   columns `from` (for initial values) and `to` (for resulting values).
#' @param ownership vector of company ownership types to be distinguished for
#'   cut-off or separation.
#' @param remove_ownership Flag that defines whether ownership type (like llc)
#'   should be cut-off.
#'
#' @return
#' * `to_alias()` returns a character string.
#' * `from_name_to_alias()` returns a [tibble::tibble] with columns `from` and
#' `to`.
#'
#' @examples
#' library(dplyr)
#'
#' to_alias("A. and B")
#' to_alias("Acuity Brands Inc")
#' to_alias(c("3M Company", "Abbott Laboratories", "AbbVie Inc."))
#'
#' custom_replacement <- tibble(from = "AAAA", to = "B")
#' to_alias("Aa Aaaa", from_to = custom_replacement)
#'
#' neutral_replacement <- tibble(from = character(0), to = character(0))
#' to_alias("Company Name Owner", from_to = neutral_replacement)
#' to_alias(
#'   "Company Name Owner",
#'   from_to = neutral_replacement,
#'   ownership = "owner",
#'   remove_ownership = TRUE
#' )
#'
#' from_name_to_alias()
#'
#' append_replacements <- from_name_to_alias() %>%
#'   add_row(
#'     .before = 1,
#'     from = c("AA", "BB"), to = c("alpha", "beta")
#'   )
#' append_replacements
#'
#' # And in combination with `to_alias()`
#' to_alias(c("AA", "BB", "1"), from_to = append_replacements)
#' @export
to_alias <- function(x,
                     from_to = NULL,
                     ownership = NULL,
                     remove_ownership = FALSE) {
  # lowercase
  out <- tolower(x)

  # base latin characters
  out <- stringi::stri_trans_general(out, "any-latin")
  out <- stringi::stri_trans_general(out, "latin-ascii")

  # symbols
  out <- purrr::reduce(get_sym_replace(), replace_abbrev, fixed = TRUE, .init = out)

  # only one space between words
  out <- gsub("[[:space:]]+", " ", out)

  out <- replace_with_abbreviation(from_to, .init = out)

  # trim redundant whitespaces
  out <- trimws(out, which = "both")

  # ?
  out <- gsub("(?<=\\s[a-z]{1}) (?=[a-z]{1})", "", out, perl = TRUE)

  out <- may_remove_ownership(remove_ownership, ownership, .init = out)

  # final adjustments
  out <- gsub("-", " ", out)
  out <- gsub("[[:space:]]", "", out)
  out <- gsub("[^[:alnum:][:space:]$]", "", out)
  out <- gsub("$", " ", out, fixed = TRUE)

  out
}

may_remove_ownership <- function(remove_ownership, ownership, .init) {
  ownership <- ownership %||% get_ownership_type()

  # ownership type distinguished (with $ sign) in company name
  paste_or_not <- function(x, remove_ownership) {
    if (remove_ownership) {
      c(paste0(" ", x, "$"), "")
    } else {
      c(paste0(" ", x, "$"), paste0("$", x))
    }
  }

  out <- purrr::map(ownership, ~ paste_or_not(.x, remove_ownership))
  purrr::reduce(out, replace_abbrev, .init = .init)
}

# Technology mix for analysis
get_ownership_type <- function() {
  c(
    "ab",
    "ag",
    "as",
    "asa",
    "bhd",
    "bsc",
    "bv",
    "co",
    "corp",
    "cv",
    "dac",
    "gmbh",
    "govt",
    "hldgs",
    "inc",
    "intl",
    "jsc",
    "llc",
    "lp",
    "ltd",
    "nv",
    "pcl",
    "pjsc",
    "plc",
    "pt",
    "pte",
    "sa",
    "sarl",
    "sas",
    "se",
    "spa",
    "spzoo",
    "srl"
  )
}

# replace each lhs with rhs
get_sym_replace <- function() {
  list(
    c(".", " "),
    c(",", " "),
    c("_", " "),
    c("/", " "),
    c("$", "")
  )
}

#' From name to alias
#'
#' Function that outputs a table giving default strings used to
#' convert from a name to its alias. You may amend this table and pass it to
#' `to_alias()` via the `from_to` argument.
#'
#' Source: @jdhoffa https://github.com/RMI-PACTA/r2dii.dataraw/pull/8
#'
#' @return [tibble::tibble] with columns `from` and
#' `to`.
#' @export
from_name_to_alias <- function() {
  # styler: off
  tibble::tribble(
    ~from,               ~to,
    " and ",             " & ",
    " en ",             " & ",
    " och ",             " & ",
    " und ",             " & ",
    "(pjsc)",                "",
    "(pte)",                "",
    "(pvt)",                "",
    "0",            "null",
    "1",             "one",
    "2",             "two",
    "3",           "three",
    "4",            "four",
    "5",            "five",
    "6",             "six",
    "7",           "seven",
    "8",           "eight",
    "9",            "nine",
    "aktg",              "ag",
    "associate",           "assoc",
    "associates",           "assoc",
    "berhad",             "bhd",
    "company",              "co",
    "corporation",            "corp",
    "designated activity company",             "dac",
    "development",             "dev",
    "finance",            "fine",
    "financial",            "fina",
    "financial",             "fin",
    "financing",            "fing",
    "generation",             "gen",
    "generation",             "gen",
    "golden",             "gld",
    "government",            "govt",
    "groep",             "grp",
    "group",             "grp",
    "holding",           "hldgs",
    "holdings",           "hldgs",
    "incorporated",             "inc",
    "international",            "intl",
    "investment",          "invest",
    "investment",          "invest",
    "limited",             "ltd",
    "limited partnership",              "lp",
    "ltd liability co",             "llc",
    "ograniczona odpowiedzialnoscia",              "oo",
    "partner",             "prt",
    "partners",             "prt",
    "public co ltd",             "pcl",
    "public ltd co",             "plc",
    "resource",             "res",
    "resources",             "res",
    "san tic anonim sti", "santicanonimsti",
    "san tic ltd sti",    "santicltdsti",
    "sanayi",             "san",
    "sanayi ve ticaret",  "sanayi ticaret",
    "shipping",             "shp",
    "sirketi",             "sti",
    "sp z o o",           "spzoo",
    "sp z oo",           "spzoo",
    "spolka z ",           "sp z ",
    "ticaret",             "tic"
  )
  # styler: on
}

`%||%` <- function(x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}

#' Check if a named object contains expected names
#'
#' Based on fgeo.tool::check_crucial_names()
#'
#' @param x A named object.
#' @param expected_names String; expected names of `x`.
#'
#' @return Invisible `x`, or an error with informative message.
#'
#' Adapted from: https://github.com/RMI-PACTA/r2dii.match/blob/main/R/check_crucial_names.R
#'
#' @examples
#' x <- c(a = 1)
#' check_crucial_names(x, "a")
#' try(check_crucial_names(x, "bad"))
#' @noRd
check_crucial_names <- function(x, expected_names) {
  stopifnot(rlang::is_named(x))
  stopifnot(is.character(expected_names))

  ok <- all(unique(expected_names) %in% names(x))
  if (!ok) {
    abort_missing_names(sort(setdiff(expected_names, names(x))))
  }

  invisible(x)
}

abort_missing_names <- function(missing_names) {
  rlang::abort(
    "missing_names",
    message = glue::glue(
      "Must have missing names:
      {paste0('`', missing_names, '`', collapse = ', ')}"
    )
  )
}

replace_with_abbreviation <- function(replacement, .init) {
  replacement <- replacement %||% from_name_to_alias()
  replacement <- purrr::set_names(replacement, tolower)

  check_crucial_names(replacement, c("from", "to"))

  abbrev <- purrr::map2(tolower(replacement$from), tolower(replacement$to), c)
  purrr::reduce(abbrev, replace_abbrev, fixed = TRUE, .init = .init)
}

# replace long words with abbreviations
replace_abbrev <- function(text, abr, fixed = FALSE) {
  gsub(abr[1], abr[2], text, fixed = fixed)
}

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
