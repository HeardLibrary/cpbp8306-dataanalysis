# Session 7 demo: Dataframes and Tidy Data (R)
#
# Every runnable snippet from the Session 7 slides, in slide order.
#
# Put these files next to this script, then run:  Rscript 07_dataframes_tidy_demo.R
#   patients.csv         course data folder (Fall_2026/data)
#   schools_tibble.csv   Brightspace
# penguins comes from the palmerpenguins package, so it needs no file.
#
# Needs R 4.1 or newer (for the |> pipe) and the packages readr, dplyr and palmerpenguins.

section <- function(title) {
  cat("\n", strrep("=", 70), "\n", title, "\n", strrep("=", 70), "\n", sep = "")
}

# ---------------------------------------------------------------------------
# Slides 1, 2 and 4: load the data, then look at it
# ---------------------------------------------------------------------------
section("Slides 1, 2, 4: load it, then look at it")

# Install once. The check keeps this script safe to re-run.
if (!requireNamespace("palmerpenguins", quietly = TRUE)) install.packages("palmerpenguins")

library(palmerpenguins); library(dplyr); library(readr)

df <- penguins                                       # 344 x 8, adds year
schools <- read_csv("schools_tibble.csv", show_col_types = FALSE)

print(dim(df))        # 344 8   (the Python CSV has 7: R keeps the year column)
glimpse(df)           # transposed head, use this
print(head(df))       # first 6 rows
print(summary(df))    # your first EDA pass

# ---------------------------------------------------------------------------
# Slide 5: column, row, cell
# ---------------------------------------------------------------------------
section("Slide 5: column, row, cell")

print(head(df$bill_length_mm))                       # a column
print(head(filter(df, species == "Adelie")))         # rows matching a condition
print(df[1, "bill_length_mm"])                       # a cell

# The boolean mask you already know from Sessions 3 and 4.
# (Example values, not course data.)
bp <- c(128, 135, 142, 119, 150)
print(bp[bp > 130])                                  # the values above 130
print(sum(bp >= 140))                                # how many are 140 or higher

# Positional access breaks the moment you filter: the first row of a
# filtered table is a different penguin from the first row of df.
females <- filter(df, sex == "female")
print(df[1, "bill_length_mm"])                       # first row of df
print(females[1, "bill_length_mm"])                  # first row after filtering (a different penguin)

# ---------------------------------------------------------------------------
# Slide 6: the reveal. What are the variables in this table?
# ---------------------------------------------------------------------------
section("Slide 6: messy vs. tidy")

messy <- tibble(
  patient_id = "P001",
  bp_2020 = 130,
  bp_2021 = 128,
  bp_2022 = 125
)
tidy <- tibble(
  patient_id = c("P001", "P001", "P001"),
  year = c(2020, 2021, 2022),
  bp = c(130, 128, 125)
)
print(messy)          # the variable "year" is hiding in the column names
print(tidy)           # patient_id, year, bp: one variable per column

# ---------------------------------------------------------------------------
# Slide 8: three ways real tables break the rules (schools_tibble.csv)
# ---------------------------------------------------------------------------
section("Slide 8: schools_tibble.csv")

print(dim(schools))   # 169 35

# The four-school table on the slide comes from the high schools.
# |> is a pipe. It passes the result on its left into the function on its right,
# so read it as "and then": take schools, then keep the high schools, then select
# six columns.
high <- schools |>
  filter(school_level == "High School") |>
  select(school_name, grade_9, grade_10, grade_11, grade_12, mapped_location)
print(head(high))

# 1. Headers that are values: one variable (grade) spread across 15 columns
grades <- select(schools, starts_with("grade_"))
print(ncol(grades))                                  # 15
print(sum(!is.na(grades)))                           # 868 rows if made long, not 169 x 15
print(sum(grades, na.rm = TRUE))                     # 86527 students across all grades
print(sum(schools$male + schools$female))            # 86527, the same total

# 2. Two values in one cell: latitude and longitude as one string
print(head(select(schools, mapped_location, latitude, longitude), 3))

# 3. NA that means "not offered"
print(sum(is.na(schools$grade_pre_k_3yrs)))          # 130 of 169 schools
middle <- filter(schools, school_level == "Middle School")
cat(sum(is.na(middle$grade_9)), "of", nrow(middle), "\n")   # all 31 middle schools have no grade 9

# school_year is a constant, not a violation
print(unique(schools$school_year))                   # "18-19"

# ---------------------------------------------------------------------------
# Slide 9: column types and the traps you have already met
# ---------------------------------------------------------------------------
section("Slide 9: column types")

print(sapply(df, class))                             # check types across every column

patients <- read_csv("patients.csv", show_col_types = FALSE)
print(sapply(patients, class))
print(table(patients$group))                         # "A " (trailing space) is its own group: 40 rows
print(sum(patients$age == "unknown"))                # 6 rows, so age loads as text
cat(round(mean(is.na(patients$cholesterol)) * 100, 1), "% of cholesterol is missing\n")   # 8.8

# One category, two labels in the schools file
print(table(schools$school_level))                   # Non-Traditional (5), Non-Traditional - Hybrid (2)

# factor(x, levels, labels) can map several raw labels to one level
raw_levels <- sort(unique(schools$school_level))
new_labels <- ifelse(raw_levels == "Non-Traditional - Hybrid", "Non-Traditional", raw_levels)
merged <- factor(schools$school_level, levels = raw_levels, labels = new_labels)
cat(n_distinct(schools$school_level), "->", nlevels(merged), "\n")   # 10 -> 9

# dplyr version of the same merge
merged2 <- recode(schools$school_level, "Non-Traditional - Hybrid" = "Non-Traditional")
print(n_distinct(merged2))                           # 9
