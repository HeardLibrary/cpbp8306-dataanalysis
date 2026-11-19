# =============================================================================
# Session 12 (R version): Choosing, checking, and reading statistical tests
# CPBP 8306-02, November 19, 2026
# =============================================================================
# This script covers the same material as session12_statistical_tests.ipynb,
# using R. We work through the notebook in class; this file is a resource
# for anyone who prefers R. Each section has the same number as in the notebook,
# and the comments give the output you should see, so you can check your results.
#
# Three questions to answer before you run any test:
#   1. What kind of variable is the outcome? Continuous or categorical?
#   2. What is it compared across? A reference value, 2 groups, 3+ groups,
#      or a continuous predictor?
#   3. Are the observations independent, or paired (same subjects twice)?
#
#   Outcome      Compared across         Test                 R function
#   continuous   a reference value       one-sample t-test    t.test(x, mu = ...)
#   continuous   2 paired measurements   paired t-test        t.test(x, y, paired = TRUE)
#   continuous   2 independent groups    Welch's t-test       t.test(y ~ group)
#   continuous   3+ independent groups   one-way ANOVA        aov(y ~ group)
#   categorical  another categorical     chi-square           chisq.test(table)
#   continuous   continuous predictor    linear regression    lm(y ~ x)
#   Rank-based alternatives: wilcox.test(), kruskal.test(). Small 2x2 tables:
#   fisher.test().
#
# Data: patients.csv (course data) and penguins (the palmerpenguins package).
# Put patients.csv next to this script, or the script reads it from the course
# GitHub. Set your working directory to this folder (Session > Set Working
# Directory > To Source File Location in RStudio).
#
# Packages: dplyr, readr, stringr, ggplot2, palmerpenguins. Nothing else is
# required. Effect sizes are computed by hand so you can see the formulas. The
# effectsize package does the same in one line each (cohens_d(), eta_squared(),
# cramers_v()) if you want to install it.
# =============================================================================

section <- function(title) {
  cat("\n", strrep("=", 70), "\n", title, "\n", strrep("=", 70), "\n", sep = "")
}


# -----------------------------------------------------------------------------
# 0. Setup
# -----------------------------------------------------------------------------
section("0. Setup")

for (pkg in c("dplyr", "readr", "stringr", "ggplot2", "palmerpenguins")) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
library(dplyr)
library(readr)
library(stringr)
library(ggplot2)
library(palmerpenguins)

set.seed(8306)   # so the simulations repeat. R's random numbers differ from
                 # Python's, so simulated results won't match the notebook exactly.

# read_csv() trims spaces by default, which would hide the Session 1 bug.
# trim_ws = FALSE keeps "A " so the cleaning step below is the one that fixes it.
patients_file <- if (file.exists("patients.csv")) "patients.csv" else
  "https://raw.githubusercontent.com/HeardLibrary/cpbp8306-dataanalysis/main/Fall_2026/data/patients.csv"
raw <- read_csv(patients_file, trim_ws = FALSE, show_col_types = FALSE,
                col_types = cols(visit_date = col_character()))

# The Session 8 cleaning. as.numeric() warns about the six "unknown" ages: expected.
patients <- raw %>%
  mutate(group = str_trim(group),
         sex   = str_to_upper(sex),
         age   = suppressWarnings(as.numeric(age)))

print(table(patients$group))   # A 125, B 125
df <- penguins                 # 344 x 8
print(dim(df))


# -----------------------------------------------------------------------------
# 1. What a p-value is (and isn't)
# -----------------------------------------------------------------------------
# The p-value: if there were truly no effect, how often would random sampling
# give a result at least this extreme? It is NOT the probability that the null
# is true, and it is NOT a measure of effect size.
section("1. p-values: two simulations")

# Simulation 1: two groups from the SAME population, 1,000 times.
# replicate() runs an expression many times and collects the results.
p_null <- replicate(1000, t.test(rnorm(30, 130, 12), rnorm(30, 130, 12))$p.value)
cat("share of p < 0.05 with no real difference:", mean(p_null < 0.05), "\n")   # about 0.05

# Simulation 2: a 1 mmHg true difference, small vs. huge samples.
for (n in c(20, 5000)) {
  x <- rnorm(n, 131, 12); y <- rnorm(n, 130, 12)
  d <- (mean(x) - mean(y)) / sqrt((var(x) + var(y)) / 2)
  cat(sprintf("n = %4d per group: p = %.4f, d = %.2f\n", n, t.test(x, y)$p.value, d))
}
# With n = 5000, a trivial difference (d about 0.1) is "highly significant."
# Report the p-value, the effect size, and the confidence interval.


# -----------------------------------------------------------------------------
# 2. Two groups: t-tests
# -----------------------------------------------------------------------------
# Question: does systolic pressure differ between groups A and B?
section("2. Two groups: Welch's t-test")

# Look first. Group A is lower, more spread out, and has a long low tail
# (Session 9: it mixes two recruitment sites).
print(
  ggplot(patients, aes(x = systolic, fill = group)) +
    geom_histogram(binwidth = 5, position = "identity", alpha = 0.5) +
    labs(x = "Systolic (mmHg)", y = "Count", title = "Systolic pressure by group")
)

# The formula interface: outcome ~ group. t.test() drops missing values itself,
# unlike SciPy, which returns nan. R's t.test() is Welch's by default
# (var.equal = FALSE); SciPy's ttest_ind() is Student's by default.
welch <- t.test(systolic ~ group, data = patients)
print(welch)
#   t = -2.7547, df = 227.39, p-value = 0.00635
#   95 percent confidence interval: -8.255863 -1.370253
#   mean in group A 129.3669, mean in group B 134.1800
#
# How to read it: t is the difference in means divided by its standard error.
# Its sign depends on the order (A minus B; groups are in alphabetical order).
# The CI is for mean(A) - mean(B). The df is a fraction because Welch's test
# estimates it.

# Every number is also stored in the result, which is how you put it in a report:
welch$statistic; welch$parameter; welch$p.value; welch$conf.int

# Effect size: Cohen's d = difference in means / pooled SD.
# Rough guide: 0.2 small, 0.5 medium, 0.8 large.
cohens_d <- function(x, y) {
  x <- na.omit(x); y <- na.omit(y)
  nx <- length(x); ny <- length(y)
  pooled_sd <- sqrt(((nx - 1) * var(x) + (ny - 1) * var(y)) / (nx + ny - 2))
  (mean(x) - mean(y)) / pooled_sd
}
a <- patients$systolic[patients$group == "A"]
b <- patients$systolic[patients$group == "B"]
cat("Cohen's d =", round(cohens_d(a, b), 2), "\n")   # -0.35

# Report: Group A's mean systolic pressure was 4.8 mmHg lower than group B's
# (129.4 vs. 134.2 mmHg; Welch's t(227.4) = -2.75, p = 0.006,
# 95% CI [-8.3, -1.4], d = -0.35).

# --- Assumptions ----------------------------------------------------------------
# Independence: study design (different patients in A and B).
# Normality within groups: plot first. Shapiro-Wilk is a supplement only:
# it flags trivial departures in big samples and misses big ones in small samples.
print(shapiro.test(a))   # W = 0.97373, p-value = 0.01811 (group A is a mixture)
print(shapiro.test(b))   # W = 0.98926, p-value = 0.4708

qqnorm(na.omit(a), main = "Group A: normal QQ plot"); qqline(na.omit(a))

# Equal variances (only matters for Student's t-test). Levene's test, median
# version (Brown-Forsythe) = an ANOVA on each value's distance from its group
# median. car::leveneTest() gives the same answer.
levene <- function(y, g) {
  keep <- !is.na(y)
  y <- y[keep]; g <- factor(g[keep])
  dev <- abs(y - ave(y, g, FUN = median))
  anova(lm(dev ~ g))
}
print(levene(patients$systolic, patients$group))   # F = 5.93, p = 0.0156

# The rank-based alternative: Mann-Whitney U (R calls it the Wilcoxon rank-sum
# test). It asks whether values in one group tend to be larger; it is not a
# test of medians. Use it as a sensitivity check.
print(wilcox.test(systolic ~ group, data = patients))
#   W = 6082, p-value = 0.02955. Same conclusion as the t-test.

# --- The paired trap ---------------------------------------------------------------
# A SIMULATED follow-up: 25 patients, a drug that lowers pressure by about 4 mmHg.
section("2b. Paired data")

baseline <- rnorm(25, 135, 14)
followup <- baseline - rnorm(25, 4, 4)

print(t.test(baseline, followup)$p.value)                  # wrong: large p
print(t.test(baseline, followup, paired = TRUE)$p.value)   # right: tiny p
diff <- baseline - followup
print(t.test(diff, mu = 0)$p.value)                        # identical to paired
cat("mean drop =", round(mean(diff), 1), "mmHg, d_z =",
    round(mean(diff) / sd(diff), 2), "\n")
# The independent test buries a real change under the spread BETWEEN patients.
# A paired t-test is a one-sample t-test on the differences. The two vectors
# must be in the same subject order.


# -----------------------------------------------------------------------------
# 3. Three or more groups: one-way ANOVA
# -----------------------------------------------------------------------------
# Question: does body mass differ among the three penguin species?
# Three separate t-tests would give about a 14% chance of at least one false
# positive (1 - 0.95^3). ANOVA asks one question first.
section("3. One-way ANOVA")

print(
  ggplot(df, aes(x = species, y = body_mass_g)) +
    geom_boxplot() +
    geom_jitter(width = 0.15, size = 0.6, alpha = 0.4) +
    labs(x = "Species", y = "Body mass (g)", title = "Body mass by species")
)

df %>%
  group_by(species) %>%
  summarise(n = sum(!is.na(body_mass_g)),
            mean = mean(body_mass_g, na.rm = TRUE),
            sd = sd(body_mass_g, na.rm = TRUE))
#   Adelie 151, 3701, 459 / Chinstrap 68, 3733, 384 / Gentoo 123, 5076, 504

fit_aov <- aov(body_mass_g ~ species, data = df)   # 2 rows with NA dropped
print(summary(fit_aov))
#               Df    Sum Sq  Mean Sq F value Pr(>F)
#   species      2 146864214 73432107   343.6 <2e-16 ***
#   Residuals  339  72443483   213698
#
# Sum Sq splits the variation into between-species and within-species
# (residual). F = between-group variance / within-group variance. "<2e-16" is
# R's floor for printing; report p < 0.001. Report both df: F(2, 339) = 343.6.

# Effect size: eta squared = share of the variation explained by species.
ss <- summary(fit_aov)[[1]][["Sum Sq"]]
cat("eta squared =", round(ss[1] / sum(ss), 2), "\n")   # 0.67

# ANOVA is a linear model with a categorical predictor; anova(lm(...)) gives
# the same table.
print(anova(lm(body_mass_g ~ species, data = df)))

# Assumptions: independence, roughly normal residuals, similar variances.
print(levene(df$body_mass_g, df$species))               # F = 5.12, p = 0.0064
print(oneway.test(body_mass_g ~ species, data = df))    # Welch's ANOVA: F = 317.57, denom df = 189.48
print(kruskal.test(body_mass_g ~ species, data = df))   # Kruskal-Wallis chi-squared = 217.6
# All three agree. Assumptions matter most when a result is borderline.

# Post-hoc: which species differ? Tukey's HSD holds the family-wise error at 5%.
print(TukeyHSD(fit_aov))
#                         diff        lwr       upr     p adj
#   Chinstrap-Adelie    32.43 -126.50     191.35  0.8807
#   Gentoo-Adelie     1375.35 1243.18    1507.53  0.0000
#   Gentoo-Chinstrap  1342.93 1178.48    1507.37  0.0000
# Gentoo are about 1,350 g heavier; Adelie and Chinstrap don't differ (the CI
# includes 0). "diff" is the first species named minus the second.

# Or run pairwise tests yourself and correct the p-values. Holm is the default
# in pairwise.t.test(); pool.sd = FALSE gives Welch-style tests.
print(pairwise.t.test(df$body_mass_g, df$species, p.adjust.method = "holm",
                      pool.sd = FALSE))
# p.adjust(c(p1, p2, p3), method = "holm") corrects any vector of p-values.


# -----------------------------------------------------------------------------
# 4. Two categorical variables: chi-square test of independence
# -----------------------------------------------------------------------------
# Question: is sex associated with species? The test needs a table of COUNTS.
section("4. Chi-square")

tab <- table(df$species, df$sex)   # table() drops the 11 penguins with missing sex
print(tab)
#             female male
#   Adelie        73   73
#   Chinstrap     34   34
#   Gentoo        58   61

chi <- chisq.test(tab)
print(chi)            # X-squared = 0.048607, df = 2, p-value = 0.976
print(round(chi$expected, 1))   # counts expected if sex and species were unrelated
# Report: chi-squared(2) = 0.05, p = 0.98, n = 333.
# This is "no evidence of a difference," NOT "evidence of no difference."
#
# Assumptions: each penguin counted once, counts (not percentages), expected
# counts of about 5 or more per cell. For a small 2x2 table use fisher.test().
# chisq.test() applies Yates' continuity correction to 2x2 tables by default,
# as SciPy's chi2_contingency() does.

# Effect size: Cramer's V, from 0 (no association) to 1 (perfect association).
cramers_v <- function(tab) {
  chi2 <- suppressWarnings(chisq.test(tab, correct = FALSE))$statistic
  unname(sqrt(chi2 / (sum(tab) * (min(dim(tab)) - 1))))
}
cat("species x sex:    V =", round(cramers_v(tab), 2), "\n")   # 0.01

island_tab <- table(df$species, df$island)
print(island_tab)
print(chisq.test(island_tab))   # X-squared = 299.55, df = 4, p-value < 2.2e-16
cat("species x island: V =", round(cramers_v(island_tab), 2), "\n")   # 0.66
# A strong association, but an uninteresting one: Gentoo live only on Biscoe and
# Chinstrap only on Dream. Ask whether the test answers a question you care about.


# -----------------------------------------------------------------------------
# 5. Linear regression: reading summary(lm())
# -----------------------------------------------------------------------------
# Question: how much heavier is a penguin for each extra mm of flipper?
section("5. Linear regression")

fit <- lm(body_mass_g ~ flipper_length_mm, data = df)
print(summary(fit))
#                      Estimate Std. Error t value Pr(>|t|)
#   (Intercept)       -5780.831    305.815  -18.90   <2e-16 ***
#   flipper_length_mm    49.686      1.518   32.72   <2e-16 ***
#   Residual standard error: 394.3 on 340 degrees of freedom
#     (2 observations deleted due to missingness)
#   Multiple R-squared:  0.759
#
# Estimate for flipper_length_mm: each extra mm goes with about 50 g more mass.
# (Intercept): predicted mass at flipper length 0. Not meaningful here.
# Std. Error: uncertainty in the slope. t value and Pr(>|t|): test of slope = 0.
# R-squared: flipper length explains 76% of the variation in body mass.
# "2 observations deleted due to missingness": always check this line.

print(confint(fit))   # 95% CI for the slope: 46.7 to 52.7

# Assumptions (LINE): Linearity, Independence, Normal residuals, Equal variance.
# plot(fit) draws four diagnostic plots (Session 10). We want a shapeless cloud
# in "Residuals vs Fitted" and points near the line in the QQ plot.
par(mfrow = c(2, 2)); plot(fit); par(mfrow = c(1, 1))

# Adding a variable changes the meaning of a coefficient: Simpson's paradox
# from Session 9, now in a regression.
m1 <- lm(bill_depth_mm ~ bill_length_mm, data = df)
m2 <- lm(bill_depth_mm ~ bill_length_mm + species, data = df)
print(coef(summary(m1)))   # bill_length_mm: -0.085, p = 1.1e-05
print(coef(summary(m2)))   # bill_length_mm: +0.200, p = 8.7e-26
# Both slopes are "significant," and they point in opposite directions. A
# coefficient means "the effect of x, holding the other variables in the model
# constant." speciesChinstrap and speciesGentoo are each species' difference
# from the reference level, Adelie (the first factor level).


# -----------------------------------------------------------------------------
# 6. Python <-> R: where the numbers live
# -----------------------------------------------------------------------------
#   R                                 Python
#   t.test(y ~ g)  (Welch default)    stats.ttest_ind(a, b, equal_var=False)
#   t.test(x, y, paired = TRUE)       stats.ttest_rel(x, y)
#   summary(aov(y ~ g))               sm.stats.anova_lm(smf.ols("y ~ g", data).fit())
#   TukeyHSD(aov(...))                pairwise_tukeyhsd(y, g)
#   oneway.test(y ~ g)                anova_oneway(groups, use_var="unequal")
#   wilcox.test(y ~ g)                stats.mannwhitneyu(a, b)
#   kruskal.test(y ~ g)               stats.kruskal(*groups)
#   chisq.test(table)                 stats.chi2_contingency(table)
#   summary(lm(y ~ x))                smf.ols("y ~ x", data).fit().summary()
#   confint(fit)                      fit.conf_int()
#   p.adjust(p, "holm")               multipletests(p, method="holm")
#
# Three things that catch people switching languages:
#   - R's t.test() defaults to Welch's; SciPy's ttest_ind() defaults to Student's.
#   - R prints "< 2e-16" and statsmodels prints "0.000". Neither means p = 0.
#     Report p < 0.001.
#   - R drops NA rows quietly in t.test(), aov() and lm(); SciPy returns nan.


# -----------------------------------------------------------------------------
# 7. Spot the bug
# -----------------------------------------------------------------------------
# Each block runs without an error. What's wrong? Answers at the bottom.
section("7. Spot the bug")

# Bug 1: "Compare systolic pressure between women and men."
f <- raw$systolic[raw$sex == "F"]
m <- raw$systolic[raw$sex == "M"]
print(t.test(f, m))

# Bug 2: "Missing values were a problem, so I filled them in."
df_filled <- df %>% mutate(body_mass_g = coalesce(body_mass_g, 0L))
print(summary(aov(body_mass_g ~ species, data = df_filled)))

# Bug 3: "Was Adelie sampling spread evenly across years on each island?
#         Here's the chi-square test on the percentages."
adelie <- df %>% filter(species == "Adelie")
pct <- prop.table(table(adelie$island, adelie$year), margin = 1) * 100
print(round(pct, 1))
print(chisq.test(pct)$p.value)

# Bug 4: "I compared every pair of species with a t-test, and all three are
#         significant at p < 0.05."

# Bug 5: "The chi-square test gave p = 0.98, which proves that sex and species
#         are independent."

# --- Answers -----------------------------------------------------------------------
# 1. raw$sex still contains "f" and "m", so those patients are silently dropped
#    (and so are the NA systolic values, which t.test() removes without saying).
#    Use the cleaned patients table, and print the group sizes:
#    table(patients$sex[!is.na(patients$systolic)])  -> F 118, M 123.
# 2. coalesce(..., 0) invents two penguins weighing 0 g, dragging two means
#    down and inflating the variance (F falls from 343.6 to 218.2). Leave
#    missing values as NA; aov() drops them. Report how many were dropped.
# 3. Chi-square needs counts. Percentages pretend each island had exactly 100
#    penguins. Here each has 44 to 56, so p drops from 0.47 (counts, correct)
#    to 0.11. Use chisq.test(table(adelie$island, adelie$year)).
# 4. Three uncorrected tests inflate the false-positive rate. Use ANOVA +
#    TukeyHSD(), or pairwise.t.test() with a correction. And report effect sizes
#    and CIs, not just "p < 0.05."
# 5. A large p-value means the data are compatible with no association; they may
#    also be compatible with a small one. Report Cramer's V (0.01) and n.


# -----------------------------------------------------------------------------
# 8. Reporting templates
# -----------------------------------------------------------------------------
#   Welch's t-test: t(df) = X.XX, p = .XXX, mean difference = M [95% CI L, U], d = X.XX
#   Paired t-test:  t(n-1) = X.XX, p = .XXX, mean change = M [95% CI L, U], d_z = X.XX
#   One-way ANOVA:  F(k-1, N-k) = X.XX, p = .XXX, eta^2 = X.XX; post-hoc with CIs
#   Chi-square:     chi^2(df) = X.XX, p = .XXX, n = N, Cramer's V = X.XX
#   Regression:     b = X.XX [95% CI L, U], t(df) = X.XX, p = .XXX; R^2 = X.XX, n = N
# Always report n after missing values are dropped.

sessionInfo()   # records package versions, for reproducibility
