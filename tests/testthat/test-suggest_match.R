test_that("writes the expected file", {
  out <- suggest_match()
  expect_equal(out, read(test_path("data", "to_edit.csv")))
})
