test_that("writes the expected file", {
  expect_equal(suggest_match(), read(test_path("data", "to_edit.csv")))
})
