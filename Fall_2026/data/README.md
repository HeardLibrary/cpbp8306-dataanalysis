# The course teaching dataset — `patients.csv`

250 synthetic patients. Used from Session 1 onward so that every example in the
course refers to the *same* rectangle of data instead of a fresh toy list each
week.

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
| 7–8 | Cleaning it properly: strip, recode, coerce, handle missing |
| 9 | The bimodal distribution that explains everything |

---

## A note on using it for the project

Students should use their **own** dataset for the project — this one exists so
that lecture examples are consistent and so you can plant bugs on purpose.
Do not let anyone submit an analysis of `patients.csv` as their project.

---

# `penguins.csv`

The Palmer Archipelago penguin data, referenced throughout Sessions 7–12.
Vendored into the repo so that nobody has to install a package or hit the
network mid-class. 344 rows.

Columns: `species`, `island`, `bill_length_mm`, `bill_depth_mm`,
`flipper_length_mm`, `body_mass_g`, `sex`. There are genuine missing values
(2 rows missing all measurements, 11 missing `sex`) — that's in the original
data, not something added, and it makes the file useful for Session 8's
missing-value segment.

> **One discrepancy to know about.** `lectures/07_dataframes_tidy.md` says
> `df.shape` gives `(344, 8)`. That's true of the R `palmerpenguins` package,
> which includes a `year` column. **This vendored copy has 7 columns** — it comes
> from the seaborn distribution, which drops `year`. Either update the lecture to
> say `(344, 7)`, or add a `year` column if you want the R package's shape. The
> row count is the same either way.

Source: Horst AM, Hill AP, Gorman KB (2020). *palmerpenguins: Palmer
Archipelago (Antarctica) penguin data.* Data collected by Dr. Kristen Gorman
at Palmer Station LTER. CC0.
