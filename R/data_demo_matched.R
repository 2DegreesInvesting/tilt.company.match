#' Demo matched db entries
#'
#' A simplified demo matched company data set to illustrate the manual matching process with
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
#' \item{company_alias}{name of the company, preprocessed}
#' \item{id_tilt}{a numeric id in the tilt db}
#' \item{company_name_tilt}{name of company}
#' \item{misc_info_tilt}{A placeholder column that holds additional information that human matchers would consider in matching}
#' \item{company_alias_tilt}{name of the company, preprocessed}
#' \item{string_sim}{string similarity between aliased company name in the loanbook and aliase company name in tilt db}
#' \item{suggest_match}{set to TRUE if string_sim is above a certain threshold}
#' \item{accept_match}{manual decision to whether the company from the loanbook matches a comapny in the tilt db}
#' }
#' @examples
#' demo_matched
"demo_matched"
