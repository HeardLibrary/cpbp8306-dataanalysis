# =============================================================================
# 2_statistics.R  |  Sessions 9 to 12   (comments only, no code yet)
# =============================================================================
# This script is a plan. Each section below says what the code will do, which
# cleaned file it reads, and which session it comes from. Code is added as the
# course reaches each session.
#
# Input: the files that 1_data_cleaning.R saved in data/clean/. This script never
# reads data/raw/. Run main.R first so those files exist.
# Output: figures go in figures/, and tables you want to keep go in data/clean/.
#
# To turn this script on, remove the # in front of the source() line for it at
# the bottom of main.R.
#
# Libraries to add to main.R when code arrives:
#   ggplot2   figures (Session 10)
#   glmnet    LASSO (Session 12)
# Base R already has t.test(), lm(), prcomp() and kmeans().
# =============================================================================


# -----------------------------------------------------------------------------
# Part 1: Load the cleaned data
# -----------------------------------------------------------------------------
# Read patients_clean.csv, penguins_clean.csv and schools_clean.csv with
# read_csv(). Check each with glimpse() so you can see the column types.
# schools_long.csv is read here too, for plots that need one row per grade.


# -----------------------------------------------------------------------------
# Part 2: Exploratory data analysis  (Session 9)
# -----------------------------------------------------------------------------
# Summaries before any test. For each dataset:
#   - summary() and the counts of missing values per column
#   - mean, median and standard deviation of the measurements, by group
#   - the impossible visit_date 2026-02-30 in patients: find it with
#     as.Date() and is.na(), then decide what to do with the row
#   - patients: check the corrected group sizes (A 125, B 125)
# Penguins: use the four measurement columns by name (bill_length_mm,
# bill_depth_mm, flipper_length_mm, body_mass_g). Leave year out.


# -----------------------------------------------------------------------------
# Part 3: Figures  (Session 10)
# -----------------------------------------------------------------------------
# Plots with ggplot2, each saved to figures/ with ggsave():
#   - histogram of body_mass_g
#   - boxplot of systolic blood pressure by group
#   - scatterplot of flipper_length_mm against body_mass_g, coloured by species
#   - bar chart of schools by school_level
# Every figure needs labelled axes and a title that states the finding.


# -----------------------------------------------------------------------------
# Part 4: Univariate tests  (Session 11)
# -----------------------------------------------------------------------------
# One variable at a time:
#   - t.test() on systolic blood pressure, group A against group B. The
#     corrected result is mean 129.4 against 134.2, p = 0.0064. The naive
#     result from Lecture 1 (before cleaning) was p = 0.2152.
#   - check the assumptions with a histogram and shapiro.test()
#   - wilcox.test() as the alternative when the assumptions fail
#   - chisq.test() on a table of two categorical columns
#   - several tests at once, then p.adjust() for multiple testing


# -----------------------------------------------------------------------------
# Part 5: Regression  (Session 11)
# -----------------------------------------------------------------------------
# lm() on the penguins:
#   - body_mass_g ~ flipper_length_mm, then add species
#   - read the coefficients and their confidence intervals
#   - residual plot to check the fit
#   - predict() for a new penguin


# -----------------------------------------------------------------------------
# Part 6: Multivariate methods and machine learning  (Session 12)
# -----------------------------------------------------------------------------
# Use the four penguin measurement columns, rows with no missing values:
#   X <- penguins %>% select(bill_length_mm:body_mass_g) %>% drop_na()
# Then:
#   - scale the columns, so grams do not outweigh millimetres
#   - prcomp() for PCA, with a scree plot and a plot of the first two components
#   - kmeans() with k = 3, compared with the real species
#   - train/test split with a set seed, so results repeat
#   - LASSO with glmnet to pick which measurements predict the outcome
#   - report accuracy on the test set only


# -----------------------------------------------------------------------------
# Part 7: Save results
# -----------------------------------------------------------------------------
# Figures: ggsave("figures/name.png"). Tables: write_csv() into data/clean/.
# Finish with sessionInfo() so the package versions are recorded.
