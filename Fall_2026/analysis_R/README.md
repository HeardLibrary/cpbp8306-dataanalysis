# CPBP 8306 analysis project (R)

This folder holds the code for the course. You run one file, `main.R`. It loads the packages, loads the data, and runs the scripts in `scripts/` in order. The Python version of this project is in `../analysis_python`. It does the same work with pandas.

## Folder layout

```
analysis_R/
  main.R                     run this file
  README.md                  this file
  data/
    raw/                     original files, exactly as downloaded. Never edit these.
      penguins.csv
      patients.csv
      schools_tibble.csv
    clean/                   cleaned files written by 1_data_cleaning.R
  scripts/
    0_language_basics.R      Sessions 1 to 6: labeled examples of the basic commands
    1_data_cleaning.R        Sessions 7 and 8: subset, rename, change, combine, reshape, save
    2_statistics.R           Sessions 9 to 12: comments only for now
  figures/                   plots saved by later scripts
```

## How to run it

1. Open R or RStudio. Set the working directory to this folder, the one that contains `main.R`. In RStudio: Session, Set Working Directory, Choose Directory. Or open the folder as an RStudio project.
2. Run the file.

```r
source("main.R")
```

From a terminal, inside this folder:

```bash
Rscript main.R
```

`main.R` stops with a message if it cannot find `data/raw/patients.csv`. That message means the working directory is wrong. It needs R 4.1 or newer, because the scripts use the `|>` pipe.

## Packages

`main.R` installs any package that is missing, then loads it. You need an internet connection the first time.

| Package | What it is used for |
|---|---|
| readr | `read_csv()` and `write_csv()` |
| dplyr | `filter`, `select`, `mutate`, `arrange`, `group_by`, `summarise`, joins |
| tidyr | `pivot_longer`, `pivot_wider`, `separate`, `unite`, `drop_na` |
| stringr | text cleaning: `str_trim`, `str_to_upper`, `str_detect` |
| tibble | the tibble table type |

`ggplot2` and `glmnet` are added when `2_statistics.R` gets code.

## The data

All three files are in `data/raw/`. The scripts read them and never change them.

| File | What it is | Source |
|---|---|---|
| `penguins.csv` | 344 penguins from the Palmer Archipelago, Antarctica. Species, island, four body measurements, sex, year. | Horst, Hill and Gorman (2020), palmerpenguins package, CC0 |
| `patients.csv` | 250 synthetic patients: age, sex, group, blood pressure, cholesterol, QC flag, visit date. Made up for this course, so no privacy concerns. | Course material |
| `schools_tibble.csv` | Enrollment for 169 Metro Nashville schools in 2018-19, one row per school, one column per grade. | Posted on Brightspace |

Problems in the raw files are there on purpose. Session 7 and 8 find and fix them.

- `penguins.csv`: the first column is an unnamed row number. 2 penguins have no measurements and 11 have no sex.
- `patients.csv`: `group` holds `"A"` and `"A "` (a trailing space). `sex` mixes `F`, `f`, `M` and `m`. `age` has the word `"unknown"` in 6 rows, so it loads as text. Some blood pressure and cholesterol values are missing. One `visit_date` is 2026-02-30, which does not exist.
- `schools_tibble.csv`: `school_level` uses two labels for one category (`Non-Traditional` and `Non-Traditional - Hybrid`). The 15 grade columns hold one variable, so the table is wide. A missing grade count usually means the school does not offer that grade. `mapped_location` stores latitude and longitude as one text value.

## Which script covers which lecture

| Script section | Lecture or session |
|---|---|
| `0_language_basics.R` Lecture 1 | Why code: the naive and corrected t-test |
| Lecture 2 | Data types and errors |
| Lecture 3 | Vectors, indexing, lists, data frames |
| Lecture 4 | Conditionals and loops |
| Lecture 5 | Functions |
| Lecture 6 | Files, paths, reading and writing, Git |
| `1_data_cleaning.R` Part 1 | Session 7: inspect |
| Parts 2 and 3 | Session 7 and the 2025 S02/S04 material: subset and rename |
| Parts 4 to 6 | Session 8 and 2025 S04: change values, the six functions, missing values |
| Parts 7 and 8 | Session 8 and 2025 S06: joins, bind, pivot |
| Part 9 | The cleaning pipeline and saving to `data/clean/` |
| `2_statistics.R` | Sessions 9 to 12 (plan only) |

`0_language_basics.R` is optional. It changes nothing on disk, so you can skip it or run it as a refresher.

## What gets written

Running `1_data_cleaning.R` writes four files to `data/clean/`:

- `patients_clean.csv`: group and sex tidied, age as numbers
- `penguins_clean.csv`: the row-number column removed, 8 columns
- `schools_clean.csv`: one `school_level` label per category, `zip_code` as text
- `schools_long.csv`: one row per school per grade, 868 rows

Running the project again replaces these files. Raw files are never touched.

## Git

The course used Git in Session 6. A quick version for this folder:

```bash
git status
git add main.R scripts/ README.md
git commit -m "Describe what you changed"
```

Commit the code. The files in `data/clean/` can be rebuilt by running `main.R`, so you do not need to commit them.

## Troubleshooting

| Message or symptom | Cause and fix |
|---|---|
| `cannot find data/raw/patients.csv` | The working directory is wrong. Set it to this folder. |
| A column called `...1` in penguins | The unnamed row-number column. `1_data_cleaning.R` drops it. |
| `NAs introduced by coercion` when converting age | Expected. It is the 6 `"unknown"` values becoming `NA`. |
| `read_csv` shows no `"A "` in `group` | `read_csv()` trims spaces by default. `main.R` sets `trim_ws = FALSE` so the problem stays visible. |
| `unexpected '>'` | Your R is older than 4.1 and does not know `|>`. Update R. |
| A package will not install | Check your internet connection, then run `install.packages("name")` yourself and read the error. |
