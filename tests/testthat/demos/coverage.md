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
    #> # … with 5 more variables: postcode_tilt <chr>, country_tilt <chr>,
    #> #   similarity <dbl>, suggest_match <lgl>, accept_match <lgl>, and abbreviated
    #> #   variable names ¹​company_name, ²​postcode, ³​misc_info, ⁴​company_alias,
    #> #   ⁵​company_name_tilt, ⁶​misc_info_tilt, ⁷​company_alias_tilt

## Share of matched companies after manual validation from total loanbook companies

    accepted <- to_edit %>%
      filter(accept_match)
    accepted
    #> # A tibble: 0 × 15
    #> # … with 15 variables: id <dbl>, company_name <chr>, postcode <chr>,
    #> #   country <chr>, misc_info <chr>, company_alias <chr>, id_tilt <dbl>,
    #> #   company_name_tilt <chr>, misc_info_tilt <chr>, company_alias_tilt <chr>,
    #> #   postcode_tilt <chr>, country_tilt <chr>, similarity <dbl>,
    #> #   suggest_match <lgl>, accept_match <lgl>

    matched_rows <- accepted %>% nrow()
    matched_rows
    #> [1] 0

    total_rows <- loanbook %>%
      distinct(id) %>%
      nrow()

    matched_share <- matched_rows / total_rows
    matched_share
    #> [1] 0

## Number and share of matched companies classified by `misc_info` from total loanbook companies

Please replace the `misc_info` column with variables like sectors,
headcount or similar classifier to calculate the share based on that
classifier.

    x_misc <- loanbook %>% count(misc_info)
    y_misc <- accepted %>% count(misc_info)
    misc_share <-
      left_join(x_misc, y_misc, by = c("misc_info"), suffix = c("_total", "_merged")) %>%
      mutate(n_share = n_merged / n_total)

## Calculate loan exposure classified based on `misc_info`

The `loan_amount` column is added as a sample column to calculate the
loan exposure output. Please replace `loan_amount` column and the
loanbook dataset with the original loan column and loanbook dataset!

    accepted_loan <- accepted %>% mutate(loan_amount = c(1000))

    # Calculate number of loans and their share from total rows after grouping by
    # `misc_info`
    exposure_count <- accepted_loan %>%
      count(misc_info) %>%
      mutate(count_share = n / sum(n))

    # Calculate sum of loan values and their share from total value after grouping
    # by `misc_info`
    exposure_sum <- accepted_loan %>%
      group_by(misc_info) %>%
      summarise(sum_expo = sum(loan_amount)) %>%
      mutate(sum_share = sum_expo / sum(sum_expo))
