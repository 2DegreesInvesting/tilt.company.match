# hasn't changed

    Code
      as.list(out)
    Output
      $id
       [1]  1  1  1  2  2  2  3  4  4  4  5  6  6  7  8  9 10 11
      
      $company_name
       [1] "Peasant Peter"          "Peasant Peter"          "Peasant Peter"          "Peasant Peter"          "Peasant Peter"          "Peasant Peter"          "Peasant Peter"          "Peasant Paul"           "Peasant Paul"          
      [10] "Peasant Paul"           "Bread Bakers Limited"   "Flower Power & Company" "Flower Power & Company" "Screwdriver Experts"    "Screwdriver Expert"     "John Meier's Groceries" "John Meier's Groceries" "John Meier's Groceries"
      
      $postcode
       [1] "01234" "01234" "01234" "01234" "01234" "01234" "11234" "01234" "01234" "01234" "23456" "34567" "34567" "45678" "45678" "56789" "55555" "55555"
      
      $country
       [1] "germany" "germany" "germany" "germany" "germany" "germany" "germany" "germany" "germany" "germany" "germany" "germany" "germany" "germany" "germany" "germany" "germany" "norway" 
      
      $misc_info
       [1] "A" "A" "A" "Z" "Z" "Z" "Z" "Z" "Z" "Z" "C" "Z" "Z" "D" "Z" "E" "Y" "Y"
      
      $company_alias
       [1] "peasantpeter"        "peasantpeter"        "peasantpeter"        "peasantpeter"        "peasantpeter"        "peasantpeter"        "peasantpeter"        "peasantpaul"         "peasantpaul"         "peasantpaul"         "breadbakers ltd"    
      [12] "flowerpower co"      "flowerpower co"      "screwdriverexperts"  "screwdriverexpert"   "johnmeiersgroceries" "johnmeiersgroceries" "johnmeiersgroceries"
      
      $id_tilt
       [1]  1  2  4  1  2  4  3  4  1  2  5  7  6 NA NA  8 NA NA
      
      $company_name_tilt
       [1] "Peasant Peter"                "Peasant Peter"                "Peasant Paul"                 "Peasant Peter"                "Peasant Peter"                "Peasant Paul"                 "Peasant Peter"               
       [8] "Peasant Paul"                 "Peasant Peter"                "Peasant Peter"                "The Bread Bakers Ltd"         "Flower Power and Co."         "Flower Power Friends and Co." NA                            
      [15] NA                             "John and Jacques Groceries"   NA                             NA                            
      
      $misc_info_tilt
       [1] "A" "Z" "B" "A" "Z" "B" "Z" "B" "A" "Z" "C" "F" "D" NA  NA  "E" NA  NA 
      
      $company_alias_tilt
       [1] "peasantpeter"          "peasantpeter"          "peasantpaul"           "peasantpeter"          "peasantpeter"          "peasantpaul"           "peasantpeter"          "peasantpaul"           "peasantpeter"          "peasantpeter"         
      [11] "thebreadbakers ltd"    "flowerpower co"        "flowerpowerfriends co" NA                      NA                      "johnjacquesgroceries"  NA                      NA                     
      
      $postcode_tilt
       [1] NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA
      
      $country_tilt
       [1] NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA
      
      $similarity
       [1] 1.0000000 1.0000000 0.8787879 1.0000000 1.0000000 0.8787879 1.0000000 1.0000000 0.8787879 0.8787879 0.8444444 1.0000000 0.9333333        NA        NA 0.8478947        NA        NA
      
      $suggest_match
       [1]   NA   NA   NA   NA   NA   NA TRUE TRUE   NA   NA   NA TRUE   NA   NA   NA   NA   NA   NA
      
      $accept_match
       [1] NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA NA
      
      attr(,"spec")
      cols(
        id = col_double(),
        company_name = col_character(),
        postcode = col_character(),
        country = col_character(),
        misc_info = col_character(),
        .delim = ","
      )
      attr(,"problems")
      <pointer: 0x555fd6dbdc80>

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
    

