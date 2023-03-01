# tilt.company.match (development version)

* The get-started.Rmd template now longer exists. It's now
replaced by two templates for the step 1 and 3 of the process. You can use them respectively with:

```r
# Step 1: Suggest matching candidates
usethis::use_template("suggest.Rmd", package = "tilt.company.match")

# Step 2: Manual

# Step 3: Pick matches
usethis::use_template("suggest.Rmd", package = "tilt.company.match")
```

* The Get started article moves to README.

# tilt.company.match 0.0.0.9002

* You can now get the source code of the article Get started with:

```r
usethis::use_template("get-started.Rmd", package = "tilt.company.match")
```

* The Get started article supersedes README. README will get only major fixes
but no enhancements.

* The Get started article gains the new section "System requirements" (#83).

* Show installation instructions from r-universe (#78).

* Replace readr with vroom to help users read data separated with a wider range
of delimiters (#77).

* README and Get started now show how to handle missing `postcode` and `country
(#52).

# tilt.company.match 0.0.0.9001

* Added a `NEWS.md` file to track changes to the package.
