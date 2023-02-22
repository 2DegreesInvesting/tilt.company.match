testthat::test_that("returns correct booleans", {
  data <- tibble(x = c("company_1", "company_1"), y = c("01", "02"))
  expect_equal(duplicated_paste(data$x, data$y), c(FALSE, FALSE))
})
