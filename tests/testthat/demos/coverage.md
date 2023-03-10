## Setup

Use the required packages, read your `loanbook` and `tilt` datasets,
check your `loanbook` and suggest matches. For a gentle walkthrough see
[Get
started](https://2degreesinvesting.github.io/tilt.company.match/articles/tilt-company-match.html).

    library(dplyr, warn.conflicts = FALSE)
    library(vroom)
    library(tilt.company.match)

    loanbook <- vroom(example_file("demo_loanbook.csv"), show_col_types = FALSE)
    tilt <- vroom(example_file("demo_tilt.csv"), show_col_types = FALSE)

    loanbook %>% check_loanbook()
    #> Found duplicate(s) on columns company_name, postcode, country of the data set.
    #> ✖ Found for the company Peasant Peter, postcode: 01234, country: germany
    #> ℹ Please check if these duplicates are intended and have an unique id.

    to_edit <- loanbook %>% suggest_match(tilt)
    #> Joining with `by = join_by(id, company_name)`
    to_edit
    #> # A tibble: 18 × 15
    #>       id company_name postc…¹ country misc_…² compa…³ id_tilt compa…⁴
    #>    <dbl> <chr>        <chr>   <chr>   <chr>   <chr>     <dbl> <chr>  
    #>  1     1 Peasant Pet… 01234   germany A       peasan…       1 Peasan…
    #>  2     1 Peasant Pet… 01234   germany A       peasan…       2 Peasan…
    #>  3     1 Peasant Pet… 01234   germany A       peasan…       4 Peasan…
    #>  4     2 Peasant Pet… 01234   germany Z       peasan…       1 Peasan…
    #>  5     2 Peasant Pet… 01234   germany Z       peasan…       2 Peasan…
    #>  6     2 Peasant Pet… 01234   germany Z       peasan…       4 Peasan…
    #>  7     3 Peasant Pet… 11234   germany Z       peasan…       3 Peasan…
    #>  8     4 Peasant Paul 01234   germany Z       peasan…       4 Peasan…
    #>  9     4 Peasant Paul 01234   germany Z       peasan…       1 Peasan…
    #> 10     4 Peasant Paul 01234   germany Z       peasan…       2 Peasan…
    #> 11     5 Bread Baker… 23456   germany C       breadb…       5 The Br…
    #> 12     6 Flower Powe… 34567   germany Z       flower…       7 Flower…
    #> 13     6 Flower Powe… 34567   germany Z       flower…       6 Flower…
    #> 14     7 Screwdriver… 45678   germany D       screwd…      NA <NA>   
    #> 15     8 Screwdriver… 45678   germany Z       screwd…      NA <NA>   
    #> 16     9 John Meier'… 56789   germany E       johnme…       8 John a…
    #> 17    10 John Meier'… 55555   germany Y       johnme…      NA <NA>   
    #> 18    11 John Meier'… 55555   norway  Y       johnme…      NA <NA>   
    #> # … with 7 more variables: misc_info_tilt <chr>,
    #> #   company_alias_tilt <chr>, postcode_tilt <chr>,
    #> #   country_tilt <chr>, similarity <dbl>, suggest_match <lgl>,
    #> #   accept_match <lgl>, and abbreviated variable names ¹​postcode,
    #> #   ²​misc_info, ³​company_alias, ⁴​company_name_tilt

## Share of matched companies from total loanbook companies

    suggested <- to_edit %>%
      filter(suggest_match)

    matched_rows <- suggested %>% nrow()
    total_rows <- loanbook %>%
      distinct(company_name) %>%
      nrow()

    matched_share <- matched_rows / total_rows
    matched_share
    #> [1] 0.375

## Number and share of matched companies classified by `misc_info` from total loanbook companies

`misc_info` should be replaced with variables like sectors, headcount
etc.

    x <- loanbook %>% count(misc_info)
    y <- suggested %>% count(misc_info)
    misc_share <-
      left_join(x, y, by = c("misc_info"), suffix = c("_loanbook", "_merged")) %>%
      mutate(n_share = n_merged / n_loanbook)

## Calculate loan exposure categorised based on `misc_info`

The `id_tilt` column is used as the substitute due to unavailability of
loan amount column in sample data. Please replace `id_tilt` column with
the loan amount column.

    # Calculate number of loans and their share from total after grouping by
    # `misc_info`
    exposure_count <- suggested %>%
      count(misc_info) %>%
      mutate(count_share = n / sum(n))

    # Calculate sum of loan values and their share from total value after grouping
    # by `misc_info`
    exposure_sum <- suggested %>%
      group_by(misc_info) %>%
      summarise(sum_expo = sum(id_tilt)) %>%
      mutate(sum_share = sum_expo / sum(sum_expo))
