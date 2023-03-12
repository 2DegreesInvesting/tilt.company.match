test_that("if `accept_match` is a character errors gracefully (#122)", {
  expect_error(
    report_no_matches(
      tibble(id = 1, company_name = "a"),
      tibble(id = 1, accept_match = "TRUE ")
    ),
    class = "vctrs_error_assert_ptype"
  )
})

test_that("without crucial columns errors gracefully", {
  expect_error(
    report_no_matches(tibble(id = 1), tibble(id = 1)),
    class = "missing_names"
  )

  expect_no_error(
    report_no_matches(
      tibble(id = 1, company_name = "a"),
      tibble(id = 1, accept_match = TRUE)
    ),
    class = "missing_names"
  )
})

test_that("without crucial datasets errors gracefully", {
  loanbook <- read_example("demo_loanbook.csv")
  matched <- read_example("demo_matched.csv")

  expect_no_error(report_no_matches(loanbook, matched))
  expect_error(report_no_matches(loanbook), "matched.*missing.*no default")
  expect_error(
    report_no_matches(manually_matched = matched),
    "loanbook.*missing.*no default"
  )
})

test_that("nothing unmatched yields 0 rows", {
  loanbook <- tibble(id = 1, company_name = "a")
  accepted <- tibble(id = 1, accept_match = TRUE)
  out <- report_no_matches(loanbook, accepted)
  expect_equal(nrow(out), 0L)
})

test_that("nothing unmatched yields columns `id` and `company_name`", {
  loanbook <- tibble(id = 1, company_name = "a")
  accepted <- tibble(id = 1, accept_match = TRUE)
  out <- report_no_matches(loanbook, accepted)
  expect_equal(names(out), c("id", "company_name"))
})

test_that("with 1 unmatched company returns 1 row with that company", {
  loanbook <- tibble(id = 1:2, company_name = c("a", "b"))

  .accept_match <- c(TRUE, NA)
  matched <- tibble(id = 1:2, accept_match = .accept_match)
  out <- report_no_matches(loanbook, matched)
  expect_equal(out, tibble(id = 2, company_name = "b"))

  # Same
  .accept_match <- c(TRUE, FALSE)
  matched <- tibble(id = 1:2, accept_match = .accept_match)
  out <- report_no_matches(loanbook, matched)
  expect_equal(out, tibble(id = 2, company_name = "b"))
})
