# hasn't changed

    Code
      demo_matched
    Output
      # A tibble: 18 x 13
            id compa~1 postc~2 country misc_~3 compa~4 id_tilt compa~5 misc_~6 compa~7
         <dbl> <chr>   <chr>   <chr>   <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
       1     1 Peasan~ 01234   germany A       peasan~       1 Peasan~ A       peasan~
       2     1 Peasan~ 01234   germany A       peasan~       2 Peasan~ Z       peasan~
       3     1 Peasan~ 01234   germany A       peasan~       4 Peasan~ B       peasan~
       4     2 Peasan~ 01234   germany Z       peasan~       1 Peasan~ A       peasan~
       5     2 Peasan~ 01234   germany Z       peasan~       2 Peasan~ Z       peasan~
       6     2 Peasan~ 01234   germany Z       peasan~       4 Peasan~ B       peasan~
       7     3 Peasan~ 11234   germany Z       peasan~       3 Peasan~ Z       peasan~
       8     4 Peasan~ 01234   germany Z       peasan~       4 Peasan~ B       peasan~
       9     4 Peasan~ 01234   germany Z       peasan~       1 Peasan~ A       peasan~
      10     4 Peasan~ 01234   germany Z       peasan~       2 Peasan~ Z       peasan~
      11     5 Bread ~ 23456   germany C       breadb~       5 The Br~ C       thebre~
      12     6 Flower~ 34567   germany Z       flower~       7 Flower~ F       flower~
      13     6 Flower~ 34567   germany Z       flower~       6 Flower~ D       flower~
      14     7 Screwd~ 45678   germany D       screwd~      NA <NA>    <NA>    <NA>   
      15     8 Screwd~ 45678   germany Z       screwd~      NA <NA>    <NA>    <NA>   
      16     9 John M~ 56789   germany E       johnme~       8 John a~ E       johnja~
      17    10 John M~ 55555   germany Y       johnme~      NA <NA>    <NA>    <NA>   
      18    11 John M~ 55555   norway  Y       johnme~      NA <NA>    <NA>    <NA>   
      # ... with 3 more variables: string_sim <dbl>, suggest_match <lgl>,
      #   accept_match <lgl>, and abbreviated variable names 1: company_name,
      #   2: postcode, 3: misc_info, 4: company_alias, 5: company_name_tilt,
      #   6: misc_info_tilt, 7: company_alias_tilt

