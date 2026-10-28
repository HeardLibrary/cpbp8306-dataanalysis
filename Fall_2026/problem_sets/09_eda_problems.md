# Problem Set 09: Exploratory Data Analysis

**Session:** 9 (Unit 2: Data Wrangling)
**Course data:** penguins (the `palmerpenguins` package in R, or `penguins.csv` in Python), `patients.csv`, and `schools_tibble.csv`, all on Brightspace
**Use with:** `general_tutor_gpt.md`
**Time target:** ~20–25 minutes, worked through with the tutor (Problem 6 is a short extra for anyone with time left)

---

## Instructions for students

Paste this whole file into the Course Tutor and work through the problems together, in order. These are the same three datasets as Sessions 7 and 8. This session comes back to the flagship Session 1 story and finally shows you the visual clue that was there all along.

Load the data first. Every problem below assumes these objects exist. `patients` is the Session 8 cleaning, and `raw` keeps the original `group` labels so you can still see the trailing space.

```r
library(dplyr); library(tidyr); library(readr); library(stringr)
library(palmerpenguins); library(ggplot2)
raw <- read_csv("patients.csv", trim_ws = FALSE)    # keep trailing spaces
patients <- raw %>%
  mutate(group = str_trim(group), sex = str_to_upper(sex), age = as.numeric(age))
schools <- read_csv("schools_tibble.csv")
df <- penguins                                      # 344 x 8, includes year
```

```python
import numpy as np, pandas as pd, seaborn as sns
df = pd.read_csv("penguins.csv")
# A CSV written from R has a row-number column that pandas calls "Unnamed: 0". It is harmless
# as long as you pick columns by name.
raw = pd.read_csv("patients.csv")
patients = raw.copy()
patients["group"] = patients["group"].str.strip()
patients["sex"] = patients["sex"].str.upper()
patients["age"] = pd.to_numeric(patients["age"], errors="coerce")
schools = pd.read_csv("schools_tibble.csv")
```

Two things to know about R. `read_csv()` reads `visit_date` as a date and turns the impossible date `2026-02-30` into `NA` with a warning, while pandas keeps it as text. And `as.numeric(age)` warns because six ages say `"unknown"`. Both are expected.

---

## Problems

1. **Summary sanity check.** Summarize the four penguin measurements and the patient numbers, then read the result like a diagnostic.

   ```r
   df %>% select(bill_length_mm:body_mass_g) %>% summary()
   patients %>% select(age, systolic, diastolic, cholesterol) %>% summary()
   colSums(is.na(patients))
   ```

   ```python
   cols = ["bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"]
   df[cols].describe()
   patients[["age", "systolic", "diastolic", "cholesterol"]].describe()
   patients.isna().sum()
   ```

   (a) Do the numeric ranges look plausible for a penguin (body mass in grams) and for a patient (blood pressure in mmHg)?
   (b) Which column has the most missing values, and what fraction is that? Would you still use the column?
   (c) Compare the mean and the median of `systolic`. Which one is larger, and what does that say about the tail of the distribution?

   ```r
   patients %>% summarise(mean = mean(systolic, na.rm = TRUE), median = median(systolic, na.rm = TRUE))
   ```

   ```python
   patients["systolic"].agg(["mean", "median", "skew"])
   ```

   (d) Now find the impossible value in `visit_date`. One date is `2026-02-30`. What is wrong with it, and is that a missing value, an outlier, or an impossible value? Which patient does it belong to?

   ```r
   raw %>% filter(is.na(visit_date)) %>% select(patient_id, group, visit_date)
   ```

   ```python
   d = pd.to_datetime(patients["visit_date"], errors="coerce")
   patients.loc[d.isna(), ["patient_id", "group", "visit_date"]]
   ```

   The R version shows `NA` because `read_csv()` already turned the bad date into a missing value. Read the column as text to see the original string: `read_csv("patients.csv", col_types = cols(visit_date = col_character()))`.

2. **The plot that explains Session 1.** Draw a histogram of `systolic` for group A, using your cleaned `group` column.

   ```r
   a <- patients %>% filter(group == "A")
   ggplot(a, aes(systolic)) + geom_histogram(binwidth = 5)
   ```

   ```python
   a = patients[patients.group == "A"]
   sns.histplot(a, x="systolic", binwidth=5)
   ```

   (a) Is it one clean peak, or is there a second bump? Where is it?
   (b) Now color the same histogram by the original label, using the `raw` table, so the patients whose group was `"A "` stand out. What does the second color show?

   ```r
   a2 <- raw %>%
     filter(str_trim(group) == "A") %>%
     mutate(site = if_else(group == "A ", "second site", "first site"))
   ggplot(a2, aes(systolic, fill = site)) + geom_histogram(binwidth = 5)
   ```

   ```python
   a2 = raw[raw.group.str.strip() == "A"].assign(
       site=lambda d: np.where(d.group == "A ", "second site", "first site"))
   sns.histplot(a2, x="systolic", hue="site", multiple="stack", binwidth=5)
   ```

   (c) Compute the mean `systolic` for each site. What did the Session 1 test do to the 40 `"A "` patients, and why did it return a false negative?

3. **Choose the plot.** For each question, which plot fits best: histogram, box plot, or scatter plot? Then draw one of them.

   (a) "What does the distribution of `bill_length_mm` look like?"
   (b) "Does `bill_length_mm` differ by `species`?"
   (c) "Is `bill_length_mm` related to `body_mass_g`?"

   ```r
   ggplot(df, aes(species, bill_length_mm)) + geom_boxplot()
   ```

   ```python
   sns.boxplot(df, x="species", y="bill_length_mm")
   ```

4. **Reading a correlation matrix.** Compute the correlation matrix for the four penguin measurements. Select them by name, so `year` stays out in R and the row-number column stays out in Python.

   ```r
   df %>% select(bill_length_mm:body_mass_g) %>% cor(use = "pairwise.complete.obs")
   ```

   ```python
   df[cols].corr()
   ```

   (a) Find the strongest pair. Is a correlation of 0.87 between two predictors something to just note, or something to flag before you put both in one model? Where would you draw the line?
   (b) `bill_length_mm` and `bill_depth_mm` have a negative correlation overall. Before you believe it, compute the same correlation inside each species. What do you find, and what is this called?

   ```r
   df %>% group_by(species) %>%
     summarise(r = cor(bill_length_mm, bill_depth_mm, use = "complete.obs"))
   ```

   ```python
   for name, d in df.groupby("species"):
       print(name, d.bill_length_mm.corr(d.bill_depth_mm))
   ```

   (c) Compute the correlation matrix for the four patient numbers, then the rank-based (Spearman) version for the penguins. Which patient pair moves together, and what does the near-zero correlation for `cholesterol` tell you? Does r near 0 prove two variables are unrelated?

   ```r
   patients %>% select(age, systolic, diastolic, cholesterol) %>% cor(use = "pairwise.complete.obs")
   df %>% select(bill_length_mm:body_mass_g) %>% cor(use = "pairwise.complete.obs", method = "spearman")
   ```

   ```python
   patients[["age", "systolic", "diastolic", "cholesterol"]].corr()
   df[cols].corr(method="spearman")
   ```

5. **Missing values and outliers: decide, don't delete.** Three problems from the lecture show up in these data.

   (a) The `schools` table has `NA` in many grade columns. Count the missing cells in the 15 `grade_*` columns, then count the `NA` in `grade_9` for the middle schools. What does an `NA` mean here, and would you fill it with 0?

   ```r
   schools %>% select(starts_with("grade_")) %>% is.na() %>% sum()
   schools %>% filter(school_level == "Middle School") %>% summarise(missing = sum(is.na(grade_9)), n = n())
   ```

   ```python
   schools.filter(like="grade_").isna().sum().sum()
   mid = schools[schools.school_level == "Middle School"]
   mid.grade_9.isna().sum(), len(mid)
   ```

   (b) Back in `patients`, `cholesterol` is missing for 22 patients. Count the missing values in each `group`. Does the pattern look like missing completely at random (MCAR), missing at random (MAR) or missing not at random (MNAR)? What else would you check before deciding?

   ```r
   table(patients$group, is.na(patients$cholesterol))
   ```

   ```python
   pd.crosstab(patients["group"], patients["cholesterol"].isna())
   ```

   (c) List the `systolic` values beyond the box-plot whiskers. Eight values appear. Four of the low ones belong to the second site you found in Problem 2. Are those outliers errors?

   ```r
   boxplot.stats(patients$systolic)$out
   ```

   ```python
   s = patients.systolic
   q1, q3 = s.quantile([.25, .75])
   s[(s < q1 - 1.5 * (q3 - q1)) | (s > q3 + 1.5 * (q3 - q1))]
   ```

   (d) True or false: "you should delete outliers if they are making your p-value less significant." Explain your answer, and say what you should write in your notebook for every value you drop or fill in.

6. **Let a package do the first look.** DataExplorer (R) draws most of the checks from Problems 1 to 5 in a few calls. In Python, the pandas lines below do the same job for the parts they cover. Install it once with `install.packages("DataExplorer")`.

   ```r
   library(DataExplorer)
   introduce(patients)
   plot_missing(patients)
   plot_bar(raw %>% select(group, sex))
   nums <- patients %>% select(age, systolic, diastolic, cholesterol)
   plot_correlation(nums)
   plot_correlation(nums, cor_args = list(use = "pairwise.complete.obs"))
   create_report(patients %>% select(-patient_id, -visit_date), y = "group")
   ```

   ```python
   n = patients.select_dtypes("number").shape[1]
   print(len(patients), patients.shape[1], patients.shape[1] - n, n, patients.dropna().shape[0])
   patients.isna().mean().sort_values()
   raw["group"].value_counts()
   raw["sex"].value_counts()
   patients[["age", "systolic", "diastolic", "cholesterol"]].corr()
   ```

   (a) What does `introduce(patients)` tell you in one row? How many columns are text and how many are numbers, and what share of rows have no missing value at all?
   (b) Run `plot_bar()` on the raw table (the one read with `trim_ws = FALSE`). What do you see in `group` and in `sex`? Would the same chart on the cleaned `patients` table show it?
   (c) Run `plot_correlation()` with the defaults, then with `cor_args = list(use = "pairwise.complete.obs")`. Why is the first one mostly grey?
   (d) Open the HTML report. Name its sections, and find the one that matches each of Problems 1 to 5. Then find the second bump in group A. Does the report explain it?

---

## Coverage (for instructor reference)

| # | Slides | Concept |
|---|--------|---------|
| 1 | 4 and 9 | Numerical summaries read as a diagnostic; missing counts; mean against median (skew); the impossible value |
| 2 | 7 | The second bump in group A, the Session 1 story resolved visually; keep the raw label before you clean |
| 3 | 5 | Choosing histogram vs. box plot vs. scatter for exploration |
| 4 | 6 and 8 | Reading a correlation matrix, multicollinearity, Simpson's paradox, Spearman, what r near 0 means |
| 5 | 9 | Structural missingness, MCAR/MAR/MNAR, outliers that are real, and the rule against cherry-picking |
| 6 | 10 | DataExplorer: the one-call first look, the raw-file bar chart, the `plot_correlation()` default, and what a report cannot explain |

### Verified facts about the data (for the tutor; do not invent others)

- **Patients:** 250 rows after cleaning, `group` A 125 and B 125. Missing counts: `age` 6, `systolic` 9, `diastolic` 7, `cholesterol` 22 (8.8%, the largest). Means: `age` 56.4, `systolic` 131.8, `diastolic` 81.6, `cholesterol` 195.4. `systolic` runs from 87.5 to 170.9, with a median of 133.7 and a skew of -0.54. No row has `systolic` below `diastolic`.
- **Problem 1:** (c) the mean (131.8) is below the median (133.7), so the tail is longer on the low side. Problem 2 shows where that tail comes from. (d) the impossible date is `2026-02-30`, patient P094, group B. In R, `read_csv()` has already turned it into `NA`, so `colSums(is.na(patients))` shows 1 missing `visit_date`; pandas keeps the text, so `isna().sum()` shows 0 until you convert with `errors="coerce"`. `as.Date("2026-02-30")` on its own is an error in R. It is an impossible value, because the date can never exist, and the fix is to trace it upstream and not to filter it out.
- **Problem 2:** group A has 125 rows, 121 with a recorded `systolic`. The first site (`"A"`) has 81 patients with mean 136.2. The second site (`"A "`) has 40 with mean 115.5. The naive test from Session 1 dropped the 40, giving group A 136.2 (n = 81) against group B 134.2 (n = 120), p = 0.2152. With them restored, group A is 129.4 (n = 121), p = 0.0064.
- **Problem 3:** (a) histogram, (b) box plot, (c) scatter plot.
- **Problem 4:** the four penguin measurements have 342 complete rows. The strongest pair is `flipper_length_mm` and `body_mass_g` at 0.87. The lecture's rule of thumb is to look twice beyond about 0.7 and to keep two predictors above 0.9 out of one regression, so 0.87 is worth flagging. `bill_length_mm` and `bill_depth_mm` are -0.24 overall and +0.39 (Adelie), +0.65 (Chinstrap) and +0.64 (Gentoo) within species. That reversal is Simpson's paradox. (c) Patients: `systolic` and `diastolic` are at 0.88, and `cholesterol` is 0.03 to 0.04 with everything else. A real variable that is not related to the others is a legitimate finding. Pearson's r only sees straight-line association, so r near 0 does not prove there is no relationship (plot it). Spearman for flipper and body mass is 0.84, close to the Pearson 0.87.
- **Problem 5:** (a) the schools file has 1,667 empty cells out of 2,535 in the 15 `grade_*` columns. All 31 middle schools have `NA` in `grade_9`. The `NA` means the school does not offer that grade, so 0 would be wrong. (b) `cholesterol` is missing for 11 patients in each group, so nothing obvious points to a pattern, which is consistent with MCAR. MCAR cannot be proven from the data. Check whether the missing rows differ on age, sex or site, and ask whether a patient might skip the test because of what it would show (MNAR). (c) `systolic` has 8 values beyond the whiskers (87.5, 88.1, 93.4, 96.1, 97.1, 98.3, 99.8, 170.9), and 4 of them are second-site patients, so they are real. The penguin measurements have no points beyond the whiskers. (d) False. Deleting values to improve a p-value is a research-integrity problem. Every value you drop or fill in gets one sentence in the notebook saying why.
- **Problem 6:** (a) `introduce(patients)` gives 250 rows, 9 columns, 5 discrete (text) and 4 continuous (numeric) columns, 44 missing numbers (`age` 6, `systolic` 9, `diastolic` 7, `cholesterol` 22), and 208 complete rows, which is 83.2%. R also counts the impossible `visit_date` as missing and reports 45. pandas keeps `visit_date` as text and reports 44. (b) On the raw table `group` has three bars, "A" (85), "A " (40) and "B" (125), and `sex` has four, M 119, F 112, m 10 and f 9. On the cleaned table `group` has only A and B and `sex` only M and F, so the problem has already been fixed and the chart cannot show it. (c) By default `plot_correlation()` uses every row, so any pair that includes a column with an `NA` is `NA` and draws grey. Only the diagonal is colored. With `use = "pairwise.complete.obs"` each pair uses the rows it has, and the matrix matches Problem 4(c). (d) The report has seven sections: basic statistics, data structure, missing data profile, univariate distributions, correlation analysis, principal component analysis and bivariate distributions. They match Problem 1 (basic statistics), 5 (missing data profile), 3 (univariate and bivariate plots) and 4 (correlation analysis). The group A histograms are in the univariate section, with the second bump visible, but nothing in the report says it is a second recruitment site. That connection comes from knowing the data. `patient_id` and `visit_date` are skipped in the bar charts because they have more than 50 distinct values. Python has no single equivalent, and ydata-profiling is the closest (optional).
