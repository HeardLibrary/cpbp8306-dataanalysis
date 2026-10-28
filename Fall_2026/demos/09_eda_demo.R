# Session 9 demo: Exploratory Data Analysis (R)
#
# Every code snippet from the Session 9 slides, in slide order. Each block says what
# the code does and what you should see, so you can check your own output against
# the comments.
#
# It uses the same three datasets as Sessions 7 and 8: penguins, patients and
# schools. Nothing is made up.
#
# Put these two files next to this script, then run:  Rscript 09_eda_demo.R
#   patients.csv         Brightspace
#   schools_tibble.csv   Brightspace
# penguins comes from the palmerpenguins package, so it needs no file.
#
# Plots are saved as PNG files in a folder called demo09_figures, so the script
# also works when you run it from a terminal. To see a plot on screen instead,
# run the ggplot() line by itself in RStudio.
#
# Needs the packages dplyr, readr, stringr, ggplot2, palmerpenguins, skimr and
# DataExplorer (slide 10). naniar is optional (slide 9).

section <- function(title) {
  cat("\n", strrep("=", 70), "\n", title, "\n", strrep("=", 70), "\n", sep = "")
}

# ---------------------------------------------------------------------------
# Slide 2: load the data
# ---------------------------------------------------------------------------
section("Slide 2: load the data")

# Install once. The check keeps this script safe to run again.
for (pkg in c("palmerpenguins", "skimr", "ggplot2", "DataExplorer")) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}

library(dplyr)           # filter, select, mutate, group_by, summarise
library(readr)           # read_csv
library(stringr)         # str_trim, str_to_upper
library(palmerpenguins)  # the penguins data
library(ggplot2)         # plots

# read_csv() removes spaces at the start and end of text values unless you set
# trim_ws = FALSE. We keep them, so the original "A " label is still there to find.
raw <- read_csv("patients.csv", trim_ws = FALSE, show_col_types = FALSE)

# The Session 8 cleaning, in a few lines. as.numeric() warns because six ages say
# "unknown". That warning is expected.
patients <- raw %>%
  mutate(group = str_trim(group),
         sex = str_to_upper(sex),
         age = as.numeric(age))

df <- penguins           # df is the penguins table in both languages

print(dim(patients))     # 250 9
print(dim(df))           # 344 8   (includes year)
print(table(patients$group))   # A 125, B 125: the Session 8 cleaning worked

# R reads visit_date as a date and turns the impossible date 2026-02-30 into NA.
# pandas keeps it as text. We come back to this on slide 9.
print(class(patients$visit_date))   # "Date"

dir.create("demo09_figures", showWarnings = FALSE)
save_plot <- function(p, name) {
  path <- file.path("demo09_figures", paste0(name, ".png"))
  suppressWarnings(ggsave(path, p, width = 6, height = 3.6, dpi = 150))
  cat("saved", path, "\n")
}


# ---------------------------------------------------------------------------
# Slide 4: the one-shot summary, read like a diagnostic
# ---------------------------------------------------------------------------
section("Slide 4: numerical summaries")

nums <- patients %>% select(age, systolic, diastolic, cholesterol)

# summary() gives the minimum, quartiles, mean, maximum and the number of NAs.
print(summary(nums))
# age: 22 to 89, mean 56.42, 6 NA
# systolic: 87.5 to 170.9, mean 131.8, median 133.7, 9 NA
# diastolic: 52.2 to 110.9, mean 81.55, 7 NA
# cholesterol: 106.5 to 292.1, mean 195.4, 22 NA

# skim() adds the share of values that are present and a tiny histogram per column.
print(skimr::skim(nums))
# cholesterol complete_rate 0.912: 22 of 250 are missing, 8.8%

# Questions to ask of any summary:
#   Is each mean plausible? Is each range possible? Is the median far from the mean?
#   How many values are missing?
# The median of systolic (133.7) is a little above the mean (131.8), a hint of a
# tail on the low side. We find out why on slide 7.
print(round(mean(patients$systolic, na.rm = TRUE) - median(patients$systolic, na.rm = TRUE), 1))   # -1.9

# For a categorical column, count the values and check the balance.
print(table(patients$group))   # A 125, B 125


# ---------------------------------------------------------------------------
# Slide 5: three plots you make every time you touch new data
# ---------------------------------------------------------------------------
section("Slide 5: histogram, box plot, scatter plot")

# Histogram: the shape of one variable. Look for two peaks, long tails, spikes.
# Penguin bill lengths have two clusters, a hint that another variable is mixed in.
p_hist <- ggplot(df, aes(bill_length_mm)) + geom_histogram(bins = 30)
save_plot(p_hist, "05_histogram")

# Box plot: one variable across groups. Do the groups overlap? Any dots beyond
# the whiskers? Adelie sits lower. Gentoo has one dot above its whisker.
p_box <- ggplot(df, aes(species, bill_length_mm)) + geom_boxplot()
save_plot(p_box, "05_boxplot")

# Scatter plot: two variables, colored by group. Look at direction, curves,
# and whether the groups differ. Three clouds, one per species.
p_scatter <- ggplot(df, aes(bill_length_mm, body_mass_g, color = species)) + geom_point()
save_plot(p_scatter, "05_scatter")
# ggplot() warns about rows removed because of missing values. Two penguins have
# no measurements.


# ---------------------------------------------------------------------------
# Slide 6: Simpson's paradox
# ---------------------------------------------------------------------------
section("Slide 6: Simpson's paradox")

# Overall, deeper bills go with shorter bills.
print(round(cor(df$bill_length_mm, df$bill_depth_mm, use = "complete.obs"), 2))   # -0.24

# Inside each species, deeper bills go with longer bills.
by_species <- df %>%
  group_by(species) %>%
  summarise(r = cor(bill_length_mm, bill_depth_mm, use = "complete.obs"))
print(by_species)   # Adelie 0.39, Chinstrap 0.65, Gentoo 0.64
# The species differ in both measurements, and that difference hides the pattern
# inside each one. Color by group before you trust a trend.

p_overall <- ggplot(df, aes(bill_length_mm, bill_depth_mm)) +
  geom_point() + geom_smooth(method = "lm", se = FALSE)
p_split <- ggplot(df, aes(bill_length_mm, bill_depth_mm, color = species)) +
  geom_point() + geom_smooth(method = "lm", se = FALSE)
save_plot(p_overall, "06_simpson_overall")
save_plot(p_split, "06_simpson_by_species")


# ---------------------------------------------------------------------------
# Slide 7: the plot Session 1 was missing
# ---------------------------------------------------------------------------
section("Slide 7: the reveal")

# Group A systolic pressure, after the Session 8 cleaning.
a <- patients %>% filter(group == "A")
print(nrow(a))                     # 125 rows
print(sum(!is.na(a$systolic)))     # 121 with a recorded systolic value
p_a <- ggplot(a, aes(systolic)) + geom_histogram(binwidth = 5)
save_plot(p_a, "07_group_a")
# Not one clean peak: there is a second bump on the low side, around 115 to 120.

# Why? Keep the original label in its own column BEFORE cleaning, then color by it.
# The 40 rows that read "A " are a second recruitment site.
a_site <- raw %>%
  filter(str_trim(group) == "A") %>%
  mutate(site = if_else(group == "A ", "second site", "first site"))
p_site <- ggplot(a_site, aes(systolic, fill = site)) + geom_histogram(binwidth = 5)
save_plot(p_site, "07_group_a_by_site")

print(a_site %>%
        group_by(site) %>%
        summarise(n = sum(!is.na(systolic)), mean = round(mean(systolic, na.rm = TRUE), 1)))
# first site: n 81, mean 136.2 / second site: n 40, mean 115.5

# The naive test from Lecture 1 kept only group == "A" (no trailing space).
# It quietly dropped the second site.
naive_a <- raw %>% filter(group == "A") %>% pull(systolic)
group_b <- patients %>% filter(group == "B") %>% pull(systolic)
print(t.test(naive_a, group_b, var.equal = TRUE)$p.value)         # 0.2152, "no difference"
all_a <- patients %>% filter(group == "A") %>% pull(systolic)
print(t.test(all_a, group_b, var.equal = TRUE)$p.value)           # 0.0064, a real difference
print(round(c(mean(all_a, na.rm = TRUE), mean(group_b, na.rm = TRUE)), 1))   # 129.4 134.2
# The silent data loss produced a false negative. One histogram, drawn before the
# test, would have shown two groups of patients mixed together.


# ---------------------------------------------------------------------------
# Slide 8: a correlation matrix, read half of it
# ---------------------------------------------------------------------------
section("Slide 8: correlation")

# Select the four measurements by name. Taking every numeric column would pull in year.
penguin_cor <- df %>%
  select(bill_length_mm:body_mass_g) %>%
  cor(use = "pairwise.complete.obs")
print(round(penguin_cor, 2))
# The diagonal is 1 and the matrix is symmetric, so read one triangle.
# flipper_length_mm and body_mass_g: 0.87, the strongest pair.
# bill_depth_mm is negative with the other three (the Simpson's paradox again).

# Two predictors above 0.9 would be multicollinear. 0.87 is close enough to flag.
print(round(max(penguin_cor[upper.tri(penguin_cor)]), 2))   # 0.87

# A rank-based correlation is more robust to skew and outliers.
print(round(df %>% select(bill_length_mm:body_mass_g) %>%
              cor(use = "pairwise.complete.obs", method = "spearman"), 2))
# flipper and body mass: 0.84

# The patients: systolic and diastolic move together. Cholesterol relates to nothing.
print(round(cor(nums, use = "pairwise.complete.obs"), 2))
# systolic and diastolic: 0.88 / cholesterol with the others: 0.03 to 0.04
# A real variable that is unrelated to the others is a legitimate finding.


# ---------------------------------------------------------------------------
# Slide 9: three problems, and what each one is called
# ---------------------------------------------------------------------------
section("Slide 9: missing values, outliers, impossible values")

# 1. Missing values: where, how many, and why?
print(colSums(is.na(patients)))
# age 6, systolic 9, diastolic 7, cholesterol 22, visit_date 1 (see below)
print(table(patients$group, is.na(patients$cholesterol)))   # 11 missing in each group

# The schools file is different. A missing grade usually means "not offered".
schools <- read_csv("schools_tibble.csv", show_col_types = FALSE)
grades <- schools %>% select(starts_with("grade_"))
print(sum(is.na(grades)))                      # 1667 empty cells out of 2535
print(sum(is.na(schools$grade_pre_k_3yrs)))    # 130
middle <- schools %>% filter(school_level == "Middle School")
print(c(missing = sum(is.na(middle$grade_9)), schools = nrow(middle)))   # 31 of 31
# Filling these with 0 would be wrong. Leave them missing.

# Optional: naniar draws the pattern of missingness in one call.
if (requireNamespace("naniar", quietly = TRUE)) {
  save_plot(naniar::vis_miss(patients), "09_missingness")
}

# 2. Outliers: a real extreme value, or an entry error?
print(boxplot.stats(patients$systolic)$out)
# 88.1 99.8 96.1 98.3 87.5 93.4 97.1 170.9: eight values beyond the whiskers
# Four of them are second-site patients (87.5, 88.1, 93.4, 97.1), so they are real.
# Never delete an outlier because the p-value would look better without it.
print(boxplot.stats(df$body_mass_g)$out)       # integer(0): no penguin outliers

# 3. Impossible values: could this value exist at all?
# read_csv() already turned the impossible date into NA (and warned when it read it).
print(patients %>% filter(is.na(visit_date)) %>% select(patient_id, group, visit_date))
# P094, group B, NA. The original text is gone, so read the column as text to see it:
raw_text <- read_csv("patients.csv", col_types = cols(visit_date = col_character()))
print(raw_text %>% filter(patient_id == "P094") %>% select(patient_id, visit_date))   # 2026-02-30
# as.Date() on its own raises an error for this value.
print(tryCatch(as.Date("2026-02-30"), error = function(e) conditionMessage(e)))
# No row has systolic below diastolic, another check for impossible values.
print(sum(patients$systolic < patients$diastolic, na.rm = TRUE))   # 0

# The rule that matters most: write down what you decided and why. Every value you
# drop or fill in gets one sentence in your notebook.


# ---------------------------------------------------------------------------
# Slide 10: DataExplorer, the whole first look in one call
# ---------------------------------------------------------------------------
section("Slide 10: DataExplorer")

library(DataExplorer)

# introduce() is the overview of slide 4 as a one-row table: rows, columns, how many
# are text and how many are numbers, and how many values are missing.
print(as.data.frame(t(introduce(patients))))
# rows 250, columns 9, discrete 5, continuous 4, total_missing_values 45,
# complete_rows 208, total_observations 2250
# 45 is the 44 missing numbers from slide 9 plus the one visit_date that read_csv()
# turned into NA. 208 of 250 rows (83.2%) have no missing value at all.

# profile_missing() is the table behind plot_missing(): count and share per column.
print(profile_missing(patients))   # cholesterol 22, 0.088 is the largest

# DataExplorer's plot_ functions draw the plot as soon as they run, so to save one we
# open a PNG device first. This helper does that.
save_de <- function(plot_call, name, width = 6, height = 4) {
  path <- file.path("demo09_figures", paste0(name, ".png"))
  png(path, width = width, height = height, units = "in", res = 150)
  invisible(suppressWarnings(plot_call))   # evaluating the call draws the plot
  dev.off()
  cat("saved", path, "\n")
}
save_de(plot_intro(patients), "09_de_intro")       # the table above, as bars
save_de(plot_missing(patients), "09_de_missing")   # percent missing for each column

# plot_histogram() draws every numeric column, so patients get four panels at once.
# plot_bar() draws every text column. Columns with more than 50 distinct values
# (patient_id, visit_date) are skipped, and the console says so.
save_de(plot_histogram(patients), "09_de_histograms", 7, 5)
save_de(plot_bar(patients), "09_de_bars", 7, 4)

# The check that would have caught Session 1. Run plot_bar() on the RAW table, the one
# read with trim_ws = FALSE. It draws two bars labeled A (85 and 40 rows), plus four
# spellings of sex (M, F, m, f). The cleaned table has only A and B, and M and F.
print(table(raw$group))   # "A" 85, "A " 40, "B" 125
print(table(raw$sex))     # f 9, F 112, m 10, M 119
save_de(plot_bar(raw %>% select(group, sex)), "09_de_bars_raw", 6, 3)

# A gotcha. plot_correlation() uses every row by default, so any pair that includes a
# column with an NA comes out grey. Ask for pairwise.complete.obs, as on slide 8.
save_de(plot_correlation(nums), "09_de_corr_default", 5, 4)   # grey, only the diagonal
save_de(plot_correlation(nums, cor_args = list(use = "pairwise.complete.obs")),
        "09_de_corr_pairwise", 5, 4)
# systolic and diastolic 0.88, cholesterol 0.03 to 0.04 with the others, as before.

# create_report() bundles all of this into one HTML file: basic statistics, data
# structure, missing data profile, univariate distributions (histograms, bar charts,
# QQ plots), correlation analysis, principal component analysis, and bivariate
# distributions (box plots and scatter plots, split by the y column). It takes a few
# seconds and needs pandoc, which RStudio includes.
if (rmarkdown::pandoc_available()) {
  create_report(patients %>% select(-patient_id, -visit_date), y = "group",
                output_file = "09_dataexplorer_report.html",
                output_dir = "demo09_figures", quiet = TRUE)
  cat("saved demo09_figures/09_dataexplorer_report.html. Open it in a browser.\n")
}
# The report draws the shape of every column. It cannot tell you why a column looks
# odd. The second bump in group A (slide 7) is in the histograms, but nothing in the
# report says it is a second recruitment site.


# ---------------------------------------------------------------------------
# Try it yourself
# ---------------------------------------------------------------------------
# 1. Change binwidth = 5 to binwidth = 2 in the group A histogram. Does the second
#    bump get clearer or noisier?
# 2. Make the box plot for body_mass_g instead of bill_length_mm. Do the species overlap more?
# 3. Compute the Simpson's paradox correlations for bill_length_mm and flipper_length_mm.
#    Does the sign flip inside the species?
# 4. Run summary() on the schools grade_9 column. What does the NA count tell you?
# 5. Run create_report() on penguins with y = "species". Which section shows that
#    flipper length and body mass move together?
