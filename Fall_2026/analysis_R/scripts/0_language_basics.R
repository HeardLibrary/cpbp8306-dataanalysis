# =============================================================================
# 0_language_basics.R  |  Lectures 1 to 6, plus the 2025 R basics (S02)
# =============================================================================
# This script collects the commands from the first six lectures and tries them on
# real data. It does not clean anything and does not save anything. It works on
# copies, so you can run it, change it, and break it without harming the data.
#
# Contents
#   Lecture 1   Look at the data before you test it
#   Lecture 2   Types: what kind of value is this?
#   Lecture 3   Collections: vectors, lists, indexing, boolean masks
#   Lecture 4   Control flow: if, for, while
#   Lecture 5   Functions
#   Lecture 6   Projects, paths and reading files
#
# Run it from main.R, or open it and run one section at a time. Before you run
# a line, say out loud what you expect it to print. Then run it and compare.
#
# Needs these objects from main.R: patients_raw, penguins_raw, schools_raw
# =============================================================================

if (!exists("patients_raw")) {
  stop("Run main.R first. It loads the data this script uses.")
}

# A small helper that prints a heading, so the output is easy to read.
section <- function(title) {
  cat("\n", strrep("=", 70), "\n", title, "\n", strrep("=", 70), "\n", sep = "")
}

# Working copies. Everything below changes these, never the _raw objects.
patients_demo <- patients_raw
penguins_demo <- penguins_raw
schools_demo  <- schools_raw


# =============================================================================
# LECTURE 1: Look at the data before you test it
# =============================================================================
section("Lecture 1: look at the data before you test it")

# The scenario from Session 1: compare systolic blood pressure between group A
# and group B. An AI would write this without looking at the group column.
a_values <- patients_demo$systolic[patients_demo$group == "A"]
b_values <- patients_demo$systolic[patients_demo$group == "B"]

# t.test() compares two means. Session 11 explains it. Here it only shows how
# one bad value changes the answer. var.equal = TRUE makes it the classic
# two-sample test. t.test ignores missing values on its own.
naive_test <- t.test(a_values, b_values, var.equal = TRUE)
cat("Group A mean:", round(mean(a_values, na.rm = TRUE), 1),
    " (n =", sum(!is.na(a_values)), ")\n")
cat("Group B mean:", round(mean(b_values, na.rm = TRUE), 1),
    " (n =", sum(!is.na(b_values)), ")\n")
cat("p =", round(naive_test$p.value, 4), " -> no significant difference?\n")

# Nobody looked at the group column. Count what is in it:
print(table(patients_demo$group))       # three values, not two: "A", "A " and "B"
print(unique(patients_demo$group))      # the quotes make the trailing space visible

# 40 rows say "A " (with a space). They were silently left out of group A.
# str_trim() removes spaces from both ends of a text value.
patients_demo$group <- str_trim(patients_demo$group)
print(table(patients_demo$group))       # now two groups: A 125 and B 125

# Same test, on the corrected data:
a_fixed <- patients_demo$systolic[patients_demo$group == "A"]
b_fixed <- patients_demo$systolic[patients_demo$group == "B"]
fixed_test <- t.test(a_fixed, b_fixed, var.equal = TRUE)
cat("Corrected group A mean:", round(mean(a_fixed, na.rm = TRUE), 1),
    " (n =", sum(!is.na(a_fixed)), ")\n")
cat("p =", round(fixed_test$p.value, 4), " -> a real difference\n")
# One line of cleaning changed the conclusion. The code ran without an error
# both times. That is why you look before you test.


# =============================================================================
# LECTURE 2: Types: what kind of value is this?
# =============================================================================
section("Lecture 2: types")

# Assignment stores a value under a name. The right side is worked out first.
patient_count <- 42
patient_count <- patient_count + 1
print(patient_count)                    # 43

# class() tells you the type of a value. Check it whenever a result surprises you.
class(42L)          # "integer"    a whole number (the L marks it as an integer)
class(117.3)        # "numeric"    a decimal number
class("P042")       # "character"  text
class(TRUE)         # "logical"    TRUE or FALSE

# The three-second habit: check the type of EVERY column right after you load a file.
print(sapply(patients_demo, class))     # age is "character", not a number
glimpse(patients_demo)                  # one line per column: its type and the first values
# str(patients_demo) shows similar information in a longer format.

# Why is age text? Look at the values that are not numbers.
print(unique(patients_demo$age[is.na(suppressWarnings(as.numeric(patients_demo$age)))]))

# Logical values are secretly numbers: TRUE counts as 1 and FALSE as 0.
print(sum(patients_demo$passed_qc))     # how many patients passed QC
print(mean(patients_demo$passed_qc))    # the proportion that passed

# String traps
print(paste0("5", "3"))                 # "53": gluing two pieces of text, not adding
add_text_to_number <- tryCatch("5" + 3, error = function(e) conditionMessage(e))
print(add_text_to_number)               # R refuses: non-numeric argument to a binary operator
print(5 == "5")                         # TRUE, with no warning. R turned 5 into "5" first.
print(identical(5, "5"))                # FALSE: identical() does not convert anything

# Decimal numbers are stored approximately.
print(0.1 + 0.2 == 0.3)                 # FALSE
print(isTRUE(all.equal(0.1 + 0.2, 0.3)))# TRUE: all.equal() allows a tiny difference

# --- Changing a column's type (S02, "Changing numeric, character and factor") ---
# zip_code is an identifier, not a quantity. You would never add two zip codes.
print(class(schools_demo$zip_code))                      # "numeric"
schools_demo$zip_code <- as.character(schools_demo$zip_code)
print(class(schools_demo$zip_code))                      # "character"

# A factor is a text column with a fixed set of allowed values, called levels.
schools_demo$zip_code <- as.factor(schools_demo$zip_code)
print(class(schools_demo$zip_code))                      # "factor"
print(head(levels(schools_demo$zip_code), 5))

# The factor trap: as.numeric() on a factor returns the level NUMBER, not the label.
print(head(as.numeric(schools_demo$zip_code)))                   # 1, 2, 3 ... wrong
print(head(as.numeric(as.character(schools_demo$zip_code))))     # the real zip codes

# --- Common errors and their fixes (S02) ---
# 1. Missing values (NA) make a mean NA.
print(mean(schools_demo$grade_1))                        # NA
print(mean(schools_demo$grade_1, na.rm = TRUE))          # ignore the NA values
print(mean(na.omit(schools_demo$grade_1)))               # drop them first, same answer
# 2. The wrong type. school_year is text like "18-19", so a mean makes no sense.
print(suppressWarnings(mean(schools_demo$school_year)))  # NA, and R warns about it
print(class(schools_demo$school_year))                   # "character"


# =============================================================================
# LECTURE 3: Collections: vectors, lists, indexing, boolean masks
# =============================================================================
section("Lecture 3: collections")

# A vector is an ordered set of values of ONE type. c() means "combine".
bp <- c(117, 122, 141, 130, 118)        # five systolic readings from the lecture
print(length(bp))                       # 5
print(class(bp))                        # "numeric"

# Mixing types: R changes everything to the most flexible type, and says nothing.
mixed <- c(1, 2, "three")
print(class(mixed))                     # "character": the numbers became text
# This is what happens when one row of the age column says "unknown".

# Sequences
print(3:9)                              # 3 4 5 6 7 8 9
print(10:0)                             # counts down
print(seq(0, 100, by = 25))             # 0 25 50 75 100

# Indexing. R counts from 1, and square brackets pick elements.
print(bp[1])                            # the first element
print(bp[2:4])                          # elements 2, 3 and 4 (the end is INCLUDED)
print(bp[c(1, 3, 5)])                   # pick specific elements
print(bp[-1])                           # everything EXCEPT the first (in Python, -1 is the last)
print(bp[10])                           # NA: past the end is not an error
print(bp[0])                            # numeric(0): an empty result, not an error
bp[2] <- 120                            # change one element
print(bp)
bp[2] <- 122                            # put it back

# Boolean masks: the most important idea in the course.
print(bp > 130)                         # step 1: TRUE or FALSE for every element
print(bp[bp > 130])                     # step 2: keep the elements where it is TRUE
print(sum(bp > 130))                    # step 3: count them (TRUE counts as 1)
print(mean(bp > 130))                   # or take the fraction
# filter() in dplyr and df[df.age > 65] in pandas are this same idea.

# The same mask on a real column. systolic has missing values, so remove them first.
systolic <- patients_demo$systolic
print(sum(is.na(systolic)))                       # 9 missing
print(sum(systolic > 130, na.rm = TRUE))          # how many readings are above 130
print(head(systolic[!is.na(systolic) & systolic > 130]))   # & means "and"

# Lists hold values of different types. Name the items and look them up by name.
patient <- list(id = "P042", age = 61, systolic = 141, treated = TRUE)
print(patient$age)                      # lookup by name
print(patient[["id"]])                  # the same, with double brackets
patient$age <- 62                       # change a value
print(names(patient))

# A list can hold a whole vector (S02).
species_info <- list(name = "Adelie", n = 152, islands = c("Biscoe", "Dream", "Torgersen"))
print(species_info[[3]])                # the third item, the whole vector
print(species_info$islands[2])          # one element inside it: "Dream"

# --- A data frame is a list of equal-length vectors (S02) ---
species     <- c("Adelie", "Chinstrap", "Gentoo")
n_penguins  <- c(152, 68, 124)
mean_mass_g <- c(3701, 3733, 5076)
species_table <- data.frame(species, n_penguins, mean_mass_g)
print(species_table)

print(species_table$species)            # a column, by name
print(species_table[2, 1])              # a cell: row 2, column 1
print(species_table$mean_mass_g[3])     # a cell: column by name, then position

# Arithmetic works on whole vectors at once.
species_table$total_mass_kg <- species_table$n_penguins * species_table$mean_mass_g / 1000
print(species_table)

# Vector recycling (S02): the shorter vector is reused. R warns when the lengths
# do not divide evenly.
short <- c(1, 2)
long  <- c(10, 15, 17, 5, 1)
recycled <- tryCatch(short + long, warning = function(w) conditionMessage(w))
print(recycled)                         # longer object length is not a multiple of shorter


# =============================================================================
# LECTURE 4: Control flow: if, for, while
# =============================================================================
section("Lecture 4: control flow")

# if / else if / else chooses ONE path. Only the first TRUE condition runs.
bp_value <- 130
if (bp_value >= 140) {
  category <- "high"
} else if (bp_value >= 120) {
  category <- "elevated"
} else {
  category <- "normal"
}
print(category)                         # "elevated"

# A common bug: three separate if statements instead of else if. Each one runs.
for (reading in c(145, 130, 110)) {
  wrong <- NA
  if (reading >= 140) wrong <- "high"
  if (reading >= 120) wrong <- "elevated"    # runs AGAIN for 145 and overwrites "high"
  if (reading < 120)  wrong <- "normal"
  cat("bp =", reading, "-> three ifs says:", wrong, "\n")
}
# 145 comes out "elevated". No error, just a wrong answer.

# A for loop repeats a block once for each item. This one labels the first ten
# patients. is.na() handles the missing readings.
first_ten <- patients_demo$systolic[1:10]
labels <- character(length(first_ten))        # an empty result to fill in
for (i in seq_along(first_ten)) {
  if (is.na(first_ten[i])) {
    labels[i] <- "missing"
  } else if (first_ten[i] >= 140) {
    labels[i] <- "high"
  } else if (first_ten[i] >= 120) {
    labels[i] <- "elevated"
  } else {
    labels[i] <- "normal"
  }
}
print(data.frame(systolic = first_ten, label = labels))

# The accumulator pattern: set up BEFORE the loop, update INSIDE, use AFTER.
count_high <- 0
for (reading in na.omit(patients_demo$systolic)) {
  if (reading >= 140) count_high <- count_high + 1
}
print(count_high)

# The same job with no loop (vectorized). This is shorter and much faster.
print(sum(patients_demo$systolic >= 140, na.rm = TRUE))      # same number

# Vectorized if/else: ifelse() decides for a whole column at once.
bp_label <- ifelse(patients_demo$systolic >= 140, "high", "not high")
print(table(bp_label, useNA = "ifany"))

# Loop over the columns of a data frame (S04) and report each one's type.
for (col_name in names(patients_demo)) {
  cat(col_name, ":", class(patients_demo[[col_name]]), "\n")
}

# A while loop repeats as long as a condition is TRUE. You must change something
# inside the loop that eventually makes the condition FALSE.
i <- 1
while (i <= 5) {
  cat("schools column", i, "is called", names(schools_demo)[i], "\n")
  i <- i + 1                            # without this line the loop never ends
}


# =============================================================================
# LECTURE 5: Functions
# =============================================================================
section("Lecture 5: functions")

# A function packages a piece of code so you can reuse it. The pieces:
#   name <- function(inputs) { steps; the last value is returned }
# threshold = 140 gives the input a default, so you can leave it out.
#
# count_high_bp: how many readings meet or exceed a cutoff.
#   bps        a vector of systolic readings, in mmHg
#   threshold  the cutoff. At or above it counts as high.
#   na.rm is TRUE, so missing readings are skipped.
count_high_bp <- function(bps, threshold = 140) {
  sum(bps >= threshold, na.rm = TRUE)
}

print(count_high_bp(patients_demo$systolic))                  # uses the default of 140
print(count_high_bp(patients_demo$systolic, threshold = 130)) # a different cutoff
# Change the threshold in ONE place and every call follows it.

# categorize_bp: turn one reading into a label.
categorize_bp <- function(bp) {
  if (is.na(bp)) return("missing")
  if (bp >= 140) return("high")
  if (bp >= 120) return("elevated")
  "normal"
}
print(categorize_bp(145))               # "high"

# sapply() runs a function on every element and collects the results.
patients_demo$bp_category <- sapply(patients_demo$systolic, categorize_bp)
print(table(patients_demo$bp_category))

# check_threshold (from the 2025 practice assignment): say whether all values in
# a column are below, above, or mixed relative to a threshold.
check_threshold <- function(data, column, threshold) {
  values <- na.omit(data[[column]])
  if (all(values < threshold)) {
    "Below threshold"
  } else if (all(values > threshold)) {
    "Above threshold"
  } else {
    "Mixed values"
  }
}
print(check_threshold(patients_demo, "systolic", 140))        # "Mixed values"

# capitalize_colnames (from S04): a function that takes a data frame and returns
# it with upper-case column names.
capitalize_colnames <- function(data) {
  colnames(data) <- toupper(colnames(data))
  data
}
print(names(capitalize_colnames(patients_demo))[1:4])

# clean_names: turn messy column headings into tidy ones. This is the same job
# as janitor::clean_names(), written by hand so you can see what it does.
#   1. make everything lower case   2. turn spaces and symbols into underscores
#   3. trim underscores from the ends
clean_names <- function(data) {
  new_names <- tolower(names(data))
  new_names <- str_replace_all(new_names, "[^a-z0-9]+", "_")
  new_names <- str_replace_all(new_names, "^_|_$", "")
  names(data) <- new_names
  data
}
messy <- data.frame("Bill Length (mm)" = c(39.1, 39.5), "Body Mass (g)" = c(3750, 3800),
                    check.names = FALSE)
print(names(messy))                     # "Bill Length (mm)" "Body Mass (g)"
print(names(clean_names(messy)))        # "bill_length_mm" "body_mass_g"


# =============================================================================
# LECTURE 6: Projects, paths and reading files
# =============================================================================
section("Lecture 6: projects, paths and reading files")

# A project keeps everything for one analysis in one folder, with the same
# layout every time (see README.md). Paths are RELATIVE to that folder, so the
# project works on any computer and in any location.
print(getwd())                          # where R is looking right now
print(list.files("data/raw"))           # the files in a folder
print(file.exists("data/raw/patients.csv"))   # TRUE if the path is right

# A relative path:  "data/raw/patients.csv"
# An absolute path: "/Users/yourname/Desktop/project/data/raw/patients.csv"
# The absolute path breaks on every computer except yours.
# setwd("path/to/folder") changes the working directory. Avoid it inside scripts.
# Set the working directory once, in RStudio, and use relative paths.

# --- read.csv() and read_csv() (S02) ---
# read.csv() is base R and returns a data frame. read_csv() is from readr and
# returns a tibble. A tibble prints more safely and does not change your text
# columns to factors or your column names.
schools_base  <- read.csv("data/raw/schools_tibble.csv")
schools_tibble <- read_csv("data/raw/schools_tibble.csv", show_col_types = FALSE)
print(class(schools_base))              # "data.frame"
print(class(schools_tibble))            # "tbl_df" "tbl" "data.frame"
print(head(schools_base[, 1:4], 3))
print(head(schools_tibble[, 1:4], 3))   # a tibble also prints each column's type

# Parsing problems. If you let read_csv() guess the type of visit_date, it
# decides the column is a date and then cannot read 2026-02-30. It turns that
# value into NA and warns you. problems() lists what went wrong.
patients_guess <- suppressWarnings(read_csv("data/raw/patients.csv", show_col_types = FALSE))
print(class(patients_guess$visit_date))          # "Date"
print(sum(is.na(patients_guess$visit_date)))     # 1: the impossible date vanished
print(problems(patients_guess)[, c("row", "col", "expected", "actual")])

# Whitespace. read_csv() trims spaces from the start and end of every text value
# by default. That hides the trailing-space bug from Lecture 1. Base read.csv()
# keeps the spaces, and so does read_csv(trim_ws = FALSE), which is what main.R uses.
patients_trimmed <- suppressWarnings(read_csv("data/raw/patients.csv", show_col_types = FALSE))
print(table(patients_trimmed$group))                      # A 125, B 125: the space is gone
print(table(read.csv("data/raw/patients.csv")$group))     # A 85, "A " 40, B 125

# Other ways to read data (commented out, because they need a file or a network).
# From a web address:
#   read_csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/gis/wg/Metro_Nashville_Schools.csv")
# From a file you pick with a dialog box:    read_csv(file.choose())
# A tab-separated file:                      read_tsv("file.tsv")
# An Excel file (needs library(openxlsx)):   read.xlsx("file.xlsx", sheet = "name")

# Writing a file. write_csv(table, "path/file.csv") creates or replaces the file.
# 1_data_cleaning.R does this at the end, and writes into data/clean/, never
# into data/raw/.
#   write_csv(my_table, "data/clean/my_table.csv")

# Version control. Git is a terminal tool, so it is not part of this script.
# See the "Version control" section of README.md for the commands.

cat("\nDone: 0_language_basics.R\n")
