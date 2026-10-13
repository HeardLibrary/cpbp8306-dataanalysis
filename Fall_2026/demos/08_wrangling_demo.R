# Session 8 demo: Data Wrangling, Cleaning, Joining, Reshaping (R)
#
# Every code snippet from the Session 8 slides, in slide order. Each block says what
# the code does and what you should see, so you can check your own output against
# the comments.
#
# It uses the same three datasets as Session 7: penguins, patients and schools.
# Nothing is made up.
#
# Put these two files next to this script, then run:  Rscript 08_wrangling_demo.R
#   patients.csv         Brightspace
#   schools_tibble.csv   Brightspace
# penguins comes from the palmerpenguins package, so it needs no file.
#
# Needs the packages dplyr, tidyr, stringr, readr and palmerpenguins. The base R
# pipe |> shown on Slide 5 also needs R 4.1 or newer.

section <- function(title) {
  cat("\n", strrep("=", 70), "\n", title, "\n", strrep("=", 70), "\n", sep = "")
}

# ---------------------------------------------------------------------------
# Slide 2: load the data
# ---------------------------------------------------------------------------
section("Slide 2: load the data")

# Install once. The check keeps this script safe to run again.
if (!requireNamespace("palmerpenguins", quietly = TRUE)) install.packages("palmerpenguins")

library(dplyr)           # filter, select, mutate, arrange, group_by, summarise, joins
library(tidyr)           # pivot_longer, pivot_wider
library(stringr)         # str_trim, str_to_upper
library(palmerpenguins)  # the penguins data
library(readr)           # read_csv

# read_csv() removes spaces at the start and end of text values unless you set
# trim_ws = FALSE. We keep them here, so the "A " problem in Slide 7 is still
# there to find. (pandas keeps the spaces by default.)
patients <- read_csv("patients.csv", trim_ws = FALSE, show_col_types = FALSE)
schools <- read_csv("schools_tibble.csv", show_col_types = FALSE)

print(dim(penguins))     # 344 8   (includes year)
print(dim(patients))     # 250 9
print(dim(schools))      # 169 35


# ---------------------------------------------------------------------------
# Slide 4: six functions, one way each changes a table
# ---------------------------------------------------------------------------
# These are the six dplyr functions, which dplyr calls verbs. Each line prints
# the size of the result, so you can see what changed: rows, columns, or both.
section("Slide 4: six functions")

# filter: keep the rows that match a condition.
# The rows go down and the columns stay the same.
print(dim(penguins %>% filter(species == "Gentoo")))            # 124 8

# select: keep or drop columns. The columns go down and the rows stay the same.
print(dim(penguins %>% select(species, body_mass_g)))           # 344 2

# mutate: create or change a column. It adds one column and keeps every row.
print(dim(penguins %>% mutate(kg = body_mass_g / 1000)))        # 344 9

# arrange: sort the rows. The size does not change, only the order.
# arrange() goes from smallest to largest. desc() flips it.
print(head(penguins %>% arrange(body_mass_g), 3))               # the lightest penguins first
print(head(penguins %>% arrange(desc(body_mass_g)), 3))         # the heaviest penguins first

# group_by: mark rows as belonging to groups. On its own it changes nothing you
# can see. It waits for the next step.
by_species <- penguins %>% group_by(species)

# summarise: collapse each group to one row. n() counts the rows in the group.
print(by_species %>% summarise(n = n()))                        # Adelie 152, Chinstrap 68, Gentoo 124


# ---------------------------------------------------------------------------
# Slide 5: R has two pipes
# ---------------------------------------------------------------------------
section("Slide 5: two pipes")

# A pipe passes the result of one step into the next. Read it as "and then".
# R has two of them, and the lines below do exactly the same thing.
#   |>   the base R pipe. Built into R 4.1 and later. Nothing to load.
#   %>%  the dplyr pipe, from the magrittr package. Loading dplyr gives it to you,
#        and it works in any version of R.
with_base_pipe  <- penguins |> filter(species == "Adelie") |> head(3)
with_dplyr_pipe <- penguins %>% filter(species == "Adelie") %>% head(3)
print(identical(with_base_pipe, with_dplyr_pipe))   # TRUE: same rows, same columns

# Difference 1: parentheses. |> needs a function call on its right-hand side.
print(penguins %>% head %>% dim())                  # 6 8: %>% accepts a bare function name
result_without_parens <- tryCatch(
  eval(parse(text = "penguins |> head")),
  error = function(e) conditionMessage(e))
print(result_without_parens)                        # "The pipe operator requires a function call as RHS ..."
print(dim(penguins |> head()))                      # 6 8: with parentheses, |> works

# Difference 2: the placeholder. When the piped value should land somewhere other
# than the first argument, |> uses _ (in a named argument) and %>% uses a dot.
print(penguins %>% lm(body_mass_g ~ flipper_length_mm, data = .) %>% coef() %>% round(1))
print(penguins |> lm(body_mass_g ~ flipper_length_mm, data = _) |> coef() |> round(1))
# Both give the same intercept (-5780.8) and slope (49.7).

# From here on, every pipe in this script is %>%, the same one the slides use.


# ---------------------------------------------------------------------------
# Slide 6: chain the functions and check the size after each step
# ---------------------------------------------------------------------------
section("Slide 6: a pipeline, one step at a time")

# The pipe %>% passes the result of one step into the next. Read it as "and then".
result <- penguins %>%
  filter(species == "Adelie") %>%                 # keep Adelie penguins
  mutate(kg = body_mass_g / 1000) %>%             # add body mass in kilograms
  group_by(island) %>%                            # one group per island
  summarise(mean_kg = mean(kg, na.rm = TRUE))    # one row per island
print(result)
# Biscoe 3.71, Dream 3.69, Torgersen 3.71.
# na.rm = TRUE tells mean() to skip missing values. One Adelie penguin has no body
# mass, so without it the island with that penguin would come back as NA.

# The same chain, run one step at a time, with the size printed after each step.
step1 <- penguins %>% filter(species == "Adelie")
step2 <- step1 %>% mutate(kg = body_mass_g / 1000)
step3 <- step2 %>% group_by(island) %>% summarise(mean_kg = mean(kg, na.rm = TRUE))
cat(nrow(penguins), "->", nrow(step1), "->", nrow(step2), "->", nrow(step3), "\n")   # 344 -> 152 -> 152 -> 3
# mutate kept every row (152 in, 152 out). summarise collapsed each group to one
# row (152 in, 3 out). Printing the size after each step is how you catch the two
# getting mixed up.

# Verb order matters. Each step only sees what the step before it kept.
# Here select() drops body_mass_g, so filter() has nothing to test.
bad_order <- tryCatch(
  penguins %>% select(species, island) %>% filter(body_mass_g > 4000),
  error = function(e) "error: object 'body_mass_g' not found"
)
print(bad_order)


# ---------------------------------------------------------------------------
# Slide 7: the payoff. Fix group and sex in patients.csv.
# ---------------------------------------------------------------------------
section("Slide 7: clean group and sex")

# Count first, before you change anything. Finding the problem is the real work.
print(table(patients$group))   # "A " 40, A 85, B 125: three groups, not two
print(table(patients$sex))     # F 112, M 119, f 9, m 10: four groups, not two

# The fix is one mutate() call.
# str_trim() removes spaces at the start and end of each value, so "A " becomes "A".
# str_to_upper() makes every letter uppercase, so "m" becomes "M".
patients <- patients %>% mutate(
  group = str_trim(group),
  sex = str_to_upper(sex))

# Count again to check the fix worked.
print(table(patients$group))   # A 125, B 125: the 40 rows rejoined group A
print(table(patients$sex))     # F 121, M 129


# ---------------------------------------------------------------------------
# Slide 8: decide what each missing value means
# ---------------------------------------------------------------------------
section("Slide 8: missing values")

# 1. "unknown" becomes NA. age loads as text because six rows say "unknown".
print(class(patients$age))                 # "character"
# as.numeric() turns text into numbers. Anything that is not a number becomes NA,
# R's marker for a missing value. R prints a warning when this happens. The
# warning is expected here. It is the six "unknown" rows.
patients$age <- as.numeric(patients$age)
print(class(patients$age))                 # "numeric"
print(sum(is.na(patients$age)))            # 6: the "unknown" rows are now missing values

# 2. Not offered. A middle school has no grade 9, so the cell is empty by design.
middle <- filter(schools, school_level == "Middle School")
cat(sum(is.na(middle$grade_9)), "of", nrow(middle), "\n")   # 31 of 31
# Filling these with 0 would say "zero students in grade 9". The truth is that
# the grade does not exist there, so leave them missing.

# 3. Not measured. Two penguins have no bill length and eleven have no sex.
cat(sum(is.na(penguins$bill_length_mm)), sum(is.na(penguins$sex)), "\n")   # 2 11

# R refuses to guess. One missing value makes the whole mean NA.
print(mean(penguins$bill_length_mm))                # NA
print(mean(penguins$bill_length_mm, na.rm = TRUE))  # 43.92, na.rm = TRUE skips the missing rows
# pandas does the opposite: .mean() skips missing values unless you pass
# skipna=False. In either language, skipping rows is a decision about your data.
# Ask whether the values are missing at random before you make it.


# ---------------------------------------------------------------------------
# Slide 9: two tables, one shared key
# ---------------------------------------------------------------------------
section("Slide 9: joins")

# Two small tables built from the penguins data. The slide calls them L and R.
# They share one key column, species, but only Adelie appears in both.
species_means <- penguins %>%
  group_by(species) %>%
  summarise(mean_mass = round(mean(body_mass_g, na.rm = TRUE)),
            mean_bill = round(mean(bill_length_mm, na.rm = TRUE), 1))
L <- species_means %>% filter(species %in% c("Adelie", "Gentoo")) %>% select(species, mean_mass)
R <- species_means %>% filter(species %in% c("Adelie", "Chinstrap")) %>% select(species, mean_bill)
print(L)    # Adelie 3701, Gentoo 5076
print(R)    # Adelie 38.8, Chinstrap 48.8

# left join: every row of L. NA where R has no match.
print(left_join(L, R, by = "species"))     # Adelie, Gentoo (bill is NA for Gentoo)

# inner join: only the rows that match in both tables.
print(inner_join(L, R, by = "species"))    # Adelie only

# full join: every row from both tables.
print(full_join(L, R, by = "species"))     # Adelie, Gentoo, Chinstrap
# dplyr has no default join. You choose left_join, inner_join or full_join by
# name. pandas merge() uses an inner join when you leave how out.

# The sanity check: after every join, look at the row count.
island_means <- penguins %>%
  group_by(island) %>%
  summarise(mean_mass = round(mean(body_mass_g, na.rm = TRUE)))          # 3 rows
species_by_island <- penguins %>% count(species, island, name = "n")      # 5 rows
joined <- left_join(island_means, species_by_island, by = "island")
cat(nrow(island_means), "->", nrow(joined), "\n")    # 3 -> 5
print(joined)
# Biscoe and Dream each appear twice in species_by_island, so they appear twice
# in the result. More rows than the left table means the key repeats on the right.


# ---------------------------------------------------------------------------
# Slide 10: wide to long, the grade columns from Session 7
# ---------------------------------------------------------------------------
section("Slide 10: wide to long")

# The four high schools shown on the slide, in wide form.
four <- c("Antioch High School", "Cane Ridge High School", "Glencliff High School", "Hillsboro High")
wide4 <- schools %>%
  filter(school_name %in% four) %>%
  select(school_name, grade_9, grade_10, grade_11, grade_12)
print(wide4)

# pivot_longer() makes the table long. cols says which columns to unpivot,
# names_to is the new column that holds the old column names, and values_to
# holds the numbers.
long4 <- wide4 %>% pivot_longer(
  cols = grade_9:grade_12,
  names_to = "grade", values_to = "students")
print(long4)                  # 16 rows: 4 schools x 4 grades

# The same call on the whole file. starts_with("grade_") picks every column whose
# name begins with grade_, which is all 15 of them. values_drop_na = TRUE drops
# the grades a school does not offer, which are the not-offered NA values.
schools_long <- schools %>% pivot_longer(
  cols = starts_with("grade_"),
  names_to = "grade", values_to = "students",
  values_drop_na = TRUE)
print(nrow(schools_long))              # 868 rows, not 169 x 15
print(sum(schools_long$students))      # 86527 students, the same total as male + female


# ---------------------------------------------------------------------------
# Slide 11: long to wide, a table a person can read
# ---------------------------------------------------------------------------
section("Slide 11: long to wide")

# count() counts the penguins in each species and island combination.
# The result is long: one row per combination.
counts <- penguins %>% count(species, island)
print(counts)

# pivot_wider() moves the island values into columns. names_from says which
# column supplies the new column names, and values_from says which column
# supplies the numbers. values_fill = 0 fills the combinations that never occur,
# such as Gentoo on Dream.
print(counts %>% pivot_wider(names_from = island, values_from = n, values_fill = 0))
# Adelie 44, 56, 52 / Chinstrap 0, 68, 0 / Gentoo 124, 0, 0 (Biscoe, Dream, Torgersen)


# ---------------------------------------------------------------------------
# Try it yourself
# ---------------------------------------------------------------------------
# 1. Change left_join() to right_join() in the island join. Predict the row count first.
# 2. Remove values_drop_na = TRUE from the schools reshape. How many rows do you get now?
# 3. Add round(2) to the island averages in the pipeline. What changes?
# 4. Run the group_by on slide 4 with island instead of species.
