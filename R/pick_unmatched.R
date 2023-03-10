pick_unmatched <- function(loanbook, validated) {
  check_crucial_names(loanbook, c("id", "company_name"))
  check_crucial_names(validated, c("id", "accept_match"))

  .x <- select(loanbook, "id", "company_name")
  .y <- select(validated, "id", "accept_match")
  anti_join(.x, filter(.y, .data$accept_match), by = "id")
}
