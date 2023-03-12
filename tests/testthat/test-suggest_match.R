test_that("hasn't changed", {
  loanbook <- vroom(example_file("demo_loanbook.csv"), show_col_types = FALSE)
  tilt <- vroom(example_file("demo_tilt.csv"), show_col_types = FALSE)
  out <- suggest_match(loanbook, tilt) |> suppressMessages()
  expect_snapshot(as.data.frame(out))
})

test_that("output with a fully matched company", {
  # TODO:
  # For consistency with `r2dii.match::match_name()`:
  # * Rename `similarity` to `score`
  # * Remove `suggest_match` and `accept_match`. Ask users to indicate match
  # by setting `score` to 1
  # * `accept_match` should be FALSE not NA
  # FIXME:
  # * `postcode_tilt` must not be NA
  # * `country_tilt` must not be NA
  # * Remove "Joining with ..." message
  out <- suggest_match(toy(), toy()) |> suppressMessages()
  expect_snapshot_output(as.list(out))
})

test_that("with no match outputs 0-rows", {
  expect_warning(
    out <- suggest_match(toy(), toy(id = 2, company_name = "x")),
    # FIXME
    "no non-missing arguments to max; returning -Inf"
  ) |> suppressMessages()
  expect_equal(nrow(out), 0L)
})

