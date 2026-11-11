# =============================================================================
# 2_statistics.R  |  Sessions 9 to 12   (Sessions 9 and 10 are code, the rest is a plan)
# =============================================================================
# Part 1 loads the cleaned data, Part 2 is Session 9 (exploratory data analysis)
# and Part 3 is Session 10 (figures), both with working code. Parts 4 to 7 are
# comments that say what the code will do, which cleaned file it reads, and which
# session it comes from. Code is added as the course reaches each session.
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
# Needs these objects and packages from main.R: patients_raw, and readr, dplyr,
# stringr and ggplot2. skimr, naniar, DataExplorer and patchwork are optional. Each one
# is used only if it is installed.
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
# Session 9's plots were for you. These are for a reader. Every figure is described by
# five parts: data, aesthetics, geometry, statistics and coordinates. Each one is
# saved to figures/ with a name that starts 10_.

# --- 3a. The five parts of a plot, one layer at a time -----------------------
section("3a: data, aesthetics, geometry, statistics, coordinates")

# Data and aesthetics first. With no geometry there is nothing to draw but the axes.
p <- ggplot(penguins, aes(x = bill_length_mm, y = body_mass_g, color = species))
# + geom_point() adds the geometry, the mark. Each + adds one layer.
save_plot(p + geom_point(), "10_points")
# geom_smooth(method = "lm") is a geometry with a statistic behind it: it fits a
# regression line for you. Both layers together are composable, points and lines.
save_plot(p + geom_point() + geom_smooth(method = "lm", formula = y ~ x),
          "10_points_and_lines")
# The coordinates are the axes, linear by default. scale_x_log10() or coord_flip()
# change them without touching the data.

# A prompt for an AI assistant should name all five parts. "Make a nice bar chart"
# names none of them.

# --- 3b. Where the aesthetic lives -------------------------------------------
section("3b: color in ggplot() or in one layer")

# aes() inside ggplot() is inherited by every layer. color = species is global here,
# so geom_smooth() draws one line per species (three lines).
save_plot(ggplot(penguins, aes(bill_length_mm, body_mass_g, color = species)) +
            geom_point() + geom_smooth(method = "lm", formula = y ~ x, se = FALSE),
          "10_global_color")
# aes() inside geom_point() belongs to that layer only, so geom_smooth() sees all the
# penguins together and draws one line.
save_plot(ggplot(penguins, aes(bill_length_mm, body_mass_g)) +
            geom_point(aes(color = species)) +
            geom_smooth(method = "lm", formula = y ~ x, se = FALSE),
          "10_local_color")
# The slopes behind the lines, in grams per millimeter of bill.
print(round(coef(lm(body_mass_g ~ bill_length_mm, data = penguins))[2], 1))   # 87.4 overall
print(penguins %>%
        group_by(species) %>%
        summarise(slope = round(coef(lm(body_mass_g ~ bill_length_mm))[2], 1)) %>%
        as.data.frame())
# Adelie 94.5, Chinstrap 59.1, Gentoo 109.5. The overall line mixes the difference
# between species into the slope, which is Session 9's Simpson's paradox again.

# --- 3c. What plot, for what question ----------------------------------------
section("3c: choose the plot")

# One continuous variable: a histogram.
save_plot(ggplot(penguins, aes(body_mass_g)) + geom_histogram(bins = 30),
          "10_histogram_body_mass")

# Two continuous variables, colored by group: a scatter plot.
save_plot(ggplot(penguins, aes(flipper_length_mm, body_mass_g, color = species)) +
            geom_point(),
          "10_flipper_vs_mass")

# One categorical variable: a bar chart of counts. geom_bar() counts the rows, which
# is the statistics part. Long labels go on the y axis, sorted by count.
print(count(schools, school_level, sort = TRUE))
# Elementary School 76, Charter 31, Middle School 31, High School 17, Non-Traditional 7,
# Special Education 3, Alternative Learning Center 2, Adult 1, GATE Center 1
save_plot(ggplot(schools, aes(y = reorder(school_level, school_level, FUN = length))) +
            geom_bar() + labs(y = "School level", x = "Schools"),
          "10_schools_by_level")

# Continuous by categorical: the anti-pattern first, a bar chart of means.
means <- patients %>%
  group_by(group) %>%
  summarise(mean = mean(systolic, na.rm = TRUE), sd = sd(systolic, na.rm = TRUE),
            n = sum(!is.na(systolic)))
print(means)   # A 129.4 (sd 15.1, n 121), B 134.2 (sd 11.9, n 120)
bars <- ggplot(means, aes(group, mean)) + geom_col() +
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.2) +
  labs(x = "Group", y = "Systolic pressure (mmHg), mean and sd")
save_plot(bars, "10_bar_of_means")
# Two bars and two error bars. Nothing says group A holds two kinds of patient.

# The same data as points, colored by the original label from patients_raw. The 40
# rows that read "A " (a trailing space) are the second recruitment site from Session 1.
by_site <- patients_raw %>%
  mutate(site = if_else(group == "A ", "second site", "first site"),
         group = str_trim(group))
points <- ggplot(by_site, aes(group, systolic, color = site)) +
  geom_jitter(width = 0.15, height = 0, alpha = 0.7) +
  labs(x = "Group", y = "Systolic pressure (mmHg)", color = "Site")
save_plot(points, "10_points_by_site")
print(by_site %>%
        filter(group == "A") %>%
        group_by(site) %>%
        summarise(n = sum(!is.na(systolic)), mean = round(mean(systolic, na.rm = TRUE), 1)))
# first site: n 81, mean 136.2 / second site: n 40, mean 115.5. The points show it and
# the bars hide it. Under about 30 points per group, plot the points. With more, a box
# plot at least.
save_plot(ggplot(by_site, aes(group, systolic)) +
            geom_boxplot(outlier.shape = NA) +
            geom_jitter(aes(color = site), width = 0.15, height = 0, alpha = 0.6) +
            labs(x = "Group", y = "Systolic pressure (mmHg)", color = "Site"),
          "10_systolic_box_by_group")

# --- 3d. Facets --------------------------------------------------------------
section("3d: facets")

# facet_wrap() makes one small plot per level. Every panel shares the same axes by
# default, so the panels compare honestly.
save_plot(ggplot(penguins, aes(bill_length_mm, body_mass_g)) +
            geom_point(alpha = 0.6) + facet_wrap(~ species),
          "10_facet_wrap", width = 7, height = 3)
# facet_grid(rows ~ columns) uses two grouping variables.
print(table(penguins$species, penguins$island))
# Adelie is on all three islands (44, 56, 52), Chinstrap only on Dream (68) and Gentoo
# only on Biscoe (124). So 5 of the 9 panels hold data. A grid shows which combinations
# exist, and for Chinstrap and Gentoo an island effect cannot be separated from a species
# effect.
save_plot(ggplot(penguins, aes(bill_length_mm, body_mass_g)) +
            geom_point(alpha = 0.6) + facet_grid(island ~ species),
          "10_facet_grid", width = 7, height = 5)
# Past 3 or 4 groups, facet instead of coloring.

# --- 3e. Labels and the three plotting sins ----------------------------------
section("3e: labels, scales and chart junk")

# A figure for a reader names each axis with units and states the finding. The viridis
# palette survives grayscale printing and most kinds of color blindness.
polished <- ggplot(penguins, aes(bill_length_mm, body_mass_g, color = species)) +
  geom_point(alpha = 0.7) +
  scale_color_viridis_d(end = 0.85) +
  labs(title = "Longer bills go with heavier penguins in all three species",
       x = "Bill length (mm)", y = "Body mass (g)", color = "Species") +
  theme_minimal(base_size = 12)
save_plot(polished, "10_polished")

# The three sins: chart junk (3D bars, shadows, gridlines with no data), ambiguous
# labels ("value" is not a label), and misleading scales. Here is the same bar chart
# of means twice. Bars must start at zero, because their length is the data.
group_means <- patients %>% group_by(group) %>% summarise(mean = mean(systolic, na.rm = TRUE))
honest <- ggplot(group_means, aes(group, mean)) + geom_col() +
  labs(x = "Group", y = "Mean systolic pressure (mmHg)")
save_plot(honest, "10_bars_from_zero", width = 3.5, height = 3.2)
save_plot(honest + coord_cartesian(ylim = c(125, 135)), "10_bars_truncated",
          width = 3.5, height = 3.2)
print(round(group_means$mean, 1))                                              # 129.4 134.2
print(round(group_means$mean[2] / group_means$mean[1], 3))                     # 1.037
print(round((group_means$mean[2] - 125) / (group_means$mean[1] - 125), 1))     # 2.1
# Cut at 125 and B's bar looks 2.1 times as tall as A's, for a 3.7% difference.

# --- 3f. Saving a figure at the size it will be printed ----------------------
section("3f: ggsave() and combining panels")

# ggsave() takes the size in inches, so the text stays readable at the size on the
# page. Many journals ask for about 3.5 inches (one column) or 7 inches (two columns).
# dpi = 300 is the usual minimum for a raster figure: 7 inches is 2100 pixels wide.
dir.create("figures", showWarnings = FALSE)
suppressWarnings(ggsave("figures/10_figure1.png", polished, width = 7, height = 4, dpi = 300))
# A vector format has no resolution, so it stays sharp at any size.
suppressWarnings(ggsave("figures/10_figure1.pdf", polished, width = 7, height = 4))
cat("saved figures/10_figure1.png (2100 x 1200 pixels) and figures/10_figure1.pdf\n")
# Save with code, not the export button: a script rebuilds the figure when a
# reviewer asks for a change.

# patchwork (optional) puts two plots in one figure. a | b is side by side, a / b is
# stacked, and plot_annotation() adds the panel letters. Fall 2025 Session 8 used it.
# Session 13 comes back to it. install.packages("patchwork")
if (requireNamespace("patchwork", quietly = TRUE)) {
  library(patchwork)
  combo <- (bars | points) + plot_annotation(tag_levels = "A")
  suppressWarnings(ggsave("figures/10_combined.png", combo, width = 9, height = 3.8, dpi = 150))
  cat("saved figures/10_combined.png\n")
}

# --- 3g. Plots that check a model: residuals and the QQ plot -----------------
section("3g: diagnostic plots")

# A residual is what the model did not explain: observed minus fitted. Diagnostic
# plots look at the residuals to see whether the model is a fair description. This is
# the Fall 2025 Session 10 material. Session 11 fits models in earnest.
fit <- lm(body_mass_g ~ flipper_length_mm, data = penguins)
print(round(summary(fit)$r.squared, 3))   # 0.759
print(round(coef(fit), 2))                # intercept -5780.83, slope 49.69 g per mm

# plot(fit) draws four standard plots from a fitted model: residuals vs fitted, the QQ
# plot, scale-location and residuals vs leverage. Part 3h reads all four.
png("figures/10_diagnostics_base.png", width = 9, height = 6, units = "in", res = 120)
par(mfrow = c(2, 2))
plot(fit)
dev.off()
cat("saved figures/10_diagnostics_base.png\n")

# Residuals vs fitted: you want a shapeless cloud around zero. A curve means the line
# is the wrong shape and a funnel means the spread changes. Colored by species, the
# residuals show structure the line missed.
resid_df <- penguins %>%
  filter(!is.na(body_mass_g), !is.na(flipper_length_mm)) %>%
  mutate(fitted = fitted(fit), resid = resid(fit))
save_plot(ggplot(resid_df, aes(fitted, resid, color = species)) +
            geom_hline(yintercept = 0, linetype = "dashed") + geom_point() +
            labs(x = "Fitted body mass (g)", y = "Residual (g)", color = "Species"),
          "10_residuals_vs_fitted")
print(resid_df %>% group_by(species) %>% summarise(mean_resid = round(mean(resid))))
# Adelie 44, Chinstrap -216, Gentoo 66. Chinstrap sits below the line. Adding species
# raises R-squared from 0.759 to 0.783 (Session 11).
print(round(summary(lm(body_mass_g ~ flipper_length_mm + species, data = penguins))$r.squared, 3))

# QQ plot: sorted values against what a normal distribution would give. Points on the
# line mean normal. Ends that peel away mean skew or extreme values. This is systolic
# pressure by group, the data behind the Session 1 test.
save_plot(ggplot(filter(patients, !is.na(systolic)), aes(sample = systolic)) +
            stat_qq() + stat_qq_line() + facet_wrap(~ group) +
            labs(x = "Theoretical quantiles", y = "Systolic pressure (mmHg)"),
          "10_qq_by_group", width = 6, height = 3)
a_sys <- patients %>% filter(group == "A", !is.na(systolic)) %>% pull(systolic)
b_sys <- patients %>% filter(group == "B", !is.na(systolic)) %>% pull(systolic)
print(round(c(A = shapiro.test(a_sys)$p.value, B = shapiro.test(b_sys)$p.value), 3))   # A 0.018, B 0.471
# Group A's ends curl away from the line (p = 0.018) and group B follows it. A QQ plot
# drawn before the t-test would have flagged group A, as Session 9's histogram did.
# Cook's distance in the flipper model peaks at 0.039, far below 1: no one penguin pulls
# the fit.

# --- 3h. Reading the four plots from plot(fit): unusual schools --------------
section("3h: leverage and Cook's distance")

# A model with some unusual points: the number of students with a disability against
# total enrollment at the 169 Metro Nashville schools. total is the sum of the 15 grade
# columns. A missing grade count means the grade is not offered, so na.rm = TRUE.
schools_fit <- schools %>%
  mutate(total = rowSums(across(starts_with("grade_")), na.rm = TRUE))
fit2 <- lm(disability ~ total, data = schools_fit)
print(round(summary(fit2)$r.squared, 3))   # 0.598
print(round(coef(fit2), 4))                # intercept 8.2973, slope 0.1097

# The four panels. Each checks a different assumption, and the same school can show up in
# several. The numbers on the points are row numbers. Then Cook's distance as bars.
png("figures/10_four_plots_schools.png", width = 9, height = 6, units = "in", res = 150)
par(mfrow = c(2, 2))
plot(fit2)
dev.off()
png("figures/10_cooks_distance_schools.png", width = 7, height = 3, units = "in", res = 150)
plot(fit2, which = 4)
dev.off()
cat("saved figures/10_four_plots_schools.png and figures/10_cooks_distance_schools.png\n")

# Who are the unusual points?
cd <- cooks.distance(fit2)
top <- order(cd, decreasing = TRUE)[1:3]
print(top)                       # 102 53 99
print(round(cd[top], 3))         # 0.398 0.314 0.303: none reaches 0.5
print(schools_fit %>%
        slice(top) %>%
        transmute(school_name, school_level, total, disability,
                  fitted = round(fitted(fit2)[top], 1),
                  residual = round(resid(fit2)[top], 1),
                  leverage = round(hatvalues(fit2)[top], 3)))
# McGavock High (102): 2276 students, the most leverage (0.166), near the line.
# Harris-Hillman Special Education (53): 335 students with a disability against 95.9
#   predicted, a residual of +239.1, but ordinary leverage (0.010).
# Martin Luther King Jr School (99): 23 with a disability against 146.7, a residual of -123.7.
# A point needs both a large residual and high leverage to be influential. All three are
# real schools, not entry errors, and none crosses a Cook's contour.

# What to do with an unusual point: check it, refit without it, and report both fits.
refit <- function(drop) {
  f <- lm(disability ~ total, data = schools_fit[-drop, ])
  round(c(slope = unname(coef(f)[2]), r_squared = summary(f)$r.squared), 3)
}
print(refit(102))            # without McGavock:        slope 0.104, R-squared 0.533
print(refit(53))             # without Harris-Hillman:  slope 0.106, R-squared 0.686
print(refit(c(53, 102)))     # without both:            slope 0.099, R-squared 0.627
# The full fit is slope 0.110 and R-squared 0.598.


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
