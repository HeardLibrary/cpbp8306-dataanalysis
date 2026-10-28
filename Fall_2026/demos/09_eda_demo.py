"""
Session 9 demo: Exploratory Data Analysis (Python)

Every code snippet from the Session 9 slides, in slide order. Each block says what
the code does and what you should see, so you can check your own output against
the comments. The slides show the R version first. This script uses the pandas and
seaborn version of each one.

It uses the same three datasets as Sessions 7 and 8: penguins, patients and
schools. Nothing is made up.

Put these three files next to this script, then run:  python 09_eda_demo.py
    penguins.csv         Brightspace
    patients.csv         Brightspace
    schools_tibble.csv   Brightspace

Plots are saved as PNG files in a folder called demo09_figures, so the script also
works from a terminal. To see a plot on screen instead, run the plotting line by
itself in VS Code or Jupyter and add plt.show().

Needs pandas, numpy, scipy, matplotlib and seaborn
(pip install pandas numpy scipy matplotlib seaborn). Slide 10 also mentions ydata-profiling,
which is optional (pip install ydata-profiling).
"""
import os

import matplotlib
matplotlib.use("Agg")                     # draw to files, so no window is needed
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from scipy import stats


def section(title):
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


os.makedirs("demo09_figures", exist_ok=True)


def save_plot(name):
    """Save the current figure as a PNG and close it."""
    path = os.path.join("demo09_figures", name + ".png")
    plt.tight_layout()
    plt.savefig(path, dpi=150)
    plt.close()
    print("saved", path)


# ---------------------------------------------------------------------------
# Slide 2: load the data
# ---------------------------------------------------------------------------
section("Slide 2: load the data")

df = pd.read_csv("penguins.csv")          # df is the penguins table in both languages
raw = pd.read_csv("patients.csv")         # pandas keeps the trailing space in "A "

# The Session 8 cleaning, in a few lines. errors="coerce" turns the six "unknown"
# ages into NaN.
patients = raw.copy()
patients["group"] = patients["group"].str.strip()
patients["sex"] = patients["sex"].str.upper()
patients["age"] = pd.to_numeric(patients["age"], errors="coerce")

print(patients.shape)                     # (250, 9)
print(df.shape)                           # (344, 9): 8 columns plus an unnamed row-number column
print(patients["group"].value_counts())   # A 125, B 125: the Session 8 cleaning worked

# pandas keeps visit_date as text. R reads it as a date and turns the impossible
# date 2026-02-30 into NA. We come back to this on slide 9.
print(patients["visit_date"].dtype)       # text: "str" in pandas 3, "object" in older versions


# ---------------------------------------------------------------------------
# Slide 4: the one-shot summary, read like a diagnostic
# ---------------------------------------------------------------------------
section("Slide 4: numerical summaries")

nums = patients[["age", "systolic", "diastolic", "cholesterol"]]

# describe() gives the count of values that are not missing, mean, standard
# deviation, minimum, quartiles and maximum.
print(nums.describe().round(2))
# age: count 244, mean 56.42, range 22 to 89
# systolic: count 241, mean 131.76, median 133.7, range 87.5 to 170.9
# diastolic: count 243, mean 81.55
# cholesterol: count 228, mean 195.4. 250 - 228 = 22 are missing, 8.8%.

# isna().sum() counts the missing values in every column.
print(patients.isna().sum())
# age 6, systolic 9, diastolic 7, cholesterol 22, visit_date 0

# describe(include="all") adds the text columns: count, unique values, top value.
print(patients.describe(include="all").shape)

# Questions to ask of any summary:
#   Is each mean plausible? Is each range possible? Is the median far from the mean?
#   How many values are missing?
# The median of systolic (133.7) is a little above the mean (131.8), a hint of a
# tail on the low side. We find out why on slide 7.
print(round(nums["systolic"].mean() - nums["systolic"].median(), 1))   # -1.9
print(round(nums["systolic"].skew(), 2))                               # -0.54

# For a categorical column, count the values and check the balance.
print(patients["group"].value_counts())   # A 125, B 125


# ---------------------------------------------------------------------------
# Slide 5: three plots you make every time you touch new data
# ---------------------------------------------------------------------------
section("Slide 5: histogram, box plot, scatter plot")

# Histogram: the shape of one variable. Look for two peaks, long tails, spikes.
# Penguin bill lengths have two clusters, a hint that another variable is mixed in.
sns.histplot(df, x="bill_length_mm", bins=30)
save_plot("05_histogram")

# Box plot: one variable across groups. Do the groups overlap? Any dots beyond
# the whiskers? Adelie sits lower. Gentoo has one dot above its whisker.
sns.boxplot(df, x="species", y="bill_length_mm")
save_plot("05_boxplot")

# Scatter plot: two variables, colored by group. Look at direction, curves,
# and whether the groups differ. Three clouds, one per species.
sns.scatterplot(df, x="bill_length_mm", y="body_mass_g", hue="species")
save_plot("05_scatter")


# ---------------------------------------------------------------------------
# Slide 6: Simpson's paradox
# ---------------------------------------------------------------------------
section("Slide 6: Simpson's paradox")

# Overall, deeper bills go with shorter bills. pandas skips missing values.
print(round(df["bill_length_mm"].corr(df["bill_depth_mm"]), 2))   # -0.24

# Inside each species, deeper bills go with longer bills.
for name, d in df.groupby("species"):
    print(name, round(d["bill_length_mm"].corr(d["bill_depth_mm"]), 2))
# Adelie 0.39, Chinstrap 0.65, Gentoo 0.64
# The species differ in both measurements, and that difference hides the pattern
# inside each one. Color by group before you trust a trend.

sns.regplot(df, x="bill_length_mm", y="bill_depth_mm", ci=None, scatter_kws={"s": 12})
save_plot("06_simpson_overall")
sns.lmplot(df, x="bill_length_mm", y="bill_depth_mm", hue="species", ci=None, height=3.6, aspect=1.6)
save_plot("06_simpson_by_species")


# ---------------------------------------------------------------------------
# Slide 7: the plot Session 1 was missing
# ---------------------------------------------------------------------------
section("Slide 7: the reveal")

# Group A systolic pressure, after the Session 8 cleaning.
a = patients[patients["group"] == "A"]
print(len(a))                         # 125 rows
print(a["systolic"].notna().sum())    # 121 with a recorded systolic value
sns.histplot(a, x="systolic", binwidth=5)
save_plot("07_group_a")
# Not one clean peak: there is a second bump on the low side, around 115 to 120.

# Why? Keep the original label in its own column BEFORE cleaning, then color by it.
# The 40 rows that read "A " are a second recruitment site.
a_site = raw[raw["group"].str.strip() == "A"].assign(
    site=lambda d: np.where(d["group"] == "A ", "second site", "first site"))
sns.histplot(a_site, x="systolic", hue="site", multiple="stack", binwidth=5)
save_plot("07_group_a_by_site")

print(a_site.groupby("site")["systolic"].agg(["count", "mean"]).round(1))
# first site: n 81, mean 136.2 / second site: n 40, mean 115.5

# The naive test from Lecture 1 kept only group == "A" (no trailing space).
# It quietly dropped the second site.
naive_a = raw.loc[raw["group"] == "A", "systolic"].dropna()
group_b = patients.loc[patients["group"] == "B", "systolic"].dropna()
print(round(stats.ttest_ind(naive_a, group_b).pvalue, 4))         # 0.2152, "no difference"
all_a = patients.loc[patients["group"] == "A", "systolic"].dropna()
print(round(stats.ttest_ind(all_a, group_b).pvalue, 4))           # 0.0064, a real difference
print(round(all_a.mean(), 1), round(group_b.mean(), 1))           # 129.4 134.2
# The silent data loss produced a false negative. One histogram, drawn before the
# test, would have shown two groups of patients mixed together.


# ---------------------------------------------------------------------------
# Slide 8: a correlation matrix, read half of it
# ---------------------------------------------------------------------------
section("Slide 8: correlation")

# Select the four measurements by name. Taking every numeric column would pull in
# year and the unnamed row-number column.
cols = ["bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"]
penguin_cor = df[cols].corr()
print(penguin_cor.round(2))
# The diagonal is 1 and the matrix is symmetric, so read one triangle.
# flipper_length_mm and body_mass_g: 0.87, the strongest pair.
# bill_depth_mm is negative with the other three (the Simpson's paradox again).

# Two predictors above 0.9 would be multicollinear. 0.87 is close enough to flag.
upper = penguin_cor.where(np.triu(np.ones(penguin_cor.shape, dtype=bool), k=1))
print(round(upper.max().max(), 2))                                # 0.87

sns.heatmap(penguin_cor, annot=True, cmap="RdBu_r", center=0)
save_plot("08_heatmap")

# A rank-based correlation is more robust to skew and outliers.
print(df[cols].corr(method="spearman").round(2))                  # flipper and body mass: 0.84

# The patients: systolic and diastolic move together. Cholesterol relates to nothing.
print(nums.corr().round(2))
# systolic and diastolic: 0.88 / cholesterol with the others: 0.03 to 0.04
# A real variable that is unrelated to the others is a legitimate finding.


# ---------------------------------------------------------------------------
# Slide 9: three problems, and what each one is called
# ---------------------------------------------------------------------------
section("Slide 9: missing values, outliers, impossible values")

# 1. Missing values: where, how many, and why?
print(patients.isna().mean().round(3).sort_values(ascending=False).head(4))
# cholesterol 0.088, systolic 0.036, diastolic 0.028, age 0.024
print(pd.crosstab(patients["group"], patients["cholesterol"].isna()))   # 11 missing in each group

# The schools file is different. A missing grade usually means "not offered".
schools = pd.read_csv("schools_tibble.csv")
grades = schools.filter(like="grade_")
print(int(grades.isna().sum().sum()))                  # 1667 empty cells out of 2535
print(int(schools["grade_pre_k_3yrs"].isna().sum()))   # 130
middle = schools[schools["school_level"] == "Middle School"]
print(int(middle["grade_9"].isna().sum()), len(middle))   # 31 of 31
# Filling these with 0 would be wrong. Leave them missing.

# 2. Outliers: a real extreme value, or an entry error? Use the box-plot rule:
# anything beyond 1.5 times the interquartile range from the quartiles.
s = patients["systolic"]
q1, q3 = s.quantile([.25, .75])
lo = q1 - 1.5 * (q3 - q1)
hi = q3 + 1.5 * (q3 - q1)
print(sorted(s[(s < lo) | (s > hi)]))
# 87.5 88.1 93.4 96.1 97.1 98.3 99.8 170.9: eight values beyond the whiskers
# Four of them are second-site patients (87.5, 88.1, 93.4, 97.1), so they are real.
# Never delete an outlier because the p-value would look better without it.
m = df["body_mass_g"]
mq1, mq3 = m.quantile([.25, .75])
print(int(((m < mq1 - 1.5 * (mq3 - mq1)) | (m > mq3 + 1.5 * (mq3 - mq1))).sum()))   # 0: no penguin outliers

# 3. Impossible values: could this value exist at all?
# pd.Timestamp("2026-02-30") raises an error, so it is a quick way to test one date.
try:
    pd.Timestamp("2026-02-30")
except ValueError as error:
    print("Timestamp error:", error)
# errors="coerce" turns every impossible date into NaT, so you can find the rows.
d = pd.to_datetime(patients["visit_date"], errors="coerce")
print(patients.loc[d.isna(), ["patient_id", "group", "visit_date"]])
# P094, group B, 2026-02-30. pandas kept the original text, so you can see it.
# No row has systolic below diastolic, another check for impossible values.
print(int((patients["systolic"] < patients["diastolic"]).sum()))   # 0

# The rule that matters most: write down what you decided and why. Every value you
# drop or fill in gets one sentence in your notebook.


# ---------------------------------------------------------------------------
# Slide 10: the whole first look in one call (R's DataExplorer, in pandas)
# ---------------------------------------------------------------------------
section("Slide 10: introduce, missing profile, bar charts")

# The slide shows R's DataExplorer package. Python has no single package that does
# the same, but a few lines of pandas give you its introduce() table.
def introduce(frame):
    """Rows, columns, text and number columns, and missing values, in one table."""
    numeric = frame.select_dtypes("number").shape[1]
    return pd.Series({
        "rows": len(frame),
        "columns": frame.shape[1],
        "discrete_columns": frame.shape[1] - numeric,
        "continuous_columns": numeric,
        "total_missing_values": int(frame.isna().sum().sum()),
        "complete_rows": int(frame.dropna().shape[0]),
        "total_observations": frame.size,
    })

print(introduce(patients))
# rows 250, columns 9, discrete 5, continuous 4, total_missing_values 44,
# complete_rows 208, total_observations 2250
# R reports 45 missing values, because read_csv() also turned the impossible
# visit_date into NA. pandas kept it as text. 208 of 250 rows (83.2%) are complete.

# The missing profile, the table behind DataExplorer's plot_missing(): the share of
# each column that is missing, drawn as bars.
missing = patients.isna().mean().sort_values()
print(missing.round(3))   # cholesterol 0.088 is the largest
missing.plot.barh(color="#1b9e77", figsize=(6, 4))
plt.xlabel("Share missing")
save_plot("09_de_missing")

# plot_bar() draws the counts of every text column. Run it on the RAW table, the one
# that still has the trailing space. It shows two bars labeled A (85 and 40 rows),
# plus four spellings of sex (M, F, m, f). The cleaned table has only A and B.
print(raw["group"].value_counts())   # B 125, A 85, "A " 40
print(raw["sex"].value_counts())     # M 119, F 112, m 10, f 9
fig, axes = plt.subplots(1, 2, figsize=(7, 3))
raw["group"].value_counts().plot.barh(ax=axes[0], color="#444444", title="group")
raw["sex"].value_counts().plot.barh(ax=axes[1], color="#444444", title="sex")
axes[0].set_yticklabels([repr(v) for v in raw["group"].value_counts().index])   # repr() shows 'A '
save_plot("09_de_bars_raw")

# plot_histogram() draws every numeric column. pandas does the same in one call.
patients.select_dtypes("number").hist(bins=30, figsize=(7, 5))
save_plot("09_de_histograms")

# DataExplorer's plot_correlation() turns grey when a column has missing values, unless
# you ask for pairwise.complete.obs. pandas' .corr() already skips missing values pair
# by pair, so this gotcha does not exist here.
print(patients[["age", "systolic", "diastolic", "cholesterol"]].corr().round(2))

# create_report() in R bundles all of this into one HTML file. In Python the closest
# tool is ydata-profiling. It is a heavier install, so this block is optional and runs
# only if the package is there.
try:
    from ydata_profiling import ProfileReport
    ProfileReport(patients.drop(columns=["patient_id", "visit_date"]), minimal=True).to_file(
        os.path.join("demo09_figures", "09_profile_report.html"))
    print("saved demo09_figures/09_profile_report.html. Open it in a browser.")
except ImportError:
    print("ydata-profiling is not installed. pip install ydata-profiling to try it.")
# Like DataExplorer, it draws the shape of every column and cannot say why a column
# looks odd. The second bump in group A (slide 7) is in the histograms, but nothing in
# the report says it is a second recruitment site.


# ---------------------------------------------------------------------------
# Try it yourself
# ---------------------------------------------------------------------------
# 1. Change binwidth=5 to binwidth=2 in the group A histogram. Does the second
#    bump get clearer or noisier?
# 2. Make the box plot for body_mass_g instead of bill_length_mm. Do the species overlap more?
# 3. Compute the Simpson's paradox correlations for bill_length_mm and flipper_length_mm.
#    Does the sign flip inside the species?
# 4. Call describe() on the schools grade_9 column. What does the count tell you?
# 5. Run introduce() on penguins. How many rows have no missing value?
