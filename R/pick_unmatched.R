pick_unmatched <- function(loanbook, accepted) {
  check_crucial_names(loanbook, c("id", "company_name"))
  check_crucial_names(accepted, c("id", "accept_match"))

  .y <- select(accepted, "id", "accept_match")
  .x <- select(loanbook, "id", "company_name")
  anti_join(.x, filter(.y, .data$accept_match), by = "id")
}
