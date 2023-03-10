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

    to_edit %>% glimpse()
    #> Rows: 18
    #> Columns: 15
    #> $ id                 <dbl> 1, 1, 1, 2, 2, 2, 3, 4, 4, 4, 5, 6, 6, 7,…
    #> $ company_name       <chr> "Peasant Peter", "Peasant Peter", "Peasan…
    #> $ postcode           <chr> "01234", "01234", "01234", "01234", "0123…
    #> $ country            <chr> "germany", "germany", "germany", "germany…
    #> $ misc_info          <chr> "A", "A", "A", "Z", "Z", "Z", "Z", "Z", "…
    #> $ company_alias      <chr> "peasantpeter", "peasantpeter", "peasantp…
    #> $ id_tilt            <dbl> 1, 2, 4, 1, 2, 4, 3, 4, 1, 2, 5, 7, 6, NA…
    #> $ company_name_tilt  <chr> "Peasant Peter", "Peasant Peter", "Peasan…
    #> $ misc_info_tilt     <chr> "A", "Z", "B", "A", "Z", "B", "Z", "B", "…
    #> $ company_alias_tilt <chr> "peasantpeter", "peasantpeter", "peasantp…
    #> $ postcode_tilt      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    #> $ country_tilt       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    #> $ similarity         <dbl> 1.0000000, 1.0000000, 0.8787879, 1.000000…
    #> $ suggest_match      <lgl> NA, NA, NA, NA, NA, NA, TRUE, TRUE, NA, N…
    #> $ accept_match       <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…

    suggested <- to_edit %>%
      filter(suggest_match)

    #### Number of matched companies based on suggested matches
    matched_rows <- suggested %>% nrow()
    matched_rows
    #> [1] 3

    #### Share of matched companies from total loanbook companies
    total_rows <- loanbook %>%
      distinct(company_name) %>%
      nrow()
    matched_share <- matched_rows / total_rows
    matched_share
    #> [1] 0.375

#### Number and share of matched companies classified by misc\_info from total loanbook companies

misc\_info should be replaced with variables like sectors, headcount
etc.

    x <- loanbook %>% count(misc_info)
    y <- suggested %>% count(misc_info)
    misc_share <-
      left_join(x, y, by = c("misc_info"), suffix = c("_loanbook", "_merged")) %>%
      mutate(n_share = n_merged / n_loanbook)

#### Calculate loan exposure categorised based on misc\_info

id\_tilt column is used as the substitute due to unavailability of loan
amount column in sample data. Please replace id\_tilt column with the
loan amount column.

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
