test_that("with inexistent file errors", {
  expect_error(example_file("bad.csv"))
})

test_that("without `file` errors gracefully", {
  expect_error(example_file(), "file.*")
})

test_that("can find `demo_loanbook.csv`", {
  out <- example_file("demo_loanbook.csv")
  expect_match(basename(out), "demo_loanbook.csv")
})

test_that("can find `demo_tilt.csv`", {
  out <- example_file("demo_tilt.csv")
  expect_match(basename(out), "demo_tilt.csv")
})

test_that("can find `demo_matched.csv`", {
  out <- example_file("demo_matched.csv")
  expect_match(basename(out), "demo_matched.csv")
})
