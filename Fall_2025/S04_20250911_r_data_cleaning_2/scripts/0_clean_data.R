# --------------------------
# Load libraries and data
# --------------------------
library(tidyverse)
schools_tibble <- read_csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/gis/wg/Metro_Nashville_Schools.csv") %>% clean_names()

# --------------------------
# If statements, loops, and functions
# --------------------------
## If, else if, else statement
x <- 9
if (x < 10) {
  print("x is less than 10")
} else if (x == 10) {
  print("x is equal to 10")
} else {
  print("x is greater than 10")
}

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
# Pasting strings
# --------------------------
paste("Hello", "world!")
paste("Hello", "world!", sep = "_")
paste0("Hello", "world!")
paste0("20", schools_tibble$school_year)

# --------------------------
# Column names
# --------------------------
names(schools_tibble_capitalized)
colnames(schools_tibble_capitalized)
colnames(schools_tibble_capitalized)[colnames(schools_tibble_capitalized) == "SCHOOL_YEAR"] <- "YEAR"
schools_tibble_capitalized %>% janitor::clean_names()

# --------------------------
# Sub-setting and filtering data 
# --------------------------
# Using column numbers
schools_tibble[1]
schools_tibble[1:2]
# Subset by column name
subset(schools_tibble, select = c(school_name, zip_code))
subset(schools_tibble, select = -c(grade_1:grade_12))
# Subset to change the order of columns
subset(schools_tibble, select = c(school_name, zip_code, school_level, school_year, grade_1:grade_12))
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

# --------------------------
# Piping using dplyr
# --------------------------
## Select columns
schools_tibble %>% select(school_name, zip_code)
schools_tibble %>% select(-grade_1:-grade_12)
## Filter rows
schools_tibble %>% filter(school_level == "Elementary School")
schools_tibble %>% filter(school_level != "Elementary School")
schools_tibble %>% filter(school_year == "18-19" & grade_1 >= 100)
schools_tibble %>% filter(str_detect(school_name, "Nashville"))
## Mutate columns
schools_tibble %>% mutate(grade_1 = grade_1 * 2)
schools_tibble %>% mutate(grade_1 = grade_1 * 2, school_year = school_year %>% str_replace_all("-19", ""))
## Arrange rows
schools_tibble %>% arrange(school_level)
schools_tibble$school_level_clean <- factor(schools_tibble$school_level, levels=c("Elementary School", "Middle School", "High School", 
                                                                                  "Charter", "Adult","Special Education", "Non-Traditional - Hybrid", 
                                                                                  "Non-Traditional", "GATE Center", "Alternative Learning Center"),
                                                                         labels=c("Elementary", "Middle", "High", 
                                                                                  "Charter", "Adult","Special", "Non-Traditional", 
                                                                                  "Non-Traditional", "GATE", "Alternative"))
schools_tibble %>% arrange(school_level_clean) %>% select(last_col(), everything())
## Separating columns
schools_tibble %>% separate(school_year, into = c("year_start", "year_end"), sep = "-")
## Combining columns
schools_tibble %>% separate(school_year, into = c("year_start", "year_end"), sep = "-") %>% 
                   unite(school_year, year_start, year_end, sep = "-")

## Summarize data
schools_tibble %>% summarize(mean_grade_1 = mean(grade_1, na.rm = TRUE), 
                             median_grade_1 = median(grade_1, na.rm = TRUE), 
                             sd_grade_1 = sd(grade_1, na.rm = TRUE))
## Combining functions with group_by
schools_tibble %>% group_by(zip_code) %>% summarize(mean_grade_1 = mean(grade_1, na.rm = TRUE), 
                                                    median_grade_1 = median(grade_1, na.rm = TRUE), 
                                                    sd_grade_1 = sd(grade_1, na.rm = TRUE))
schools_tibble %>% group_by(zip_code, school_level) %>% transform(mean_grade_1 = mean(grade_1, na.rm = TRUE), 
                                                                  median_grade_1 = median(grade_1, na.rm = TRUE), 
                                                                  sd_grade_1 = sd(grade_1, na.rm = TRUE))

