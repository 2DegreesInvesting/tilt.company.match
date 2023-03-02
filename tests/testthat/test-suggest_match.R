test_that("hasn't changed", {
  loanbook <- vroom(example_file("demo_loanbook.csv"), show_col_types = FALSE)
  tilt <- vroom(example_file("demo_tilt.csv"), show_col_types = FALSE)
  out <- suggest_match(loanbook, tilt)
  expect_snapshot(as.data.frame(out))
})
