test_that("without crucial columns errors gracefully", {
  expect_error(
    pick_unmatched(tibble(id = 1), tibble(id = 1)),
    class = "missing_names"
  )

  expect_no_error(
    pick_unmatched(
      tibble(id = 1, company_name = "a"),
      tibble(id = 1, accept_match = TRUE)
    ),
    class = "missing_names"
  )
})

test_that("without crucial datasets errors gracefully", {
  loanbook <- read_example("demo_loanbook.csv")
  accepted <- read_example("demo_matched.csv")

  expect_no_error(pick_unmatched(loanbook, accepted))
  expect_error(pick_unmatched(loanbook), "accepted.*missing.*no default")
  expect_error(
    pick_unmatched(accepted = accepted),
    "loanbook.*missing.*no default"
  )
})

test_that("nothing unmatched yields 0 rows", {
  loanbook <- tibble(id = 1, company_name = "a")
  accepted <- tibble(id = 1, accept_match = TRUE)
  out <- pick_unmatched(loanbook, accepted)
  expect_equal(nrow(out), 0L)
})

test_that("nothing unmatched yields columns `id` and `company_name`", {
  loanbook <- tibble(id = 1, company_name = "a")
  accepted <- tibble(id = 1, accept_match = TRUE)
  out <- pick_unmatched(loanbook, accepted)
  expect_equal(names(out), c("id", "company_name"))
})

