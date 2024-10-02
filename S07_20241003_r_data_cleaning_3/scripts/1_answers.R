## How can we get GDP data for each country?
gdp_per_capita_data <- gdp_capita_data_long %>% select(-c(name)) %>%
  left_join(population_data_long, by = c("iso_code", "year")) %>%
  mutate(gdp = gdp_capita * population) %>%
  select(-c(gdp_capita, population)) %>%
  pivot_wider(names_from = year, values_from = gdp_per_capita)
