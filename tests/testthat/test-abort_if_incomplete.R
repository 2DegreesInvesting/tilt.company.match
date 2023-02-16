test_that("with complete data returns data", {
  data <- tibble(x = 1)
  expect_equal(abort_if_incomplete(data), data)
})

test_that("with complete data returns invisibly", {
  expect_invisible(abort_if_incomplete(tibble(x = 1)))
})

test_that("with NA in non-nullable columns shows columns to review as error", {
  data <- tibble(x = NA)
  expect_error(abort_if_incomplete(data, "x"), "review.*x$")
})

test_that("takes all columns as non-nullable by default", {
  data <- tibble(x = NA, y = NA)
  expect_error(abort_if_incomplete(data), "x.*y$")

  data <- tibble(x = NA, y = 1)
  expect_error(abort_if_incomplete(data), "x$")
})

test_that("shows problematic columns only", {
  data <- tibble(x = NA, y = 1)
  expect_error(abort_if_incomplete(data, c("x", "y")), "x$")
})
