# hasn't changed

    Code
      as.data.frame(out)
    Output
         id           company_name postcode country misc_info       company_alias id_tilt            company_name_tilt misc_info_tilt    company_alias_tilt postcode_tilt country_tilt similarity
      1   1          Peasant Peter    01234 germany         A        peasantpeter       1                Peasant Peter              A          peasantpeter          <NA>         <NA>  1.0000000
      2   1          Peasant Peter    01234 germany         A        peasantpeter       2                Peasant Peter              Z          peasantpeter          <NA>         <NA>  1.0000000
      3   1          Peasant Peter    01234 germany         A        peasantpeter       4                 Peasant Paul              B           peasantpaul          <NA>         <NA>  0.8787879
      4   2          Peasant Peter    01234 germany         Z        peasantpeter       1                Peasant Peter              A          peasantpeter          <NA>         <NA>  1.0000000
      5   2          Peasant Peter    01234 germany         Z        peasantpeter       2                Peasant Peter              Z          peasantpeter          <NA>         <NA>  1.0000000
      6   2          Peasant Peter    01234 germany         Z        peasantpeter       4                 Peasant Paul              B           peasantpaul          <NA>         <NA>  0.8787879
      7   3          Peasant Peter    11234 germany         Z        peasantpeter       3                Peasant Peter              Z          peasantpeter          <NA>         <NA>  1.0000000
      8   4           Peasant Paul    01234 germany         Z         peasantpaul       4                 Peasant Paul              B           peasantpaul          <NA>         <NA>  1.0000000
      9   4           Peasant Paul    01234 germany         Z         peasantpaul       1                Peasant Peter              A          peasantpeter          <NA>         <NA>  0.8787879
      10  4           Peasant Paul    01234 germany         Z         peasantpaul       2                Peasant Peter              Z          peasantpeter          <NA>         <NA>  0.8787879
      11  5   Bread Bakers Limited    23456 germany         C     breadbakers ltd       5         The Bread Bakers Ltd              C    thebreadbakers ltd          <NA>         <NA>  0.8444444
      12  6 Flower Power & Company    34567 germany         Z      flowerpower co       7         Flower Power and Co.              F        flowerpower co          <NA>         <NA>  1.0000000
      13  6 Flower Power & Company    34567 germany         Z      flowerpower co       6 Flower Power Friends and Co.              D flowerpowerfriends co          <NA>         <NA>  0.9333333
      14  7    Screwdriver Experts    45678 germany         D  screwdriverexperts      NA                         <NA>           <NA>                  <NA>          <NA>         <NA>         NA
      15  8     Screwdriver Expert    45678 germany         Z   screwdriverexpert      NA                         <NA>           <NA>                  <NA>          <NA>         <NA>         NA
      16  9 John Meier's Groceries    56789 germany         E johnmeiersgroceries       8   John and Jacques Groceries              E  johnjacquesgroceries          <NA>         <NA>  0.8478947
      17 10 John Meier's Groceries    55555 germany         Y johnmeiersgroceries      NA                         <NA>           <NA>                  <NA>          <NA>         <NA>         NA
      18 11 John Meier's Groceries    55555  norway         Y johnmeiersgroceries      NA                         <NA>           <NA>                  <NA>          <NA>         <NA>         NA
         suggest_match accept_match
      1             NA           NA
      2             NA           NA
      3             NA           NA
      4             NA           NA
      5             NA           NA
      6             NA           NA
      7           TRUE           NA
      8           TRUE           NA
      9             NA           NA
      10            NA           NA
      11            NA           NA
      12          TRUE           NA
      13            NA           NA
      14            NA           NA
      15            NA           NA
      16            NA           NA
      17            NA           NA
      18            NA           NA

# output with a fully matched company

    $id
    [1] 1
    
    $company_name
    [1] "a"
    
    $country
    [1] "b"
    
    $postcode
    [1] "c"
    
    $company_alias
    [1] "a"
    
    $id_tilt
    [1] 1
    
    $company_name_tilt
    [1] "a"
    
    $company_alias_tilt
    [1] "a"
    
    $postcode_tilt
    [1] NA
    
    $country_tilt
    [1] NA
    
    $similarity
    [1] 1
    
    $suggest_match
    [1] TRUE
    
    $accept_match
    [1] NA
    

