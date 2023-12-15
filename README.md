
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tilt.company.match

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
![r-universe](https://2DegreesInvesting.r-universe.dev/badges/tilt.company.match)
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
tilt.company.match. For a complete and gentle walk-through see [Get
started](https://2degreesinvesting.github.io/tilt.company.match/articles/tilt-company-match.html).

``` r
library(vroom, warn.conflicts = FALSE)
library(tilt.company.match)

# TODO: Replace with the path/to/your/real/loanbook.csv
loanbook_csv <- example_file("demo_loanbook.csv")
loanbook_csv
#> [1] "/usr/local/lib/R/site-library/tilt.company.match/extdata/demo_loanbook.csv"

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
#> [1] "/usr/local/lib/R/site-library/tilt.company.match/extdata/demo_tilt.csv"

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
#> # A tibble: 18 × 15
#>       id company_name           postcode country misc_info company_alias id_tilt
#>    <dbl> <chr>                  <chr>    <chr>   <chr>     <chr>           <dbl>
#>  1     1 Peasant Peter          01234    germany A         peasantpeter        1
#>  2     1 Peasant Peter          01234    germany A         peasantpeter        2
#>  3     1 Peasant Peter          01234    germany A         peasantpeter        4
#>  4     2 Peasant Peter          01234    germany Z         peasantpeter        1
#>  5     2 Peasant Peter          01234    germany Z         peasantpeter        2
#>  6     2 Peasant Peter          01234    germany Z         peasantpeter        4
#>  7     3 Peasant Peter          11234    germany Z         peasantpeter        3
#>  8     4 Peasant Paul           01234    germany Z         peasantpaul         4
#>  9     4 Peasant Paul           01234    germany Z         peasantpaul         1
#> 10     4 Peasant Paul           01234    germany Z         peasantpaul         2
#> 11     5 Bread Bakers Limited   23456    germany C         breadbakers …       5
#> 12     6 Flower Power & Company 34567    germany Z         flowerpower …       7
#> 13     6 Flower Power & Company 34567    germany Z         flowerpower …       6
#> 14     7 Screwdriver Experts    45678    germany D         screwdrivere…      NA
#> 15     8 Screwdriver Expert     45678    germany Z         screwdrivere…      NA
#> 16     9 John Meier's Groceries 56789    germany E         johnmeiersgr…       8
#> 17    10 John Meier's Groceries 55555    germany Y         johnmeiersgr…      NA
#> 18    11 John Meier's Groceries 55555    norway  Y         johnmeiersgr…      NA
#> # ℹ 8 more variables: company_name_tilt <chr>, misc_info_tilt <chr>,
#> #   company_alias_tilt <chr>, postcode_tilt <chr>, country_tilt <chr>,
#> #   similarity <dbl>, suggest_match <lgl>, accept_match <lgl>
```

[Get
started](https://2degreesinvesting.github.io/tilt.company.match/articles/tilt-company-match.html).
