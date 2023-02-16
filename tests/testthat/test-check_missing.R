test_that("with complete data returns data", {
  data <- tibble(x = 1)
  expect_equal(check_missing(data), data)
})

test_that("with complete data returns invisibly", {
  expect_invisible(check_missing(tibble(x = 1)))
})

test_that("with NA in nullable columns shows columns to review as warning", {
  data <- tibble(x = 1, y = NA)
  expect_warning(check_missing(data, "x"), "y")
})

test_that("with NA in non-nullable columns shows columns to review as error", {
  data <- tibble(x = NA)
  expect_error(check_missing(data, "x"), "review")
})

test_that("takes all columns as non-nullable by default", {
  data <- tibble(x = NA, y = NA)
  expect_error(check_missing(data), "x, y$")

  data <- tibble(x = NA, y = 1)
  expect_error(check_missing(data), "x$")
})

test_that("shows problematic columns only", {
  data <- tibble(x = NA, y = 1)
  expect_error(check_missing(data, c("x", "y")), "x$")
})
