# Problem Set 07: Dataframes and Tidy Data

**Session:** 7 (Unit 2: Data Wrangling)
**Course data:** penguins (new this session: the `palmerpenguins` package in R, or `cpbp8306-dataanalysis/Fall_2026/data/penguins.csv` in Python), `patients.csv` (continuing), and `schools_tibble.csv` (new this session, on Brightspace)
**Use with:** `general_tutor_gpt.md`
**Time target:** ~20–25 minutes, worked through with the tutor

---

## Instructions for students

Paste this whole file into the Course Tutor and work through the problems together, in order. Download `schools_tibble.csv` from Brightspace first and save it next to your script. You'll use it in problem 3 and problem 5, and again next week.

Starting this session, the penguins data becomes the course's second running dataset (344 rows; the CSV has 7 columns: `species`, `island`, `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm`, `body_mass_g`, `sex`, and the R package adds an eighth, `year`, the year each penguin was sampled, 2007 to 2009), used alongside `patients.csv` through the rest of the semester. In R, load it from the `palmerpenguins` package. In Python, read `penguins.csv` from the course data folder. It is the same 344 penguins either way, but the rows are in a different order, and in R the package stores `species`, `island` and `sex` as factors (with `sex` in lowercase) while the CSV loads them as text. `schools_tibble.csv` (169 Nashville schools, 2018-19, 35 columns) is a real, messy table that this unit uses to practice tidy data.

The course uses three rules for tidy data: **each variable is a column, each observation is a row, and each cell holds one value.**

---

## Problems

1. **First look.** Load the penguins data, then run `df.shape` / `dim(df)` and `df.dtypes` / `glimpse(df)` (or `str(df)`). How many rows and columns are there in each language, and which extra column does R show? Which columns have missing values?

   ```python
   import pandas as pd
   df = pd.read_csv("penguins.csv")
   ```

   ```r
   library(palmerpenguins); library(dplyr)
   df <- penguins
   ```

2. **Access.** Give the pandas *or* R/tidyverse code to: (a) pull out just the `bill_length_mm` column, (b) keep only rows where `species == "Adelie"`, (c) get a single cell by row and column *name* rather than position.

3. **Tidy or not? The schools file.** Load `schools_tibble.csv` and look at the high schools:

   ```python
   import pandas as pd
   schools = pd.read_csv("schools_tibble.csv")
   schools[schools.school_level == "High School"][
       ["school_name", "grade_9", "grade_10", "grade_11", "grade_12", "mapped_location"]
   ].head()
   ```

   ```r
   library(readr); library(dplyr)
   schools <- read_csv("schools_tibble.csv")
   schools |>
     filter(school_level == "High School") |>
     select(school_name, grade_9, grade_10, grade_11, grade_12, mapped_location) |>
     head()
   ```

   In the R code, `|>` is a pipe. It passes the result of one step into the next, so read it as "and then": take `schools`, then keep the high schools, then select six columns, then show the first rows.

   (a) Which columns break the three tidy rules, and which rule does each one break? What single variable is hiding in the `grade_9` to `grade_12` headers?
   (b) The full file has 15 `grade_*` columns. Before running anything, predict: if you made it long, with one row per school per grade, would you get exactly 169 × 15 rows? Why or why not? Then count the non-missing grade cells to check, and say what an `NA` in `grade_9` means for a middle school: unknown, or not offered?
   (c) `mapped_location` is a text string like `"(36.05, -86.60)"`. Which rule does it break, and which columns already in the file make it redundant?

4. **Revisit `patients.csv` with fresh eyes.** Run `patients_df.dtypes` (or `str(patients_df)`) again. You already found the `age` and `group` problems in earlier sessions. Now check `patient_id`: is it stored as a number or as text? Why does it matter that IDs like `P001` have leading zeros? Then answer a habit question: when you do fix `patients.csv` next week, where should the original file stay, where should the cleaned copy go, and why should you never overwrite the original?

5. **Types and labels.** Check the type of `species` in your penguins `df` (`df.dtypes` in pandas, `class(df$species)` in R). In pandas it loads as text, and in R the package already makes it a factor. Is `species` a good candidate to be treated as a category/factor either way? Why does that distinction matter for statistics later in the course (Session 11)? If yours is still text, show the code that converts it (`astype("category")` in pandas, `factor()` in R) and confirm the type changed. Then look at `schools.school_level`: count how many schools fall in each level, and notice that `"Non-Traditional"` and `"Non-Traditional - Hybrid"` look like one category with two labels. Show the code that treats them as one category without editing the file (pandas `.replace`, or R `recode` or `factor(levels, labels)`), and check that the number of distinct levels dropped by one.

---

## Coverage (for instructor reference)

| # | Concept |
|---|---------|
| 1 | Inspecting a dataframe: shape, dtypes, head |
| 2 | Column / row / cell access |
| 3 | The three rules of tidy data on a real wide table: headers that are values, two values in one cell, NA that means "not offered" |
| 4 | Revisiting `patients.csv`'s real defects with the tidy-data lens; raw vs. cleaned files |
| 5 | Categorical/factor columns, one category with two labels, foreshadowing Session 11 |

### Verified facts about the penguins data (for the tutor; do not invent others)

- 344 rows. `penguins.csv` (Python) has 7 columns; the R package has 8 because it keeps `year` (an integer, 2007 to 2009). Missing values: 2 in each of the four measurement columns and 11 in `sex`.
- `year` is the sampling year, not a measurement. Later sessions select the four measurement columns by name, so keep `year` out of any PCA or correlation.
- The R package and the CSV hold the same penguins in a different row order (R: Adelie, Gentoo, Chinstrap; CSV: Adelie, Chinstrap, Gentoo).
- Types differ: in R the package stores `species`, `island` and `sex` as factors with lowercase `sex`; `penguins.csv` loads them as text (pandas `object`) with `Male`/`Female`.
- Do not use R 4.5+'s built-in `penguins`. Its columns are named `bill_len`, `bill_dep`, `flipper_len` and `body_mass`, which breaks the code in this set.

### Verified facts about `schools_tibble.csv` (for the tutor; do not invent others)

- 169 rows, 35 columns. `school_year` is `"18-19"` in every row (a constant, not a tidy-data violation).
- 15 `grade_*` columns: `grade_pre_k_3yrs`, `grade_pre_k_4yrs`, `grade_k`, `grade_1` through `grade_12`. Made long, there are 868 non-missing rows (not 169 × 15 = 2,535). The grade counts sum to 86,527, which equals `male` + `female` summed.
- 130 of 169 schools have `NA` for `grade_pre_k_3yrs`. All 31 middle schools have `NA` for `grade_9`. In both cases `NA` means "the school does not offer that grade," not "unknown."
- `mapped_location` holds `"(latitude, longitude)"` as one text string in the 168 rows where it is filled, and matches the existing `latitude` and `longitude` columns.
- `school_level` has 10 distinct labels, including `"Non-Traditional"` (5 schools) and `"Non-Traditional - Hybrid"` (2). Merging them gives 9 labels.
- Pivoting is next week's skill (`pivot_longer` in R, `melt` in pandas). This week the goal is to diagnose, not to fix.
