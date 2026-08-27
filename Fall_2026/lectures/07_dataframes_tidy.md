# Session 7 — Dataframes and Tidy Data

**Unit:** 2 (Data Wrangling)
**Duration:** 30-minute lecture + 20-minute activity
**Companion tutor:** `assistants_per_lecture/07_dataframes_tidy_gpt.md`

---

## Framing

Almost every dataset in research is a rectangle: rows are observations, columns are variables. Both Python (`pandas.DataFrame`) and R (`tibble` / `data.frame`) have first-class support for this shape. This session is where the course pivots from "the language" to "the tools researchers actually use." From here forward, we work with both pandas and tidyverse **side by side**, because your dissertation will almost certainly touch both.

---

## Learning objectives

Students should be able to:

1. Load a CSV into a pandas DataFrame and into an R tibble.
2. Inspect a dataframe: shape, column names, dtypes, head, summary.
3. Access a single column, a single row, a single cell, and a subset of rows/columns.
4. State the three rules of **tidy data** and identify whether a dataset violates them.
5. Recognize when their data is stored the wrong way (e.g., wide when it should be long).

---

## 30-minute outline

| Time     | Segment                                       |
|----------|-----------------------------------------------|
| 0–3      | Recap: files/git                              |
| 3–10     | Loading + inspecting a dataframe              |
| 10–18    | Column / row / cell access                    |
| 18–25    | The three rules of tidy data                  |
| 25–30    | Column types and factor/category surprises    |

---

## Segment 1 (0–3 min): Recap

Ask a student to name the four Git commands. Reinforce.

---

## Segment 2 (3–10 min): Loading + inspecting

Same dataset, two languages, side by side. Use a small public dataset for demo — e.g., `palmerpenguins` (`penguins.csv`).

```python
import pandas as pd
df = pd.read_csv("data/penguins.csv")
df.shape           # (344, 8) — 344 rows, 8 columns
df.columns         # Index(['species', 'island', 'bill_length_mm', ...])
df.dtypes          # each column's type
df.head()          # first 5 rows
df.describe()      # summary of numeric columns
df.info()          # types + missing counts
```

```r
library(readr)
library(dplyr)
df <- read_csv("data/penguins.csv")
dim(df)            # 344 8
names(df)          # column names
glimpse(df)        # transposed head — GREAT for wide data
head(df)
summary(df)
```

Every student should learn to **look at the data before touching it.** Every single week this semester should start with `df.head()` / `head(df)`. It is not optional.

Two habits to emphasize:

1. **`glimpse()` in R and `df.info()` in Python** are the fastest way to see types + missingness at once. Use them.
2. **`summary()` and `df.describe()`** are your first EDA pass. If a numeric column's summary is nonsense (mean = NaN, min = "unknown"), something loaded wrong. Session 9 goes deep.

---

## Segment 3 (10–18 min): Access

**Column access:**

```python
df["bill_length_mm"]           # a pandas Series
df[["bill_length_mm", "species"]]  # a DataFrame with two columns
df.bill_length_mm              # attribute style — works but fragile
```

```r
df$bill_length_mm              # a vector
df[["bill_length_mm"]]         # same
df |> select(bill_length_mm, species)   # a tibble — the tidyverse way
```

**Row access:**

```python
df.iloc[0]                     # first row by position
df.iloc[0:5]                   # first 5 rows
df[df.species == "Adelie"]     # rows where species is Adelie — boolean filter
```

```r
df[1, ]                        # first row
df[1:5, ]                      # first 5 rows
df |> filter(species == "Adelie")   # the tidyverse way — preferred
```

**Single cell:**

```python
df.iloc[0, 2]                  # row 0, column 2 (positional)
df.loc[0, "bill_length_mm"]    # row 0, column named — safer
```

```r
df[1, "bill_length_mm"]
df$bill_length_mm[1]
```

Emphasize the boolean-filter idiom from Session 3. It is the same idea, extended to a whole table. `df[df.species == "Adelie"]` reads as "give me rows of df where the species column equals Adelie." This idiom is the load-bearing beam of data wrangling.

---

## Segment 4 (18–25 min): The three rules of tidy data

From Hadley Wickham's *Tidy Data* paper. Say them out loud:

1. **Each variable is a column.**
2. **Each observation is a row.**
3. **Each type of observational unit is its own table.**

Show a "messy" example:

```
patient_id | bp_2020 | bp_2021 | bp_2022
P001       | 130     | 128     | 125
P002       | 145     | 142     | 141
```

Ask: what are the variables here? Students usually say "bp_2020, bp_2021, bp_2022." Correct them: **the variable is `year`, and the values are years.** The actual variable set is: `patient_id`, `year`, `bp`.

The tidy version:

```
patient_id | year | bp
P001       | 2020 | 130
P001       | 2021 | 128
P001       | 2022 | 125
P002       | 2020 | 145
...
```

Why tidy matters:

- Every dplyr/pandas verb is designed for tidy data. `group_by(year)` only makes sense if `year` is a column.
- ggplot2 will *only* plot tidy data. If you ask for `aes(x = year, y = bp)`, `year` must be a column.
- The wrangling verbs from Session 8 (`pivot_longer`, `pivot_wider`) exist to convert between tidy and untidy shapes.

Tell students: **if your ChatGPT-produced plot code isn't working, first check whether your data is in tidy shape.** More often than not, that's the fix.

---

## Segment 5 (25–30 min): Column types and factor gotchas

Every column has a type. Common types:

| Type              | Python (pandas)     | R (tibble)          |
|-------------------|---------------------|---------------------|
| Integer           | `int64`             | `<int>` / integer   |
| Floating point    | `float64`           | `<dbl>` / numeric   |
| Text              | `object` / `string` | `<chr>` / character |
| Date/time         | `datetime64`        | `<date>` / Date     |
| Categorical       | `category`          | `<fct>` / factor    |
| Boolean           | `bool`              | `<lgl>` / logical   |

The one that bites everyone: **factor / category.** In R, character columns are sometimes silently converted to factors. Factors look like strings but are stored as integers with a labels table. They matter for statistical models (a factor with the levels "control, treated" versus a raw string is treated differently by `lm`). Foreshadow this for Session 11.

Command to always know:

```python
df.dtypes             # Python — check types
```

```r
sapply(df, class)     # R — check types across all columns
```

If a numeric column is showing as `object` in pandas, or as `<chr>` in R, you have a data-loading problem. That is *always* worth investigating before you do anything else.

---

## Key vocabulary

- **DataFrame / tibble** — the rectangle: rows = observations, columns = variables.
- **Series / vector** — a single column.
- **Tidy data** — the shape where one variable = one column, one observation = one row.
- **Long vs. wide** — long = tidy (each observation on its own row). Wide = observations spread across columns.
- **Factor / categorical** — a text column with a fixed set of possible values, used in statistical models.

---

## Common student mistakes

- Treating a wide table as if it were tidy → all your dplyr/pandas code breaks in confusing ways.
- Not checking dtypes after loading. Silent type coercion is the #1 first-week bug in data work.
- Using positional indexing (`df.iloc[0, 2]`) instead of named (`df.loc[0, "bp"]`). Positions change when you filter; names don't.

---

## Handoff to tutor activity

`assistants_per_lecture/07_dataframes_tidy_gpt.md` — the tutor shows the student a messy dataset and asks them to identify what's wrong with it before writing any transformation code.
