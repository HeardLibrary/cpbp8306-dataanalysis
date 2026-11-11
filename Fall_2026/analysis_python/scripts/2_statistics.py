# =============================================================================
# 2_statistics.py  |  Sessions 9 to 12   (Sessions 9 and 10 are code, the rest is a plan)
# =============================================================================
# Part 1 loads the cleaned data, Part 2 is Session 9 (exploratory data analysis)
# and Part 3 is Session 10 (figures), both with working code. Parts 4 to 7 are
# comments that say what the code will do, which cleaned file it reads, and which
# session it comes from. Code is added as the course reaches each session.
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
#   Part 3  Figures                      (Session 10)
#             3a  The five parts of a plot, one layer at a time
#             3b  Where the aesthetic lives
#             3c  What plot, for what question
#             3d  Facets
#             3e  Labels and the three plotting sins
#             3f  Saving a figure at the size it will be printed
#             3g  Plots that check a model: residuals and the QQ plot
#             3h  Reading the four plots from plot(fit): unusual schools
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


def save_plot(name, width=None, height=None):
    """Save the current figure in figures/ as a PNG, close it, and say where it went.
    width and height are in inches and are optional."""
    os.makedirs("figures", exist_ok=True)
    path = os.path.join("figures", name + ".png")
    if width:
        plt.gcf().set_size_inches(width, height)
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
# Session 9's plots were for you. These are for a reader. Every figure is described by
# five parts: data, aesthetics, geometry, statistics and coordinates. Each one is
# saved to figures/ with a name that starts 10_.
import seaborn.objects as so    # seaborn 0.12 or newer: the closest thing to ggplot2

# --- 3a. The five parts of a plot, one layer at a time -----------------------
section("3a: data, aesthetics, geometry, statistics, coordinates")

# Data and aesthetics first. With no geometry there is nothing to draw but the axes.
# so.Plot() builds a plot the way ggplot2 does, and .add() puts a layer on it.
p = (so.Plot(penguins, x="bill_length_mm", y="body_mass_g", color="species")
       .layout(size=(6, 3.6)))
# .add(so.Dot()) is the geometry, the mark. so.Line() with so.PolyFit() is a geometry
# with a statistic behind it: it fits a regression line for you. Both layers together
# are composable, points and lines.
os.makedirs("figures", exist_ok=True)
p.add(so.Dot()).save("figures/10_points.png", bbox_inches="tight")
p.add(so.Dot()).add(so.Line(), so.PolyFit(order=1)).save("figures/10_points_and_lines.png",
                                                         bbox_inches="tight")
print("saved figures/10_points.png and figures/10_points_and_lines.png")
# The coordinates are the axes, linear by default. .scale(x="log") changes them without
# touching the data.

# A prompt for an AI assistant should name all five parts. "Make a nice bar chart"
# names none of them.

# --- 3b. Where the aesthetic lives -------------------------------------------
section("3b: color in so.Plot() or in one layer")

# color in so.Plot() is inherited by every layer, so the line is drawn once per species
# (three lines).
(so.Plot(penguins, x="bill_length_mm", y="body_mass_g", color="species")
   .layout(size=(6, 3.6)).add(so.Dot()).add(so.Line(), so.PolyFit(order=1))
   .save("figures/10_global_color.png", bbox_inches="tight"))
# color in .add(so.Dot(), color=...) belongs to that layer only, so the line sees all
# the penguins together and is drawn once.
(so.Plot(penguins, x="bill_length_mm", y="body_mass_g")
   .layout(size=(6, 3.6)).add(so.Dot(), color="species").add(so.Line(), so.PolyFit(order=1))
   .save("figures/10_local_color.png", bbox_inches="tight"))
print("saved figures/10_global_color.png and figures/10_local_color.png")

# The slopes behind the lines, in grams per millimeter of bill.
both = penguins.dropna(subset=["bill_length_mm", "body_mass_g"])
print(round(stats.linregress(both["bill_length_mm"], both["body_mass_g"]).slope, 1))   # 87.4 overall
for name, g in both.groupby("species"):
    print(name, round(stats.linregress(g["bill_length_mm"], g["body_mass_g"]).slope, 1))
# Adelie 94.5, Chinstrap 59.1, Gentoo 109.5. The overall line mixes the difference
# between species into the slope, which is Session 9's Simpson's paradox again.

# --- 3c. What plot, for what question ----------------------------------------
section("3c: choose the plot")

# One continuous variable: a histogram.
sns.histplot(penguins, x="body_mass_g", bins=30)
save_plot("10_histogram_body_mass")

# Two continuous variables, colored by group: a scatter plot.
sns.scatterplot(penguins, x="flipper_length_mm", y="body_mass_g", hue="species")
save_plot("10_flipper_vs_mass")

# One categorical variable: a bar chart of counts. countplot() counts the rows. Long
# labels go on the y axis, sorted by count.
print(schools["school_level"].value_counts())
# Elementary School 76, Charter 31, Middle School 31, High School 17, Non-Traditional 7,
# Special Education 3, Alternative Learning Center 2, Adult 1, GATE Center 1
sns.countplot(schools, y="school_level", order=schools["school_level"].value_counts().index)
plt.xlabel("Schools")
plt.ylabel("School level")
save_plot("10_schools_by_level")

# Continuous by categorical: the anti-pattern first, a bar chart of means.
means = patients.groupby("group")["systolic"].agg(["mean", "std", "count"])
print(means.round(1))   # A 129.4 (sd 15.1, n 121), B 134.2 (sd 11.9, n 120)
sns.barplot(patients, x="group", y="systolic", errorbar="sd", capsize=0.2, color="0.35")
plt.xlabel("Group")
plt.ylabel("Systolic pressure (mmHg), mean and sd")
save_plot("10_bar_of_means")
# Two bars and two error bars. Nothing says group A holds two kinds of patient.

# The same data as points, colored by the original label from patients_raw. The 40 rows
# that read "A " (a trailing space) are the second recruitment site from Session 1.
by_site = patients_raw.assign(
    site=np.where(patients_raw["group"] == "A ", "second site", "first site"))
by_site["group"] = by_site["group"].str.strip()
sns.stripplot(by_site, x="group", y="systolic", hue="site", jitter=0.15, alpha=0.7)
plt.xlabel("Group")
plt.ylabel("Systolic pressure (mmHg)")
save_plot("10_points_by_site")
print(by_site[by_site["group"] == "A"].groupby("site")["systolic"].agg(["count", "mean"]).round(1))
# first site: n 81, mean 136.2 / second site: n 40, mean 115.5. The points show it and
# the bars hide it. Under about 30 points per group, plot the points. With more, a box
# plot at least.
sns.boxplot(by_site, x="group", y="systolic", showfliers=False, color="white")
sns.stripplot(by_site, x="group", y="systolic", hue="site", jitter=0.15, alpha=0.6)
plt.xlabel("Group")
plt.ylabel("Systolic pressure (mmHg)")
save_plot("10_systolic_box_by_group")

# --- 3d. Facets --------------------------------------------------------------
section("3d: facets")

# relplot() with col= makes one small plot per level. Every panel shares the same axes
# by default, so the panels compare honestly.
sns.relplot(penguins, x="bill_length_mm", y="body_mass_g", col="species", alpha=0.6,
            height=3, aspect=0.9)
plt.savefig("figures/10_facet_wrap.png", dpi=150)
plt.close()
# row= and col= together use two grouping variables.
print(pd.crosstab(penguins["species"], penguins["island"]))
# Adelie is on all three islands (44, 56, 52), Chinstrap only on Dream (68) and Gentoo
# only on Biscoe (124). So 5 of the 9 panels hold data. A grid shows which combinations
# exist, and for Chinstrap and Gentoo an island effect cannot be separated from a species
# effect.
sns.relplot(penguins, x="bill_length_mm", y="body_mass_g", row="island", col="species",
            alpha=0.6, height=2.2, aspect=1.2, facet_kws={"margin_titles": True})
plt.savefig("figures/10_facet_grid.png", dpi=150)
plt.close()
print("saved figures/10_facet_wrap.png and figures/10_facet_grid.png")
# Past 3 or 4 groups, facet instead of coloring.

# --- 3e. Labels and the three plotting sins ----------------------------------
section("3e: labels, scales and chart junk")

# A figure for a reader names each axis with units and states the finding. The viridis
# palette survives grayscale printing and most kinds of color blindness.
sns.set_theme(style="ticks")
fig, ax = plt.subplots()
sns.scatterplot(penguins, x="bill_length_mm", y="body_mass_g", hue="species",
                palette="viridis", alpha=0.7, ax=ax)
ax.set(title="Longer bills go with heavier penguins in all three species",
       xlabel="Bill length (mm)", ylabel="Body mass (g)")
ax.legend(title="Species", frameon=False)
sns.despine()
save_plot("10_polished")

# The three sins: chart junk (3D bars, shadows, gridlines with no data), ambiguous
# labels ("value" is not a label), and misleading scales. Here is the same bar chart
# of means twice. Bars must start at zero, because their length is the data.
group_means = patients.groupby("group")["systolic"].mean()
for name, ylim in [("10_bars_from_zero", None), ("10_bars_truncated", (125, 135))]:
    fig, ax = plt.subplots()
    ax.bar(group_means.index, group_means.values, color="0.35")
    ax.set(xlabel="Group", ylabel="Mean systolic pressure (mmHg)")
    if ylim:
        ax.set_ylim(*ylim)
    sns.despine()
    save_plot(name, 3.5, 3.2)
print(group_means.round(1).tolist())                                    # [129.4, 134.2]
print(round(group_means["B"] / group_means["A"], 3))                    # 1.037
print(round((group_means["B"] - 125) / (group_means["A"] - 125), 1))    # 2.1
# Cut at 125 and B's bar looks 2.1 times as tall as A's, for a 3.7% difference.

# --- 3f. Saving a figure at the size it will be printed ----------------------
section("3f: savefig() and combining panels")

# savefig() takes the resolution as dpi and the size from the figure, in inches. Many
# journals ask for about 3.5 inches (one column) or 7 inches (two columns). dpi=300 is
# the usual minimum for a raster figure: 7 inches is 2100 pixels wide.
fig, ax = plt.subplots(figsize=(7, 4))
sns.scatterplot(penguins, x="bill_length_mm", y="body_mass_g", hue="species",
                palette="viridis", alpha=0.7, ax=ax)
ax.set(xlabel="Bill length (mm)", ylabel="Body mass (g)")
sns.despine()
fig.savefig("figures/10_figure1.png", dpi=300, bbox_inches="tight")
# A vector format has no resolution, so it stays sharp at any size.
fig.savefig("figures/10_figure1.pdf", bbox_inches="tight")
plt.close(fig)
print("saved figures/10_figure1.png (2100 pixels wide) and figures/10_figure1.pdf")
# Save with code, not the export button: a script rebuilds the figure when a reviewer
# asks for a change.

# Two plots in one figure, with panel letters. R uses the patchwork package for this.
# Session 13 comes back to it.
fig, axes = plt.subplots(1, 2, figsize=(9, 3.8))
sns.barplot(patients, x="group", y="systolic", errorbar="sd", capsize=0.2, color="0.35",
            ax=axes[0])
sns.stripplot(by_site, x="group", y="systolic", hue="site", jitter=0.15, alpha=0.7,
              ax=axes[1])
for ax, letter in zip(axes, "AB"):
    ax.set_title(letter, loc="left", fontweight="bold")
    ax.set(xlabel="Group", ylabel="Systolic pressure (mmHg)")
sns.despine()
fig.tight_layout()
fig.savefig("figures/10_combined.png", dpi=150)
plt.close(fig)
print("saved figures/10_combined.png")

# --- 3g. Plots that check a model: residuals and the QQ plot -----------------
section("3g: diagnostic plots")

# A residual is what the model did not explain: observed minus fitted. Diagnostic plots
# look at the residuals to see whether the model is a fair description. Session 11 fits
# models in earnest. This uses only numpy and scipy.
resid_df = penguins.dropna(subset=["body_mass_g", "flipper_length_mm"]).copy()
slope, intercept = np.polyfit(resid_df["flipper_length_mm"], resid_df["body_mass_g"], 1)
resid_df["fitted"] = intercept + slope * resid_df["flipper_length_mm"]
resid_df["resid"] = resid_df["body_mass_g"] - resid_df["fitted"]
ss_total = ((resid_df["body_mass_g"] - resid_df["body_mass_g"].mean()) ** 2).sum()
print(round(1 - (resid_df["resid"] ** 2).sum() / ss_total, 3))   # 0.759
print(round(intercept, 2), round(slope, 2))                       # -5780.83 and 49.69 g per mm

# Residuals vs fitted: you want a shapeless cloud around zero. A curve means the line is
# the wrong shape and a funnel means the spread changes. Colored by species, the residuals
# show structure the line missed.
ax = sns.scatterplot(resid_df, x="fitted", y="resid", hue="species")
ax.axhline(0, linestyle="--", color="black", linewidth=1)
ax.set(xlabel="Fitted body mass (g)", ylabel="Residual (g)")
save_plot("10_residuals_vs_fitted")
print(resid_df.groupby("species")["resid"].mean().round().tolist())   # Adelie 44, Chinstrap -216, Gentoo 66
# Chinstrap sits below the line. Adding species raises R-squared from 0.759 to 0.783
# (Session 11):
X = np.column_stack([np.ones(len(resid_df)), resid_df["flipper_length_mm"],
                     resid_df["species"] == "Chinstrap",
                     resid_df["species"] == "Gentoo"]).astype(float)
beta, *_ = np.linalg.lstsq(X, resid_df["body_mass_g"].to_numpy(), rcond=None)
resid2 = resid_df["body_mass_g"].to_numpy() - X @ beta
print(round(1 - (resid2 ** 2).sum() / ss_total, 3))   # 0.783

# QQ plot: sorted values against what a normal distribution would give. Points on the
# line mean normal. Ends that peel away mean skew or extreme values. This is systolic
# pressure by group, the data behind the Session 1 test.
fig, axes = plt.subplots(1, 2, figsize=(6, 3), sharey=True)
for ax, (name, g) in zip(axes, patients.groupby("group")):
    stats.probplot(g["systolic"].dropna(), dist="norm", plot=ax)
    ax.set_title(name)
    ax.set_xlabel("Theoretical quantiles")
axes[0].set_ylabel("Systolic pressure (mmHg)")
axes[1].set_ylabel("")
save_plot("10_qq_by_group")
a_sys = patients.loc[patients["group"] == "A", "systolic"].dropna()
b_sys = patients.loc[patients["group"] == "B", "systolic"].dropna()
print(round(stats.shapiro(a_sys).pvalue, 3), round(stats.shapiro(b_sys).pvalue, 3))   # 0.018 and 0.471
# Group A's ends curl away from the line (p = 0.018) and group B follows it. A QQ plot
# drawn before the t-test would have flagged group A, as Session 9's histogram did.

# R's plot(fit) also draws scale-location and residuals vs leverage. In Python those come
# from statsmodels, which Session 11 installs. Part 3h uses it. This block runs only if it
# is there.
try:
    import statsmodels.api as sm
    sm_fit = sm.OLS(resid_df["body_mass_g"], sm.add_constant(resid_df["flipper_length_mm"])).fit()
    print("largest Cook's distance:", round(sm_fit.get_influence().cooks_distance[0].max(), 3))   # 0.039
    # far below 1, so no one penguin pulls the fit
except ImportError:
    print("statsmodels is not installed, so the Cook's distance check is skipped.")

# --- 3h. Reading the four plots from plot(fit): unusual schools --------------
section("3h: leverage and Cook's distance")

# A model with some unusual points: the number of students with a disability against
# total enrollment at the 169 Metro Nashville schools. total is the sum of the 15 grade
# columns, and a missing grade count means the grade is not offered, so it adds nothing.
# statsmodels gives the leverage, standardized residual and Cook's distance for each school.
try:
    import statsmodels.api as sm
except ImportError:
    sm = None
    print("statsmodels is not installed, so Part 3h is skipped.")

if sm is not None:
    schools_fit = schools.assign(total=schools.filter(like="grade_").sum(axis=1))
    fit2 = sm.OLS(schools_fit["disability"], sm.add_constant(schools_fit["total"])).fit()
    print(round(fit2.rsquared, 3))                      # 0.598
    print(fit2.params.round(4).tolist())                # intercept 8.2973, slope 0.1097

    infl = fit2.get_influence()
    leverage = infl.hat_matrix_diag
    std_resid = infl.resid_studentized_internal
    cooks = infl.cooks_distance[0]

    # Residuals vs leverage, and Cook's distance as bars. The rule-of-thumb lines in R's
    # leverage plot are 0.5 and 1.
    fig, axes = plt.subplots(1, 2, figsize=(9, 3.6))
    axes[0].scatter(leverage, std_resid, facecolors="none", edgecolors="black")
    axes[0].axhline(0, linestyle=":", color="grey")
    axes[0].set(xlabel="Leverage", ylabel="Standardized residual", title="Residuals vs leverage")
    axes[1].vlines(np.arange(1, len(cooks) + 1), 0, cooks, color="black", linewidth=0.8)
    axes[1].set(xlabel="Observation number", ylabel="Cook's distance", title="Cook's distance")
    top = np.argsort(cooks)[::-1][:3]
    for i in top:
        axes[0].annotate(str(i + 1), (leverage[i], std_resid[i]), xytext=(4, 2), textcoords="offset points")
        axes[1].annotate(str(i + 1), (i + 1, cooks[i]), xytext=(0, 3), textcoords="offset points", ha="center")
    save_plot("10_leverage_and_cooks_schools", 9, 3.6)

    # Who are the unusual points? Observation numbers start at 1, and pandas rows at 0.
    print(top + 1)                                      # 102 53 99
    print(cooks[top].round(3))                          # 0.398 0.314 0.303: none reaches 0.5
    print(schools_fit.loc[top, ["school_name", "school_level", "total", "disability"]])
    # McGavock High (102): 2276 students, the most leverage (0.166), near the line.
    # Harris-Hillman Special Education (53): 335 students with a disability against 95.9
    #   predicted, a residual of +239.1, but ordinary leverage (0.010).
    # Martin Luther King Jr School (99): 23 with a disability against 146.7, a residual of -123.7.
    # A point needs both a large residual and high leverage to be influential. All three are
    # real schools, not entry errors, and none crosses a Cook's contour.

    # What to do with an unusual point: check it, refit without it, and report both fits.
    def refit(drop):
        keep = schools_fit.drop(index=drop)
        f = sm.OLS(keep["disability"], sm.add_constant(keep["total"])).fit()
        return round(float(f.params["total"]), 3), round(float(f.rsquared), 3)

    print(refit([101]))          # without McGavock:        slope 0.104, R-squared 0.533
    print(refit([52]))           # without Harris-Hillman:  slope 0.106, R-squared 0.686
    print(refit([52, 101]))      # without both:            slope 0.099, R-squared 0.627
    # The full fit is slope 0.110 and R-squared 0.598.


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
