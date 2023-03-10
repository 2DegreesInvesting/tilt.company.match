test_that("without the second argument errors gracefully", {
  expect_error(report_no_matches(loanbook = tibble(x = 1)), "is missing")
})

test_that("without the first argument errors gracefully", {
  expect_error(report_no_matches(manually_matched = tibble(x = 1)), "is missing")
})
