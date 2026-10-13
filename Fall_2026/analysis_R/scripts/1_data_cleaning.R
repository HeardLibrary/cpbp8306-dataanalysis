# =============================================================================
# 1_data_cleaning.R  |  Sessions 7 and 8, plus S02, S04 and S06 from 2025
# =============================================================================
# This script shows how real data is loaded, inspected, subset, renamed, changed,
# combined, reshaped, cleaned and saved. Parts 1 to 8 are labeled examples. Each
# one starts from a fresh copy of the raw data, so you can run any part on its
# own. Part 9 is the actual cleaning pipeline. It writes cleaned files to
# data/clean/ and leaves data/raw/ untouched.
#
# Contents
#   Part 1  Inspect the data                       (Session 7)
#   Part 2  Subset: pick columns, rows and cells   (Session 7, S02, S04)
#   Part 3  Change column headings                 (S02, S04, S06)
#   Part 4  Change values                          (Session 8, S04)
#   Part 5  The six functions and the pipe         (Session 8, S04)
#   Part 6  Missing values                         (Session 8, S02, S06)
#   Part 7  Combine tables: bind and join          (Session 8, S06)
#   Part 8  Reshape: long and wide                 (Session 8, S06)
#   Part 9  The cleaning pipeline and saving       (all of the above)
#
# The rule for the whole script: raw data is read-only. Examples change copies.
# The pipeline in Part 9 writes new files and never overwrites the originals.
#
# A note on the pipe: from Part 4 on, some code uses %>%. It passes the result on
# its left into the function on its right, so read it as "and then". Part 5
# explains it, and the second pipe R has, |>.
#
# Needs these objects from main.R: patients_raw, penguins_raw, schools_raw
# =============================================================================

if (!exists("patients_raw")) {
  stop("Run main.R first. It loads the data this script uses.")
}

# Helpers -------------------------------------------------------------------
# A heading for the printed output.
section <- function(title) {
  cat("\n", strrep("=", 70), "\n", title, "\n", strrep("=", 70), "\n", sep = "")
}
# Print a one-line summary of a table's size, so you can see what a step did.
show <- function(x, label) {
  cat(sprintf("%-58s %4d rows x %2d columns\n", label, nrow(x), ncol(x)))
}
# Turn messy column headings into tidy ones: lower case, underscores, no symbols.
# This is the same job as janitor::clean_names(), written by hand (Lecture 5).
clean_names <- function(data) {
  new_names <- tolower(names(data))
  new_names <- str_replace_all(new_names, "[^a-z0-9]+", "_")
  new_names <- str_replace_all(new_names, "^_|_$", "")
  names(data) <- new_names
  data
}


# =============================================================================
# PART 1: Inspect the data  (Session 7)
# =============================================================================
section("Part 1: inspect the data")

# Before you change anything, look. These commands answer: how big is it, what
# are the columns called, what type is each one, and what do the first rows look like?

# dim() gives rows then columns. nrow() and ncol() give each one separately.
print(dim(penguins_raw))                # 344 9: the 9th column is the row number
print(dim(patients_raw))                # 250 9
print(dim(schools_raw))                 # 169 35

# names() lists the column headings.
print(names(penguins_raw))              # the first heading is ...1, an unnamed row number
print(names(patients_raw))

# glimpse() shows one line per column: its type and the first few values.
# This is where you spot the age column that loaded as text.
glimpse(penguins_raw)
glimpse(patients_raw)

# head() and tail() show the first and last rows (6 by default).
print(head(penguins_raw, 3))
print(tail(penguins_raw, 3))

# summary() gives min, quartiles, mean and the NA count for numeric columns.
print(summary(penguins_raw[, c("bill_length_mm", "body_mass_g")]))

# sapply(data, class) gives the type of every column in one line.
print(sapply(schools_raw[, 1:8], class))


# =============================================================================
# PART 2: Subset: pick columns, rows and cells  (Session 7, S02, S04)
# =============================================================================
section("Part 2: subset columns, rows and cells")

penguins_demo <- penguins_raw
schools_demo  <- schools_raw

# --- Columns -----------------------------------------------------------------
# Square brackets are [rows, columns]. Leave one side empty to mean "all".
head(penguins_demo$species)                       # $ pulls out ONE column as a vector
head(penguins_demo[["species"]])                  # the same, with double brackets
show(penguins_demo["species"], "penguins_demo['species']  (single brackets, a tibble)")
show(penguins_demo[, c("species", "body_mass_g")], "penguins_demo[, c('species', 'body_mass_g')]")
show(penguins_demo[, 2:4], "penguins_demo[, 2:4]  (columns 2 to 4)")

# dplyr's select() does the same, and it can pick columns by pattern or type.
show(select(penguins_demo, species, body_mass_g), "select(species, body_mass_g)")
show(select(penguins_demo, starts_with("bill")), "select(starts_with('bill'))")
show(select(penguins_demo, where(is.numeric)), "select(where(is.numeric))")
show(select(penguins_demo, -1), "select(-1)  (drop the first column)")
show(select(schools_demo, -(grade_1:grade_12)), "select(-(grade_1:grade_12))  (drop a range)")

# Reorder columns: name the ones you want first, then everything() for the rest.
reordered <- select(schools_demo, school_name, zip_code, school_level, everything())
print(names(reordered)[1:5])

# --- Rows --------------------------------------------------------------------
print(penguins_demo[1, ])                         # the first row
show(penguins_demo[1:3, ], "penguins_demo[1:3, ]  (rows 1 to 3)")
show(penguins_demo[penguins_demo$species == "Adelie", ], "penguins_demo[species == 'Adelie', ]  (a boolean mask)")
show(slice(penguins_demo, 1:3), "slice(1:3)")
show(filter(penguins_demo, species == "Adelie"), "filter(species == 'Adelie')")

# --- Cells -------------------------------------------------------------------
print(penguins_demo[1, "bill_length_mm"])         # row 1, column by name (a 1 x 1 tibble)
print(penguins_demo$bill_length_mm[1])            # the column, then position 1 (a number)
print(penguins_demo[[1, "bill_length_mm"]])       # double brackets return the bare value

# --- Subsetting with conditions: base R subset() (S04) ----------------------
# subset(data, condition) keeps the rows where the condition is TRUE.
#   ==  equal   !=  not equal   >=  at least   &  and   |  or   %in%  one of
show(subset(schools_demo, school_level == "High School"), "subset(school_level == 'High School')")
show(subset(schools_demo, school_level != "Elementary School"), "subset(school_level != 'Elementary School')")
show(subset(schools_demo, school_level == "High School" & grade_9 >= 300), "subset(High School & grade_9 >= 300)")
show(subset(schools_demo, zip_code == 37013 | zip_code == 37211), "subset(zip_code == 37013 | zip_code == 37211)")
show(subset(schools_demo, zip_code %in% c(37013, 37211)), "subset(zip_code %in% c(37013, 37211))  (same result)")
show(subset(schools_demo, grepl("high", school_name, ignore.case = TRUE)), "subset(grepl('high', school_name))  (text search)")
show(subset(schools_demo, is.na(grade_pre_k_3yrs)), "subset(is.na(grade_pre_k_3yrs))")
show(subset(schools_demo, !is.na(grade_pre_k_3yrs)), "subset(!is.na(grade_pre_k_3yrs))  (the opposite)")
# subset() can also pick columns: subset(schools_demo, select = c(school_name, zip_code))

# --- The same with dplyr filter() -------------------------------------------
# Several conditions separated by commas mean "and".
show(filter(schools_demo, school_level == "High School", grade_9 >= 300), "filter(High School, grade_9 >= 300)")
show(filter(schools_demo, str_detect(school_name, "High")), "filter(str_detect(school_name, 'High'))")
print(head(arrange(select(filter(schools_demo, school_level == "High School"), school_name, grade_9), desc(grade_9)), 3))


# =============================================================================
# PART 3: Change column headings  (S02, S04, S06)
# =============================================================================
section("Part 3: change column headings")

penguins_demo <- penguins_raw
print(names(penguins_demo)[1:3])                  # "...1" "species" "island"

# Base R: assign new names to names(). By position:
names(penguins_demo)[1] <- "row_number"
# Or by name. The comparison finds the right heading, then the new name replaces it.
names(penguins_demo)[names(penguins_demo) == "body_mass_g"] <- "body_mass"
print(names(penguins_demo))

# dplyr: rename(data, new_name = old_name).
penguins_demo <- rename(penguins_demo, bill_length = bill_length_mm)
print(names(penguins_demo)[4])                    # "bill_length"

# Change every heading at once with a function (S04).
upper_demo <- penguins_raw
colnames(upper_demo) <- toupper(colnames(upper_demo))
print(names(upper_demo))

# clean_names() (defined at the top) turns messy headings into tidy ones.
messy <- data.frame("Bill Length (mm)" = c(39.1, 39.5), "Body Mass (g)" = c(3750, 3800),
                    check.names = FALSE)
print(names(messy))
print(names(clean_names(messy)))

# Drop a column you do not need. The unnamed row-number column carries no data.
penguins_demo <- select(penguins_demo, -row_number)
print(names(penguins_demo)[1:3])                  # "species" "island" "bill_length"


# =============================================================================
# PART 4: Change values  (Session 8, S04)
# =============================================================================
section("Part 4: change values")

patients_demo <- patients_raw
schools_demo  <- schools_raw

# Count the values first. Finding the problem is most of the work.
print(table(patients_demo$group))                 # A 85, "A " 40, B 125
print(table(patients_demo$sex))                   # F 112, M 119, f 9, m 10

# --- Text functions ----------------------------------------------------------
# Base R:  trimws() removes spaces at both ends.  toupper() makes upper case.
print(trimws("A "))
print(toupper("m"))
# stringr does the same with names that all start with str_.
print(str_trim("A "))
print(str_to_upper("m"))
print(str_replace_all("Non-Traditional - Hybrid", " - Hybrid", ""))

# mutate() changes or adds columns. This is the cleaning step from Session 8.
# %>% is the pipe: take patients_demo, and then mutate it. Part 5 explains it.
patients_demo <- patients_demo %>%
  mutate(group = str_trim(group),
         sex = str_to_upper(sex))
print(table(patients_demo$group))                 # A 125, B 125
print(table(patients_demo$sex))                   # F 121, M 129

# --- Replace values by rule --------------------------------------------------
# ifelse(test, value_if_TRUE, value_if_FALSE) decides row by row.
patients_demo$qc_label <- ifelse(patients_demo$passed_qc, "pass", "fail")
# recode() swaps specific values for others.
patients_demo$sex_label <- recode(patients_demo$sex, "F" = "female", "M" = "male")
# case_when() handles several conditions, in order. TRUE ~ means "everything else".
patients_demo$bp_category <- case_when(
  is.na(patients_demo$systolic) ~ "missing",
  patients_demo$systolic >= 140 ~ "high",
  patients_demo$systolic >= 120 ~ "elevated",
  TRUE ~ "normal")
print(table(patients_demo$bp_category))
# replace() changes values at chosen positions. This changes one copy, not the data.
print(head(replace(patients_demo$group, patients_demo$group == "A", "Group A")))

# --- One category with two labels: factor levels and labels (S04) -----------
# school_level has "Non-Traditional" and "Non-Traditional - Hybrid". They mean
# the same thing. factor() can map several old labels onto one new label.
level_set <- sort(unique(schools_demo$school_level))
new_labels <- ifelse(level_set == "Non-Traditional - Hybrid", "Non-Traditional", level_set)
schools_demo$school_level_clean <- factor(schools_demo$school_level,
                                          levels = level_set, labels = new_labels)
print(length(level_set))                          # 10 labels before
print(nlevels(schools_demo$school_level_clean))   # 9 labels after
print(table(schools_demo$school_level_clean))

# --- Gluing text together: paste() and paste0() (S04) ------------------------
print(paste("Hello", "world!"))                   # "Hello world!"   a space between
print(paste("Hello", "world!", sep = "_"))        # "Hello_world!"   you choose the separator
print(paste0("Hello", "world!"))                  # "Helloworld!"    no separator
print(head(paste0("20", schools_demo$school_year)))   # "2018-19" ...
patients_demo$label <- paste(patients_demo$patient_id, patients_demo$group, sep = "_")
print(head(patients_demo$label))

# --- Split one column into two, and join them back (S04) ---------------------
# separate() splits school_year ("18-19") at the dash into two columns.
split_years <- schools_demo %>%
  separate(school_year, into = c("year_start", "year_end"), sep = "-")
print(head(split_years[, c("school_name", "year_start", "year_end")], 3))
# unite() glues them back together.
rejoined <- split_years %>% unite(school_year, year_start, year_end, sep = "-")
print(head(rejoined$school_year, 3))

# mapped_location stores latitude and longitude as ONE text value, "(36.02, -86.66)".
# Session 7 called this two values in one cell. Split it, then convert to numbers.
location_split <- schools_demo %>%
  separate(mapped_location, into = c("lat_text", "lon_text"), sep = ", ") %>%
  mutate(lat_new = as.numeric(str_remove(lat_text, "\\(")),
         lon_new = as.numeric(str_remove(lon_text, "\\)")))
# The result matches the latitude and longitude columns the file already has.
print(all(abs(location_split$lat_new - location_split$latitude) < 1e-6, na.rm = TRUE))   # TRUE

# --- Arithmetic on columns ---------------------------------------------------
penguins_demo <- penguins_raw %>% mutate(body_mass_kg = body_mass_g / 1000)
print(head(penguins_demo[, c("body_mass_g", "body_mass_kg")], 3))

# --- Change a column's type --------------------------------------------------
# age is text because of the word "unknown". as.numeric() turns text into numbers
# and anything that is not a number into NA. R warns when this happens.
patients_demo$age <- suppressWarnings(as.numeric(patients_demo$age))
print(class(patients_demo$age))                   # "numeric"


# =============================================================================
# PART 5: The six functions and the pipe  (Session 8, S04)
# =============================================================================
section("Part 5: the six functions and the pipe")

# Cleaned patients, used by the examples below.
patients_ok <- patients_raw %>%
  mutate(group = str_trim(group), sex = str_to_upper(sex),
         age = suppressWarnings(as.numeric(age)))

# Each function changes a table in one way. show() prints the size after each.
show(patients_ok %>% filter(systolic > 130), "filter(systolic > 130)             rows go down")
show(patients_ok %>% select(patient_id, systolic, group), "select(patient_id, systolic, group)  columns go down")
show(patients_ok %>% mutate(pulse_pressure = systolic - diastolic), "mutate(pulse_pressure = ...)           one column added")
show(patients_ok %>% arrange(desc(systolic)), "arrange(desc(systolic))               same size, new order")
# group_by() marks the groups. summarise() collapses each group to one row.
print(patients_ok %>%
        group_by(group) %>%
        summarise(n = n(), mean_systolic = mean(systolic, na.rm = TRUE)))

# A pipe passes each result into the next function. Read it as "and then".
# R has two pipes that do the same job:
#   %>%  the dplyr pipe (from the magrittr package). Loading dplyr gives it to you,
#        and it works in any version of R. We use it in every script here.
#   |>   the base R pipe, built into R 4.1 and later. It needs parentheses after
#        the function (x |> head(), not x |> head), and its placeholder is _
#        where %>% uses a dot.
# You will see both in tutorials and in AI-written code. Pandas has no pipe
# operator. Method chaining does the same job there.
# Run a pipeline one step at a time, and look at the size after each step.
step1 <- penguins_raw %>% filter(species == "Adelie")
step2 <- step1 %>% mutate(kg = body_mass_g / 1000)
step3 <- step2 %>% group_by(island) %>% summarise(mean_kg = mean(kg, na.rm = TRUE))
cat(nrow(penguins_raw), "->", nrow(step1), "->", nrow(step2), "->", nrow(step3), "rows\n")   # 344 -> 152 -> 152 -> 3
print(step3)
# mutate kept every row. summarise collapsed each group.

# Order matters. select() dropped body_mass_g, so the filter has nothing to test.
wrong_order <- tryCatch(
  penguins_raw %>% select(species, island) %>% filter(body_mass_g > 4000),
  error = function(e) "error: object 'body_mass_g' not found")
print(wrong_order)


# =============================================================================
# PART 6: Missing values  (Session 8, S02, S06)
# =============================================================================
section("Part 6: missing values")

# Count them. colSums(is.na(data)) gives the number of NA in every column.
print(colSums(is.na(penguins_raw)))               # 2 in each measurement, 11 in sex
print(sum(is.na(patients_ok$age)))                # 6, the "unknown" ages
print(colSums(is.na(patients_ok))[c("systolic", "diastolic", "cholesterol")])

# NA is contagious: one NA makes a mean NA, unless you tell R to skip it.
print(mean(penguins_raw$bill_length_mm))                  # NA
print(mean(penguins_raw$bill_length_mm, na.rm = TRUE))    # 43.92
print(mean(na.omit(penguins_raw$bill_length_mm)))         # the same, dropping first

# Find the rows with a missing value.
print(head(filter(penguins_raw, is.na(sex))[, c("species", "island", "sex")], 3))

# Three ways to drop rows that have any NA. Each gives 333 penguins.
print(nrow(drop_na(penguins_raw)))                # tidyr
print(nrow(na.omit(penguins_raw)))                # base R
print(sum(complete.cases(penguins_raw)))          # a count of complete rows

# Dropping rows is a decision about your data. Not every NA means "unknown":
#   patients age         "unknown" became NA: the age exists but was not recorded
#   schools grade_9      NA for a middle school: the grade does not exist there
#   penguins sex         NA: the penguin was not sexed
# Filling the schools NA values with 0 would be wrong. Leave them missing.
middle <- filter(schools_raw, school_level == "Middle School")
cat(sum(is.na(middle$grade_9)), "of", nrow(middle), "middle schools have no grade 9\n")


# =============================================================================
# PART 7: Combine tables: bind and join  (Session 8, S06)
# =============================================================================
section("Part 7: combine tables")

# --- Stack tables: bind rows (S06) -------------------------------------------
# Split the patients by group, then put the pieces back together.
group_a <- filter(patients_ok, group == "A")
group_b <- filter(patients_ok, group == "B")
show(group_a, "group_a")
show(group_b, "group_b")
show(rbind(group_a, group_b), "rbind(group_a, group_b)  (base R)")
show(bind_rows(group_a, group_b), "bind_rows(group_a, group_b)  (dplyr)")
# rbind needs the same columns in both tables.
rbind_error <- tryCatch(rbind(group_a, select(group_b, -age)), error = function(e) conditionMessage(e))
print(rbind_error)

# --- Put tables side by side: bind columns -----------------------------------
ids  <- select(patients_ok, patient_id, age)
bps  <- select(patients_ok, systolic, diastolic)
show(cbind(ids, bps), "cbind(ids, bps)  (base R)")
show(bind_cols(ids, bps), "bind_cols(ids, bps)  (dplyr)")
# Binding columns trusts that row 1 matches row 1. A join checks a key instead.

# --- Joins: match rows by a shared key ---------------------------------------
# Two small tables built from the penguins data, called L and R. They share the
# key column species, but only Adelie appears in both.
species_means <- penguins_raw %>%
  group_by(species) %>%
  summarise(mean_mass = round(mean(body_mass_g, na.rm = TRUE)),
            mean_bill = round(mean(bill_length_mm, na.rm = TRUE), 1))
L <- species_means %>% filter(species %in% c("Adelie", "Gentoo")) %>% select(species, mean_mass)
R <- species_means %>% filter(species %in% c("Adelie", "Chinstrap")) %>% select(species, mean_bill)
print(L)
print(R)

print(inner_join(L, R, by = "species"))           # only rows in both: Adelie
print(left_join(L, R, by = "species"))            # every row of L: Adelie, Gentoo (NA for bill)
print(right_join(L, R, by = "species"))           # every row of R: Adelie, Chinstrap (NA for mass)
print(full_join(L, R, by = "species"))            # every row of both: all three species
print(semi_join(L, R, by = "species"))            # rows of L that HAVE a match; no columns added
print(anti_join(L, R, by = "species"))            # rows of L that have NO match: Gentoo
print(anti_join(R, L, by = "species"))            # the other direction: Chinstrap

# Base R merge() does the same jobs with arguments instead of function names.
#   all = FALSE  inner join     all.x = TRUE  left join
#   all.y = TRUE right join     all = TRUE    full join
print(merge(L, R, by = "species", all = FALSE))
print(merge(L, R, by = "species", all.x = TRUE))
print(merge(L, R, by = "species", all.y = TRUE))
print(merge(L, R, by = "species", all = TRUE))

# --- Build a combined table step by step (S06) -------------------------------
# Add each penguin's species average to its own row. A left join keeps every
# penguin, so the row count should not change.
penguins_plus <- penguins_raw %>%
  left_join(species_means, by = "species") %>%
  select(species, island, body_mass_g, mean_mass, everything())
cat(nrow(penguins_raw), "->", nrow(penguins_plus), "rows\n")            # 344 -> 344
names(penguins_plus)[names(penguins_plus) == "mean_mass"] <- "species_mean_mass"
print(head(penguins_plus[, 1:4], 3))

# The sanity check: after every join, compare the row counts.
island_means <- penguins_raw %>%
  group_by(island) %>%
  summarise(mean_mass = round(mean(body_mass_g, na.rm = TRUE)))          # 3 rows
species_by_island <- penguins_raw %>% count(species, island, name = "n")  # 5 rows
too_many <- left_join(island_means, species_by_island, by = "island")
cat(nrow(island_means), "->", nrow(too_many), "rows\n")                  # 3 -> 5
# Biscoe and Dream appear twice in species_by_island, so they appear twice in
# the result. More rows than the left table means the key repeats on the right.


# =============================================================================
# PART 8: Reshape: long and wide  (Session 8, S06)
# =============================================================================
section("Part 8: reshape")

# A table is WIDE when one variable is spread across column headings. The
# schools file has one column per grade: grade_9, grade_10, and so on.
four_schools <- c("Antioch High School", "Cane Ridge High School",
                  "Glencliff High School", "Hillsboro High")
wide4 <- schools_raw %>%
  filter(school_name %in% four_schools) %>%
  select(school_name, grade_9, grade_10, grade_11, grade_12)
print(wide4)

# pivot_longer() makes it long. cols = which columns to unpivot,
# names_to = the new column for the old headings, values_to = the new column for the numbers.
long4 <- wide4 %>% pivot_longer(cols = grade_9:grade_12, names_to = "grade", values_to = "students")
print(long4)                                      # 16 rows: 4 schools x 4 grades

# The same on the whole file. starts_with("grade_") picks all 15 grade columns.
# names_prefix removes "grade_" from the new values. values_drop_na = TRUE drops
# the grades a school does not offer (the NA that means "not offered").
schools_long_demo <- schools_raw %>%
  select(school_id, school_name, starts_with("grade_")) %>%
  pivot_longer(cols = starts_with("grade_"), names_to = "grade", names_prefix = "grade_",
               values_to = "students", values_drop_na = TRUE)
cat(nrow(schools_long_demo), "rows, not", nrow(schools_raw) * 15, "\n")          # 868, not 2535
print(sum(schools_long_demo$students))            # 86527, the same total as male + female
print(sum(schools_raw$male + schools_raw$female)) # 86527

# The new grade column holds text such as "9", "10", "k" and "pre_k_3yrs".
# as.numeric() converts the ones that are numbers and gives NA for the rest.
grade_numbers <- suppressWarnings(as.numeric(schools_long_demo$grade))
print(table(is.na(grade_numbers)))
# The 2025 lecture did the same with substr() on column names such as "x2020":
print(as.numeric(substr("x2020", 2, 5)))          # 2020

# pivot_wider() goes the other way: long back to wide.
schools_wide_again <- schools_long_demo %>%
  pivot_wider(names_from = grade, values_from = students)
show(schools_wide_again, "pivot_wider(): back to one row per school")

# Wide is easier for a person to read. Count penguins by species and island,
# then spread the islands into columns. values_fill = 0 fills the empty combinations.
penguin_counts <- penguins_raw %>% count(species, island)
print(penguin_counts)                             # long: one row per combination
print(penguin_counts %>% pivot_wider(names_from = island, values_from = n, values_fill = 0))


# =============================================================================
# PART 9: The cleaning pipeline and saving  (all of the above)
# =============================================================================
section("Part 9: the cleaning pipeline")

# Everything above was practice on copies. This part applies the cleaning
# decisions once, from the raw data, and saves the results.
#
# Decisions, and why:
#   patients  group: strip the trailing space.  sex: one case.  age: numbers, with
#             "unknown" as NA. visit_date is left as text, because the impossible
#             date 2026-02-30 is a Session 9 problem.
#   penguins  drop the unnamed row-number column. Keep NA values: whether to drop
#             them depends on the analysis.
#   schools   merge the two Non-Traditional labels. Make zip_code text, because
#             it is an identifier. Drop mapped_location, which repeats latitude and
#             longitude. Keep NA in the grade columns.

dir.create("data/clean", showWarnings = FALSE)

patients_clean <- patients_raw %>%
  mutate(group = str_trim(group),
         sex = str_to_upper(sex),
         age = suppressWarnings(as.numeric(age)))

penguins_clean <- penguins_raw %>%
  select(-1)                                      # the unnamed row-number column

schools_clean <- schools_raw %>%
  mutate(school_level = recode(school_level, "Non-Traditional - Hybrid" = "Non-Traditional"),
         zip_code = as.character(zip_code)) %>%
  select(-mapped_location)

# A long version of the schools table, one row per school per grade.
schools_long <- schools_clean %>%
  select(school_id, school_name, school_level, zip_code, starts_with("grade_")) %>%
  pivot_longer(cols = starts_with("grade_"), names_to = "grade", values_to = "students",
               values_drop_na = TRUE)

# Check the result before you save it. stopifnot() stops with an error if any
# of these is FALSE, so a mistake cannot slip into the saved files.
stopifnot(
  nrow(patients_clean) == 250,
  sum(patients_clean$group == "A") == 125,
  sum(patients_clean$sex == "M") == 129,
  sum(is.na(patients_clean$age)) == 6,
  ncol(penguins_clean) == 8,
  nrow(schools_clean) == 169,
  n_distinct(schools_clean$school_level) == 9,
  nrow(schools_long) == 868,
  sum(schools_long$students) == 86527
)
cat("All checks passed.\n")

# Save to data/clean/. write_csv(table, path) creates the file, or replaces it
# if it already exists. NA values are written as the text NA.
write_csv(patients_clean, "data/clean/patients_clean.csv")
write_csv(penguins_clean, "data/clean/penguins_clean.csv")
write_csv(schools_clean,  "data/clean/schools_clean.csv")
write_csv(schools_long,   "data/clean/schools_long.csv")
cat("Saved:", paste(list.files("data/clean", pattern = "csv$"), collapse = ", "), "\n")

# 2_statistics.R will read these files with read_csv("data/clean/...").

cat("\nDone: 1_data_cleaning.R\n")
