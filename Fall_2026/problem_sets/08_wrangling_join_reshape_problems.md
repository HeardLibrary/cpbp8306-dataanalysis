# Problem Set 08: Data Wrangling, Cleaning, Joining, Reshaping

**Session:** 8 (Unit 2: Data Wrangling)
**Course data:** penguins (the `palmerpenguins` package in R, or `penguins.csv` in Python), `patients.csv`, and `schools_tibble.csv`, all on Brightspace
**Use with:** `general_tutor_gpt.md`
**Time target:** ~20–25 minutes, worked through with the tutor

---

## Instructions for students

Paste this whole file into the Course Tutor and work through the problems together, in order. These are the same three datasets as Session 7, so nothing here is new data. Problems 2 and 3 are where you finally fix the defects in `patients.csv` that you found in Sessions 1 to 3.

Load the data first. Every problem below assumes these objects exist.

```r
library(dplyr); library(tidyr); library(stringr); library(readr)
library(palmerpenguins)                       # gives you penguins (344 x 8, includes year)
patients <- read_csv("patients.csv", trim_ws = FALSE)   # keep trailing spaces so you can find them in Problem 2
schools <- read_csv("schools_tibble.csv")
```

```python
import pandas as pd
penguins = pd.read_csv("penguins.csv")
# A CSV written from R has a row-number column that pandas calls "Unnamed: 0". Drop it if it is there.
penguins = penguins.loc[:, ~penguins.columns.str.startswith("Unnamed")]
patients = pd.read_csv("patients.csv")
schools = pd.read_csv("schools_tibble.csv")
```

`read_csv()` removes spaces at the start and end of text values unless you set `trim_ws = FALSE`. Without it, the `"A "` problem would disappear before you ever saw it. pandas keeps the spaces by default.

Session 7's three rules still apply: each variable is a column, each observation is a row, and each cell holds one value. Today's functions are how you get a table into that shape.

---

## Problems

1. **Six functions and a pipeline.** Each function changes a table in one way. `filter` drops rows, `select` drops columns, `mutate` adds a column, `arrange` reorders rows, `group_by` marks groups, and `summarise` collapses each group to one row. Here is one pipeline on the penguins data. A pipe passes the result of one step into the next, so read `%>%` as "and then":

   ```r
   penguins %>%
     filter(species == "Adelie") %>%
     mutate(kg = body_mass_g / 1000) %>%
     group_by(island) %>%
     summarise(mean_kg = mean(kg, na.rm = TRUE))
   ```

   ```python
   (penguins
     .query("species == 'Adelie'")
     .assign(kg=lambda d: d.body_mass_g / 1000)
     .groupby("island")
     .agg(mean_kg=("kg", "mean")))
   ```

   (a) Before running anything, predict how many rows you have after `filter`, after `mutate`, and after `group_by` plus `summarise`. Then run the pipeline one step at a time and check.
   (b) Which of these steps keeps every row, and which one collapses rows? Why is mixing them up a common AI mistake?
   (c) Suppose you put `select(species, island)` before a filter on `body_mass_g`. What happens, and why does verb order matter?
   (d) R has two pipes. This problem set uses `%>%`, which comes with dplyr. Base R has its own, `|>`. Rewrite the first two lines of the pipeline with `|>` and check that you get the same rows. Then try `penguins |> head` with no parentheses and read the error. What does `%>%` do with `penguins %>% head`?

2. **Fix `group` and `sex` in `patients.csv`.** Count the values first, then clean them.

   ```r
   table(patients$group)
   table(patients$sex)
   ```

   ```python
   patients.group.value_counts()
   patients.sex.value_counts()
   ```

   (a) How many distinct values does each column have, and why are there more than you expect?
   (b) Write the cleaning step: strip the whitespace from `group` and make `sex` consistently uppercase (`str_trim` and `str_to_upper` in R, `.str.strip()` and `.str.upper()` in pandas). Which single dplyr function lets you do both in one call?
   (c) Count again. What numbers do you expect for each column, and what happened to the 40 rows that were `"A "`?

3. **Handle missing values on purpose.** Three columns in these datasets have missing values for three different reasons.

   ```r
   patients$age <- as.numeric(patients$age)
   mean(penguins$bill_length_mm)
   mean(penguins$bill_length_mm, na.rm = TRUE)
   ```

   ```python
   patients["age"] = pd.to_numeric(patients["age"], errors="coerce")
   penguins["bill_length_mm"].mean()
   penguins["bill_length_mm"].mean(skipna=False)
   ```

   (a) After converting `age`, how many values are missing? Why did the conversion not stop with an error?
   (b) R and pandas disagree about what `mean()` does with missing values. What does each one return, and which default is safer?
   (c) For each case, say what the missing value means and whether you would drop it, fill it, or keep it: `age` for a patient whose row said `"unknown"`, `grade_9` for a middle school in `schools_tibble.csv`, and `sex` for a penguin that was not sexed.

4. **Join two tables on a key.** Build two small tables from the penguins data. They share the key `species`, but only Adelie appears in both.

   ```r
   species_means <- penguins %>%
     group_by(species) %>%
     summarise(mean_mass = round(mean(body_mass_g, na.rm = TRUE)),
               mean_bill = round(mean(bill_length_mm, na.rm = TRUE), 1))
   L <- species_means %>% filter(species %in% c("Adelie", "Gentoo")) %>% select(species, mean_mass)
   R <- species_means %>% filter(species %in% c("Adelie", "Chinstrap")) %>% select(species, mean_bill)
   left_join(L, R, by = "species")
   ```

   ```python
   species_means = penguins.groupby("species", as_index=False).agg(
       mean_mass=("body_mass_g", "mean"), mean_bill=("bill_length_mm", "mean"))
   L = species_means[species_means.species.isin(["Adelie", "Gentoo"])][["species", "mean_mass"]].round(0)
   R = species_means[species_means.species.isin(["Adelie", "Chinstrap"])][["species", "mean_bill"]].round(1)
   L.merge(R, on="species", how="left")
   ```

   (a) Predict how many rows a left join, an inner join, and a full join of `L` and `R` give. Then run all three and check. Which join type keeps only the rows that match in both tables?
   (b) If you call pandas `merge()` without `how=`, which join do you get? What does dplyr do?
   (c) Sanity check. Join island averages (3 rows) to species counts by island, and compare the row counts before and after. Why did the number change?

   ```r
   island_means <- penguins %>% group_by(island) %>% summarise(mean_mass = round(mean(body_mass_g, na.rm = TRUE)))
   species_by_island <- penguins %>% count(species, island, name = "n")
   left_join(island_means, species_by_island, by = "island")
   ```

   ```python
   island_means = penguins.groupby("island", as_index=False).agg(mean_mass=("body_mass_g", "mean")).round(0)
   species_by_island = penguins.groupby(["species", "island"], as_index=False).size().rename(columns={"size": "n"})
   island_means.merge(species_by_island, on="island", how="left")
   ```

5. **Reshape: wide to long and back.** Last session you found that `schools_tibble.csv` stores one variable, grade, across 15 column headers (`grade_pre_k_3yrs` through `grade_12`).

   ```r
   select(schools, starts_with("grade_")) %>% ncol()
   ```

   ```python
   len(schools.filter(like="grade_").columns)
   ```

   (a) Which tool fixes that: `pivot_longer`/`melt`, or `pivot_wider`/`pivot`? Write the call that makes it long with new columns named `grade` and `students`, dropping the cells where a school does not offer that grade.
   (b) Predict the number of rows before you run it. Why is it not 169 × 15? Then check that the students add up to the same total as `male` plus `female`.
   (c) Now go the other way. Count penguins by species and island (`count()` in R, `value_counts()` in pandas), then make a table with one row per species and one column per island. Where do the `0` values come from?

---

## Coverage (for instructor reference)

| # | Slides | Concept |
|---|--------|---------|
| 1 | 4 to 6 | The six functions, the two R pipes, and checking the row count after each step; `mutate` vs. `summarise`; verb order |
| 2 | 7 | `mutate` for cleaning; fixing the real `group` and `sex` defects |
| 3 | 8 | Three kinds of missing value; `na.rm` in R vs. the pandas default |
| 4 | 9 | Join types, the pandas and dplyr defaults, and the row-count sanity check |
| 5 | 10 and 11 | `pivot_longer`/`melt`, then `pivot_wider`/`unstack` |

### Verified facts about the data (for the tutor; do not invent others)

- **Penguins:** 344 rows. The R package has 8 columns because it keeps `year`; the current `penguins.csv` is an export of that data with a row-number column that pandas reads as `Unnamed: 0`. Species counts are Adelie 152, Chinstrap 68, Gentoo 124. Missing values: 2 in `bill_length_mm` and 11 in `sex`. Do not use R 4.5+'s built-in `penguins`, whose columns are named `bill_len`, `bill_dep`, `flipper_len` and `body_mass`.
- **Problem 1:** after `filter` there are 152 rows and 8 columns, after `mutate` 152 rows and 9 columns, and the final result has 3 rows (Biscoe 3.71, Dream 3.69, Torgersen 3.71, in kilograms). If `select(species, island)` comes first, `body_mass_g` no longer exists and the filter fails. For part (d), `|>` and `%>%` return the same rows. `penguins |> head` is an error (the right side must be a function call), while `penguins %>% head` works.
- **Problem 2:** `group` starts as B 125, A 85, `"A "` 40 and becomes A 125, B 125. `sex` starts as M 119, F 112, m 10, f 9 and becomes M 129, F 121. `mutate()` does both in one call.
- **Problem 3:** 6 `age` values read `"unknown"`, so `age` loads as text. After conversion 6 are missing and the mean of the rest is 56.42. `mean(bill_length_mm)` is `NA` in R and 43.92 in pandas; with `na.rm = TRUE` R also gives 43.92. All 31 middle schools have `NA` for `grade_9` because they do not offer it. R prints a warning when `as.numeric` meets `"unknown"`. The warning is expected.
- **Problem 4:** `L` has Adelie 3701 and Gentoo 5076. `R` has Adelie 38.8 and Chinstrap 48.8. A left join gives 2 rows (Gentoo has `NA` for `mean_bill`), an inner join 1 row, and a full join 3 rows. pandas `merge()` defaults to an inner join; dplyr has no default and you pick `left_join`, `inner_join` or `full_join` by name. `island_means` has 3 rows and `species_by_island` has 5, so the left join returns 5 rows, because Biscoe and Dream each appear twice on the right.
- **Problem 5:** the schools file has 169 rows and 15 `grade_*` columns. Made long with the not-offered cells dropped, there are 868 rows, and the students sum to 86,527, which equals `male` plus `female`. R lists the long rows school by school and pandas `melt` lists them grade by grade, so the order differs. The species and island counts are Adelie 44 (Biscoe), 56 (Dream), 52 (Torgersen); Chinstrap 68 (Dream); Gentoo 124 (Biscoe). The wide table fills the combinations that never occur with 0.
