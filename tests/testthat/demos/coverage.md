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

    # Edited file after manual validation
    edited <- vroom(example_file("demo_matched.csv"), show_col_types = FALSE)
    edited
    #> # A tibble: 18 × 13
    #>       id company_name postc…¹ country misc_…² compa…³
    #>    <dbl> <chr>        <chr>   <chr>   <chr>   <chr>  
    #>  1     1 Peasant Pet… 01234   germany A       peasan…
    #>  2     1 Peasant Pet… 01234   germany A       peasan…
    #>  3     1 Peasant Pet… 01234   germany A       peasan…
    #>  4     2 Peasant Pet… 01234   germany Z       peasan…
    #>  5     2 Peasant Pet… 01234   germany Z       peasan…
    #>  6     2 Peasant Pet… 01234   germany Z       peasan…
    #>  7     3 Peasant Pet… 11234   germany Z       peasan…
    #>  8     4 Peasant Paul 01234   germany Z       peasan…
    #>  9     4 Peasant Paul 01234   germany Z       peasan…
    #> 10     4 Peasant Paul 01234   germany Z       peasan…
    #> 11     5 Bread Baker… 23456   germany C       breadb…
    #> 12     6 Flower Powe… 34567   germany Z       flower…
    #> 13     6 Flower Powe… 34567   germany Z       flower…
    #> 14     7 Screwdriver… 45678   germany D       screwd…
    #> 15     8 Screwdriver… 45678   germany Z       screwd…
    #> 16     9 John Meier'… 56789   germany E       johnme…
    #> 17    10 John Meier'… 55555   germany Y       johnme…
    #> 18    11 John Meier'… 55555   norway  Y       johnme…
    #> # … with 7 more variables: id_tilt <dbl>,
    #> #   company_name_tilt <chr>, misc_info_tilt <chr>,
    #> #   company_alias_tilt <chr>, string_sim <dbl>,
    #> #   suggest_match <lgl>, accept_match <lgl>, and
    #> #   abbreviated variable names ¹​postcode,
    #> #   ²​misc_info, ³​company_alias

## Share of matched companies after manual validation from total loanbook companies

    accepted <- edited %>%
      filter(accept_match)
    accepted
    #> # A tibble: 4 × 13
    #>      id company_name  postc…¹ country misc_…² compa…³
    #>   <dbl> <chr>         <chr>   <chr>   <chr>   <chr>  
    #> 1     1 Peasant Peter 01234   germany A       peasan…
    #> 2     2 Peasant Peter 01234   germany Z       peasan…
    #> 3     3 Peasant Peter 11234   germany Z       peasan…
    #> 4     6 Flower Power… 34567   germany Z       flower…
    #> # … with 7 more variables: id_tilt <dbl>,
    #> #   company_name_tilt <chr>, misc_info_tilt <chr>,
    #> #   company_alias_tilt <chr>, string_sim <dbl>,
    #> #   suggest_match <lgl>, accept_match <lgl>, and
    #> #   abbreviated variable names ¹​postcode,
    #> #   ²​misc_info, ³​company_alias

    matched_rows <- accepted %>% nrow()
    matched_rows
    #> [1] 4

    total_rows <- loanbook %>%
      distinct(id) %>%
      nrow()

    matched_share <- matched_rows / total_rows
    matched_share
    #> [1] 0.3333333

## Number and share of matched companies classified by `misc_info` from total loanbook companies

Please replace the `misc_info` column with variables like sectors,
headcount or similar classifier to calculate the share based on that
classifier.

    x_misc <- loanbook %>% count(misc_info)
    y_misc <- accepted %>% count(misc_info)
    misc_share <-
      left_join(x_misc, y_misc, by = c("misc_info"), suffix = c("_total", "_merged")) %>%
      mutate(n_share = n_merged / n_total)
    misc_share
    #> # A tibble: 7 × 4
    #>   misc_info n_total n_merged n_share
    #>   <chr>       <int>    <int>   <dbl>
    #> 1 A               1        1     1  
    #> 2 C               1       NA    NA  
    #> 3 D               1       NA    NA  
    #> 4 E               1       NA    NA  
    #> 5 F               1       NA    NA  
    #> 6 Y               2       NA    NA  
    #> 7 Z               5        3     0.6

## Calculate loan exposure classified based on `misc_info`

The `loan_amount` column is added as a sample column to calculate the
loan exposure output. Please replace the name of sample `loan_amount`
column and the sample loanbook dataset with the original loan amount
column name and the original loanbook dataset!

    accepted_loan <- accepted %>% mutate(loan_amount = c(1000))

    # Calculate number of loans and their share from total rows after grouping by
    # `misc_info`
    exposure_count <- accepted_loan %>%
      count(misc_info) %>%
      mutate(count_share = n / sum(n))
    exposure_count
    #> # A tibble: 2 × 3
    #>   misc_info     n count_share
    #>   <chr>     <int>       <dbl>
    #> 1 A             1        0.25
    #> 2 Z             3        0.75

    # Calculate sum of loan values and their share from total value after grouping
    # by `misc_info`
    exposure_sum <- accepted_loan %>%
      group_by(misc_info) %>%
      summarise(sum_expo = sum(loan_amount)) %>%
      mutate(sum_share = sum_expo / sum(sum_expo))
    exposure_sum
    #> # A tibble: 2 × 3
    #>   misc_info sum_expo sum_share
    #>   <chr>        <dbl>     <dbl>
    #> 1 A             1000      0.25
    #> 2 Z             3000      0.75
