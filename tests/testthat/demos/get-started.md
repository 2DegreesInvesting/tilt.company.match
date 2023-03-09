tilt.company.match
================

This document explains how to match companies in a loanbook from a bank
to companies in a tilt dataset from 2 Degrees Investing Initiative.

## Considerations

- The company’s name may be different in each dataset, for example
  because of typos.
- The company’s country and postcode are useful. A match by name,
  country, and postcode is more reliable than a match by name alone.
- The company may not exist in the tilt dataset.

## Data requirements

Both your loanbook and tilt dataset must meet these requirements:

- It’s an R dataframe.
- It has the columns `id`, `company_name`, `postcode`, and `country`.
- It may or may not have other columns.
- The column `id` holds unique row-identifiers.

## System requirements

- [Install R and
  RStudio](https://happygitwithr.com/install-r-rstudio.html).
- [Setup an R build
  toolchain](https://r-pkgs.org/setup.html#setup-tools).

## 1. In R (session 1)

In this first R session you’ll create a dataset with candidate matches
for the companies in your loanbook.

### Install tilt.company.match

You can install
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

Call this function if things seem weird and you’re not sure what’s wrong
or how to fix it.

``` r
devtools::dev_sitrep()
```

### Use R packages

Installing tilt.company.match should automatically install other useful
packages. You can use them all with:

``` r
library(dplyr, warn.conflicts = FALSE)
library(vroom, warn.conflicts = FALSE)
library(stringdist)
library(tilt.company.match)
```

### Read the datasets

This example uses “demo” datasets. You should use your real `loanbook`
and `tilt` datasets instead.

``` r
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
```

### Check data quality

Check your `loanbook` meets the [Data requirements](#data-requirements)
(we check the `tilt` dataset before we distribute it). For details see
`?check_loanbook()`.

``` r
check_loanbook(loanbook)
#> Found duplicate(s) on columns company_name, postcode, country of the data set.
#> ✖ Found for the company Peasant Peter, postcode: 01234, country: germany
#> ℹ Please check if these duplicates are intended and have an unique id.
```

### Suggest matches

Suggest matching companies between your `loanbook` and `tilt` datasets.
For details see `?suggest_match()`.

``` r
to_edit <- suggest_match(loanbook, tilt)
#> Joining with `by = join_by(id, company_name)`
to_edit
#> # A tibble: 18 × 15
#>       id company_n…¹ postc…² country misc_…³ compa…⁴ id_tilt compa…⁵ misc_…⁶ compa…⁷
#>    <dbl> <chr>       <chr>   <chr>   <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
#>  1     1 Peasant Pe… 01234   germany A       peasan…       1 Peasan… A       peasan…
#>  2     1 Peasant Pe… 01234   germany A       peasan…       2 Peasan… Z       peasan…
#>  3     1 Peasant Pe… 01234   germany A       peasan…       4 Peasan… B       peasan…
#>  4     2 Peasant Pe… 01234   germany Z       peasan…       1 Peasan… A       peasan…
#>  5     2 Peasant Pe… 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#>  6     2 Peasant Pe… 01234   germany Z       peasan…       4 Peasan… B       peasan…
#>  7     3 Peasant Pe… 11234   germany Z       peasan…       3 Peasan… Z       peasan…
#>  8     4 Peasant Pa… 01234   germany Z       peasan…       4 Peasan… B       peasan…
#>  9     4 Peasant Pa… 01234   germany Z       peasan…       1 Peasan… A       peasan…
#> 10     4 Peasant Pa… 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#> 11     5 Bread Bake… 23456   germany C       breadb…       5 The Br… C       thebre…
#> 12     6 Flower Pow… 34567   germany Z       flower…       7 Flower… F       flower…
#> 13     6 Flower Pow… 34567   germany Z       flower…       6 Flower… D       flower…
#> 14     7 Screwdrive… 45678   germany D       screwd…      NA <NA>    <NA>    <NA>   
#> 15     8 Screwdrive… 45678   germany Z       screwd…      NA <NA>    <NA>    <NA>   
#> 16     9 John Meier… 56789   germany E       johnme…       8 John a… E       johnja…
#> 17    10 John Meier… 55555   germany Y       johnme…      NA <NA>    <NA>    <NA>   
#> 18    11 John Meier… 55555   norway  Y       johnme…      NA <NA>    <NA>    <NA>   
#> # … with 5 more variables: postcode_tilt <chr>, country_tilt <chr>,
#> #   similarity <dbl>, suggest_match <lgl>, accept_match <lgl>, and abbreviated
#> #   variable names ¹​company_name, ²​postcode, ³​misc_info, ⁴​company_alias,
#> #   ⁵​company_name_tilt, ⁶​misc_info_tilt, ⁷​company_alias_tilt
```

Write `to_edit` as a .csv file so that you can explore it in a
spreadsheet editor like Excel or GoogleSheets.

``` r
vroom::vroom_write(to_edit, "to_edit.csv", delim = ",")
```

## 2. In a spreadsheet editor

### Accept or reject matches

- Import the dataset `to_edit` into a spreadsheet editor like Excel or
  GoogleSheets.
- For each row decide if you want to reject or accept the suggested
  match ([manual decision
  rules](https://docs.google.com/document/d/140t0YOaTbX0Vh4Fpay8y5pEJjXXPxXbupxjoyymimRc)).
  By default each row is rejected. To accept it type TRUE in the column
  `accept_match`.
- Save the edited file to later use it again in R, for example e.g. as
  “edited.csv”.

## 3. In R (session 2)

### Use R packages and read data

Restart R to ensure nothing from the previous R session affects this
one.

Use the required packages for this section.

``` r
library(dplyr, warn.conflicts = FALSE)
library(tilt.company.match)
```

Read the “edited.csv” file, and again your loanbook.

``` r
# TODO: Replace with the path/to/your/real/edited.csv
edited_csv <- example_file("demo_matched.csv")
edited_csv
#> [1] "/home/rstudio/git/tilt.company.match/inst/extdata/demo_matched.csv"

edited <- vroom(edited_csv, show_col_types = FALSE)
edited
#> # A tibble: 18 × 13
#>       id company_n…¹ postc…² country misc_…³ compa…⁴ id_tilt compa…⁵ misc_…⁶ compa…⁷
#>    <dbl> <chr>       <chr>   <chr>   <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
#>  1     1 Peasant Pe… 01234   germany A       peasan…       1 Peasan… A       peasan…
#>  2     1 Peasant Pe… 01234   germany A       peasan…       2 Peasan… Z       peasan…
#>  3     1 Peasant Pe… 01234   germany A       peasan…       4 Peasan… B       peasan…
#>  4     2 Peasant Pe… 01234   germany Z       peasan…       1 Peasan… A       peasan…
#>  5     2 Peasant Pe… 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#>  6     2 Peasant Pe… 01234   germany Z       peasan…       4 Peasan… B       peasan…
#>  7     3 Peasant Pe… 11234   germany Z       peasan…       3 Peasan… Z       peasan…
#>  8     4 Peasant Pa… 01234   germany Z       peasan…       4 Peasan… B       peasan…
#>  9     4 Peasant Pa… 01234   germany Z       peasan…       1 Peasan… A       peasan…
#> 10     4 Peasant Pa… 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#> 11     5 Bread Bake… 23456   germany C       breadb…       5 The Br… C       thebre…
#> 12     6 Flower Pow… 34567   germany Z       flower…       7 Flower… F       flower…
#> 13     6 Flower Pow… 34567   germany Z       flower…       6 Flower… D       flower…
#> 14     7 Screwdrive… 45678   germany D       screwd…      NA <NA>    <NA>    <NA>   
#> 15     8 Screwdrive… 45678   germany Z       screwd…      NA <NA>    <NA>    <NA>   
#> 16     9 John Meier… 56789   germany E       johnme…       8 John a… E       johnja…
#> 17    10 John Meier… 55555   germany Y       johnme…      NA <NA>    <NA>    <NA>   
#> 18    11 John Meier… 55555   norway  Y       johnme…      NA <NA>    <NA>    <NA>   
#> # … with 3 more variables: string_sim <dbl>, suggest_match <lgl>,
#> #   accept_match <lgl>, and abbreviated variable names ¹​company_name, ²​postcode,
#> #   ³​misc_info, ⁴​company_alias, ⁵​company_name_tilt, ⁶​misc_info_tilt,
#> #   ⁷​company_alias_tilt

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
```

### Check the edited dataset

Manual work is prone to errors. Check the edited dataset to ensure it’s
correct:

- Use `report_no_matches()` to explore companies in the loanbook that
  didn’t match any company in the tilt dataset.

``` r
not_matched <- loanbook %>% report_no_matches(edited)
#> Joining with `by = join_by(id, company_name, postcode, country, misc_info)`
#> Companies not matched in the loanbook by the tilt data set: Peasant Paul Bread
#> Bakers Limited Screwdriver Experts Screwdriver Expert John Meier's Groceries John
#> Meier's Groceries John Meier's Groceries Best Bakers ℹ Did you match these
#> companies manually correctly ?
not_matched
#> # A tibble: 8 × 2
#>   company_name              id
#>   <chr>                  <dbl>
#> 1 Peasant Paul               4
#> 2 Bread Bakers Limited       5
#> 3 Screwdriver Experts        7
#> 4 Screwdriver Expert         8
#> 5 John Meier's Groceries     9
#> 6 John Meier's Groceries    10
#> 7 John Meier's Groceries    11
#> 8 Best Bakers               12
```

- Use `check_duplicated_relation()` to check if a company from loanbook
  has been matched to more than one company from the tilt dataset or
  reverse.

``` r
edited %>% check_duplicated_relation()
#> No duplicated matches found in the data.
```

With bad data you get informative errors (for examples see
`?check_duplicated_relation()`) – fix it and check it again.

### Pick the matching companies

Once your edited dataset is correct, pick the matching companies and
you’re done. Your final dataset will have as many rows as the number of
`TRUE` values in the `accept_match` columns of your edited dataset.

``` r
edited %>% count(accept_match)
#> # A tibble: 2 × 2
#>   accept_match     n
#>   <lgl>        <int>
#> 1 TRUE             4
#> 2 NA              14

final <- edited %>% filter(accept_match)
final
#> # A tibble: 4 × 13
#>      id company_name postc…¹ country misc_…² compa…³ id_tilt compa…⁴ misc_…⁵ compa…⁶
#>   <dbl> <chr>        <chr>   <chr>   <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
#> 1     1 Peasant Pet… 01234   germany A       peasan…       1 Peasan… A       peasan…
#> 2     2 Peasant Pet… 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#> 3     3 Peasant Pet… 11234   germany Z       peasan…       3 Peasan… Z       peasan…
#> 4     6 Flower Powe… 34567   germany Z       flower…       7 Flower… F       flower…
#> # … with 3 more variables: string_sim <dbl>, suggest_match <lgl>,
#> #   accept_match <lgl>, and abbreviated variable names ¹​postcode, ²​misc_info,
#> #   ³​company_alias, ⁴​company_name_tilt, ⁵​misc_info_tilt, ⁶​company_alias_tilt
```

If you need to use your final dataset elsewhere, you may write it to a
.csv file like before with:

``` r
final %>% vroom::vroom_write("final.csv", delim = ",")
```
