test_that("hasn't changed", {
  out <- suggest_match(
    loanbook = example_file("demo_loanbook.csv"),
    tilt = example_file("demo_tilt.csv")
  ) |>
    # FIXME: Implement `quietly`
    suppressMessages()

  expect_snapshot(as.data.frame(out))
})
