testthat::test_that("returns correct booleans", {
  data <- tibble(x = c("a", "a"), y = 1:2)
  expect_equal(duplicated_paste(data$x, data$y), c(FALSE, FALSE))
  expect_false(identical(
    duplicated(data$x, data$y),
    duplicated_paste(data$x, data$y)
  ))
})
