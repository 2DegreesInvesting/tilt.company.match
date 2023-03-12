# hasn't changed

    Code
      as.data.frame(out)
    Output
         id           company_name postcode country misc_info       company_alias
      1   1          Peasant Peter    01234 germany         A        peasantpeter
      2   1          Peasant Peter    01234 germany         A        peasantpeter
      3   1          Peasant Peter    01234 germany         A        peasantpeter
      4   2          Peasant Peter    01234 germany         Z        peasantpeter
      5   2          Peasant Peter    01234 germany         Z        peasantpeter
      6   2          Peasant Peter    01234 germany         Z        peasantpeter
      7   3          Peasant Peter    11234 germany         Z        peasantpeter
      8   4           Peasant Paul    01234 germany         Z         peasantpaul
      9   4           Peasant Paul    01234 germany         Z         peasantpaul
      10  4           Peasant Paul    01234 germany         Z         peasantpaul
      11  5   Bread Bakers Limited    23456 germany         C     breadbakers ltd
      12  6 Flower Power & Company    34567 germany         Z      flowerpower co
      13  6 Flower Power & Company    34567 germany         Z      flowerpower co
      14  7    Screwdriver Experts    45678 germany         D  screwdriverexperts
      15  8     Screwdriver Expert    45678 germany         Z   screwdriverexpert
      16  9 John Meier's Groceries    56789 germany         E johnmeiersgroceries
      17 10 John Meier's Groceries    55555 germany         Y johnmeiersgroceries
      18 11 John Meier's Groceries    55555  norway         Y johnmeiersgroceries
         id_tilt            company_name_tilt misc_info_tilt    company_alias_tilt
      1        1                Peasant Peter              A          peasantpeter
      2        2                Peasant Peter              Z          peasantpeter
      3        4                 Peasant Paul              B           peasantpaul
      4        1                Peasant Peter              A          peasantpeter
      5        2                Peasant Peter              Z          peasantpeter
      6        4                 Peasant Paul              B           peasantpaul
      7        3                Peasant Peter              Z          peasantpeter
      8        4                 Peasant Paul              B           peasantpaul
      9        1                Peasant Peter              A          peasantpeter
      10       2                Peasant Peter              Z          peasantpeter
      11       5         The Bread Bakers Ltd              C    thebreadbakers ltd
      12       7         Flower Power and Co.              F        flowerpower co
      13       6 Flower Power Friends and Co.              D flowerpowerfriends co
      14      NA                         <NA>           <NA>                  <NA>
      15      NA                         <NA>           <NA>                  <NA>
      16       8   John and Jacques Groceries              E  johnjacquesgroceries
      17      NA                         <NA>           <NA>                  <NA>
      18      NA                         <NA>           <NA>                  <NA>
         postcode_tilt country_tilt similarity suggest_match accept_match
      1           <NA>         <NA>  1.0000000            NA           NA
      2           <NA>         <NA>  1.0000000            NA           NA
      3           <NA>         <NA>  0.8787879            NA           NA
      4           <NA>         <NA>  1.0000000            NA           NA
      5           <NA>         <NA>  1.0000000            NA           NA
      6           <NA>         <NA>  0.8787879            NA           NA
      7           <NA>         <NA>  1.0000000          TRUE           NA
      8           <NA>         <NA>  1.0000000          TRUE           NA
      9           <NA>         <NA>  0.8787879            NA           NA
      10          <NA>         <NA>  0.8787879            NA           NA
      11          <NA>         <NA>  0.8444444            NA           NA
      12          <NA>         <NA>  1.0000000          TRUE           NA
      13          <NA>         <NA>  0.9333333            NA           NA
      14          <NA>         <NA>         NA            NA           NA
      15          <NA>         <NA>         NA            NA           NA
      16          <NA>         <NA>  0.8478947            NA           NA
      17          <NA>         <NA>         NA            NA           NA
      18          <NA>         <NA>         NA            NA           NA

# output with a fully matched company

    Rows: 1
    Columns: 13
    $ id                 [3m[38;5;246m<dbl>[39m[23m 1
    $ company_name       [3m[38;5;246m<chr>[39m[23m "a"
    $ country            [3m[38;5;246m<chr>[39m[23m "b"
    $ postcode           [3m[38;5;246m<chr>[39m[23m "c"
    $ company_alias      [3m[38;5;246m<chr>[39m[23m "a"
    $ id_tilt            [3m[38;5;246m<dbl>[39m[23m 1
    $ company_name_tilt  [3m[38;5;246m<chr>[39m[23m "a"
    $ company_alias_tilt [3m[38;5;246m<chr>[39m[23m "a"
    $ postcode_tilt      [3m[38;5;246m<chr>[39m[23m NA
    $ country_tilt       [3m[38;5;246m<chr>[39m[23m NA
    $ similarity         [3m[38;5;246m<dbl>[39m[23m 1
    $ suggest_match      [3m[38;5;246m<lgl>[39m[23m TRUE
    $ accept_match       [3m[38;5;246m<lgl>[39m[23m NA

