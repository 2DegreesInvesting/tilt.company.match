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
```

### Check data quality

Let’s first check you `loanbook` is as we expect.

#### Expected columns

Do you have the expected columns `id`, `company_name`, `postcode`, and
`country`?

``` r
expected <- c("id", "company_name", "postcode", "country")
loanbook %>% check_crucial_names(expected)

# Anything different throws an error
bad <- rename(loanbook, ids = id)
bad %>%
  check_crucial_names(expected) %>%
  try()
#> Error in abort_missing_names(sort(setdiff(expected_names, names(x)))) : 
#>   Must have missing names:
#> `id`
```

#### Duplicates

Do you have any duplicates in the column `id`?

``` r
has_no_duplicates <- identical(anyDuplicated(loanbook$id), 0L)
# If you get an error, remove the duplicates and try again
stopifnot(has_no_duplicates)
```

Do you have duplicates in `company_name`, `postcode` or `country`?

It’s best if there is none. But if you find duplicates and they belong
to different companies, then you don’t have to fix them.

``` r
best_without_duplicates <- c("company_name", "postcode", "country")
report_duplicates(loanbook, best_without_duplicates)
#> Found duplicate(s) on columns company_name, postcode, country of the data set.
#> ✖ Found for the company Peasant Peter, postcode: 01234, country: germany
#> ℹ Please check if these duplicates are intended and have an unique id.
```

For example, here the column `misc_info` suggests the duplicates belong
to different companies, so it’s OK:

``` r
loanbook %>%
  filter(company_name == "Peasant Peter") %>%
  filter(postcode == "01234")
#> # A tibble: 2 × 5
#>      id company_name  postcode country misc_info
#>   <dbl> <chr>         <chr>    <chr>   <chr>    
#> 1     1 Peasant Peter 01234    germany A        
#> 2     2 Peasant Peter 01234    germany Z
```

#### Missing values

Do you have missing values (`NA`s) in non-nullable columns?

Non-nullable columns must not have missing values. If they do you have
to remove them. Missing values in other columns are fine.

``` r
non_nullable <- c("id", "company_name")
loanbook %>% abort_if_incomplete(non_nullable)
```

For example, here the non-nullable `id` column has one missing value:

``` r
bad_loanbook <- tribble(
  ~id, ~company_name, ~postcode, ~country, ~misc_info,
  NA, "John Meier's Groceries", "55555", "germany", "Y",
  11, "John Meier's Groceries", "55555", "norway", "Y"
)
bad_loanbook %>%
  abort_if_incomplete(non_nullable) %>%
  try()
#> Error in abort_if_incomplete(., non_nullable) : 
#>   Non-nullable columns must not have `NA`s.
#> ✖ Columns to review: id

fixed_loanbook <- filter(bad_loanbook, !is.na(id))
# NA's are OK in columns other than non-nullable ones
fixed_loanbook
#> # A tibble: 1 × 5
#>      id company_name           postcode country misc_info
#>   <dbl> <chr>                  <chr>    <chr>   <chr>    
#> 1    11 John Meier's Groceries 55555    norway  Y

fixed_loanbook %>% abort_if_incomplete(non_nullable)
```

### Create a standard alias of `company_name` in both datasets

Use `to_alias()` to reduce the chance you’ll miss a match because of
spurious differences in the company name between the loanbook and tilt
dataset. This helps you get a less noisy, more consistent version of
`company_name` in each of the two datasets.

``` r
loanbook_alias <- loanbook %>% mutate(company_alias = to_alias(company_name))
loanbook_alias
#> # A tibble: 12 × 6
#>       id company_name           postcode country misc_info company_alias      
#>    <dbl> <chr>                  <chr>    <chr>   <chr>     <chr>              
#>  1     1 Peasant Peter          01234    germany A         peasantpeter       
#>  2     2 Peasant Peter          01234    germany Z         peasantpeter       
#>  3     3 Peasant Peter          11234    germany Z         peasantpeter       
#>  4     4 Peasant Paul           01234    germany Z         peasantpaul        
#>  5     5 Bread Bakers Limited   23456    germany C         breadbakers ltd    
#>  6     6 Flower Power & Company 34567    germany Z         flowerpower co     
#>  7     7 Screwdriver Experts    45678    germany D         screwdriverexperts 
#>  8     8 Screwdriver Expert     45678    germany Z         screwdriverexpert  
#>  9     9 John Meier's Groceries 56789    germany E         johnmeiersgroceries
#> 10    10 John Meier's Groceries 55555    germany Y         johnmeiersgroceries
#> 11    11 John Meier's Groceries 55555    norway  Y         johnmeiersgroceries
#> 12    12 Best Bakers            65656    france  F         bestbakers

tilt_alias <- tilt %>% mutate(company_alias = to_alias(company_name))
tilt_alias
#> # A tibble: 11 × 6
#>       id company_name                 postcode country misc_info company_alias  
#>    <dbl> <chr>                        <chr>    <chr>   <chr>     <chr>          
#>  1     1 Peasant Peter                01234    germany A         peasantpeter   
#>  2     2 Peasant Peter                01234    germany Z         peasantpeter   
#>  3     3 Peasant Peter                11234    germany Z         peasantpeter   
#>  4     4 Peasant Paul                 01234    germany B         peasantpaul    
#>  5     5 The Bread Bakers Ltd         23456    germany C         thebreadbakers…
#>  6     6 Flower Power Friends and Co. 34567    germany D         flowerpowerfri…
#>  7     7 Flower Power and Co.         34567    germany F         flowerpower co 
#>  8     8 John and Jacques Groceries   56789    germany E         johnjacquesgro…
#>  9     9 John and Jacques Groceries   98765    germany E         johnjacquesgro…
#> 10    10 John and Jacques Groceries   98765    france  E         johnjacquesgro…
#> 11    11 Cranes and Friends           65656    france  F         cranesfriends
```

### Match candidates

To inform the decision about which companies in your `loanbook` match
companies in the `tilt` dataset, we compare the values in the columns
`postcode` and `country`:

- If your `loanbook` has both `postcode` and `country` we match
  companies in that specific `postcode` and that specific `country`. You
  will likely match companies that are really the same (true positives)
  because it’s unlikely that two companies with similar name will be
  located close to each other. This will cost you the minimum amount of
  manual-validation work ahead.

``` r
lacks_none <- loanbook_alias %>%
  filter(!is.na(postcode) & !is.na(country)) %>%
  left_join(
    tilt_alias,
    by = c("country", "postcode"),
    suffix = c("", "_tilt"),
    multiple = "all"
  )
```

- If your `loanbook` lacks `postcode` but has `country` we match
  companies in that specific `country` but across every `postcode`. You
  will possibly match companies that are not really the same (false
  positives) but happen to have a similar name and are located in the
  same `country`. This will cost you additional manual-validation work
  ahead.

``` r
lacks_postcode <- loanbook_alias %>%
  filter(is.na(postcode) & !is.na(country)) %>%
  left_join(
    tilt_alias,
    by = c("country"),
    suffix = c("", "_tilt"),
    multiple = "all"
  )
```

- If your `loanbook` has `postcode` but lacks `country` we match
  companies with the same `postcode` but across every `country`. You
  will possibly match companies that are not really the same (false
  positives) but happen to have a similar name and the same postcode.
  This will cost you additional manual-validation work ahead.

``` r
lacks_country <- loanbook_alias %>%
  filter(!is.na(postcode) & is.na(country)) %>%
  left_join(tilt_alias, by = c("postcode"), suffix = c("", "_tilt"))
```

- If your `loanbook` lacks both `postcode` and `country` we match
  companies across the entire dataset. You will most likely match
  companies that are not really the same (false positives). This will
  cost you the greatest amount of additional manual-validation work
  ahead.

``` r
lacks_both <- loanbook_alias %>%
  filter(is.na(postcode) & is.na(country)) %>%
  mutate(postcode = "join_helper") %>%
  inner_join(
    dplyr::mutate(tilt_alias, postcode = "join_helper"),
    by = c("postcode"),
    suffix = c("", "_tilt"),
    multiple = "all"
  ) %>%
  mutate(postcode = NA_character_)
```

Having considered all cases, you can now combine them all in a single
dataset:

``` r
candidates <- bind_rows(lacks_none, lacks_postcode, lacks_country, lacks_both)

candidates
#> # A tibble: 19 × 12
#>       id compa…¹ postc…² country misc_…³ compa…⁴ id_tilt compa…⁵ misc_…⁶ compa…⁷
#>    <dbl> <chr>   <chr>   <chr>   <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
#>  1     1 Peasan… 01234   germany A       peasan…       1 Peasan… A       peasan…
#>  2     1 Peasan… 01234   germany A       peasan…       2 Peasan… Z       peasan…
#>  3     1 Peasan… 01234   germany A       peasan…       4 Peasan… B       peasan…
#>  4     2 Peasan… 01234   germany Z       peasan…       1 Peasan… A       peasan…
#>  5     2 Peasan… 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#>  6     2 Peasan… 01234   germany Z       peasan…       4 Peasan… B       peasan…
#>  7     3 Peasan… 11234   germany Z       peasan…       3 Peasan… Z       peasan…
#>  8     4 Peasan… 01234   germany Z       peasan…       1 Peasan… A       peasan…
#>  9     4 Peasan… 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#> 10     4 Peasan… 01234   germany Z       peasan…       4 Peasan… B       peasan…
#> 11     5 Bread … 23456   germany C       breadb…       5 The Br… C       thebre…
#> 12     6 Flower… 34567   germany Z       flower…       6 Flower… D       flower…
#> 13     6 Flower… 34567   germany Z       flower…       7 Flower… F       flower…
#> 14     7 Screwd… 45678   germany D       screwd…      NA <NA>    <NA>    <NA>   
#> 15     8 Screwd… 45678   germany Z       screwd…      NA <NA>    <NA>    <NA>   
#> 16     9 John M… 56789   germany E       johnme…       8 John a… E       johnja…
#> 17    10 John M… 55555   germany Y       johnme…      NA <NA>    <NA>    <NA>   
#> 18    11 John M… 55555   norway  Y       johnme…      NA <NA>    <NA>    <NA>   
#> 19    12 Best B… 65656   france  F       bestba…      11 Cranes… F       cranes…
#> # … with 2 more variables: postcode_tilt <chr>, country_tilt <chr>, and
#> #   abbreviated variable names ¹​company_name, ²​postcode, ³​misc_info,
#> #   ⁴​company_alias, ⁵​company_name_tilt, ⁶​misc_info_tilt, ⁷​company_alias_tilt
```

Above each join allowed any one company in your `loanbook` to match
`"all"` of the potentially `multiple` companies the `tilt` dataset.
Here, for example, one company in our demo `loanbook` matches three
candidates in our demo `tilt` dataset:

``` r
candidates %>%
  filter(id == 1) %>%
  select(company_alias, id_tilt, company_alias_tilt)
#> # A tibble: 3 × 3
#>   company_alias id_tilt company_alias_tilt
#>   <chr>           <dbl> <chr>             
#> 1 peasantpeter        1 peasantpeter      
#> 2 peasantpeter        2 peasantpeter      
#> 3 peasantpeter        4 peasantpaul
```

Next, calculate the string similarity between the aliased `company_name`
from the loanbook and tilt datasets. Complete similarity corresponds to
`1`, and complete dissimilarity corresponds to `0`. For each company in
the loanbook, arrange matching candidates by descending similarity.

``` r
okay_candidates <- candidates %>%
  # Other parameters may perform best. See `?stringdist::stringsim`
  mutate(similarity = stringsim(
    company_alias, company_alias_tilt,
    # Good to compare human typed text that might have typos.
    method = "jw",
    p = 0.1
  )) %>%
  # Arrange matching candidates from more to less similar
  arrange(id, -similarity)

okay_candidates %>% relocate(similarity)
#> # A tibble: 19 × 13
#>    simil…¹    id compa…² postc…³ country misc_…⁴ compa…⁵ id_tilt compa…⁶ misc_…⁷
#>      <dbl> <dbl> <chr>   <chr>   <chr>   <chr>   <chr>     <dbl> <chr>   <chr>  
#>  1   1         1 Peasan… 01234   germany A       peasan…       1 Peasan… A      
#>  2   1         1 Peasan… 01234   germany A       peasan…       2 Peasan… Z      
#>  3   0.879     1 Peasan… 01234   germany A       peasan…       4 Peasan… B      
#>  4   1         2 Peasan… 01234   germany Z       peasan…       1 Peasan… A      
#>  5   1         2 Peasan… 01234   germany Z       peasan…       2 Peasan… Z      
#>  6   0.879     2 Peasan… 01234   germany Z       peasan…       4 Peasan… B      
#>  7   1         3 Peasan… 11234   germany Z       peasan…       3 Peasan… Z      
#>  8   1         4 Peasan… 01234   germany Z       peasan…       4 Peasan… B      
#>  9   0.879     4 Peasan… 01234   germany Z       peasan…       1 Peasan… A      
#> 10   0.879     4 Peasan… 01234   germany Z       peasan…       2 Peasan… Z      
#> 11   0.844     5 Bread … 23456   germany C       breadb…       5 The Br… C      
#> 12   1         6 Flower… 34567   germany Z       flower…       7 Flower… F      
#> 13   0.933     6 Flower… 34567   germany Z       flower…       6 Flower… D      
#> 14  NA         7 Screwd… 45678   germany D       screwd…      NA <NA>    <NA>   
#> 15  NA         8 Screwd… 45678   germany Z       screwd…      NA <NA>    <NA>   
#> 16   0.848     9 John M… 56789   germany E       johnme…       8 John a… E      
#> 17  NA        10 John M… 55555   germany Y       johnme…      NA <NA>    <NA>   
#> 18  NA        11 John M… 55555   norway  Y       johnme…      NA <NA>    <NA>   
#> 19   0.548    12 Best B… 65656   france  F       bestba…      11 Cranes… F      
#> # … with 3 more variables: company_alias_tilt <chr>, postcode_tilt <chr>,
#> #   country_tilt <chr>, and abbreviated variable names ¹​similarity,
#> #   ²​company_name, ³​postcode, ⁴​misc_info, ⁵​company_alias, ⁶​company_name_tilt,
#> #   ⁷​misc_info_tilt
```

### Pick best candidates

``` r
eligibility_threshold <- 0.75
```

Empirically we found that candidates under a `similarity` threshold of
0.75 are most likely false positives. Pick `similarity` values above
that threshold to drastically reduce the number of candidates you’ll
need to validate manually. We believe this benefit outweighs the
potential loss of a few true positives.

``` r
best_candidates <- okay_candidates %>%
  filter(similarity > eligibility_threshold | is.na(similarity))
```

After picking the best candidates, some companies in your `loanbook`
might no longer have any candidate in the `tilt` dataset.

``` r
unmatched <- anti_join(
  okay_candidates %>% distinct(id, company_name),
  best_candidates %>% distinct(id, company_name)
)
#> Joining with `by = join_by(id, company_name)`

unmatched
#> # A tibble: 1 × 2
#>      id company_name
#>   <dbl> <chr>       
#> 1    12 Best Bakers
```

### Suggest matches

``` r
# Decided upon extensive experience
suggestion_threshold <- 0.9
```

Later you’ll need to manually decide which of all candidates if any is a
true match. To make that job easier, we can automatically make some
suggestions in a new column `suggest_match`.

The values of `suggest_match` are set to `TRUE` where the value of
`similarity` meets all of these conditions:

- It’s the highest among all other candidates.
- It’s above a threshold of 0.9.
- It’s the only such highest value in the group defined by a combination
  of `company_name` x `postcode` – to avoid duplicates.

``` r
candidates_suggest_match <- best_candidates %>%
  # - It's the highest among all other candidates.
  group_by(id) %>%
  filter(similarity == max(similarity)) %>%
  # - It's above the threshold.
  filter(similarity > suggestion_threshold) %>%
  # - It's the only such highest value in the group defined by a combination of
  # `company_name` x `postcode` -- to avoid duplicates.
  mutate(duplicates = any(duplicated_paste(company_name, postcode))) %>%
  filter(!duplicates) %>%
  select(id, id_tilt) %>%
  mutate(suggest_match = TRUE) %>%
  ungroup()
```

In all other rows the value of `suggest_match` is automatically set to
`NA`. Also now create a new column `accept_match` and fill it with `NA`.
Later you’ll edit this column.

``` r
to_edit <- best_candidates %>%
  left_join(candidates_suggest_match, by = c("id", "id_tilt")) %>%
  mutate(accept_match = NA)

to_edit %>% relocate(similarity, suggest_match)
#> # A tibble: 18 × 15
#>    simil…¹ sugge…²    id compa…³ postc…⁴ country misc_…⁵ compa…⁶ id_tilt compa…⁷
#>      <dbl> <lgl>   <dbl> <chr>   <chr>   <chr>   <chr>   <chr>     <dbl> <chr>  
#>  1   1     NA          1 Peasan… 01234   germany A       peasan…       1 Peasan…
#>  2   1     NA          1 Peasan… 01234   germany A       peasan…       2 Peasan…
#>  3   0.879 NA          1 Peasan… 01234   germany A       peasan…       4 Peasan…
#>  4   1     NA          2 Peasan… 01234   germany Z       peasan…       1 Peasan…
#>  5   1     NA          2 Peasan… 01234   germany Z       peasan…       2 Peasan…
#>  6   0.879 NA          2 Peasan… 01234   germany Z       peasan…       4 Peasan…
#>  7   1     TRUE        3 Peasan… 11234   germany Z       peasan…       3 Peasan…
#>  8   1     TRUE        4 Peasan… 01234   germany Z       peasan…       4 Peasan…
#>  9   0.879 NA          4 Peasan… 01234   germany Z       peasan…       1 Peasan…
#> 10   0.879 NA          4 Peasan… 01234   germany Z       peasan…       2 Peasan…
#> 11   0.844 NA          5 Bread … 23456   germany C       breadb…       5 The Br…
#> 12   1     TRUE        6 Flower… 34567   germany Z       flower…       7 Flower…
#> 13   0.933 NA          6 Flower… 34567   germany Z       flower…       6 Flower…
#> 14  NA     NA          7 Screwd… 45678   germany D       screwd…      NA <NA>   
#> 15  NA     NA          8 Screwd… 45678   germany Z       screwd…      NA <NA>   
#> 16   0.848 NA          9 John M… 56789   germany E       johnme…       8 John a…
#> 17  NA     NA         10 John M… 55555   germany Y       johnme…      NA <NA>   
#> 18  NA     NA         11 John M… 55555   norway  Y       johnme…      NA <NA>   
#> # … with 5 more variables: misc_info_tilt <chr>, company_alias_tilt <chr>,
#> #   postcode_tilt <chr>, country_tilt <chr>, accept_match <lgl>, and
#> #   abbreviated variable names ¹​similarity, ²​suggest_match, ³​company_name,
#> #   ⁴​postcode, ⁵​misc_info, ⁶​company_alias, ⁷​company_name_tilt
```

Note that even a `similarity` of `1` in the same `postcode` can be a
false positive. For example, this is false positive:

``` r
to_edit %>%
  filter(id == 4, id_tilt == 4) %>%
  select(suggest_match, similarity, postcode, matches("misc_info"))
#> # A tibble: 1 × 5
#>   suggest_match similarity postcode misc_info misc_info_tilt
#>   <lgl>              <dbl> <chr>    <chr>     <chr>         
#> 1 TRUE                   1 01234    Z         B
```

Now write the dataset `to_edit` so that you can explore it in a
spreadsheet editor. For example, you may write it as a .csv or .xlsx
file then open it in Excel or GoogleSheets.

``` r
vroom::vroom_write(to_edit, "to_edit.csv", delim = ",")

# Or, you can install the writexl package with: `install.packages("writexl")`
writexl::write_xlsx(to_edit, "to_edit.xlsx")
```

### Calculate coverage statistics

``` r
suggested <- to_edit %>%
  filter(suggest_match)

#### Number of matched companies based on suggested matches
matched_rows <- suggested %>% nrow()
matched_rows
#> [1] 3

#### Share of matched companies from total loanbook companies
matched_share <- matched_rows / loanbook %>%
  distinct(company_name) %>%
  nrow()
matched_share
#> [1] 0.375
```

#### Number and share of matched companies classified by misc_info from total loanbook companies

misc_info should be replaced with variables like sectors, headcount etc.

``` r
x <- loanbook %>% count(misc_info)
y <- suggested %>% count(misc_info)
misc_share <-
  left_join(x, y, by = c("misc_info"), suffix = c("_loanbook", "_merged")) %>%
  mutate(n_share = n_merged / n_loanbook)
```

#### Calculate loan exposure categorised based on misc_info

id_tilt column is used as the substitute due to unavailability of loan
amount column in sample data. Please replace id_tilt column with the
loan amount column.

``` r
# Calculate number of loans and their share from total after grouping by
# misc_info
exposure_count <- suggested %>%
  count(misc_info) %>%
  mutate(count_share = n / sum(n))

# Calculate sum of loan values and their share from total value after grouping
# by misc_info
exposure_sum <- suggested %>%
  group_by(misc_info) %>%
  summarise(sum_expo = sum(id_tilt)) %>%
  mutate(sum_share = sum_expo / sum(sum_expo))
```

## 2. In a spreadsheet editor

### Accept or reject matches

- Import the dataset `to_edit` into a spreadsheet editor like Excel or
  GoogleSheets.
- For each row decide if you want to reject or accept the suggested
  match. By default each row is rejected. To accept it type TRUE in the
  column `accept_match`.
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
#> [1] "/usr/local/lib/R/site-library/tilt.company.match/extdata/demo_matched.csv"

edited <- vroom(edited_csv, show_col_types = FALSE)
edited
#> # A tibble: 18 × 13
#>       id compa…¹ postc…² country misc_…³ compa…⁴ id_tilt compa…⁵ misc_…⁶ compa…⁷
#>    <dbl> <chr>   <chr>   <chr>   <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
#>  1     1 Peasan… 01234   germany A       peasan…       1 Peasan… A       peasan…
#>  2     1 Peasan… 01234   germany A       peasan…       2 Peasan… Z       peasan…
#>  3     1 Peasan… 01234   germany A       peasan…       4 Peasan… B       peasan…
#>  4     2 Peasan… 01234   germany Z       peasan…       1 Peasan… A       peasan…
#>  5     2 Peasan… 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#>  6     2 Peasan… 01234   germany Z       peasan…       4 Peasan… B       peasan…
#>  7     3 Peasan… 11234   germany Z       peasan…       3 Peasan… Z       peasan…
#>  8     4 Peasan… 01234   germany Z       peasan…       4 Peasan… B       peasan…
#>  9     4 Peasan… 01234   germany Z       peasan…       1 Peasan… A       peasan…
#> 10     4 Peasan… 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#> 11     5 Bread … 23456   germany C       breadb…       5 The Br… C       thebre…
#> 12     6 Flower… 34567   germany Z       flower…       7 Flower… F       flower…
#> 13     6 Flower… 34567   germany Z       flower…       6 Flower… D       flower…
#> 14     7 Screwd… 45678   germany D       screwd…      NA <NA>    <NA>    <NA>   
#> 15     8 Screwd… 45678   germany Z       screwd…      NA <NA>    <NA>    <NA>   
#> 16     9 John M… 56789   germany E       johnme…       8 John a… E       johnja…
#> 17    10 John M… 55555   germany Y       johnme…      NA <NA>    <NA>    <NA>   
#> 18    11 John M… 55555   norway  Y       johnme…      NA <NA>    <NA>    <NA>   
#> # … with 3 more variables: string_sim <dbl>, suggest_match <lgl>,
#> #   accept_match <lgl>, and abbreviated variable names ¹​company_name,
#> #   ²​postcode, ³​misc_info, ⁴​company_alias, ⁵​company_name_tilt, ⁶​misc_info_tilt,
#> #   ⁷​company_alias_tilt

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
#> Bakers Limited Screwdriver Experts Screwdriver Expert John Meier's Groceries
#> John Meier's Groceries John Meier's Groceries Best Bakers ℹ Did you match these
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
# Good
edited %>% check_duplicated_relation()
#> No duplicated matches found in the data.
```

With bad data you get informative errors.

``` r
# Bad: A single loanbook-company can't match multiple tilt-companies
bad_edited <- edited %>%
  mutate(accept_match = if_else(id %in% c(1, 2), TRUE, accept_match))
bad_edited %>% filter(id %in% c(1, 2))
#> # A tibble: 6 × 13
#>      id compan…¹ postc…² country misc_…³ compa…⁴ id_tilt compa…⁵ misc_…⁶ compa…⁷
#>   <dbl> <chr>    <chr>   <chr>   <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
#> 1     1 Peasant… 01234   germany A       peasan…       1 Peasan… A       peasan…
#> 2     1 Peasant… 01234   germany A       peasan…       2 Peasan… Z       peasan…
#> 3     1 Peasant… 01234   germany A       peasan…       4 Peasan… B       peasan…
#> 4     2 Peasant… 01234   germany Z       peasan…       1 Peasan… A       peasan…
#> 5     2 Peasant… 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#> 6     2 Peasant… 01234   germany Z       peasan…       4 Peasan… B       peasan…
#> # … with 3 more variables: string_sim <dbl>, suggest_match <lgl>,
#> #   accept_match <lgl>, and abbreviated variable names ¹​company_name,
#> #   ²​postcode, ³​misc_info, ⁴​company_alias, ⁵​company_name_tilt, ⁶​misc_info_tilt,
#> #   ⁷​company_alias_tilt

bad_edited %>%
  check_duplicated_relation() %>%
  try()
#> Error in check_duplicated_relation(.) : 
#>   Duplicated match of company in loanbook detected.
#> Duplicated company name: Peasant Peter, id: 1.
#> Duplicated company name: Peasant Peter, id: 2.
#> Company names where `accept_match` is `TRUE` must be unique by `id`.
#> Have you ensured that only one tilt-id per loanbook-id is set to `TRUE`?

# Bad: Multiple loanbook-companies can't match a single tilt-company
bad_edited2 <- demo_matched %>%
  filter(id_tilt == 3) %>%
  mutate(id = 12) %>%
  bind_rows(demo_matched)
bad_edited2 %>%
  filter(accept_match == TRUE & id_tilt == 3)
#> # A tibble: 2 × 13
#>      id compan…¹ postc…² country misc_…³ compa…⁴ id_tilt compa…⁵ misc_…⁶ compa…⁷
#>   <dbl> <chr>    <chr>   <chr>   <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
#> 1    12 Peasant… 11234   germany Z       peasan…       3 Peasan… Z       peasan…
#> 2     3 Peasant… 11234   germany Z       peasan…       3 Peasan… Z       peasan…
#> # … with 3 more variables: string_sim <dbl>, suggest_match <lgl>,
#> #   accept_match <lgl>, and abbreviated variable names ¹​company_name,
#> #   ²​postcode, ³​misc_info, ⁴​company_alias, ⁵​company_name_tilt, ⁶​misc_info_tilt,
#> #   ⁷​company_alias_tilt

bad_edited2 %>%
  check_duplicated_relation() %>%
  try()
#> Error in check_duplicated_relation(.) : 
#>   Duplicated match of company from tilt db detected.
#> ✖ Duplicated tilt company name: Peasant Peter, tilt id: 3.
#> ℹ Have you ensured that each tilt-id is set to `TRUE` for maximum 1 company from the loanbook?
```

If your edited dataset is wrong, go back to your spreadsheet editor
(i.e. repeat step 2), fix it, then check it again (i.e. repeat step 3).

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
#>      id compan…¹ postc…² country misc_…³ compa…⁴ id_tilt compa…⁵ misc_…⁶ compa…⁷
#>   <dbl> <chr>    <chr>   <chr>   <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
#> 1     1 Peasant… 01234   germany A       peasan…       1 Peasan… A       peasan…
#> 2     2 Peasant… 01234   germany Z       peasan…       2 Peasan… Z       peasan…
#> 3     3 Peasant… 11234   germany Z       peasan…       3 Peasan… Z       peasan…
#> 4     6 Flower … 34567   germany Z       flower…       7 Flower… F       flower…
#> # … with 3 more variables: string_sim <dbl>, suggest_match <lgl>,
#> #   accept_match <lgl>, and abbreviated variable names ¹​company_name,
#> #   ²​postcode, ³​misc_info, ⁴​company_alias, ⁵​company_name_tilt, ⁶​misc_info_tilt,
#> #   ⁷​company_alias_tilt
```

If you need to use your final dataset elsewhere, you may write it to a
.csv file like before with:

``` r
final %>% vroom::vroom_write("final.csv", delim = ",")
```
