demo_tilt <- tibble::tribble(
  ~id, ~company_name, ~postcode, ~country, ~misc_info,
  1, "Peasant Peter", "01234", "germany", "A",
  2, "Peasant Peter", "01234", "germany", "Z", # same name and postcode but different company to other entry
  3, "Peasant Peter", "11234", "germany", "Z", # same name but different postcode and company to other entry
  4, "Peasant Paul", "01234", "germany", "B",
  5, "The Bread Bakers Ltd", "23456", "germany", "C",
  6, "Flower Power Friends and Co.", "34567", "germany", "D",
  7, "Flower Power and Co.", "34567", "germany", "F", # similar name and same postcode but different company to other entry
  8, "John and Jacques Groceries", "56789", "germany", "E",
  9, "John and Jacques Groceries", "98765", "germany", "E", # same name but different postcode and different company to other entry
  10, "John and Jacques Groceries", "98765", "france", "E",
  11, "Cranes and Friends", "65656", "france", "F"
)

file <- here::here("inst", "extdata", "demo_tilt.csv")
vroom::vroom_write(demo_tilt, file, delim = ",")

usethis::use_data(demo_tilt, overwrite = TRUE)
