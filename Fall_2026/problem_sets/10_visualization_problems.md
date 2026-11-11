# Problem Set 10: Data Visualization

**Session:** 10 (Unit 3: Analysis)
**Course data:** penguins (the `palmerpenguins` package in R, or `penguins.csv` in Python), `patients.csv`, and `schools_tibble.csv`, all on Brightspace
**Use with:** `general_tutor_gpt.md`
**Time target:** ~20–25 minutes, worked through with the tutor (Problem 7 is a short extra for anyone with time left)

---

## Instructions for students

Paste this whole file into the Course Tutor and work through the problems together, in order. These are the same three datasets as Sessions 7 to 9. Session 9's plots were for you. These problems build plots for a reader, and they finish the Session 1 story with the plot a reader would have needed.

Load the data first. Every problem below assumes these objects exist. `patients` is the Session 8 cleaning, and `raw` keeps the original `group` labels so you can still see the trailing space.

```r
library(dplyr); library(tidyr); library(readr); library(stringr)
library(palmerpenguins); library(ggplot2)
raw <- read_csv("patients.csv", trim_ws = FALSE,
                col_types = cols(visit_date = col_character()))   # keep trailing spaces
patients <- raw %>%
  mutate(group = str_trim(group), sex = str_to_upper(sex), age = as.numeric(age))
schools <- read_csv("schools_tibble.csv") %>%
  mutate(school_level = str_replace(school_level, " - Hybrid$", ""))
df <- penguins                                      # 344 x 8, includes year
```

```python
import numpy as np, pandas as pd, seaborn as sns
import matplotlib.pyplot as plt
from scipy import stats
df = pd.read_csv("penguins.csv")
# A CSV written from R has a row-number column that pandas calls "Unnamed: 0". It is harmless
# as long as you pick columns by name.
raw = pd.read_csv("patients.csv")
patients = raw.copy()
patients["group"] = patients["group"].str.strip()
patients["sex"] = patients["sex"].str.upper()
patients["age"] = pd.to_numeric(patients["age"], errors="coerce")
schools = pd.read_csv("schools_tibble.csv")
schools["school_level"] = schools["school_level"].str.replace(" - Hybrid", "", regex=False)
```

Two things to know about R. `as.numeric(age)` warns because six ages say `"unknown"`, which is expected. And a plot that includes the two penguins with no measurements warns about removed rows, which is also expected.

---

## Problems

1. **Name the five parts.** Here is a plot, built in layers.

   ```r
   p <- ggplot(df, aes(x = bill_length_mm, y = body_mass_g, color = species))
   p
   p + geom_point()
   p + geom_point() + geom_smooth(method = "lm")
   ```

   ```python
   import seaborn.objects as so
   p = so.Plot(df, x="bill_length_mm", y="body_mass_g", color="species")
   p.add(so.Dot())
   p.add(so.Dot()).add(so.Line(), so.PolyFit(order=1))
   ```

   (a) For the second plot, name the data, the aesthetics and the geometry. There is no statistic and no non-default coordinate. Why not?
   (b) The first line draws empty axes. Why are there no points?
   (c) What did `geom_smooth(method = "lm")` add, and which of the five parts is it?
   (d) Rewrite "make a nice plot of penguin size" as a prompt for an AI assistant that names all five parts.

2. **Where does the aesthetic live?** These two plots differ only in where `color = species` sits.

   ```r
   ggplot(df, aes(bill_length_mm, body_mass_g, color = species)) +
     geom_point() + geom_smooth(method = "lm", se = FALSE)
   ggplot(df, aes(bill_length_mm, body_mass_g)) +
     geom_point(aes(color = species)) + geom_smooth(method = "lm", se = FALSE)
   ```

   ```python
   sns.lmplot(df, x="bill_length_mm", y="body_mass_g", hue="species", ci=None)
   ax = sns.scatterplot(df, x="bill_length_mm", y="body_mass_g", hue="species")
   sns.regplot(df, x="bill_length_mm", y="body_mass_g", scatter=False, ci=None, color="black", ax=ax)
   ```

   (a) How many lines does each plot draw, and why?
   (b) Compute the slope of body mass on bill length for all penguins, then inside each species. How does the overall slope compare with the three within-species slopes?

   ```r
   coef(lm(body_mass_g ~ bill_length_mm, data = df))[2]
   df %>% group_by(species) %>% summarise(slope = coef(lm(body_mass_g ~ bill_length_mm))[2])
   ```

   ```python
   d = df.dropna(subset=["bill_length_mm", "body_mass_g"])
   print(stats.linregress(d.bill_length_mm, d.body_mass_g).slope)
   for name, g in d.groupby("species"):
       print(name, stats.linregress(g.bill_length_mm, g.body_mass_g).slope)
   ```

   (c) Which plot would you put in a paper, and what does the other one risk telling the reader? Connect your answer to Simpson's paradox from Session 9.

3. **Pick the geom, then draw one.** Match each goal to a geom, and draw (d).

   (a) The distribution of `body_mass_g` alone.
   (b) `body_mass_g` compared across `species`.
   (c) The relationship between `bill_length_mm` and `body_mass_g`.
   (d) The number of schools at each `school_level`. The labels are long, so put them on the y axis and sort the bars by count.

   ```r
   ggplot(schools, aes(y = reorder(school_level, school_level, FUN = length))) + geom_bar()
   ```

   ```python
   sns.countplot(schools, y="school_level", order=schools.school_level.value_counts().index)
   ```

   Which level has the most schools, and how many? `geom_bar()` counts the rows for you. Which of the five parts is doing that?

4. **The bar chart of means.** Draw systolic pressure for the two groups as bars with error bars, then as points, colored by recruitment site.

   ```r
   means <- patients %>%
     group_by(group) %>%
     summarise(mean = mean(systolic, na.rm = TRUE), sd = sd(systolic, na.rm = TRUE))
   ggplot(means, aes(group, mean)) + geom_col() +
     geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.2)

   by_site <- raw %>%
     mutate(site = if_else(group == "A ", "second site", "first site"),
            group = str_trim(group))
   ggplot(by_site, aes(group, systolic, color = site)) +
     geom_jitter(width = 0.15, height = 0)
   ```

   ```python
   sns.barplot(patients, x="group", y="systolic", errorbar="sd", capsize=0.2)
   plt.show()
   by_site = raw.assign(site=np.where(raw.group == "A ", "second site", "first site"))
   by_site["group"] = by_site.group.str.strip()
   sns.stripplot(by_site, x="group", y="systolic", hue="site", jitter=0.15)
   ```

   (a) What does the bar chart tell a reader? What are the two means?
   (b) What does the point plot show that the bar chart hid? Compute the mean `systolic` for each site within group A.
   (c) Why is "a bar chart of means with a t-test asterisk" called an anti-pattern? How many points per group is the rule of thumb for plotting the raw points?

5. **Facet or color?** `penguins` has three species and three islands. You want to compare bill length against body mass across both at once.

   ```r
   table(df$species, df$island)
   ggplot(df, aes(bill_length_mm, body_mass_g)) + geom_point() + facet_grid(island ~ species)
   ```

   ```python
   pd.crosstab(df.species, df.island)
   sns.relplot(df, x="bill_length_mm", y="body_mass_g", row="island", col="species",
               facet_kws={"margin_titles": True})
   ```

   (a) How many panels does the grid have, and how many hold data?
   (b) What does the empty pattern tell you about species and island? Can you separate an island effect from a species effect for Gentoo?
   (c) State the rule of thumb for facets against color. Why does it hold?

6. **Spot the sins and fix them.** This plot has three problems.

   ```r
   group_means <- patients %>% group_by(group) %>% summarise(mean = mean(systolic, na.rm = TRUE))
   ggplot(group_means, aes(group, mean)) +
     geom_col(fill = "red") +
     coord_cartesian(ylim = c(125, 135)) +
     theme(panel.grid.major = element_line(color = "black", linewidth = 1))
   ```

   ```python
   group_means = patients.groupby("group")["systolic"].mean()
   fig, ax = plt.subplots()
   ax.bar(group_means.index, group_means.values, color="red")
   ax.set_ylim(125, 135)
   ax.grid(True, color="black", linewidth=1)
   ```

   (a) Name each of the three plotting sins, and point to the line of code behind it.
   (b) The means are 129.4 and 134.2. By what percent does group B exceed group A? On this plot, how many times as tall does B's bar look? Use the axis limits to work it out.
   (c) Fix the plot. Label both axes with units, add a title that states what the plot shows, and start the bars at zero (or switch to points).
   (d) Save your fixed plot at 7 inches wide and 4 inches tall, at 300 dpi. How many pixels wide is the file? Why might a journal ask for a PDF instead?

   ```r
   ggsave("figure1.png", width = 7, height = 4, dpi = 300)
   ggsave("figure1.pdf", width = 7, height = 4)
   ```

   ```python
   fig.savefig("figure1.png", dpi=300, bbox_inches="tight")
   fig.savefig("figure1.pdf", bbox_inches="tight")
   ```

7. **Plots that check a model.** Fit body mass from flipper length and look at what the model did not explain.

   ```r
   fit <- lm(body_mass_g ~ flipper_length_mm, data = df)
   par(mfrow = c(2, 2)); plot(fit); par(mfrow = c(1, 1))
   d <- df %>% filter(!is.na(body_mass_g), !is.na(flipper_length_mm)) %>%
     mutate(fitted = fitted(fit), resid = resid(fit))
   ggplot(d, aes(fitted, resid, color = species)) +
     geom_hline(yintercept = 0, linetype = "dashed") + geom_point()
   ggplot(filter(patients, !is.na(systolic)), aes(sample = systolic)) +
     stat_qq() + stat_qq_line() + facet_wrap(~ group)
   ```

   ```python
   d = df.dropna(subset=["body_mass_g", "flipper_length_mm"]).copy()
   slope, intercept = np.polyfit(d.flipper_length_mm, d.body_mass_g, 1)
   d["fitted"] = intercept + slope * d.flipper_length_mm
   d["resid"] = d.body_mass_g - d.fitted
   ax = sns.scatterplot(d, x="fitted", y="resid", hue="species")
   ax.axhline(0, linestyle="--", color="black")
   plt.show()
   fig, axes = plt.subplots(1, 2, sharey=True)
   for ax, (name, g) in zip(axes, patients.groupby("group")):
       stats.probplot(g.systolic.dropna(), plot=ax); ax.set_title(name)
   ```

   (a) In the residuals-vs-fitted plot, what shape do you want? Color the residuals by species. Which species sits below zero, and what could you add to the model as a result?
   (b) In the QQ plots of `systolic`, which group's points leave the line at the ends? Check with `shapiro.test()` (R) or `stats.shapiro()` (Python).
   (c) The Session 1 test compared these two groups with a t-test. What does the QQ plot suggest about that test, and what did Session 9's histogram already tell you?
   (d) `plot(fit)` draws four panels: residuals vs fitted, Q-Q, scale-location and residuals vs leverage. Fit the number of students with a disability on total enrollment for the schools and read all four. Which school has the largest residual, and which has the most leverage? Does either cross a Cook's distance contour? Refit without the school with the most leverage. What happens to the slope and R-squared, and what would you report?

   ```r
   schools <- schools %>% mutate(total = rowSums(across(starts_with("grade_")), na.rm = TRUE))
   fit2 <- lm(disability ~ total, data = schools)
   par(mfrow = c(2, 2)); plot(fit2); par(mfrow = c(1, 1))
   plot(fit2, which = 4)                                    # Cook's distance
   schools %>% slice(c(53, 99, 102)) %>% select(school_name, school_level, total, disability)
   fit3 <- lm(disability ~ total, data = schools[-102, ])
   c(coef(fit2)[2], summary(fit2)$r.squared, coef(fit3)[2], summary(fit3)$r.squared)
   ```

   ```python
   import statsmodels.api as sm      # pip install statsmodels
   schools["total"] = schools.filter(like="grade_").sum(axis=1)
   fit2 = sm.OLS(schools.disability, sm.add_constant(schools.total)).fit()
   infl = fit2.get_influence()
   print(np.argsort(infl.cooks_distance[0])[::-1][:3] + 1)       # observation numbers
   print(schools.loc[[52, 98, 101], ["school_name", "school_level", "total", "disability"]])
   keep = schools.drop(index=101)
   fit3 = sm.OLS(keep.disability, sm.add_constant(keep.total)).fit()
   print(fit2.params["total"], fit2.rsquared, fit3.params["total"], fit3.rsquared)
   ```

   ```r
   shapiro.test(filter(patients, group == "A")$systolic)$p.value
   shapiro.test(filter(patients, group == "B")$systolic)$p.value
   ```

   ```python
   stats.shapiro(patients[patients.group == "A"].systolic.dropna()).pvalue
   stats.shapiro(patients[patients.group == "B"].systolic.dropna()).pvalue
   ```

---

## Coverage (for instructor reference)

| # | Slides | Concept |
|---|--------|---------|
| 1 | 4 | The five grammar-of-graphics parts, layers adding up, and naming the parts in an AI prompt |
| 2 | 5 | Where the aesthetic lives, and a line per group against one overall line (Simpson's paradox again) |
| 3 | 6 | Matching a goal to a geom, `geom_bar()` as a statistic, sorting and flipping a bar chart |
| 4 | 6 | The bar chart of means against the raw points, and the second site resolved visually |
| 5 | 7 | Facets against color, a grid showing which combinations exist |
| 6 | 8 and 9 | The three plotting sins, truncated bars, labels, and saving at a size and resolution |
| 7 | 10 and 11 | Residual plots, the QQ plot, the Shapiro-Wilk check, the four `plot(fit)` panels, leverage and Cook's distance, and refitting without a point |

### Verified facts about the data (for the tutor; do not invent others)

- **Penguins:** 344 rows, 342 with both bill length and body mass. Adelie 152, Chinstrap 68, Gentoo 124. The overall correlation of bill length with body mass is 0.60.
- **Problem 1:** (a) data = `df`, aesthetics = `x = bill_length_mm`, `y = body_mass_g`, `color = species`, geometry = `geom_point()`. There is no statistic because the points are the raw rows, and the coordinates are the default linear axes. (b) the data and the aesthetics are set, and no geometry says what mark to draw, so only axes appear. (c) `geom_smooth(method = "lm")` adds a fitted straight line per species, and it is a geometry with a statistic behind it (the regression). (d) any prompt that names all five works, for example: "Use the penguins table. Put bill_length_mm on x and body_mass_g on y, colored by species. Draw points and add a linear fit for each species. Use linear axes and no facets. Label the axes with units."
- **Problem 2:** (a) the first plot draws three lines, because `color` in `ggplot()` is inherited by every layer, so `geom_smooth()` fits each species separately. The second draws one line, because `color` lives only in `geom_point()`, so `geom_smooth()` fits all 342 penguins together. (b) the overall slope is 87.4 g per mm. Within species it is Adelie 94.5, Chinstrap 59.1 and Gentoo 109.5 (R prints the last one as 109. because a tibble shows three significant digits). The overall slope sits between them, because the species also differ in both measurements. Here the sign does not flip, so it is a milder cousin of Session 9's Simpson's paradox. (c) the per-species plot is the better choice for a paper, because the question is usually about the relationship inside a group. The single line mixes the between-species difference into the slope and reports a number that describes no actual species.
- **Problem 3:** (a) histogram or density, (b) box plot or violin, (c) scatter plot, (d) bar chart of counts. Elementary School has the most schools, 76. Then Charter 31, Middle School 31, High School 17, Non-Traditional 7, Special Education 3, Alternative Learning Center 2, Adult 1 and GATE Center 1. `geom_bar()` counting the rows is the statistics part.
- **Problem 4:** (a) two bars, A 129.4 (sd 15.1, n 121) and B 134.2 (sd 11.9, n 120), with overlapping error bars. A reader concludes the groups are similar. (b) the point plot shows that group A is two clusters. The 40 rows labeled `"A "` sit around 115 and the 81 labeled `"A"` sit higher. The first site has mean 136.2 (n 81) and the second site 115.5 (n 40). That is the Session 1 trailing-space bug, now visible. (c) a bar chart of means hides the distribution, the sample size and every outlier, and the asterisk adds confidence without adding information. The rule of thumb is to plot the raw points with fewer than about 30 per group, and a box plot at least beyond that.
- **Problem 5:** (a) 9 panels, 5 with data. (b) Adelie is on Biscoe (44), Dream (56) and Torgersen (52). Chinstrap is only on Dream (68) and Gentoo only on Biscoe (124). Species and island are mostly the same information, so for Gentoo an island effect cannot be separated from a species effect. Only Adelie lives on more than one island. (c) facet past three or four groups. Eyes cannot tell eight shades of one color apart, but they can scan eight small plots, and the panels share axes so they compare honestly.
- **Problem 6:** (a) chart junk is `theme(panel.grid.major = ...)` or `ax.grid(...)` with thick black gridlines (and the red fill is a distraction). The ambiguous labels are the default axis titles, `mean` and `group` in R and none in Python. The misleading scale is `coord_cartesian(ylim = c(125, 135))` or `ax.set_ylim(125, 135)`. (b) 134.2 is 3.7% above 129.4 (a ratio of 1.037). With the axis cut at 125, B's bar is 9.2 tall and A's is 4.4, so B looks 2.1 times as tall. (c) bars start at zero because their length is the data. Points do not need to start at zero. (d) 7 inches at 300 dpi is 2,100 pixels wide and 1,200 tall. A PDF is a vector format with no resolution, so it stays sharp at any size and many journals prefer it.
- **Problem 7:** (a) a shapeless cloud around zero. A curve means the line is the wrong shape and a funnel means the spread changes. Chinstrap sits below zero, with a mean residual of -216 g (Adelie +44, Gentoo +66), so species belongs in the model, and adding it lifts R-squared from 0.759 to 0.783. The fitted line is body mass = -5780.83 + 49.69 x flipper length. (b) group A's ends curl away from the line (Shapiro-Wilk p = 0.018), and group B follows it (p = 0.471). (c) the t-test assumes roughly normal data within each group, and group A is not, which is the second site again. Session 9's histogram showed the second bump. The QQ plot is the quick check you can run before the test. With 121 and 120 values the t-test is fairly robust, so the lesson is to look first and then decide, and Session 11 covers the options. The largest Cook's distance in the flipper model is 0.039, well under 1, so no single penguin pulls the fit. (d) the model `disability ~ total` has 169 schools, slope 0.110 students per student, intercept 8.30 and R-squared 0.598. Harris-Hillman Special Education (observation 53) has the largest residual: 799 students, 335 with a disability, 95.9 predicted, so +239 (standardized 7.83), with ordinary leverage (0.010) and D = 0.314. McGavock High (102) has the most leverage: 2,276 students, leverage 0.166, standardized residual 2.0, D = 0.398, the highest, and the point nearest the 0.5 contour. Martin Luther King Jr School (99), with 1,262 students and 23 with a disability, has a residual of -124 and D = 0.303. No school has D above 0.5, so none crosses a contour. A large residual alone (Harris-Hillman) or high leverage alone (McGavock) does not make a point influential. Both are real schools, so neither is an entry error. Without McGavock the slope goes from 0.110 to 0.104 and R-squared from 0.598 to 0.533. Without Harris-Hillman the slope is 0.106 and R-squared is 0.686, and without both it is 0.099 and 0.627. Report the full fit, say which schools were examined, and give the refit as a sensitivity check. In Python, `np.argsort(...)[::-1][:3] + 1` returns 102, 53 and 99, and the `.loc` rows are 0-based, so they are 52, 98 and 101.
