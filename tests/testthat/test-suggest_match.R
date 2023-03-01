test_that("writes the expected file", {
  .params <- NULL
  out <- suggest_match(.params)
  expect_equal(out, read(test_path("data", "to_edit.csv")))
})
