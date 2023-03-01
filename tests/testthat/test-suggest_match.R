test_that("writes the expected file", {
  out <- suggest_match(
    loanbook_csv = example_file("demo_loanbook.csv"),
    tilt_csv = example_file("demo_tilt.csv")
  )
  ref <- read(test_path("data", "to_edit.csv"))
  expect_equal(out, ref)
})
