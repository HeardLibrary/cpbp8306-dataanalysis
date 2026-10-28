# =============================================================================
# 2_statistics.py  |  Sessions 9 to 12   (Session 9 is code, the rest is a plan)
# =============================================================================
# Part 1 loads the cleaned data and Part 2 is Session 9, exploratory data
# analysis, with working code. Parts 3 to 7 are comments that say what the code
# will do, which cleaned file it reads, and which session it comes from. Code is
# added as the course reaches each session.
#
# Input: the files that 1_data_cleaning.py saved in data/clean/. This script
# never reads data/raw/. The one exception is patients_raw, which main.py already
# loaded: Part 2 needs the original group labels, and the cleaned file has lost
# them. Run main.py first so everything exists.
# Output: figures go in figures/, and tables you want to keep go in data/clean/.
#
# Contents
#   Part 1  Load the cleaned data
#   Part 2  Exploratory data analysis    (Session 9)
#             2a  Numerical summaries
#             2b  Three plots: histogram, box plot, scatter
#             2c  Simpson's paradox
#             2d  The plot Session 1 was missing
#             2e  Correlation
#             2f  Three data problems: missing values, outliers, impossible values
#             2g  The whole first look in one call: introduce(), bars (DataExplorer's job)
#   Part 3  Figures                      (Session 10, plan)
#   Part 4  Univariate tests             (Session 11, plan)
#   Part 5  Regression                   (Session 11, plan)
#   Part 6  Multivariate and ML          (Session 12, plan)
#   Part 7  Save results
#
# Needs these objects from main.py: patients_raw, and the imports np, pd, sns,
# plt and stats.
# =============================================================================
import os

try:
    patients_raw
except NameError:
    raise SystemExit("Run main.py first. It loads the data this script uses.")


# Helpers -------------------------------------------------------------------
def section(title):
    """A heading for the printed output."""
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def save_plot(name):
    """Save the current figure in figures/ as a PNG, close it, and say where it went."""
    os.makedirs("figures", exist_ok=True)
    path = os.path.join("figures", name + ".png")
    plt.tight_layout()
    plt.savefig(path, dpi=150)
    plt.close()
    print("saved", path)


# -----------------------------------------------------------------------------
# Part 1: Load the cleaned data
# -----------------------------------------------------------------------------
section("Part 1: load the cleaned data")

# pd.read_csv() reads each cleaned file that 1_data_cleaning.py wrote. Raw files
# are never touched here. pandas keeps visit_date as text, so the impossible date
# 2026-02-30 stays visible for Part 2f.
patients = pd.read_csv("data/clean/patients_clean.csv")
penguins = pd.read_csv("data/clean/penguins_clean.csv")
schools = pd.read_csv("data/clean/schools_clean.csv")

# .info() shows each column's type and how many values are not missing.
patients.info()
print("patients:", len(patients), "rows. penguins:", len(penguins), "rows. schools:", len(schools), "rows.")
print(patients["group"].value_counts())   # A 125, B 125: the Session 8 cleaning worked

# schools_long.csv (one row per school per grade) is read here too when a plot
# needs it:
#   schools_long = pd.read_csv("data/clean/schools_long.csv")


# -----------------------------------------------------------------------------
# Part 2: Exploratory data analysis  (Session 9)
# -----------------------------------------------------------------------------
# Look before you test. Part 2 turns the cleaned data into numbers, then plots,
# then a short list of problems to hunt for. Each step says what to look for.

# --- 2a. Numerical summaries -------------------------------------------------
section("2a: numerical summaries")

nums = patients[["age", "systolic", "diastolic", "cholesterol"]]

# describe() gives the count of values that are not missing, mean, standard
# deviation, minimum, quartiles and maximum.
print(nums.describe().round(2))
# age: count 244, mean 56.42, range 22 to 89
# systolic: count 241, mean 131.76, median 133.7, range 87.5 to 170.9
# diastolic: count 243, mean 81.55
# cholesterol: count 228, mean 195.4

# Read the summary like a diagnostic. Is each mean plausible? Is each range
# possible? Is the median far from the mean, a sign of skew? How many values are
# missing? isna().mean() gives the fraction missing in each column.
print(nums.isna().mean().round(3))   # age 0.024, systolic 0.036, diastolic 0.028, cholesterol 0.088

# Is the median far from the mean? A mean below the median means a longer tail on
# the low side. Systolic has one (skew -0.54). Part 2d shows why.
print(round(nums["systolic"].mean() - nums["systolic"].median(), 1))   # -1.9
print(round(nums["systolic"].skew(), 2))                               # -0.54

# For a categorical column, count the values and check the balance.
print(patients["group"].value_counts())   # A 125, B 125
print(patients["sex"].value_counts())     # M 129, F 121

# The same summary split by group. count() skips missing values, so it is the n of
# rows that have a value. This is the pandas version of the Fall 2025
# group_by() + summarise() pattern.
print(patients.groupby("group")["systolic"].agg(["count", "mean", "median", "std"]).round(1))
# A: n 121, mean 129.4, median 132.2, sd 15.1 / B: n 120, mean 134.2, median 135.4, sd 11.9
# Group A has the lower mean and the wider spread. Part 2d shows why.

# describe(include="all") adds the text columns: how many distinct values, the
# most common one and how often it appears. It is the quick check for a column
# typed by hand.
print(patients[["group", "sex"]].describe(include="all"))

# Part 2g has a one-call overview, the pandas version of R's DataExplorer.

# --- 2b. Three plots you make every time you touch new data -------------------
section("2b: histogram, box plot, scatter plot")

# pandas draws a quick plot straight from a column, handy for a first look. The
# seaborn versions below are the ones saved to figures/. Session 10 builds them.
#   penguins["bill_length_mm"].plot.hist()
#   penguins.boxplot(column="bill_length_mm", by="species")
#   penguins.plot.scatter(x="bill_length_mm", y="body_mass_g")

# Histogram: the shape of one variable. Look for two peaks, long tails and
# spikes. Penguin bill lengths have two clusters, a hint that another variable is
# mixed in.
sns.histplot(penguins, x="bill_length_mm", bins=30)
save_plot("09_histogram_bill_length")

# Box plot: one variable across groups. Do the groups overlap? Are there dots
# beyond the whiskers? Adelie sits lower. Gentoo has one dot above its whisker.
sns.boxplot(penguins, x="species", y="bill_length_mm")
save_plot("09_boxplot_bill_length_by_species")

# Scatter plot: two variables, colored by group. Look at the direction, at
# curves, and at whether the groups differ. There are three clouds, one per species.
sns.scatterplot(penguins, x="bill_length_mm", y="body_mass_g", hue="species")
save_plot("09_scatter_mass_vs_bill_length")

# --- 2c. Simpson's paradox ----------------------------------------------------
section("2c: Simpson's paradox")

# Overall, deeper bills go with shorter bills. pandas skips missing values.
print(round(penguins["bill_length_mm"].corr(penguins["bill_depth_mm"]), 2))   # -0.24

# Inside each species, deeper bills go with longer bills. The species differ in
# both measurements, and that difference hides the pattern inside each one.
for name, d in penguins.groupby("species"):
    print(name, round(d["bill_length_mm"].corr(d["bill_depth_mm"]), 2))
# Adelie 0.39, Chinstrap 0.65, Gentoo 0.64
# The habit to build: color a scatter plot by every grouping variable you have
# before you believe the overall trend.
sns.regplot(penguins, x="bill_length_mm", y="bill_depth_mm", ci=None, scatter_kws={"s": 12})
save_plot("09_simpson_overall")
sns.lmplot(penguins, x="bill_length_mm", y="bill_depth_mm", hue="species", ci=None, height=3.6, aspect=1.6)
save_plot("09_simpson_by_species")

# --- 2d. The plot Session 1 was missing --------------------------------------
section("2d: group A systolic pressure")

# Group A after the Session 8 cleaning: 125 rows, 121 with a systolic value.
group_a = patients[patients["group"] == "A"]
print(len(group_a), "rows,", group_a["systolic"].notna().sum(), "with a systolic value")
sns.histplot(group_a, x="systolic", binwidth=5)
save_plot("09_group_a_systolic")
# Not one clean peak. There is a second bump on the low side, around 115 to 120.

# Why? The cleaned file has lost the original label, so go back to patients_raw,
# which main.py loaded without stripping. The 40 rows that read "A " are a second
# recruitment site. Lesson: keep the raw value in its own column BEFORE you clean
# it, or you cannot color by it later.
group_a_site = patients_raw[patients_raw["group"].str.strip() == "A"].assign(
    site=lambda d: np.where(d["group"] == "A ", "second site", "first site"))
sns.histplot(group_a_site, x="systolic", hue="site", multiple="stack", binwidth=5)
save_plot("09_group_a_by_site")
print(group_a_site.groupby("site")["systolic"].agg(["count", "mean"]).round(1))
# first site: n 81, mean 136.2 / second site: n 40, mean 115.5

# The test from Lecture 1 kept only group == "A" (no trailing space), so it
# quietly dropped the second site. With all of group A back in, the result changes.
naive_a = patients_raw.loc[patients_raw["group"] == "A", "systolic"].dropna()
all_a = group_a["systolic"].dropna()
group_b = patients.loc[patients["group"] == "B", "systolic"].dropna()
print(round(stats.ttest_ind(naive_a, group_b).pvalue, 4))   # 0.2152, "no difference"
print(round(stats.ttest_ind(all_a, group_b).pvalue, 4))     # 0.0064, a real difference
print(round(all_a.mean(), 1), round(group_b.mean(), 1))     # 129.4 134.2
# The silent data loss produced a false negative. One histogram, drawn before the
# test, would have shown two groups of patients mixed together. Session 11 comes
# back to this test.

# --- 2e. Correlation ---------------------------------------------------------
section("2e: correlation")

# Select the four measurements by name. Taking every numeric column would pull in
# year.
cols = ["bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"]
penguin_cor = penguins[cols].corr()
print(penguin_cor.round(2))
# The diagonal is 1 and the matrix is symmetric, so read one triangle.
# flipper_length_mm and body_mass_g: 0.87, the strongest pair.
# bill_depth_mm is negative with the other three, the Simpson's paradox again.
# Two predictors above 0.9 would be multicollinear (Session 12). 0.87 is close
# enough to flag.
sns.heatmap(penguin_cor, annot=True, cmap="RdBu_r", center=0)
save_plot("09_correlation_heatmap")

# Pearson's r only sees straight-line association. A rank-based correlation is
# more robust to skew and outliers.
print(penguins[cols].corr(method="spearman").round(2))   # flipper and body mass: 0.84

# The patients: systolic and diastolic move together. Cholesterol relates to
# nothing, which is a legitimate finding. Correlation is not causation.
print(nums.corr().round(2))
# systolic and diastolic: 0.88 / cholesterol with the others: 0.03 to 0.04

# --- 2f. Three data problems -------------------------------------------------
section("2f: missing values, outliers, impossible values")

# 1. Missing values: where, how many, and why?
print(patients.isna().sum())
# age 6, systolic 9, diastolic 7, cholesterol 22, visit_date 0 (it is text)
print(pd.crosstab(patients["group"], patients["cholesterol"].isna()))   # 11 missing in each group

# The schools file is different. A missing grade usually means "not offered".
grades = schools.filter(like="grade_")
print(int(grades.isna().sum().sum()), "empty cells out of", grades.size)   # 1667 out of 2535
middle = schools[schools["school_level"] == "Middle School"]
print(int(middle["grade_9"].isna().sum()), "of", len(middle), "middle schools have no grade 9")   # 31 of 31
# Filling these with 0 would be wrong. Leave them missing. Three kinds of missing
# exist: completely at random, at random given another column, and not at random.
# Nothing fixes the last kind.

# 2. Outliers: a real extreme value, or an entry error? Use the box-plot rule:
# anything beyond 1.5 times the interquartile range from the quartiles.
s = patients["systolic"]
q1, q3 = s.quantile([.25, .75])
lo = q1 - 1.5 * (q3 - q1)
hi = q3 + 1.5 * (q3 - q1)
print(sorted(s[(s < lo) | (s > hi)]))
# 87.5 88.1 93.4 96.1 97.1 98.3 99.8 170.9: eight values beyond the whiskers
# Four of them are second-site patients (87.5, 88.1, 93.4, 97.1), so they are
# real. Never delete an outlier because the p-value would look better without it.
m = penguins["body_mass_g"]
mq1, mq3 = m.quantile([.25, .75])
print(int(((m < mq1 - 1.5 * (mq3 - mq1)) | (m > mq3 + 1.5 * (mq3 - mq1))).sum()))   # 0: no penguin outliers

# 3. Impossible values: could this value exist at all?
# errors="coerce" turns every impossible date into NaT, so you can find the rows.
d = pd.to_datetime(patients["visit_date"], errors="coerce")
print(patients.loc[d.isna(), ["patient_id", "group", "visit_date"]])
# P094, group B, 2026-02-30. Find it, then trace it upstream. Do not just filter it out.
# No row has systolic below diastolic, another check for impossible values.
print(int((patients["systolic"] < patients["diastolic"]).sum()))   # 0

# The rule that matters most: write down what you decided and why. Every value
# you drop or fill in gets one sentence. This is an example log for these data:
#   - Kept the 8 systolic values beyond the whiskers. Four belong to the second
#     site and the rest look like real extremes.
#   - Left the NaN in the schools grade columns. A grade that is not offered is
#     not a zero.
#   - Kept cholesterol as it is (8.8% missing, 11 in each group). Any analysis
#     that uses it drops those rows and says so.
#   - visit_date for P094 is impossible. Leave the row in, but exclude it from
#     anything that uses visit_date, and ask the data owner what the date was.


# --- 2g. The whole first look in one call -------------------------------------
section("2g: the whole first look in one call")

# In R, the DataExplorer package does this in a few calls (Fall 2025 used it as the
# quick first look). Python has no single package that does the same, so these
# are the pandas versions of its introduce(), plot_missing(), plot_bar() and
# plot_histogram().
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
# complete_rows 208 (83.2%), total_observations 2250
# R counts 45 missing, because read_csv() also turns the impossible visit_date into
# NA. pandas keeps it as text, so it counts 44.

# The missing profile, drawn as bars (plot_missing() in R): cholesterol is the largest.
patients.isna().mean().sort_values().plot.barh(color="#1b9e77", figsize=(6, 4))
plt.xlabel("Share missing")
save_plot("09_de_missing")

# plot_bar() on the RAW table is the check that would have caught Session 1. It shows
# two bars labeled A (85 and 40 rows), and four spellings of sex (M, F, m, f).
print(patients_raw["group"].value_counts())   # B 125, A 85, "A " 40
fig, axes = plt.subplots(1, 2, figsize=(7, 3))
patients_raw["group"].value_counts().plot.barh(ax=axes[0], color="#444444", title="group")
patients_raw["sex"].value_counts().plot.barh(ax=axes[1], color="#444444", title="sex")
axes[0].set_yticklabels([repr(v) for v in patients_raw["group"].value_counts().index])   # repr() shows 'A '
save_plot("09_de_bars_raw")

# plot_histogram() draws every numeric column. So does pandas.
patients.select_dtypes("number").hist(bins=30, figsize=(7, 5))
save_plot("09_de_histograms")

# DataExplorer's plot_correlation() turns grey for any column with missing values
# unless you pass pairwise.complete.obs. pandas' .corr() already skips missing values
# pair by pair, so Part 2e needed nothing special.

# create_report() in R writes everything as one HTML file. The closest Python tool is
# ydata-profiling. It is a heavier install, so this runs only if it is there.
try:
    from ydata_profiling import ProfileReport
    ProfileReport(patients.drop(columns=["patient_id", "visit_date"]), minimal=True).to_file(
        os.path.join("figures", "09_profile_report.html"))
    print("saved figures/09_profile_report.html")
except ImportError:
    print("ydata-profiling is not installed, so the report is skipped.")
# Like DataExplorer, it draws the shape of every column. It cannot say why a column
# looks odd: nothing in it explains the second bump in group A.


# -----------------------------------------------------------------------------
# Part 3: Figures  (Session 10)
# -----------------------------------------------------------------------------
# Plots with matplotlib or seaborn, each saved to figures/ with plt.savefig():
#   - histogram of body_mass_g
#   - boxplot of systolic blood pressure by group
#   - scatterplot of flipper_length_mm against body_mass_g, colored by species
#   - bar chart of schools by school_level
# Every figure needs labeled axes and a title that states the finding.


# -----------------------------------------------------------------------------
# Part 4: Univariate tests  (Session 11)
# -----------------------------------------------------------------------------
# One variable at a time:
#   - stats.ttest_ind() on systolic blood pressure, group A against group B. The
#     corrected result is mean 129.4 against 134.2, p = 0.0064. The naive
#     result from Lecture 1 (before cleaning) was p = 0.2152.
#   - check the assumptions with a histogram and stats.shapiro()
#   - stats.mannwhitneyu() as the alternative when the assumptions fail
#   - stats.chi2_contingency() on a table of two categorical columns
#   - several tests at once, then a multiple-testing correction
#     (statsmodels.stats.multitest.multipletests)


# -----------------------------------------------------------------------------
# Part 5: Regression  (Session 11)
# -----------------------------------------------------------------------------
# Linear regression on the penguins with statsmodels:
#   - body_mass_g ~ flipper_length_mm, then add species
#   - read the coefficients and their confidence intervals
#   - residual plot to check the fit
#   - predict for a new penguin


# -----------------------------------------------------------------------------
# Part 6: Multivariate methods and machine learning  (Session 12)
# -----------------------------------------------------------------------------
# Use the four penguin measurement columns, rows with no missing values:
#   X = penguins[["bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g"]].dropna()
# Then:
#   - scale the columns, so grams do not outweigh millimeters (StandardScaler)
#   - PCA, with a scree plot and a plot of the first two components
#   - KMeans with k = 3, compared with the real species
#   - train/test split with random_state set, so results repeat
#   - LASSO (LassoCV) to pick which measurements predict the outcome
#   - report accuracy on the test set only


# -----------------------------------------------------------------------------
# Part 7: Save results
# -----------------------------------------------------------------------------
# Figures: plt.savefig("figures/name.png"). Tables: to_csv(index=False) into data/clean/.
# Finish by printing the library versions (pd.__version__ and so on) so they are recorded.
