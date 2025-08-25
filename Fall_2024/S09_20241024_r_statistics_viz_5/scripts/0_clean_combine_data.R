#########################
# Add ISO CODE to data
#########################
culture_data$iso_code <- countrycode(culture_data$country, origin = 'country.name', destination = 'iso3c')
wvs_regions_data$iso_code <- countrycode(wvs_regions_data$country, origin = 'country.name', destination = 'iso3c')
pew_climate_data$iso_code <- countrycode(pew_climate_data$country, origin = 'country.name', destination = 'iso3c')
names(population_data)[names(population_data) == "iso3"] <- "iso_code"
names(vulnerability_data)[names(vulnerability_data) == "iso3"] <- "iso_code"
names(gdp_capita_data)[names(gdp_capita_data) == "iso3"] <- "iso_code"
names(gdp_capita_data)[names(gdp_capita_data) == "gdp"] <- "gdp_capita"

#########################
# Wide versus long data
#########################
## Population data
head(population_data)
head(gdp_capita_data)
population_data_long <- population_data %>%
  pivot_longer(cols = -c(iso_code, name), names_to = "year", values_to = "population") %>%
  mutate(year = as.numeric(substr(year, 2, 5)))
gdp_capita_data_long <- gdp_capita_data %>%
  pivot_longer(cols = -c(iso_code, name), names_to = "year", values_to = "gdp_capita") %>%
  mutate(year = as.numeric(substr(year, 2, 5)))
population_data_wide <- population_data_long %>%
  pivot_wider(names_from = year, values_from = population)
gdp_capita_data_wide <- gdp_capita_data_long %>% 
  pivot_wider(names_from = year, values_from = gdp_capita)

#########################
# Combining our data
#########################
## Combine culture and gdp data
culture_gdp_2020_data <- culture_data %>% select(-c(country)) %>%
  left_join(subset(gdp_capita_data, select=c(iso_code, x2020)), by = c("iso_code")) 
culture_gdp_2020_data <- culture_gdp_2020_data %>% select(iso_code, x2020, everything())
names(culture_gdp_2020_data)[names(culture_gdp_2020_data) == "x2020"] <- "gdp_capita_2020"

## Combine culture, gdp, and population data
culture_gdp_pop_2020_data <- culture_gdp_2020_data %>%
  left_join(subset(population_data, select=c(iso_code, x2020)), by = c("iso_code")) %>%
  select(iso_code, x2020, everything())
names(culture_gdp_pop_2020_data)[names(culture_gdp_pop_2020_data) == "x2020"] <- "population_2020"

## Combine culture, gdp, population, and vulnerability data
culture_gdp_pop_vuln_2020_data <- culture_gdp_pop_2020_data %>%
  left_join(subset(vulnerability_data, select=c(iso_code, x2020)), by = c("iso_code")) %>%
  select(iso_code, x2020, everything())
names(culture_gdp_pop_vuln_2020_data)[names(culture_gdp_pop_vuln_2020_data) == "x2020"] <- "vulnerability_2020"

## Combine culture, gdp, population, vulnerability, and co2 data
culture_gdp_pop_vuln_co2_2020_data <- culture_gdp_pop_vuln_2020_data %>%
  left_join(subset(co2_data[,c(1,3,5)], year==2020), by = c("iso_code")) %>% select(-c(year)) %>%
  select(iso_code, co2_per_capita, everything())
culture_gdp_pop_vuln_co2_2020_data <- na.omit(culture_gdp_pop_vuln_co2_2020_data)

## Combine culture, gdp, population, vulnerability, and wvs data
culture_gdp_pop_vuln_co2_wvs_2020_data <- culture_gdp_pop_vuln_co2_2020_data %>%
  left_join(subset(wvs_regions_data, select=c(iso_code, wvs_region)), by = c("iso_code")) %>% 
  select(iso_code, wvs_region, everything())
