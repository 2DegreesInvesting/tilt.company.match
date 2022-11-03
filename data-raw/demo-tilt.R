demo_tilt <- tibble::tribble(
  ~id, ~company_name, ~zip, ~country, ~misc_info,
  1, "Peasant Peter", "01234", "germany", "A",
  2, "Peasant Peter", "01234", "germany", "Z", # same name and zip but different company to other entry
  3, "Peasant Peter", "11234", "germany", "Z", # same name but different zip and company to other entry
  4, "Peasant Paul", "01234", "germany", "B",
  5, "The Bread Bakers Ltd", "23456", "germany", "C",
  6, "Flower Power Friends and Co.", "34567", "germany", "D",
  7, "Flower Power and Co.", "34567", "germany", "F", # similar name and same zip but different company to other entry
  8, "John and Jacques Groceries", "56789", "germany", "E",
  9, "John and Jacques Groceries", "98765", "germany", "E", # same name but different zip and different company to other entry
  10, "John and Jacques Groceries", "98765", "france", "E"
)

usethis::use_data(demo_tilt, overwrite = TRUE)
