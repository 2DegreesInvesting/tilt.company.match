# tilt.company.match (development version)

* `report_no_matches()` is now stricter about it's inputs and errors with
informative messages (#122). Also it no longer throws a message about unmatched
companies because the output already provides that information.

* The home page of the website now shows a minimal example and points to Get started for details (#109).

* The Reference section of the website now shows the higher-level API (#117).

* Get started now links to the manual decision rules (#104).

* New article "Handling a large loanbook".

* New `check_loanbook()` extracts all checks.

* New `suggest_match()` wraps the first step (#102).

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
