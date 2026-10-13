# Course datasets

Three files live in this folder. Every example in the course uses one of them,
so students see the same rectangles of data from week to week instead of a fresh
toy list each time.

| File | What it is | Used in |
|---|---|---|
| `patients.csv` | 250 synthetic patients with planted defects | Sessions 1 to 9 |
| `penguins.csv` | 344 Palmer Archipelago penguins | Sessions 7 to 12 |
| `schools_tibble.csv` | 169 Nashville schools, one column per grade | Sessions 7 and 8 |

The `analysis_R` and `analysis_python` folders next to `data/` each keep their own
copy of these three files in `data/raw/`. If you change a file here, copy it
there too.

---

# `patients.csv`

250 synthetic patients. Used from Session 1 onward.

**It is synthetic.** No real patients, no privacy concerns, safe to commit and
to distribute. Regenerate it with:

```bash
python data/make_patients.py
```

It is seeded, so it regenerates identically every time.

---

## Columns

| Column | Type it *should* be | Notes |
|---|---|---|
| `patient_id` | text | `P001`–`P250`. Leading zeros — looks numeric, isn't. |
| `age` | integer | **Loads as text.** See defects below. |
| `sex` | category | `F`/`M` — with inconsistent casing. |
| `group` | category | `A`/`B` — with a trailing-space variant. |
| `systolic` | float | mmHg. 9 missing. |
| `diastolic` | float | mmHg. 7 missing. |
| `cholesterol` | float | mg/dL. 22 missing. |
| `passed_qc` | boolean | `TRUE`/`FALSE`. |
| `visit_date` | date | ISO format. One impossible date. |

---

## The deliberate defects

Each one is planted for a specific session. They are all realistic — every one
of these is something that actually happens to research data.

| # | Defect | Surfaces in |
|---|---|---|
| 1 | 40 rows have `group` = `"A "` with a **trailing space** | **Session 1** (the flagship hook) |
| 2 | `age` contains `"unknown"` (6 rows) and one value with a leading space, so the whole column loads as text | Session 2 |
| 3 | `patient_id` has leading zeros — numeric-looking, not numeric | Session 2 |
| 4 | `sex` mixes `"F"`, `"f"`, `"M"`, `"m"` — grouping gives four groups | Session 3 |
| 5 | Missing values in three numeric columns | Session 6, Session 9 |
| 6 | One `visit_date` is `2026-02-30`, which does not exist | Session 6 |

### Defect 1 in detail — why it's the flagship

The 40 trailing-space rows are **not a random sample**. They represent a second
recruitment site whose patients genuinely run lower. So `df["group"] == "A"`
doesn't merely shrink group A — it removes group A's entire low tail.

| Analysis | Group A | Group B | p |
|---|---|---|---|
| Naive (`== "A"`) | 136.2 mmHg (n=81) | 134.2 (n=120) | **0.2152** — "no difference" |
| Correct (`.str.strip()`) | 129.4 mmHg (n=121) | 134.2 (n=120) | **0.0064** — real difference |

This is a **false negative** produced by silent data loss, which is the most
dangerous kind: a null result rarely gets a second look.

Two things make it excellent to teach:

- `df["group"].value_counts()` shows two rows both printed as `A` — **the display
  hides the space.** You need `.unique()` with `repr()`, or `.str.len()`, to see it.
- Group A's systolic distribution is visibly **bimodal**. A single histogram
  exposes this in two seconds, which is the argument for Session 9's whole
  premise: *look before you test.*

Run `python demos/01_the_hook.py` to see the full three-part reveal.

### Loading it in R and in pandas

The two languages treat this file differently, and the differences matter for the
defects above.

| What you load | pandas `pd.read_csv()` | R `read_csv()` (readr) | R `read.csv()` (base) |
|---|---|---|---|
| `group` trailing space | kept: `"A "` is its own group | **removed by default**, so the defect disappears | kept |
| `age` with `"unknown"` | text (`object`) | text (`character`) | text |
| `visit_date` | text | guessed as a date, and `2026-02-30` becomes `NA` with a parsing warning | text |

In R, `read_csv()` removes spaces at the start and end of text values unless you
set `trim_ws = FALSE`. Sessions 1 to 3 and 8 depend on the trailing space being
there, so load the file in R with:

```r
patients <- read_csv("patients.csv", trim_ws = FALSE)
```

Add `col_types = cols(visit_date = col_character())` if you also want the
impossible date to stay visible as text.

---

## Suggested use by session

| Session | Use it for |
|---|---|
| 1 | The hook demo — code that runs, reports nothing, and is wrong |
| 2 | `df.dtypes` / `str(df)`; the real `TypeError` from `df["age"].mean()` |
| 3 | A dataframe column *is* a vector; a row *is* a dict |
| 4 | `sum(df["systolic"] > 140)` vs the loop |
| 5 | Write `count_high()` and test it against the real column |
| 6 | Relative paths; check dtypes on load; what belongs in `.gitignore` |
| 7 | Spot the defects with the tidy-data lens: types, missing values, raw vs. cleaned files |
| 8 | Fix them: `str_trim` and `str_to_upper` in one `mutate()` (`.str.strip()` and `.str.upper()` in pandas), `as.numeric` for `age`, then join and reshape |
| 9 | The bimodal distribution that explains everything |
| 11 | The corrected t-test: group A 129.4 against group B 134.2, p = 0.0064 |

---

## A note on using it for the project

Students should use their **own** dataset for the project — this one exists so
that lecture examples are consistent and so you can plant bugs on purpose.
Do not let anyone submit an analysis of `patients.csv` as their project.

---

# `penguins.csv`

The Palmer Archipelago penguin data, used in Sessions 7 to 12. It is stored here
so that nobody has to install a package or reach the network during class.
344 penguins: Adelie 152, Gentoo 124, Chinstrap 68.

The file is an export of the R `palmerpenguins` data, so it matches the package.

| Column | Notes |
|---|---|
| (unnamed first column) | A row number written by R. pandas calls it `Unnamed: 0` and readr calls it `...1`. It carries no data. |
| `species`, `island` | Text. |
| `bill_length_mm`, `bill_depth_mm`, `flipper_length_mm`, `body_mass_g` | The four measurements. 2 penguins have no measurements at all. |
| `sex` | Lowercase `female` or `male`. 11 are missing. |
| `year` | The sampling year, 2007 to 2009. It is not a measurement. |

Shape: pandas reads the file as 344 rows by 9 columns. Drop the first column and
it is 344 by 8, the same shape as the R package. In Python, `penguins.iloc[:, 1:]`
drops it. In R, `select(-1)` does.

Keep `year` out of PCA, clustering and correlation matrices. Select the four
measurement columns by name instead of taking every numeric column.

The missing values are in the original data, not added for the course. They are
what Session 8's missing-value segment uses.

Source: Horst AM, Hill AP, Gorman KB (2020). *palmerpenguins: Palmer
Archipelago (Antarctica) penguin data.* Data collected by Dr. Kristen Gorman
at Palmer Station LTER. CC0.

---

# `schools_tibble.csv`

Enrollment for 169 Nashville schools in the 2018-19 school year, one row per
school and 35 columns. Students download it from Brightspace. It is the real
example of a wide, untidy table in Sessions 7 and 8.

Source: the original citation is not recorded in this folder. Add it before the
file is shared outside the course.

| Columns | Notes |
|---|---|
| `school_year`, `school_level`, `school_id`, `school_name`, `state_school_id`, `zip_code` | Identifiers. `zip_code` and the ids are labels, not numbers to average. `school_year` is `18-19` in every row, so it is a constant. |
| `grade_pre_k_3yrs` to `grade_12` | 15 columns of student counts. One variable (grade) is spread across the headers. |
| race and ethnicity columns, `male`, `female`, `economically_disadvantaged`, `disability`, `limited_english_proficiency` | More counts. `male` plus `female` is 86,527, the same total as the grade columns. |
| `latitude`, `longitude`, `mapped_location` | `mapped_location` stores the same coordinates as one text value, so one cell holds two values. |

## What it is used to teach

| # | Defect | Surfaces in |
|---|---|---|
| 1 | The grade columns are values of one variable. Made long, the file has 868 rows, not 169 × 15. | Sessions 7 and 8 (`pivot_longer`, `melt`) |
| 2 | `mapped_location` holds latitude and longitude in one cell. | Session 7 |
| 3 | `NA` in a grade column means the school does not offer that grade. All 31 middle schools have `NA` in `grade_9`, and 130 schools have `NA` in `grade_pre_k_3yrs`. Filling with 0 would be wrong. | Sessions 7 and 8 |
| 4 | `school_level` uses two labels for one category: `Non-Traditional` (5 schools) and `Non-Traditional - Hybrid` (2). | Sessions 7 and 8 |
