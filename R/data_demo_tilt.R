#' Demo tilt db entries
#'
#' A simplified demo tilt company data set to illustrate and test matching with
#' loanbook. For details on included cases please refer to data generation
#' script.
#'
#' @format A tibble with 9 rows and 5 variables:
#' \describe{
#' \item{id}{a numeric id}
#' \item{company_name}{name of company}
#' \item{postcode}{postcode of company}
#' \item{country}{country name in lowercase}
#' \item{misc_info}{A placeholder column that holds additional information that human matchers would consider in matching}
#' }
#' @examples
#' demo_tilt
"demo_tilt"
