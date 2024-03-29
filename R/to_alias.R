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
#' @keywords internal
to_alias <- function(x,
                     from_to = NULL,
                     ownership = NULL,
                     remove_ownership = FALSE) {
  out <- x
  # base latin characters
  out <- stringi::stri_trans_general(out, "any-latin")
  out <- stringi::stri_trans_general(out, "latin-ascii")
  # lowercase
  out <- tolower(out)

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
#' @keywords internal
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
    "aktiengesellschaft", "ag",
    "aktien gesellschaft", "ag",
    "aktien-gesellschaft", "ag",
    "associate",           "assoc",
    "associates",           "assoc",
    "berhad",             "bhd",
    "company",              "co",
    "compagnie",            "co",
    "corporation",            "corp",
    "designated activity company",             "dac",
    "development",             "dev",
    "eingetragene genossenschaft", "eg",
    "eingetragener kaufmann", "ek",
    "eingetragener verein", "ev",
    "einzelunternehmen", "eu",
    "finance",            "fine",
    "financial",            "fina",
    "financial",             "fin",
    "financing",            "fing",
    "generation",             "gen",
    "generation",             "gen",
    "gesellschaft buergerliches rechts", "gbr",
    "gesellschaft burgerliches rechts", "gbr",
    "gesellschaft mit beschrankter haftung", "gmbh",
    "gesellschaft mit beschr haftg", "gmbh",
    "gesellschaft m b h", "gmbh",
    "gesellschaft mbh", "gmbh",
    "ges mit beschrankter haftung", "gmbh",
    "ges mit beschr haftg", "gmbh",
    "g mit beschr haftg", "gmbh",
    "ges m b h", "gmbh",
    "ges mb h", "gmbh",
    "ges m bh", "gmbh",
    "ges mbh",            "gmbh",
    "gesmbh", "gmbh",
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
    "kommanditgesellschaft", "kg",
    "kommanditges", "kg",
    "komm ges", "kg",
    "kommanditgesellschaft auf aktien", "kgaa",
    "kommanditgesellschaft aa", "kgaa",
    "kommanditges auf aktien", "kgaa",
    "kommanditges aa", "kgaa",
    "kg auf aktien", "kgaa",
    "limited",             "ltd",
    "limited partnership",              "lp",
    "ltd liability co",             "llc",
    "offene handelsgesellschaft", "ohg",
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
    "societas europaea", "se",
    "sp z o o",           "spzoo",
    "sp z oo",           "spzoo",
    "spolka z ",           "sp z ",
    "ticaret",             "tic",
    "ug (haftungsbeschrankt)", "ug",
    "unternehmergesellschaft (haftungsbeschrankt)", "ug",
    "unternehmergesellschaft", "ug"
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
