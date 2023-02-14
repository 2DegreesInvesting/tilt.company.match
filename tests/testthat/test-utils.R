test_that("function returns input if not NAs are present", {

  test_data <- tibble::tibble(id = 1:2,
                              company_name = c("A", "B"),
                              some_col = 3:4)

  checked_data <- report_missings(test_data)
  testthat::expect_equal(test_data, checked_data)

})

test_that("function reports NAs if NAs are present on nullable cols", {

  test_data <- tibble::tibble(id = 1:2,
                              company_name = c("A", "B"),
                              some_col = c(NA, 1))

  checked_data <- testthat::expect_output(report_missings(test_data), "Reporting missings")
  testthat::expect_equal(test_data, checked_data)

})

test_that("fucntion report NAs and throws error if NAs are present on nullable cols", {

  test_data <- tibble::tibble(id = 1:2,
                              company_name = c("A", NA),
                              some_col = 3:4)

  testthat::expect_error(report_missings(test_data), "Reporting missings")


})
