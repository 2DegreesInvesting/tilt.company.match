test_that("writes the expected file", {
  .params <- list(
    loanbook_csv = example_file("demo_loanbook.csv"),
    tilt_csv = example_file("demo_tilt.csv")
  )
  out <- suggest_match(.params)
  ref <- read(test_path("data", "to_edit.csv"))
  expect_equal(out, ref)
})
