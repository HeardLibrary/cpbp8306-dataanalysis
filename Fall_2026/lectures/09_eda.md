# Session 9 — Exploratory Data Analysis

**Unit:** 2 (Data Wrangling)
**Duration:** 30-minute lecture + 20-minute activity
**Companion tutor:** `assistants_per_lecture/09_eda_gpt.md`

---

## Framing

Before you run a statistical test on data, you have to *look at the data.* Not once, not glancingly — really look. Where are the extreme values? Are the distributions plausible? Which cells are missing? Is there a group with only two members? This session gives you the vocabulary of that first look. Skipping EDA is the fastest way to publish a paper with a preventable error, and it is the thing AI can least do for you — because it has never seen your data.

---

## Learning objectives

Students should be able to:

1. Produce a numerical summary of each variable in a dataset.
2. Plot a histogram, a box plot, and a scatter plot for exploration purposes.
3. Compute a correlation matrix and read it.
4. Detect three classes of data problem: missingness, outliers, and impossible values.
5. Recognize when EDA has revealed that the "test" they were about to run is not appropriate.

---

## 30-minute outline

| Time     | Segment                                                    |
|----------|------------------------------------------------------------|
| 0–3      | Recap: wrangling verbs                                     |
| 3–10     | Numerical summaries — the first pass                       |
| 10–18    | Visual EDA — histogram, box, scatter                       |
| 18–24    | Correlation and correlation plots                          |
| 24–30    | The three data problems + what to do                       |

---

## Segment 1 (0–3 min): Recap

Ask: name split-apply-combine in one sentence. Now cover the same tools we saw in Session 8, but pointed at *understanding* rather than *transforming*.

---

## Segment 2 (3–10 min): Numerical summaries

The one-shot summary:

```python
df.describe()          # numeric columns only
df.describe(include="all")   # everything
```

```r
summary(df)
library(skimr)
skim(df)               # much richer than summary()
library(psych)
describe(df)           # another good one
```

Read the summary carefully. For each numeric column, ask:

- **Is the mean plausible?** Blood pressure of 25 is impossible.
- **Is the range plausible?** Age from -1 to 300 means someone encoded "unknown" as -1.
- **Is the median very different from the mean?** → skewed distribution → mean may not be the right summary.
- **How many missing values?** If a column is 90% missing, you probably cannot use it.

For each categorical column, ask:

- How many unique values? If a "sex" column has 47 unique strings, someone typed it in freeform.
- Is there class imbalance? If your "treated" group has 3 patients and your "control" has 300, no test will save you.

`skimr::skim()` in R is worth showing on screen — it renders types + missingness + histograms in one call. `pandas-profiling` / `ydata-profiling` in Python is the equivalent, though heavier.

---

## Segment 3 (10–18 min): Visual EDA

Three plots you will make every time you touch a new dataset. This is a preview of Session 10's grammar-of-graphics; we're using it here as a diagnostic tool.

**Histogram** — the shape of one numeric variable:

```r
library(ggplot2)
ggplot(df, aes(x = bill_length_mm)) + geom_histogram(bins = 30)
```

```python
import seaborn as sns
sns.histplot(df, x="bill_length_mm", bins=30)
```

Look for:
- Bimodality (two peaks → maybe two subgroups mixed together).
- Extreme tails.
- A wall of zeros or a spike at a specific value (often a coding artifact).

**Box plot** — one numeric variable across groups:

```r
ggplot(df, aes(x = species, y = bill_length_mm)) + geom_boxplot()
```

```python
sns.boxplot(df, x="species", y="bill_length_mm")
```

Look for:
- Do the groups overlap? (If yes, a t-test comparing means may not find a difference even if the medians differ.)
- Outliers (dots outside the whiskers).
- Very different variances between groups.

**Scatter plot** — the relationship between two numeric variables:

```r
ggplot(df, aes(x = bill_length_mm, y = body_mass_g, color = species)) + geom_point()
```

```python
sns.scatterplot(df, x="bill_length_mm", y="body_mass_g", hue="species")
```

Look for:
- Overall direction (positive, negative, none).
- Whether the relationship is linear (or curved — Session 11 assumes linear).
- Whether groups have different relationships (Simpson's paradox lives here).

**Simpson's paradox** deserves 30 seconds of airtime. It's the phenomenon where the overall trend disappears or reverses when you condition on a group. Color by group and *look*.

---

## Segment 4 (18–24 min): Correlation

Correlation matrix — one number per pair of variables, between -1 and +1:

```r
library(dplyr)
df |> select(where(is.numeric)) |> cor(use = "pairwise.complete.obs")
```

```python
df.select_dtypes("number").corr()
```

Prettified as a heatmap:

```r
library(corrplot)
df |> select(where(is.numeric)) |> cor(use = "pairwise") |> corrplot()
```

```python
import seaborn as sns
sns.heatmap(df.select_dtypes("number").corr(), annot=True, cmap="RdBu_r", center=0)
```

Read it carefully:
- **Diagonal is always 1.** Ignore.
- **Symmetric.** You only need to look at half.
- **|r| > 0.7** — strong relationship, worth investigating.
- **Two predictors with r > 0.95** — multicollinearity; you probably shouldn't put both in a regression (foreshadow Session 12).
- Correlation ≠ causation. Say it every time.

Caveats:
- Pearson's correlation assumes linearity. A U-shaped relationship has correlation ≈ 0 but is not "no relationship."
- Spearman correlation (rank-based) is more robust; use it when data is not normally distributed.

---

## Segment 5 (24–30 min): The three data problems

**1. Missingness.** Where and how much?

```r
library(naniar)
vis_miss(df)             # visualize missingness patterns
```

```python
df.isna().mean().sort_values(ascending=False)  # fraction missing per column
```

Ask: is it *missing completely at random* (MCAR — nothing is systematic), *missing at random* (MAR — related to another observed variable), or *missing not at random* (MNAR — related to the missing value itself, e.g., patients drop out because their treatment failed)? MNAR is a problem no imputation can fix.

**2. Outliers.**

Look at histograms and box plots. Ask, for each apparent outlier:
- Is it a data-entry error (age = 999)? Fix or drop.
- Is it a real extreme observation? Keep. Consider a robust statistic (median vs mean) or a transformation (log).
- Never delete outliers because "the p-value would be prettier without them."

**3. Impossible values.**

Negative concentrations. Ages of 300. Percentages > 100. Systolic BP less than diastolic. These are always errors somewhere upstream — go find them, don't just filter them out.

Final rule: **write down what you decided and why.** Every outlier you drop, every imputation you make, gets a line in your notebook explaining the reasoning. This is the difference between analysis and hand-waving. Your future self and your reviewers will thank you.

---

## Key vocabulary

- **EDA** — exploratory data analysis; the first look.
- **Distribution** — how a variable's values are spread.
- **Skew** — asymmetry in a distribution.
- **Outlier** — a value far from the rest.
- **Correlation** — a number between -1 and 1 summarizing linear association.
- **Missingness pattern** — where NAs occur (random vs. systematic).
- **Simpson's paradox** — a trend that reverses when you condition on a subgroup.

---

## Common student mistakes

- Running a t-test before ever plotting the data. You don't know if the assumption of normality holds.
- Silently `dropna()` at the top of a script. What if 60% of your data was missing?
- Reading a correlation matrix as if r = 0.2 is "no correlation." With n = 10,000 that's a real effect.
- Deleting outliers to improve p-values. This is a research integrity issue.

---

## Handoff to tutor activity

`assistants_per_lecture/09_eda_gpt.md` — the tutor gives students a dataset with three planted problems and asks them to find each one.

---

## Milestone

By the end of Session 9, students should have **cleaned their project dataset**. Post the cleaning script + a `data/processed/` file on their GitHub. Due before Session 10.
