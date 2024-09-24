# --------------------------
# Loops and functions
# --------------------------
## For loop
for (i in colnames(schools_tibble)) {
  print(i)
}
## While loop
i <- 0
while (i < length(colnames(schools_tibble))) {
  print(colnames(schools_tibble[i]))
  i <- i + 1
}
## Function
capitalize_colnames <- function(data) {
  colnames(data) %>% toupper()
}
schools_tibble_capitalized <- schools_tibble
colnames(schools_tibble_capitalized) <- capitalize_colnames(schools_tibble)

# --------------------------
# Column names
# --------------------------
names(schools_tibble_capitalized)
colnames(schools_tibble_capitalized)
colnames(schools_tibble_capitalized)[colnames(schools_tibble_capitalized) == "SCHOOL_YEAR"] <- "YEAR"
schools_tibble_capitalized %>% janitor::clean_names()

# --------------------------
# Subsetting and filtering data 
# --------------------------
# Using column numbers
schools_tibble[1]
schools_tibble[1:2]
# Subset by column name
subset(schools_tibble, select = c(school_name, zip_code))
subset(schools_tibble, select = -c(grade_1:grade_12))
# Filter using subset function
subset(schools_tibble, school_level == "Elementary School")
subset(schools_tibble, school_level != "Elementary School")
subset(schools_tibble, school_year == "18-19" & grade_1 >= 100)
subset(schools_tibble, zip_code == 37013 | zip_code == 37211)
subset(schools_tibble, zip_code %in% c(37013, 37211))
subset(schools_tibble, grepl("nashville", school_name))
subset(schools_tibble, grepl("Nashville", school_name, ignore.case = TRUE) & grade_1 >= 50)
subset(schools_tibble, is.na(grade_pre_k_3yrs))
subset(schools_tibble, !is.na(grade_pre_k_3yrs))

# Using dplyr to select by column name
schools_tibble %>% select(school_name, zip_code)
schools_tibble %>% select(-grade_1:-grade_12)
# 


