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

test_that("the output preserves tilt's postcode and country", {
  skip("FIXME #130")
  out <- suggest_match(toy(), toy())
  expect_false(is.na(out$postcode_tilt))
  expect_false(is.na(out$country_tilt))
})

test_that("with no match outputs 0-rows", {
  expect_warning(
    out <- suggest_match(toy(), toy(id = 2, company_name = "x")),
    "no non-missing arguments to max; returning -Inf"
  )
  expect_equal(nrow(out), 0L)
})

test_that("with no match throws no warning", {
  skip("FIXME #131")
  expect_no_warning(
    suggest_match(toy(), toy(id = 2, company_name = "x")),
    "no non-missing arguments to max; returning -Inf"
  )
})

test_that("additional columns appear in the output", {
  expect_true(hasName(suggest_match(toy(x = 1), toy(y = 1)), "x"))
  expect_true(hasName(suggest_match(toy(x = 1), toy(y = 1)), "y"))
})

test_that("with 1 match in a 2-row loanbook outputs the 1 matching company", {
  t <- toy(id = 2, company_name = "b")
  l <- bind_rows(toy(), t)
  out <- suggest_match(l, t)
  expect_equal(nrow(out), 1L)
  expect_equal(out$id, 2)
  expect_equal(out$company_name, "b")
})

test_that("is sensitive to `suggestion_treshold", {
  skip("FIXME #132")
  l <- toy(id = 1:3, company_name = c("aaaaa", "aaaab", "aaabb"))
  t <- toy(id = 9, company_name = c("aaaaa"))

  # The threshold should be inclusive.
  .suggestion_threshold <- 1
  out <- suggest_match(l, t, suggestion_threshold = .suggestion_threshold)
  filter(out, similarity >= .suggestion_threshold) |>
    select(similarity, company_name, suggest_match) |>
    pull(suggest_match) |>
    expect_true()

  # This works but is not intuitive
  .suggestion_threshold <- .99
  out <- suggest_match(l, t, suggestion_threshold = .suggestion_threshold)
  filter(out, similarity >= .suggestion_threshold) |>
    select(similarity, company_name, suggest_match) |>
    pull(suggest_match) |>
    expect_true()
})

test_that("", {
  skip("TODO characterize eligibility_threshold")
})

test_that("", {
 skip("TODO characterize bad inputs")
})
