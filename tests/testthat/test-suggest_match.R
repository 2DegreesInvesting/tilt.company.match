test_that("hasn't changed", {
  loanbook <- vroom(example_file("demo_loanbook.csv"), show_col_types = FALSE)
  tilt <- vroom(example_file("demo_tilt.csv"), show_col_types = FALSE)
  out <- suggest_match(loanbook, tilt)
  expect_snapshot(as.data.frame(out))
})

test_that("output with a fully matched company", {
  out <- suggest_match(toy(), toy())
  expect_snapshot_output(as.list(out))
})

test_that("with no match outputs 0-rows", {
  expect_warning(
    out <- suggest_match(toy(), toy(id = 2, company_name = "x")),
    # FIXME
    "no non-missing arguments to max; returning -Inf"
  )
  expect_equal(nrow(out), 0L)
})

test_that("additional columns appear in the output", {
  expect_true(hasName(suggest_match(toy(x = 1), toy(y = 1)), "x"))
  expect_true(hasName(suggest_match(toy(x = 1), toy(y = 1)), "y"))
})

test_that("with 1 out of 2 matches outputs 1-row", {
  t <- toy(id = 2, company_name = "b")
  l <- bind_rows(toy(), t)
  out <- suggest_match(l, t)
  expect_equal(nrow(out), 1L)
  expect_equal(out$id, 2)
  expect_equal(out$company_name, "b")
})
