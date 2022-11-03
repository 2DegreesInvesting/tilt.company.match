demo_loanbook <- tibble::tribble(
  ~id, ~company_name, ~zip, ~country, ~misc_info,
  1, "Peasant Peter", "01234", "germany", "A", # perfect name match, same zip, same company to a tilt-demo entry
  2, "Peasant Peter", "01234", "germany", "Z", # same name and zip but different company to other entry
  3, "Peasant Peter", "11234", "germany", "Z", # same name  but different zip and company to other entry
  4, "Peasant Paul", "01234", "germany", "Z", # perfect name match, same zip, different company to a tilt-demo entry
  5, "Bread Bakers Limited", "23456", "germany", "C", # similar name, same zip, same company to a tilt-demo entry
  6, "Flower Power & Company", "34567", "germany", "Z", # similar name, same zip, different company to a tilt-demo entry
  7, "Screwdriver Experts", "45678", "germany", "D", # different name, same zip, different company to all tilt-demo entries
  8, "Screwdriver Expert", "45678", "germany", "Z", # similar name and same zip but different company to other entry
  9, "John Meier's Groceries", "56789", "germany", "E", # different name, same zip, same company to a tilt-demo entry (e.g. rename)
  10, "John Meier's Groceries", "55555", "germany", "Y", # same name but different zip and different company to other entry,
  11, "John Meier's Groceries", "55555", "norway", "Y" # not in tilt data
)

usethis::use_data(demo_loanbook, overwrite = TRUE)
