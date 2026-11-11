# Session 10 demo: Data Visualization (R)
#
# Every code snippet from the Session 10 slides, in slide order. Each block says what
# the code does and what you should see, so you can check your own output against
# the comments.
#
# It uses the same three datasets as Sessions 7 to 9: penguins, patients and
# schools. Nothing is made up.
#
# Put these two files next to this script, then run:  Rscript 10_visualization_demo.R
#   patients.csv         Brightspace
#   schools_tibble.csv   Brightspace
# penguins comes from the palmerpenguins package, so it needs no file.
#
# Plots are saved as PNG files in a folder called demo10_figures, so the script
# also works when you run it from a terminal. To see a plot on screen instead,
# run the ggplot() line by itself in RStudio.
#
# Needs the packages dplyr, readr, stringr, ggplot2 and palmerpenguins. patchwork is
# optional (slide 9). Slides 10 and 11 use base R only.

section <- function(title) {
  cat("\n", strrep("=", 70), "\n", title, "\n", strrep("=", 70), "\n", sep = "")
}

# ---------------------------------------------------------------------------
# Slide 2: load the data
# ---------------------------------------------------------------------------
section("Slide 2: load the data")

# Install once. The check keeps this script safe to run again.
for (pkg in c("palmerpenguins", "ggplot2")) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}

library(dplyr)           # filter, select, mutate, group_by, summarise
library(readr)           # read_csv
library(stringr)         # str_trim, str_to_upper, str_replace
library(palmerpenguins)  # the penguins data
library(ggplot2)         # plots

# read_csv() removes spaces at the start and end of text values unless you set
# trim_ws = FALSE. We keep them, so the original "A " label is still there to color by.
# visit_date is read as text so the impossible date from Session 9 stays visible.
raw <- read_csv("patients.csv", trim_ws = FALSE, show_col_types = FALSE,
                col_types = cols(visit_date = col_character()))

# The Session 8 cleaning, in a few lines. as.numeric() warns because six ages say
# "unknown". That warning is expected.
patients <- raw %>%
  mutate(group = str_trim(group),
         sex = str_to_upper(sex),
         age = as.numeric(age))

# The schools file has one label for two kinds of non-traditional school.
schools <- read_csv("schools_tibble.csv", show_col_types = FALSE) %>%
  mutate(school_level = str_replace(school_level, " - Hybrid$", ""))

df <- penguins           # df is the penguins table in both languages

print(dim(patients))     # 250 9
print(dim(df))           # 344 8   (includes year)
print(dim(schools))      # 169 35

dir.create("demo10_figures", showWarnings = FALSE)
# Saves a plot as a PNG in the demo10_figures folder, and says where it went.
# The warning about removed rows is expected: two penguins have no measurements.
save_plot <- function(p, name, width = 6, height = 3.6) {
  path <- file.path("demo10_figures", paste0(name, ".png"))
  suppressWarnings(ggsave(path, p, width = width, height = height, dpi = 150))
  cat("saved", path, "\n")
}


# ---------------------------------------------------------------------------
# Slide 4: five choices, every plot you will ever make
# ---------------------------------------------------------------------------
section("Slide 4: data, aesthetics, geometry, statistics, coordinates")

# Session 9 used base R for quick looks. Each line draws one plot, and none of them
# saves anything here. They are the fastest way to peek at a column in the console:
#   hist(df$bill_length_mm)
#   boxplot(bill_length_mm ~ species, data = df)
#   plot(df$bill_length_mm, df$body_mass_g)
# ggplot2 draws the same plots one layer at a time, and every layer is a choice.

# 1. DATA: the tidy data frame. 2. AESTHETICS: which column goes to which visual
# property. Nothing is drawn yet, because no geometry says what mark to use.
p <- ggplot(df, aes(x = bill_length_mm, y = body_mass_g, color = species))
save_plot(p, "04_empty_axes")       # axes and a grid, no points

# 3. GEOMETRY: the mark. Add it with +, and the points appear.
save_plot(p + geom_point(), "04_points")
# 4. STATISTICS: a summary the plot computes for you (here none, the points are raw).
# 5. COORDINATES: the axes, linear by default. scale_x_log10() or coord_flip() change
#    them without touching the data.

# A prompt for an AI assistant should name all five. "Make a nice bar chart" names
# none of them. "geom_col, x = species, y = mean_mass, fill = sex, position dodge,
# error bars from sd_mass" names them all.


# ---------------------------------------------------------------------------
# Slide 5: build it twice, one layer at a time
# ---------------------------------------------------------------------------
section("Slide 5: layers, and where the aesthetic lives")

# The same plot in the other language is in 10_visualization_demo.py. Here, the layers.
# Same data, same aesthetics, a different geometry: geom_smooth(method = "lm") draws
# a regression line per species instead of points.
save_plot(p + geom_smooth(method = "lm", formula = y ~ x), "05_smooth_only")
# Add both layers and the plot is composable: points and lines, drawn together.
save_plot(p + geom_point() + geom_smooth(method = "lm", formula = y ~ x), "05_points_and_lines")

# Where the aesthetic lives. aes() inside ggplot() is inherited by every layer. Here
# color = species is global, so geom_smooth() draws one line per species.
global_color <- ggplot(df, aes(bill_length_mm, body_mass_g, color = species)) +
  geom_point() +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE)
# Move color into geom_point() and it belongs to that layer only. geom_smooth() now
# sees all penguins together and draws one line.
local_color <- ggplot(df, aes(bill_length_mm, body_mass_g)) +
  geom_point(aes(color = species)) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE)
save_plot(global_color, "05_global_color")
save_plot(local_color, "05_local_color")

# The slopes behind the lines, in grams per millimeter of bill.
print(round(coef(lm(body_mass_g ~ bill_length_mm, data = df))[2], 1))   # 87.4 overall
print(df %>%
        group_by(species) %>%
        summarise(slope = round(coef(lm(body_mass_g ~ bill_length_mm))[2], 1)))
# Adelie 94.5, Chinstrap 59.1, Gentoo 109.5. Session 9's Simpson's paradox is the
# same split: look at the groups before you believe the overall line.

# Three ways to hand the data to ggplot. They draw the same plot (Fall 2025, Session 8).
ggplot(df, aes(bill_length_mm, body_mass_g)) + geom_point()                  # in ggplot()
ggplot() + geom_point(data = df, mapping = aes(bill_length_mm, body_mass_g)) # in one layer
df %>% ggplot(aes(bill_length_mm, body_mass_g)) + geom_point()               # piped in
# A + at the end of a line tells R the plot is not finished, so put it at the end.


# ---------------------------------------------------------------------------
# Slide 6: what plot, for what question
# ---------------------------------------------------------------------------
section("Slide 6: choose the plot")

# One continuous variable: histogram or density.
save_plot(ggplot(df, aes(body_mass_g)) + geom_histogram(bins = 30), "06_histogram")
save_plot(ggplot(df, aes(body_mass_g, fill = species)) + geom_density(alpha = 0.5),
          "06_density")

# One categorical variable: a bar chart of counts. geom_bar() counts the rows for you,
# which is the "statistics" part of the grammar. Long labels read better on the y axis,
# and bars sorted by count are easier to compare.
print(count(schools, school_level, sort = TRUE))
# Elementary School 76, Charter 31, Middle School 31, High School 17, Non-Traditional 7,
# Special Education 3, Alternative Learning Center 2, Adult 1, GATE Center 1
save_plot(ggplot(schools, aes(y = reorder(school_level, school_level, FUN = length))) +
            geom_bar() + labs(y = "School level", x = "Schools"),
          "06_bar_counts")

# Two continuous variables: a scatter plot (slide 5). Continuous by categorical: a box
# plot, and the raw points on top.
save_plot(ggplot(df, aes(species, body_mass_g)) +
            geom_boxplot(outlier.shape = NA) + geom_jitter(width = 0.15, alpha = 0.4),
          "06_box_plus_points")

# The anti-pattern: a bar chart of means. This is systolic pressure by group.
means <- patients %>%
  group_by(group) %>%
  summarise(mean = mean(systolic, na.rm = TRUE), sd = sd(systolic, na.rm = TRUE),
            n = sum(!is.na(systolic)))
print(means)   # A 129.4 (sd 15.1, n 121), B 134.2 (sd 11.9, n 120)
bars <- ggplot(means, aes(group, mean)) + geom_col() +
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.2) +
  labs(x = "Group", y = "Systolic pressure (mmHg), mean and sd")
save_plot(bars, "06_bar_of_means")
# Two bars and two error bars. Nothing shows that group A holds two kinds of patient.

# The same data as points, colored by the original label from raw. The 40 rows that read
# "A " (a trailing space) are a second recruitment site.
by_site <- raw %>%
  mutate(site = if_else(group == "A ", "second site", "first site"),
         group = str_trim(group))
points <- ggplot(by_site, aes(group, systolic, color = site)) +
  geom_jitter(width = 0.15, height = 0, alpha = 0.7) +
  labs(x = "Group", y = "Systolic pressure (mmHg)", color = "Site")
save_plot(points, "06_points_by_site")
print(by_site %>%
        filter(group == "A") %>%
        group_by(site) %>%
        summarise(n = sum(!is.na(systolic)), mean = round(mean(systolic, na.rm = TRUE), 1)))
# first site n 81, mean 136.2 / second site n 40, mean 115.5. The points show it. The bars hide it.
# Rule of thumb: under about 30 points per group, plot the points. With more, a box
# plot at least, and the points too when they are not a blur.


# ---------------------------------------------------------------------------
# Slide 7: facets, when color runs out
# ---------------------------------------------------------------------------
section("Slide 7: facets")

# facet_wrap() splits one plot into a row of small plots, one per level.
save_plot(ggplot(df, aes(bill_length_mm, body_mass_g)) +
            geom_point(alpha = 0.6) + facet_wrap(~ species),
          "07_facet_wrap", width = 7, height = 3)

# Two grouping variables: facet_grid(rows ~ columns). Species and island make a 3 x 3 grid.
print(table(df$species, df$island))
# Adelie lives on all three islands (44, 56, 52). Chinstrap is only on Dream (68) and
# Gentoo only on Biscoe (124). So 5 of the 9 panels hold data and 4 stay empty.
save_plot(ggplot(df, aes(bill_length_mm, body_mass_g)) +
            geom_point(alpha = 0.6) + facet_grid(island ~ species),
          "07_facet_grid", width = 7, height = 5)
# Every panel shares the same axes by default, so the panels compare honestly.
# Past 3 or 4 groups, facet instead of coloring. Eyes cannot tell eight shades of one
# color apart, but they can scan eight small plots.


# ---------------------------------------------------------------------------
# Slide 8: label it, then check it for the three sins
# ---------------------------------------------------------------------------
section("Slide 8: labels, scales and the three sins")

# A figure for a reader names what is on each axis, with units, and states the finding.
polished <- ggplot(df, aes(bill_length_mm, body_mass_g, color = species)) +
  geom_point(alpha = 0.7) +
  scale_color_viridis_d(end = 0.85) +                  # survives grayscale and color blindness
  labs(title = "Longer bills go with heavier penguins in all three species",
       x = "Bill length (mm)", y = "Body mass (g)", color = "Species") +
  theme_minimal(base_size = 12)
save_plot(polished, "08_polished")

# Sin 1, chart junk: 3D bars, shadows, gridlines that carry nothing. theme_minimal()
# removes most of it. Sin 2, ambiguous labels: "value" or "y" is not a label.
# Sin 3, misleading scales. Here is the same bar chart of means twice.
group_means <- patients %>% group_by(group) %>% summarise(mean = mean(systolic, na.rm = TRUE))
honest <- ggplot(group_means, aes(group, mean)) + geom_col() +
  labs(x = "Group", y = "Mean systolic pressure (mmHg)")
truncated <- honest + coord_cartesian(ylim = c(125, 135))
save_plot(honest, "08_bars_from_zero", width = 3.5, height = 3.2)
save_plot(truncated, "08_bars_truncated", width = 3.5, height = 3.2)
print(round(group_means$mean, 1))                                   # 129.4 134.2
print(round(group_means$mean[2] / group_means$mean[1], 3))          # 1.037, a 3.7% difference
print(round((group_means$mean[2] - 125) / (group_means$mean[1] - 125), 1))   # 2.1
# Cut the axis at 125 and group B's bar looks 2.1 times as tall as group A's, for a
# 3.7% difference. Bars must start at zero, because their length is the data. Points do
# not have to, because their position is the data.
# AI-written plot code often includes the junk. Delete it. Ask what the one thing this
# plot must show is, and remove anything that does not help.


# ---------------------------------------------------------------------------
# Slide 9: save it at the size it will be printed
# ---------------------------------------------------------------------------
section("Slide 9: ggsave() and combining panels")

# ggsave() sets the size in inches, so the text stays readable at the size on the page.
# Many journals ask for about 3.5 inches wide (one column) or 7 inches (two columns).
# Check the author guidelines. dpi = 300 is the usual minimum for a raster figure.
ggsave("demo10_figures/09_figure1.png", polished, width = 7, height = 4, dpi = 300)
# A vector format has no resolution, so it stays sharp at any size. Journals often want one.
ggsave("demo10_figures/09_figure1.pdf", polished, width = 7, height = 4)
# 7 inches at 300 dpi is 2100 pixels wide:
print(c(width = 7 * 300, height = 4 * 300))   # 2100 1200 pixels

# Save with code, not the export button. A script rebuilds the figure in one run when a
# reviewer asks for a change.

# Two plots in one figure, with panel letters (Fall 2025, Session 8). patchwork is an
# optional package: install.packages("patchwork"). p1 + p2 puts them side by side, and
# p1 / p2 stacks them. Session 13 comes back to this with annotations.
if (requireNamespace("patchwork", quietly = TRUE)) {
  library(patchwork)
  panel_a <- bars + labs(title = NULL)
  panel_b <- points
  combo <- (panel_a | panel_b) + plot_annotation(tag_levels = "A")
  ggsave("demo10_figures/09_combined.png", combo, width = 9, height = 3.8, dpi = 150)
  cat("saved demo10_figures/09_combined.png\n")
}


# ---------------------------------------------------------------------------
# Slide 10: plots that check a model
# ---------------------------------------------------------------------------
section("Slide 10: residuals and the QQ plot")

# Residuals are what the model did not explain: observed minus fitted. A diagnostic
# plot looks at them to see whether the model is a fair description (Fall 2025,
# Session 10). Session 11 fits models in earnest. Here is the picture.
fit <- lm(body_mass_g ~ flipper_length_mm, data = df)
print(round(summary(fit)$r.squared, 3))   # 0.759
print(round(coef(fit), 2))                # intercept -5780.83, slope 49.69 g per mm

# plot(fit) draws four diagnostic plots from the fitted model: residuals vs fitted, the
# QQ plot, scale-location and residuals vs leverage. Slide 11 reads all four.
png("demo10_figures/10_diagnostics_base.png", width = 9, height = 6, units = "in", res = 120)
par(mfrow = c(2, 2))
plot(fit)
dev.off()
cat("saved demo10_figures/10_diagnostics_base.png\n")

# Residuals vs fitted: you want a shapeless cloud around zero. A curve means the line
# is the wrong shape. A funnel means the spread changes. Colored by species, the
# residuals show structure the line missed.
d <- df %>%
  filter(!is.na(body_mass_g), !is.na(flipper_length_mm)) %>%
  mutate(fitted = fitted(fit), resid = resid(fit))
save_plot(ggplot(d, aes(fitted, resid, color = species)) +
            geom_hline(yintercept = 0, linetype = "dashed") + geom_point() +
            labs(x = "Fitted body mass (g)", y = "Residual (g)", color = "Species"),
          "10_residuals_vs_fitted")
print(d %>% group_by(species) %>% summarise(mean_resid = round(mean(resid))))
# Adelie 44, Chinstrap -216, Gentoo 66. Chinstrap penguins sit below the line. Adding
# species to the model lifts R-squared from 0.759 to 0.783 (Session 11).
print(round(summary(lm(body_mass_g ~ flipper_length_mm + species, data = df))$r.squared, 3))

# QQ plot: sorted values against what a normal distribution would give. Points on the
# line mean normal. Ends that peel away mean a skewed distribution or extreme values.
# Here is systolic pressure by group, the data behind the Session 1 test.
qq <- ggplot(filter(patients, !is.na(systolic)), aes(sample = systolic)) +
  stat_qq() + stat_qq_line() + facet_wrap(~ group) +
  labs(x = "Theoretical quantiles", y = "Systolic pressure (mmHg)")
save_plot(qq, "10_qq_by_group", width = 6, height = 3)
a <- patients %>% filter(group == "A", !is.na(systolic)) %>% pull(systolic)
b <- patients %>% filter(group == "B", !is.na(systolic)) %>% pull(systolic)
print(round(c(A = shapiro.test(a)$p.value, B = shapiro.test(b)$p.value), 3))   # A 0.018, B 0.471
# Group A's ends curl away from the line (Shapiro-Wilk p = 0.018). Group B is close to it
# (p = 0.471). A QQ plot drawn before the t-test would have flagged group A, the same
# message as the histogram on Session 9 slide 7.
# DataExplorer's plot_qq() draws a QQ plot for every numeric column at once (Session 9).


# ---------------------------------------------------------------------------
# Slide 11: reading the four plots from plot(fit)
# ---------------------------------------------------------------------------
section("Slide 11: residuals vs leverage, and Cook's distance")

# A model with some unusual points: the number of students with a disability against
# total enrollment at the 169 Metro Nashville schools. total is the sum of the 15
# grade columns, and a missing grade count means the grade is not offered, so na.rm = TRUE.
schools <- schools %>%
  mutate(total = rowSums(across(starts_with("grade_")), na.rm = TRUE))
fit2 <- lm(disability ~ total, data = schools)
print(round(summary(fit2)$r.squared, 3))   # 0.598
print(round(coef(fit2), 4))                # intercept 8.2973, slope 0.1097

# The four panels. Each one checks a different assumption, and the same school can show
# up in several of them. The numbers on the points are row numbers.
png("demo10_figures/11_four_plots_schools.png", width = 9, height = 6, units = "in", res = 150)
par(mfrow = c(2, 2))
plot(fit2)
dev.off()
cat("saved demo10_figures/11_four_plots_schools.png\n")
# Cook's distance as bars. The rule-of-thumb lines in the leverage plot are 0.5 and 1.
png("demo10_figures/11_cooks_distance_schools.png", width = 7, height = 3, units = "in", res = 150)
plot(fit2, which = 4)
dev.off()
cat("saved demo10_figures/11_cooks_distance_schools.png\n")

# Who are the unusual points?
cd <- cooks.distance(fit2)
top <- order(cd, decreasing = TRUE)[1:3]
print(top)                                  # 102 53 99
print(round(cd[top], 3))                    # 0.398 0.314 0.303: none reaches 0.5
print(schools %>%
        slice(top) %>%
        transmute(school_name, school_level, total, disability,
                  fitted = round(fitted(fit2)[top], 1),
                  residual = round(resid(fit2)[top], 1),
                  leverage = round(hatvalues(fit2)[top], 3)))
# McGavock High (102): 2276 students, leverage 0.166, the most of any school. It sits near
#   the line (standardized residual 2.0), so its pull is modest.
# Harris-Hillman Special Education (53): 799 students, 335 with a disability, 95.9
#   predicted. Residual +239.1 (standardized 7.83) but leverage only 0.010.
# Martin Luther King Jr School (99): 1262 students, 23 with a disability, residual -123.7.
# A point needs both a large residual and high leverage to be influential. Neither has
# enough of both to cross a contour, and all three are real schools, not entry errors.

# What to do with an unusual point: check it, refit without it, and report both fits.
refit <- function(drop) {
  f <- lm(disability ~ total, data = schools[-drop, ])
  round(c(slope = unname(coef(f)[2]), r_squared = summary(f)$r.squared), 3)
}
print(round(c(slope = unname(coef(fit2)[2]), r_squared = summary(fit2)$r.squared), 3))   # 0.110 0.598
print(refit(102))             # without McGavock:        0.104 0.533
print(refit(53))              # without Harris-Hillman:  0.106 0.686
print(refit(c(53, 102)))      # without both:            0.099 0.627


# ---------------------------------------------------------------------------
# Try it yourself
# ---------------------------------------------------------------------------
# 1. Replace geom_smooth(method = "lm") with geom_smooth() (no method). What kind of
#    line does it draw, and when would you not trust it?
# 2. Make a violin plot of body_mass_g by species with geom_violin(). What does it show
#    that the box plot did not?
# 3. In the global_color plot, add facet_wrap(~ island). How many panels are empty?
# 4. Change the viridis palette to scale_color_brewer(palette = "Set2"). Does the plot
#    still read in grayscale? (Print it in black and white, or use a color-blind
#    simulator.)
# 5. Save the polished plot at width = 3.5 and height = 2.5. What breaks, and how do
#    you fix it (base_size, legend position)?
# 6. Run plot(fit2, which = 5) and plot(fit2, which = 6). What do those two panels show?
# 7. Fit disability ~ total again with Harris-Hillman and McGavock High dropped. How far
#    does the slope move? Would you report it?
