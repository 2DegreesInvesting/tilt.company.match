
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tilt.company.match

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![tilt.company.match status
badge](https://2degreesinvesting.r-universe.dev/badges/tilt.company.match)](https://2degreesinvesting.r-universe.dev)
<!-- badges: end -->

The goal of tilt.company.match is to provide helpers for company name
matching in the tilt-project.

## Installation

You can install the development version of
[tilt.company.match](https://github.com/2DegreesInvesting/tilt.company.match)
from [r-universe](https://r-universe.dev/) with:

``` r
options(repos = c("https://2degreesinvesting.r-universe.dev", getOption("repos")))
install.packages("tilt.company.match")
```

Or you can install it from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("2DegreesInvesting/tilt.company.match")
```

## Example

Here is a minimal example of what you can do with the package
tilt.copmany.match. For a complete and gentle walk-through see [Get
started](https://2degreesinvesting.github.io/tilt.company.match/articles/tilt-company-match.html).

``` r
library(vroom, warn.conflicts = FALSE)
library(tilt.company.match)

# TODO: Replace with the path/to/your/real/loanbook.csv
loanbook_csv <- example_file("demo_loanbook.csv")
loanbook_csv
#> [1] "/home/rstudio/git/tilt.company.match/inst/extdata/demo_loanbook.csv"

loanbook <- vroom(loanbook_csv, show_col_types = FALSE)
loanbook
#> # A tibble: 12 × 5
#>       id company_name           postcode country misc_info
#>    <dbl> <chr>                  <chr>    <chr>   <chr>    
#>  1     1 Peasant Peter          01234    germany A        
#>  2     2 Peasant Peter          01234    germany Z        
#>  3     3 Peasant Peter          11234    germany Z        
#>  4     4 Peasant Paul           01234    germany Z        
#>  5     5 Bread Bakers Limited   23456    germany C        
#>  6     6 Flower Power & Company 34567    germany Z        
#>  7     7 Screwdriver Experts    45678    germany D        
#>  8     8 Screwdriver Expert     45678    germany Z        
#>  9     9 John Meier's Groceries 56789    germany E        
#> 10    10 John Meier's Groceries 55555    germany Y        
#> 11    11 John Meier's Groceries 55555    norway  Y        
#> 12    12 Best Bakers            65656    france  F

# TODO: Replace with the path/to/your/real/tilt.csv
tilt_csv <- example_file("demo_tilt.csv")
tilt_csv
#> [1] "/home/rstudio/git/tilt.company.match/inst/extdata/demo_tilt.csv"

tilt <- vroom(tilt_csv, show_col_types = FALSE)
tilt
#> # A tibble: 11 × 5
#>       id company_name                 postcode country misc_info
#>    <dbl> <chr>                        <chr>    <chr>   <chr>    
#>  1     1 Peasant Peter                01234    germany A        
#>  2     2 Peasant Peter                01234    germany Z        
#>  3     3 Peasant Peter                11234    germany Z        
#>  4     4 Peasant Paul                 01234    germany B        
#>  5     5 The Bread Bakers Ltd         23456    germany C        
#>  6     6 Flower Power Friends and Co. 34567    germany D        
#>  7     7 Flower Power and Co.         34567    germany F        
#>  8     8 John and Jacques Groceries   56789    germany E        
#>  9     9 John and Jacques Groceries   98765    germany E        
#> 10    10 John and Jacques Groceries   98765    france  E        
#> 11    11 Cranes and Friends           65656    france  F

check_loanbook(loanbook)
#> Found duplicate(s) on columns company_name, postcode, country of the data set.
#> ✖ Found for the company Peasant Peter, postcode: 01234, country: germany
#> ℹ Please check if these duplicates are intended and have an unique id.

suggest_match(loanbook, tilt)
#> Joining with `by = join_by(id, company_name)`
#> # A tibble: 18 × 15
#>       id company_name postc…¹ country misc_…² compa…³ id_tilt compa…⁴ misc_…⁵ compa…⁶
#>    <dbl> <chr>        <chr>   <chr>   <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
#>  1     1 Peasant Pet… 01234   germany A       peasan…       1 Peasan… A       peasan…
#>  2     1 Peasant Pet… 01234   germany A       peasan…       2 Peasan… Z       peasan…
#>  3     1 Peasant Pet… 01234   germany A       peasan…       4 Peasan… B       peasan…
#>  4     2 Peasant Pet… 01234   germany Z       peasan…       1 Peasan… A       peasan…
#>  5     2 Peasant Pet… 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#>  6     2 Peasant Pet… 01234   germany Z       peasan…       4 Peasan… B       peasan…
#>  7     3 Peasant Pet… 11234   germany Z       peasan…       3 Peasan… Z       peasan…
#>  8     4 Peasant Paul 01234   germany Z       peasan…       4 Peasan… B       peasan…
#>  9     4 Peasant Paul 01234   germany Z       peasan…       1 Peasan… A       peasan…
#> 10     4 Peasant Paul 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#> 11     5 Bread Baker… 23456   germany C       breadb…       5 The Br… C       thebre…
#> 12     6 Flower Powe… 34567   germany Z       flower…       7 Flower… F       flower…
#> 13     6 Flower Powe… 34567   germany Z       flower…       6 Flower… D       flower…
#> 14     7 Screwdriver… 45678   germany D       screwd…      NA <NA>    <NA>    <NA>   
#> 15     8 Screwdriver… 45678   germany Z       screwd…      NA <NA>    <NA>    <NA>   
#> 16     9 John Meier'… 56789   germany E       johnme…       8 John a… E       johnja…
#> 17    10 John Meier'… 55555   germany Y       johnme…      NA <NA>    <NA>    <NA>   
#> 18    11 John Meier'… 55555   norway  Y       johnme…      NA <NA>    <NA>    <NA>   
#> # … with 5 more variables: postcode_tilt <chr>, country_tilt <chr>,
#> #   similarity <dbl>, suggest_match <lgl>, accept_match <lgl>, and abbreviated
#> #   variable names ¹​postcode, ²​misc_info, ³​company_alias, ⁴​company_name_tilt,
#> #   ⁵​misc_info_tilt, ⁶​company_alias_tilt
```

[Get
started](https://2degreesinvesting.github.io/tilt.company.match/articles/tilt-company-match.html).
