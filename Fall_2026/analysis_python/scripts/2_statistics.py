# =============================================================================
# 2_statistics.py  |  Sessions 9 to 12   (comments only, no code yet)
# =============================================================================
# This script is a plan. Each section below says what the code will do, which
# cleaned file it reads, and which session it comes from. Code is added as the
# course reaches each session.
#
# Input: the files that 1_data_cleaning.py saved in data/clean/. This script never
# reads data/raw/. Run main.py first so those files exist.
# Output: figures go in figures/, and tables you want to keep go in data/clean/.
#
# To turn this script on, remove the # in front of the run_path line for it at
# the bottom of main.py.
#
# Libraries to add to main.py when code arrives:
#   matplotlib or seaborn   figures (Session 10)
#   statsmodels             regression with a coefficient table (Session 11)
#   scikit-learn            PCA, K-means, LASSO, train/test split (Session 12)
# scipy.stats is already loaded and has ttest_ind, mannwhitneyu and chi2_contingency.
# =============================================================================


# -----------------------------------------------------------------------------
# Part 1: Load the cleaned data
# -----------------------------------------------------------------------------
# Read patients_clean.csv, penguins_clean.csv and schools_clean.csv with
# pd.read_csv(). Check each with .info() so you can see the column types.
# schools_long.csv is read here too, for plots that need one row per grade.


# -----------------------------------------------------------------------------
# Part 2: Exploratory data analysis  (Session 9)
# -----------------------------------------------------------------------------
# Summaries before any test. For each dataset:
#   - .describe() and the counts of missing values per column
#   - mean, median and standard deviation of the measurements, by group
#   - the impossible visit_date 2026-02-30 in patients: find it with
#     pd.to_datetime(errors="coerce") and .isna(), then decide what to do
#   - patients: check the corrected group sizes (A 125, B 125)
# Penguins: use the four measurement columns by name (bill_length_mm,
# bill_depth_mm, flipper_length_mm, body_mass_g). Leave year out.


# -----------------------------------------------------------------------------
# Part 3: Figures  (Session 10)
# -----------------------------------------------------------------------------
# Plots with matplotlib or seaborn, each saved to figures/ with plt.savefig():
#   - histogram of body_mass_g
#   - boxplot of systolic blood pressure by group
#   - scatterplot of flipper_length_mm against body_mass_g, coloured by species
#   - bar chart of schools by school_level
# Every figure needs labelled axes and a title that states the finding.


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
#   - scale the columns, so grams do not outweigh millimetres (StandardScaler)
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
