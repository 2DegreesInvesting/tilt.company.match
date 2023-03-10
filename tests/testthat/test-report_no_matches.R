test_that("without the second argument errors gracefully", {
  expect_error(report_no_matches(loanbook = tibble(x = 1)), "is missing")
})

test_that("without the first argument errors gracefully", {
  expect_error(report_no_matches(manually_matched = tibble(x = 1)), "is missing")
})

test_that("if all companies matched the output has 0 rows", {
  x <- tibble(id = 1:2, company_name = c("a", "b"))
  y <- mutate(x, accept_match = TRUE)
  unmatched <- report_no_matches(x, y) |> suppressMessages()
  expect_equal(nrow(unmatched), 0L)
})

test_that("with one unmatched company the output has 1 row", {
  x <- tibble(id = 1:2, company_name = c("a", "b"))
  y <- tibble(id = 1:2, company_name = c("a", "b"), accept_match = c(TRUE, FALSE))
  unmatched <- report_no_matches(x, y) |> suppressMessages()
  expect_equal(nrow(unmatched), 1L)
})

test_that("with two unmatched company the output has 2 rows", {
  # FIXME: Remove after understanding this function
  x <- tibble(id = 1:2, company_name = c("a", "b"))
  y <- tibble(id = 1:2, company_name = c("a", "b"), accept_match = c(FALSE, FALSE))
  unmatched <- report_no_matches(x, y) |> suppressMessages()
  expect_equal(nrow(unmatched), 2L)
})

test_that("it's the same as anti_join(loanbook, filter(matched, accept_match))", {
  # FIXME: Remove after understanding this function
  loanbook <- tibble(id = 1:2, company_name = c("a", "b"))
  matched <- tibble(id = 1:2, company_name = c("a", "b"), accept_match = c(TRUE, FALSE))
  out <- report_no_matches(loanbook, matched) |> suppressMessages()
  out2 <- anti_join(loanbook, filter(matched, accept_match)) |> suppressMessages()
  expect_equal(out, out2[names(out)])
})
