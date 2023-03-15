#' Help construct test data like the `loanbook` and `tilt` datasets
#'
#' @param id,company_name,country,postcode Minimum columns.
#' @inheritDotParams tibble::tibble
#'
#' @return Tibble
#' @examples
#' toy()
#' toy(id = 1:2)
#' toy(id = NULL)
#' toy(new = "xyz")
#' @noRd
toy <- function(id = 1, company_name = "a", country = "b", postcode = "c", ...) {
  tibble(
    id = id,
    company_name = company_name,
    country = country,
    postcode = postcode,
    ...
  )
}
