# =============================================================================
# 2_statistics.R  |  Sessions 9 to 12   (Session 9 is code, the rest is a plan)
# =============================================================================
# Part 1 loads the cleaned data and Part 2 is Session 9, exploratory data
# analysis, with working code. Parts 3 to 7 are comments that say what the code
# will do, which cleaned file it reads, and which session it comes from. Code is
# added as the course reaches each session.
#
# Input: the files that 1_data_cleaning.R saved in data/clean/. This script
# never reads data/raw/. The one exception is patients_raw, which main.R already
# loaded: Part 2 needs the original group labels, and the cleaned file has lost
# them. Run main.R first so everything exists.
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
#             2g  The whole first look in one call: DataExplorer (optional)
#   Part 3  Figures                      (Session 10, plan)
#   Part 4  Univariate tests             (Session 11, plan)
#   Part 5  Regression                   (Session 11, plan)
#   Part 6  Multivariate and ML          (Session 12, plan)
#   Part 7  Save results
#
# Needs these objects and packages from main.R: patients_raw, and readr, dplyr,
# stringr and ggplot2. skimr, naniar and DataExplorer are optional. Each one is used
# only if it is installed.
# =============================================================================

if (!exists("patients_raw")) {
  stop("Run main.R first. It loads the data this script uses.")
}

# Helpers -------------------------------------------------------------------
# A heading for the printed output.
section <- function(title) {
  cat("\n", strrep("=", 70), "\n", title, "\n", strrep("=", 70), "\n", sep = "")
}
# Save a plot to the figures/ folder as a PNG, and say where it went.
# The warning about removed rows is expected: two penguins have no measurements.
save_plot <- function(p, name, width = 6, height = 3.6) {
  dir.create("figures", showWarnings = FALSE)
  path <- file.path("figures", paste0(name, ".png"))
  suppressWarnings(ggsave(path, p, width = width, height = height, dpi = 150))
  cat("saved", path, "\n")
}


# -----------------------------------------------------------------------------
# Part 1: Load the cleaned data
# -----------------------------------------------------------------------------
section("Part 1: load the cleaned data")

# read_csv() reads each cleaned file that 1_data_cleaning.R wrote. Raw files are
# never touched here.
#
# visit_date is read as text on purpose. If read_csv() guesses, it decides the
# column is a date and turns the impossible date 2026-02-30 into NA. Reading it
# as text keeps the original string visible, so Part 2f can find it.
patients <- read_csv("data/clean/patients_clean.csv", show_col_types = FALSE,
                     col_types = cols(visit_date = col_character()))
penguins <- read_csv("data/clean/penguins_clean.csv", show_col_types = FALSE)
schools <- read_csv("data/clean/schools_clean.csv", show_col_types = FALSE)

# glimpse() shows each column's type and its first few values.
glimpse(patients)
cat("patients:", nrow(patients), "rows. penguins:", nrow(penguins), "rows. schools:",
    nrow(schools), "rows.\n")
print(table(patients$group))   # A 125, B 125: the Session 8 cleaning worked

# schools_long.csv (one row per school per grade) is read here too when a plot
# needs it:
#   schools_long <- read_csv("data/clean/schools_long.csv", show_col_types = FALSE)


# -----------------------------------------------------------------------------
# Part 2: Exploratory data analysis  (Session 9)
# -----------------------------------------------------------------------------
# Look before you test. Part 2 turns the cleaned data into numbers, then plots,
# then a short list of problems to hunt for. Each step says what to look for.

# --- 2a. Numerical summaries -------------------------------------------------
section("2a: numerical summaries")

nums <- patients %>% select(age, systolic, diastolic, cholesterol)

# summary() gives the minimum, quartiles, mean, maximum and the number of NAs.
print(summary(nums))
# age: 22 to 89, mean 56.42, 6 NA
# systolic: 87.5 to 170.9, mean 131.8, median 133.7, 9 NA
# diastolic: 52.2 to 110.9, mean 81.55, 7 NA
# cholesterol: 106.5 to 292.1, mean 195.4, 22 NA

# Read the summary like a diagnostic. Is each mean plausible? Is each range
# possible? Is the median far from the mean, a sign of skew? How many values are
# missing? Cholesterol is missing in 22 of 250 patients, 8.8%.
print(round(colMeans(is.na(nums)), 3))   # age 0.024, systolic 0.036, diastolic 0.028, cholesterol 0.088

# skimr::skim() adds the share of values present and a tiny histogram per column.
# It is optional, so the script skips it if skimr is not installed.
if (requireNamespace("skimr", quietly = TRUE)) print(skimr::skim(nums))

# Is the median far from the mean? A mean below the median means a longer tail on
# the low side. Systolic has one. Part 2d shows why.
print(round(mean(patients$systolic, na.rm = TRUE) - median(patients$systolic, na.rm = TRUE), 1))   # -1.9

# For a categorical column, count the values and check the balance.
print(table(patients$group))   # A 125, B 125
print(table(patients$sex))     # F 121, M 129

# The same summary split by group. na.rm = TRUE skips the missing values, and n
# counts only the rows that have a value. This is the Fall 2025 group_by() +
# summarise() pattern.
print(patients %>%
        group_by(group) %>%
        summarise(n = sum(!is.na(systolic)),
                  mean = round(mean(systolic, na.rm = TRUE), 1),
                  median = round(median(systolic, na.rm = TRUE), 1),
                  sd = round(sd(systolic, na.rm = TRUE), 1)))
# A: n 121, mean 129.4, median 132.2, sd 15.1 / B: n 120, mean 134.2, median 135.4, sd 11.9
# Group A has the lower mean and the wider spread. Part 2d shows why.

# DataExplorer does the whole first look in one call. Part 2g uses it.

# --- 2b. Three plots you make every time you touch new data -------------------
section("2b: histogram, box plot, scatter plot")

# Base R draws the same three plots in one line each, which is handy for a quick
# look at the console (Fall 2025 Session 8). They are not saved here.
#   hist(penguins$bill_length_mm)
#   boxplot(bill_length_mm ~ species, data = penguins)
#   plot(penguins$bill_length_mm, penguins$body_mass_g)
# The ggplot2 versions below are the ones saved to figures/. Session 10 builds them.

# Histogram: the shape of one variable. Look for two peaks, long tails and
# spikes. Penguin bill lengths have two clusters, a hint that another variable is
# mixed in.
save_plot(ggplot(penguins, aes(bill_length_mm)) + geom_histogram(bins = 30),
          "09_histogram_bill_length")

# Box plot: one variable across groups. Do the groups overlap? Are there dots
# beyond the whiskers? Adelie sits lower. Gentoo has one dot above its whisker.
save_plot(ggplot(penguins, aes(species, bill_length_mm)) + geom_boxplot(),
          "09_boxplot_bill_length_by_species")

# Scatter plot: two variables, colored by group. Look at the direction, at
# curves, and at whether the groups differ. There are three clouds, one per species.
save_plot(ggplot(penguins, aes(bill_length_mm, body_mass_g, color = species)) + geom_point(),
          "09_scatter_mass_vs_bill_length")

# --- 2c. Simpson's paradox ----------------------------------------------------
section("2c: Simpson's paradox")

# Overall, deeper bills go with shorter bills.
print(round(cor(penguins$bill_length_mm, penguins$bill_depth_mm, use = "complete.obs"), 2))   # -0.24

# Inside each species, deeper bills go with longer bills. The species differ in
# both measurements, and that difference hides the pattern inside each one.
print(penguins %>%
        group_by(species) %>%
        summarise(r = cor(bill_length_mm, bill_depth_mm, use = "complete.obs")))
# Adelie 0.39, Chinstrap 0.65, Gentoo 0.64
# The habit to build: color a scatter plot by every grouping variable you have
# before you believe the overall trend.
save_plot(ggplot(penguins, aes(bill_length_mm, bill_depth_mm)) +
            geom_point() + geom_smooth(method = "lm", se = FALSE),
          "09_simpson_overall")
save_plot(ggplot(penguins, aes(bill_length_mm, bill_depth_mm, color = species)) +
            geom_point() + geom_smooth(method = "lm", se = FALSE),
          "09_simpson_by_species")

# --- 2d. The plot Session 1 was missing --------------------------------------
section("2d: group A systolic pressure")

# Group A after the Session 8 cleaning: 125 rows, 121 with a systolic value.
group_a <- patients %>% filter(group == "A")
cat(nrow(group_a), "rows,", sum(!is.na(group_a$systolic)), "with a systolic value\n")
save_plot(ggplot(group_a, aes(systolic)) + geom_histogram(binwidth = 5),
          "09_group_a_systolic")
# Not one clean peak. There is a second bump on the low side, around 115 to 120.

# Why? The cleaned file has lost the original label, so go back to patients_raw,
# which main.R loaded with trim_ws = FALSE. The 40 rows that read "A " are a
# second recruitment site. Lesson: keep the raw value in its own column BEFORE
# you clean it, or you cannot color by it later.
group_a_site <- patients_raw %>%
  filter(str_trim(group) == "A") %>%
  mutate(site = if_else(group == "A ", "second site", "first site"))
save_plot(ggplot(group_a_site, aes(systolic, fill = site)) + geom_histogram(binwidth = 5),
          "09_group_a_by_site")
print(group_a_site %>%
        group_by(site) %>%
        summarise(n = sum(!is.na(systolic)), mean = round(mean(systolic, na.rm = TRUE), 1)))
# first site: n 81, mean 136.2 / second site: n 40, mean 115.5

# The test from Lecture 1 kept only group == "A" (no trailing space), so it
# quietly dropped the second site. With all of group A back in, the result changes.
naive_a <- patients_raw %>% filter(group == "A") %>% pull(systolic)
all_a <- group_a$systolic
group_b <- patients %>% filter(group == "B") %>% pull(systolic)
print(t.test(naive_a, group_b, var.equal = TRUE)$p.value)   # 0.2152, "no difference"
print(t.test(all_a, group_b, var.equal = TRUE)$p.value)     # 0.0064, a real difference
print(round(c(mean(all_a, na.rm = TRUE), mean(group_b, na.rm = TRUE)), 1))   # 129.4 134.2
# The silent data loss produced a false negative. One histogram, drawn before the
# test, would have shown two groups of patients mixed together. Session 11 comes
# back to this test.

# --- 2e. Correlation ---------------------------------------------------------
section("2e: correlation")

# Select the four measurements by name. Taking every numeric column would pull in
# year.
penguin_cor <- penguins %>%
  select(bill_length_mm:body_mass_g) %>%
  cor(use = "pairwise.complete.obs")
print(round(penguin_cor, 2))
# The diagonal is 1 and the matrix is symmetric, so read one triangle.
# flipper_length_mm and body_mass_g: 0.87, the strongest pair.
# bill_depth_mm is negative with the other three, the Simpson's paradox again.
# Two predictors above 0.9 would be multicollinear (Session 12). 0.87 is close
# enough to flag.

# Pearson's r only sees straight-line association. A rank-based correlation is
# more robust to skew and outliers.
print(round(penguins %>%
              select(bill_length_mm:body_mass_g) %>%
              cor(use = "pairwise.complete.obs", method = "spearman"), 2))
# flipper and body mass: 0.84

# The patients: systolic and diastolic move together. Cholesterol relates to
# nothing, which is a legitimate finding. Correlation is not causation.
print(round(cor(nums, use = "pairwise.complete.obs"), 2))
# systolic and diastolic: 0.88 / cholesterol with the others: 0.03 to 0.04

# --- 2f. Three data problems -------------------------------------------------
section("2f: missing values, outliers, impossible values")

# 1. Missing values: where, how many, and why?
print(colSums(is.na(patients)))
# age 6, systolic 9, diastolic 7, cholesterol 22. visit_date is 0 because Part 1
# read it as text.
print(table(patients$group, is.na(patients$cholesterol)))   # 11 missing in each group

# The schools file is different. A missing grade usually means "not offered".
grades <- schools %>% select(starts_with("grade_"))
cat(sum(is.na(grades)), "empty cells out of", prod(dim(grades)), "\n")   # 1667 out of 2535
middle <- schools %>% filter(school_level == "Middle School")
cat(sum(is.na(middle$grade_9)), "of", nrow(middle), "middle schools have no grade 9\n")   # 31 of 31
# Filling these with 0 would be wrong. Leave them missing. Three kinds of missing
# exist: completely at random, at random given another column, and not at random.
# Nothing fixes the last kind.

# naniar draws the pattern of missingness in one call. It is optional.
if (requireNamespace("naniar", quietly = TRUE)) {
  save_plot(naniar::vis_miss(patients), "09_missingness")
}

# 2. Outliers: a real extreme value, or an entry error?
print(boxplot.stats(patients$systolic)$out)
# 88.1 99.8 96.1 98.3 87.5 93.4 97.1 170.9: eight values beyond the whiskers
# Four of them are second-site patients (87.5, 88.1, 93.4, 97.1), so they are
# real. Never delete an outlier because the p-value would look better without it.
print(boxplot.stats(penguins$body_mass_g)$out)   # numeric(0): no penguin outliers

# 3. Impossible values: could this value exist at all?
# Part 1 kept visit_date as text, so the bad string is still visible. as.Date()
# with an explicit format returns NA for a date that does not exist.
bad_date <- is.na(as.Date(patients$visit_date, format = "%Y-%m-%d"))
print(patients %>% filter(bad_date) %>% select(patient_id, group, visit_date))
# P094, group B, 2026-02-30. Find it, then trace it upstream. Do not just filter it out.
# No row has systolic below diastolic, another check for impossible values.
print(sum(patients$systolic < patients$diastolic, na.rm = TRUE))   # 0

# The rule that matters most: write down what you decided and why. Every value
# you drop or fill in gets one sentence. This is an example log for these data:
#   - Kept the 8 systolic values beyond the whiskers. Four belong to the second
#     site and the rest look like real extremes.
#   - Left the NA in the schools grade columns. A grade that is not offered is
#     not a zero.
#   - Kept cholesterol as it is (8.8% missing, 11 in each group). Any analysis
#     that uses it drops those rows and says so.
#   - visit_date for P094 is impossible. Leave the row in, but exclude it from
#     anything that uses visit_date, and ask the data owner what the date was.


# --- 2g. The whole first look in one call (optional) -------------------------
section("2g: DataExplorer")

# DataExplorer was the quick first look in Fall 2025. One package draws most of what
# Part 2 built by hand: the overview table, the missing-value profile, a histogram of
# every numeric column and a bar chart of every text column. It is optional, so this
# part is skipped if the package is not installed:  install.packages("DataExplorer")
if (!requireNamespace("DataExplorer", quietly = TRUE)) {
  cat("DataExplorer is not installed, so Part 2g is skipped.\n")
} else {
  library(DataExplorer)

  # introduce() is the overview of Part 2a as a one-row table.
  print(as.data.frame(t(introduce(patients))))
  # rows 250, columns 9, discrete 5, continuous 4, total_missing_values 44,
  # complete_rows 208 (83.2%), total_observations 2250
  # profile_missing() is the table behind plot_missing(): count and share per column.
  print(profile_missing(patients))   # cholesterol 22, 0.088 is the largest

  # DataExplorer's plot_ functions draw as soon as they run, so to save one we open a
  # PNG device first. This helper does that.
  save_de <- function(plot_call, name, width = 6, height = 4) {
    dir.create("figures", showWarnings = FALSE)
    path <- file.path("figures", paste0(name, ".png"))
    png(path, width = width, height = height, units = "in", res = 150)
    invisible(suppressWarnings(plot_call))
    dev.off()
    cat("saved", path, "\n")
  }
  save_de(plot_intro(patients), "09_de_intro")
  save_de(plot_missing(patients), "09_de_missing")
  save_de(plot_histogram(patients), "09_de_histograms", 7, 5)   # every numeric column
  # plot_bar() skips text columns with more than 50 distinct values (patient_id,
  # visit_date) and says so on the console.
  save_de(plot_bar(patients), "09_de_bars", 7, 4)

  # The check that would have caught Session 1: run plot_bar() on the RAW table. It
  # draws two bars labeled A (85 and 40 rows), and four spellings of sex (M, F, m, f).
  save_de(plot_bar(patients_raw %>% select(group, sex)), "09_de_bars_raw", 6, 3)

  # A gotcha. plot_correlation() uses every row by default, so any pair with a
  # missing value comes out grey. Ask for pairwise.complete.obs, as in Part 2e.
  save_de(plot_correlation(nums), "09_de_corr_default", 5, 4)   # grey, only the diagonal
  save_de(plot_correlation(nums, cor_args = list(use = "pairwise.complete.obs")),
          "09_de_corr_pairwise", 5, 4)

  # create_report() bundles all of it into one HTML file: basic statistics, data
  # structure, missing data profile, univariate distributions, correlation analysis,
  # principal component analysis and bivariate distributions, split by y. It needs
  # pandoc, which RStudio includes.
  if (rmarkdown::pandoc_available()) {
    create_report(patients %>% select(-patient_id, -visit_date), y = "group",
                  output_file = "09_dataexplorer_report.html", output_dir = "figures",
                  quiet = TRUE)
    cat("saved figures/09_dataexplorer_report.html\n")
  }
  # The report draws the shape of every column. It cannot say why a column looks odd:
  # nothing in it explains the second bump in group A.
}


# -----------------------------------------------------------------------------
# Part 3: Figures  (Session 10)
# -----------------------------------------------------------------------------
# Plots with ggplot2, each saved to figures/ with ggsave():
#   - histogram of body_mass_g
#   - boxplot of systolic blood pressure by group
#   - scatterplot of flipper_length_mm against body_mass_g, colored by species
#   - bar chart of schools by school_level
# Every figure needs labeled axes and a title that states the finding.


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
#   - scale the columns, so grams do not outweigh millimeters
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
