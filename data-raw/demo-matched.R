demo_matched <- tibble::tribble(
  ~id, ~company_name, ~postcode, ~country, ~misc_info, ~company_alias, ~id_tilt, ~company_name_tilt, ~misc_info_tilt, ~company_alias_tilt, ~string_sim, ~suggest_match, ~accept_match,
  1, "Peasant Peter", "01234", "germany", "A", "peasantpeter", 1, "Peasant Peter", "A", "peasantpeter", 1, NA, TRUE,
  1, "Peasant Peter", "01234", "germany", "A", "peasantpeter", 2, "Peasant Peter", "Z", "peasantpeter", 1, NA, NA,
  1, "Peasant Peter", "01234", "germany", "A", "peasantpeter", 4, "Peasant Paul", "B", "peasantpaul", 0.878787878787879, NA, NA,
  2, "Peasant Peter", "01234", "germany", "Z", "peasantpeter", 1, "Peasant Peter", "A", "peasantpeter", 1, NA, NA,
  2, "Peasant Peter", "01234", "germany", "Z", "peasantpeter", 2, "Peasant Peter", "Z", "peasantpeter", 1, NA, TRUE,
  2, "Peasant Peter", "01234", "germany", "Z", "peasantpeter", 4, "Peasant Paul", "B", "peasantpaul", 0.878787878787879, NA, NA,
  3, "Peasant Peter", "11234", "germany", "Z", "peasantpeter", 3, "Peasant Peter", "Z", "peasantpeter", 1, TRUE, TRUE,
  4, "Peasant Paul", "01234", "germany", "Z", "peasantpaul", 4, "Peasant Paul", "B", "peasantpaul", 1, TRUE, NA,
  4, "Peasant Paul", "01234", "germany", "Z", "peasantpaul", 1, "Peasant Peter", "A", "peasantpeter", 0.878787878787879, NA, NA,
  4, "Peasant Paul", "01234", "germany", "Z", "peasantpaul", 2, "Peasant Peter", "Z", "peasantpeter", 0.878787878787879, NA, NA,
  5, "Bread Bakers Limited", "23456", "germany", "C", "breadbakers ltd", 5, "The Bread Bakers Ltd", "C", "thebreadbakers ltd", 0.844444444444444, NA, NA,
  6, "Flower Power & Company", "34567", "germany", "Z", "flowerpower co", 7, "Flower Power and Co.", "F", "flowerpower co", 1, TRUE, TRUE,
  6, "Flower Power & Company", "34567", "germany", "Z", "flowerpower co", 6, "Flower Power Friends and Co.", "D", "flowerpowerfriends co", 0.933333333333333, NA, NA,
  7, "Screwdriver Experts", "45678", "germany", "D", "screwdriverexperts", NA, NA, NA, NA, NA, NA, NA,
  8, "Screwdriver Expert", "45678", "germany", "Z", "screwdriverexpert", NA, NA, NA, NA, NA, NA, NA,
  9, "John Meier's Groceries", "56789", "germany", "E", "johnmeiersgroceries", 8, "John and Jacques Groceries", "E", "johnjacquesgroceries", 0.847894736842105, NA, NA,
  10, "John Meier's Groceries", "55555", "germany", "Y", "johnmeiersgroceries", NA, NA, NA, NA, NA, NA, NA,
  11, "John Meier's Groceries", "55555", "norway", "Y", "johnmeiersgroceries", NA, NA, NA, NA, NA, NA, NA
)

usethis::use_data(demo_matched, overwrite = TRUE)
