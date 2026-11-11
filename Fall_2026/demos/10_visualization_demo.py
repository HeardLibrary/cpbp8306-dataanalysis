"""
Session 10 demo: Data Visualization (Python)

Every code snippet from the Session 10 slides, in slide order. Each block says what
the code does and what you should see, so you can check your own output against
the comments. The slides show the R version first. This script uses the pandas and
seaborn version of each one.

It uses the same three datasets as Sessions 7 to 9: penguins, patients and
schools. Nothing is made up.

Put these three files next to this script, then run:  python 10_visualization_demo.py
    penguins.csv         Brightspace
    patients.csv         Brightspace
    schools_tibble.csv   Brightspace

Plots are saved as PNG files in a folder called demo10_figures, so the script also
works from a terminal. To see a plot on screen instead, run the plotting line by
itself in VS Code or Jupyter and add plt.show().

Needs pandas, numpy, scipy, matplotlib and seaborn
(pip install pandas numpy scipy matplotlib seaborn). The seaborn.objects blocks need
seaborn 0.12 or newer. statsmodels is optional (slides 10 and 11).
"""
import os

import matplotlib
matplotlib.use("Agg")                     # draw to files, so no window is needed
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from scipy import stats


def section(title):
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


os.makedirs("demo10_figures", exist_ok=True)


def save_plot(name, width=6, height=3.6):
    """Save the current figure as a PNG and close it."""
    path = os.path.join("demo10_figures", name + ".png")
    plt.gcf().set_size_inches(width, height)
    plt.tight_layout()
    plt.savefig(path, dpi=150)
    plt.close()
    print("saved", path)


# ---------------------------------------------------------------------------
# Slide 2: load the data
# ---------------------------------------------------------------------------
section("Slide 2: load the data")

df = pd.read_csv("penguins.csv")          # df is the penguins table in both languages
raw = pd.read_csv("patients.csv")         # pandas keeps the trailing space in "A "

# The Session 8 cleaning, in a few lines. errors="coerce" turns the six "unknown"
# ages into NaN.
patients = raw.copy()
patients["group"] = patients["group"].str.strip()
patients["sex"] = patients["sex"].str.upper()
patients["age"] = pd.to_numeric(patients["age"], errors="coerce")

# The schools file has one label for two kinds of non-traditional school.
schools = pd.read_csv("schools_tibble.csv")
schools["school_level"] = schools["school_level"].str.replace(" - Hybrid", "", regex=False)

print(patients.shape)                     # (250, 9)
print(df.shape)                           # (344, 9): 8 columns plus an unnamed row-number column
print(schools.shape)                      # (169, 35)

# A CSV written from R has a row-number column that pandas calls "Unnamed: 0". It is
# harmless as long as you pick columns by name.


# ---------------------------------------------------------------------------
# Slide 4: five choices, every plot you will ever make
# ---------------------------------------------------------------------------
section("Slide 4: data, aesthetics, geometry, statistics, coordinates")

# seaborn.objects is the closest thing in Python to ggplot2. It builds a plot from the
# same five parts, one layer at a time.
import seaborn.objects as so

# 1. DATA and 2. AESTHETICS: the table, and which column goes to which property.
p = so.Plot(df, x="bill_length_mm", y="body_mass_g", color="species").layout(size=(7, 4))
p.save("demo10_figures/04_empty_axes.png", bbox_inches="tight")      # axes and a grid, no points
print("saved demo10_figures/04_empty_axes.png")

# 3. GEOMETRY: the mark. .add() puts a layer on the plot, like + in ggplot2.
p.add(so.Dot()).save("demo10_figures/04_points.png", bbox_inches="tight")
print("saved demo10_figures/04_points.png")
# 4. STATISTICS: a summary the plot computes (here none, the points are raw).
# 5. COORDINATES: .scale(x="log") changes the axis without touching the data.

# The classic seaborn functions draw the same thing in one call. Use whichever you
# like. Everything below uses the classic functions, with seaborn.objects as a pair.
sns.scatterplot(df, x="bill_length_mm", y="body_mass_g", hue="species")
save_plot("04_scatter")

# A prompt for an AI assistant should name all five parts. "Make a nice bar chart"
# names none of them. "Bars of mean mass by species, filled by sex, side by side, with
# error bars from the standard deviation" names them all.


# ---------------------------------------------------------------------------
# Slide 5: build it twice, one layer at a time
# ---------------------------------------------------------------------------
section("Slide 5: layers, and where the aesthetic lives")

# Same data, same aesthetics, a different geometry: a fitted line per species.
# so.PolyFit(order=1) is the statistics part: it computes the regression for you.
p.add(so.Line(), so.PolyFit(order=1)).save("demo10_figures/05_smooth_only.png", bbox_inches="tight")
print("saved demo10_figures/05_smooth_only.png")
# Add both layers and the plot is composable: points and lines, drawn together.
p.add(so.Dot()).add(so.Line(), so.PolyFit(order=1)).save("demo10_figures/05_points_and_lines.png", bbox_inches="tight")
print("saved demo10_figures/05_points_and_lines.png")

# Where the aesthetic lives. color="species" in so.Plot() is inherited by every
# layer, so the line is drawn once per species.
(so.Plot(df, x="bill_length_mm", y="body_mass_g", color="species").layout(size=(7, 4))
   .add(so.Dot()).add(so.Line(), so.PolyFit(order=1))
   .save("demo10_figures/05_global_color.png", bbox_inches="tight"))
print("saved demo10_figures/05_global_color.png")
# Move color into the Dot layer and it belongs to that layer only. The line now sees
# all the penguins together and is drawn once.
(so.Plot(df, x="bill_length_mm", y="body_mass_g").layout(size=(7, 4))
   .add(so.Dot(), color="species").add(so.Line(), so.PolyFit(order=1))
   .save("demo10_figures/05_local_color.png", bbox_inches="tight"))
print("saved demo10_figures/05_local_color.png")

# The same two ideas with the classic functions: lmplot() draws a line per hue level,
# and regplot() on top of a scatter plot draws one line for everything.
sns.lmplot(df, x="bill_length_mm", y="body_mass_g", hue="species", ci=None)
plt.savefig("demo10_figures/05_global_color_classic.png", dpi=150)
plt.close()
ax = sns.scatterplot(df, x="bill_length_mm", y="body_mass_g", hue="species")
sns.regplot(df, x="bill_length_mm", y="body_mass_g", scatter=False, ci=None,
            color="black", ax=ax)
save_plot("05_local_color_classic")

# The slopes behind the lines, in grams per millimeter of bill.
d = df.dropna(subset=["bill_length_mm", "body_mass_g"])
print(round(stats.linregress(d["bill_length_mm"], d["body_mass_g"]).slope, 1))   # 87.4 overall
for name, g in d.groupby("species"):
    print(name, round(stats.linregress(g["bill_length_mm"], g["body_mass_g"]).slope, 1))
# Adelie 94.5, Chinstrap 59.1, Gentoo 109.5. Session 9's Simpson's paradox is the
# same split: look at the groups before you believe the overall line.


# ---------------------------------------------------------------------------
# Slide 6: what plot, for what question
# ---------------------------------------------------------------------------
section("Slide 6: choose the plot")

# One continuous variable: histogram or density.
sns.histplot(df, x="body_mass_g", bins=30)
save_plot("06_histogram")
sns.kdeplot(df, x="body_mass_g", hue="species", fill=True, alpha=0.5)
save_plot("06_density")

# One categorical variable: a bar chart of counts. countplot() counts the rows for you.
# Long labels read better on the y axis, and bars sorted by count are easier to compare.
print(schools["school_level"].value_counts())
# Elementary School 76, Charter 31, Middle School 31, High School 17, Non-Traditional 7,
# Special Education 3, Alternative Learning Center 2, Adult 1, GATE Center 1
sns.countplot(schools, y="school_level", order=schools["school_level"].value_counts().index)
plt.xlabel("Schools")
plt.ylabel("School level")
save_plot("06_bar_counts")

# Continuous by categorical: a box plot, and the raw points on top.
sns.boxplot(df, x="species", y="body_mass_g", showfliers=False)
sns.stripplot(df, x="species", y="body_mass_g", color="black", alpha=0.4, jitter=0.15)
save_plot("06_box_plus_points")

# The anti-pattern: a bar chart of means. This is systolic pressure by group.
means = patients.groupby("group")["systolic"].agg(["mean", "std", "count"])
print(means.round(1))   # A 129.4 (sd 15.1, n 121), B 134.2 (sd 11.9, n 120)
sns.barplot(patients, x="group", y="systolic", errorbar="sd", capsize=0.2, color="0.35")
plt.xlabel("Group")
plt.ylabel("Systolic pressure (mmHg), mean and sd")
save_plot("06_bar_of_means")
# Two bars and two error bars. Nothing shows that group A holds two kinds of patient.

# The same data as points, colored by the original label from raw. The 40 rows that read
# "A " (a trailing space) are a second recruitment site.
by_site = raw.assign(site=np.where(raw["group"] == "A ", "second site", "first site"))
by_site["group"] = by_site["group"].str.strip()
sns.stripplot(by_site, x="group", y="systolic", hue="site", jitter=0.15, alpha=0.7)
plt.xlabel("Group")
plt.ylabel("Systolic pressure (mmHg)")
save_plot("06_points_by_site")
a = by_site[by_site["group"] == "A"]
print(a.groupby("site")["systolic"].agg(["count", "mean"]).round(1))
# first site n 81, mean 136.2 / second site n 40, mean 115.5. The points show it. The bars hide it.
# Rule of thumb: under about 30 points per group, plot the points. With more, a box
# plot at least, and the points too when they are not a blur.


# ---------------------------------------------------------------------------
# Slide 7: facets, when color runs out
# ---------------------------------------------------------------------------
section("Slide 7: facets")

# relplot() with col= splits one plot into a row of small plots, one per level.
sns.relplot(df, x="bill_length_mm", y="body_mass_g", col="species", alpha=0.6,
            height=3, aspect=0.9)
plt.savefig("demo10_figures/07_facet_wrap.png", dpi=150)
plt.close()
print("saved demo10_figures/07_facet_wrap.png")

# Two grouping variables: row= and col=. Species and island make a 3 x 3 grid.
print(pd.crosstab(df["species"], df["island"]))
# Adelie lives on all three islands (44, 56, 52). Chinstrap is only on Dream (68) and
# Gentoo only on Biscoe (124). So 5 of the 9 panels hold data and 4 stay empty.
sns.relplot(df, x="bill_length_mm", y="body_mass_g", row="island", col="species",
            alpha=0.6, height=2.2, aspect=1.2, facet_kws={"margin_titles": True})
plt.savefig("demo10_figures/07_facet_grid.png", dpi=150)
plt.close()
print("saved demo10_figures/07_facet_grid.png")
# Every panel shares the same axes by default, so the panels compare honestly.
# Past 3 or 4 groups, facet instead of coloring. Eyes cannot tell eight shades of one
# color apart, but they can scan eight small plots.


# ---------------------------------------------------------------------------
# Slide 8: label it, then check it for the three sins
# ---------------------------------------------------------------------------
section("Slide 8: labels, scales and the three sins")

# A figure for a reader names what is on each axis, with units, and states the finding.
sns.set_theme(style="ticks")                       # a quiet background, no heavy grid
ax = sns.scatterplot(df, x="bill_length_mm", y="body_mass_g", hue="species",
                     palette="viridis", alpha=0.7)    # survives grayscale and color blindness
ax.set(title="Longer bills go with heavier penguins in all three species",
       xlabel="Bill length (mm)", ylabel="Body mass (g)")
ax.legend(title="Species", frameon=False)
sns.despine()
save_plot("08_polished")
polished = plt.figure()                            # a fresh figure for the export on slide 9
plt.close(polished)

# Sin 1, chart junk: 3D bars, shadows, gridlines that carry nothing. Sin 2, ambiguous
# labels: "value" or "y" is not a label. Sin 3, misleading scales. Here is the same
# bar chart of means twice.
group_means = patients.groupby("group")["systolic"].mean()
for name, ylim in [("08_bars_from_zero", None), ("08_bars_truncated", (125, 135))]:
    fig, ax = plt.subplots()
    ax.bar(group_means.index, group_means.values, color="0.35")
    ax.set(xlabel="Group", ylabel="Mean systolic pressure (mmHg)")
    if ylim:
        ax.set_ylim(*ylim)
    sns.despine()
    plt.savefig(f"demo10_figures/{name}.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("saved", f"demo10_figures/{name}.png")
print(group_means.round(1).tolist())                                   # [129.4, 134.2]
print(round(group_means["B"] / group_means["A"], 3))                   # 1.037, a 3.7% difference
print(round((group_means["B"] - 125) / (group_means["A"] - 125), 1))   # 2.1
# Cut the axis at 125 and group B's bar looks 2.1 times as tall as group A's, for a
# 3.7% difference. Bars must start at zero, because their length is the data. Points do
# not have to, because their position is the data.
# AI-written plot code often includes the junk. Delete it. Ask what the one thing this
# plot must show is, and remove anything that does not help.


# ---------------------------------------------------------------------------
# Slide 9: save it at the size it will be printed
# ---------------------------------------------------------------------------
section("Slide 9: savefig() and combining panels")

# savefig() sets the resolution with dpi and the size with figsize, in inches. Many
# journals ask for about 3.5 inches wide (one column) or 7 inches (two columns). Check
# the author guidelines. dpi=300 is the usual minimum for a raster figure.
fig, ax = plt.subplots(figsize=(7, 4))
sns.scatterplot(df, x="bill_length_mm", y="body_mass_g", hue="species",
                palette="viridis", alpha=0.7, ax=ax)
ax.set(xlabel="Bill length (mm)", ylabel="Body mass (g)")
sns.despine()
fig.savefig("demo10_figures/09_figure1.png", dpi=300, bbox_inches="tight")
# A vector format has no resolution, so it stays sharp at any size. Journals often want one.
fig.savefig("demo10_figures/09_figure1.pdf", bbox_inches="tight")
plt.close(fig)
print("7 inches at 300 dpi is", 7 * 300, "pixels wide")   # 2100

# Save with code, not the export button. A script rebuilds the figure in one run when a
# reviewer asks for a change.

# Two plots in one figure, with panel letters (the R version uses patchwork). Session 13
# comes back to this with annotations.
fig, axes = plt.subplots(1, 2, figsize=(9, 3.8))
sns.barplot(patients, x="group", y="systolic", errorbar="sd", capsize=0.2,
            color="0.35", ax=axes[0])
sns.stripplot(by_site, x="group", y="systolic", hue="site", jitter=0.15, alpha=0.7,
              ax=axes[1])
for ax, letter in zip(axes, "AB"):
    ax.set_title(letter, loc="left", fontweight="bold")
    ax.set(xlabel="Group", ylabel="Systolic pressure (mmHg)")
sns.despine()
fig.tight_layout()
fig.savefig("demo10_figures/09_combined.png", dpi=150)
plt.close(fig)
print("saved demo10_figures/09_combined.png")


# ---------------------------------------------------------------------------
# Slide 10: plots that check a model
# ---------------------------------------------------------------------------
section("Slide 10: residuals and the QQ plot")

# Residuals are what the model did not explain: observed minus fitted. A diagnostic
# plot looks at them to see whether the model is a fair description. Session 11 fits
# models in earnest. Here is the picture, using only numpy and scipy.
d = df.dropna(subset=["body_mass_g", "flipper_length_mm"]).copy()
slope, intercept = np.polyfit(d["flipper_length_mm"], d["body_mass_g"], 1)
d["fitted"] = intercept + slope * d["flipper_length_mm"]
d["resid"] = d["body_mass_g"] - d["fitted"]
r2 = 1 - (d["resid"] ** 2).sum() / ((d["body_mass_g"] - d["body_mass_g"].mean()) ** 2).sum()
print(round(r2, 3))                           # 0.759
print(round(intercept, 2), round(slope, 2))   # -5780.83 and 49.69 g per mm

# Residuals vs fitted: you want a shapeless cloud around zero. A curve means the line
# is the wrong shape. A funnel means the spread changes. Colored by species, the
# residuals show structure the line missed.
ax = sns.scatterplot(d, x="fitted", y="resid", hue="species")
ax.axhline(0, linestyle="--", color="black", linewidth=1)
ax.set(xlabel="Fitted body mass (g)", ylabel="Residual (g)")
save_plot("10_residuals_vs_fitted")
print(d.groupby("species")["resid"].mean().round().tolist())   # Adelie 44, Chinstrap -216, Gentoo 66
# Chinstrap penguins sit below the line. Adding species to the model lifts R-squared
# from 0.759 to 0.783 (Session 11):
X = np.column_stack([np.ones(len(d)), d["flipper_length_mm"],
                     (d["species"] == "Chinstrap"), (d["species"] == "Gentoo")]).astype(float)
beta, *_ = np.linalg.lstsq(X, d["body_mass_g"].to_numpy(), rcond=None)
resid2 = d["body_mass_g"].to_numpy() - X @ beta
print(round(1 - (resid2 ** 2).sum() / ((d["body_mass_g"] - d["body_mass_g"].mean()) ** 2).sum(), 3))   # 0.783

# QQ plot: sorted values against what a normal distribution would give. Points on the
# line mean normal. Ends that peel away mean a skewed distribution or extreme values.
# Here is systolic pressure by group, the data behind the Session 1 test.
fig, axes = plt.subplots(1, 2, figsize=(6, 3), sharey=True)
for ax, (name, g) in zip(axes, patients.groupby("group")):
    stats.probplot(g["systolic"].dropna(), dist="norm", plot=ax)
    ax.set_title(name)
    ax.set_xlabel("Theoretical quantiles")
axes[0].set_ylabel("Systolic pressure (mmHg)")
axes[1].set_ylabel("")
fig.tight_layout()
fig.savefig("demo10_figures/10_qq_by_group.png", dpi=150)
plt.close(fig)
print("saved demo10_figures/10_qq_by_group.png")
a = patients.loc[patients["group"] == "A", "systolic"].dropna()
b = patients.loc[patients["group"] == "B", "systolic"].dropna()
print(round(stats.shapiro(a).pvalue, 3), round(stats.shapiro(b).pvalue, 3))   # 0.018 and 0.471
# Group A's ends curl away from the line (Shapiro-Wilk p = 0.018). Group B is close to it
# (p = 0.471). A QQ plot drawn before the t-test would have flagged group A, the same
# message as the histogram on Session 9 slide 7.

# R's plot(fit) also draws scale-location and residuals vs leverage. In Python those come
# from statsmodels, which Session 11 installs. This block runs only if it is there.
try:
    import statsmodels.api as sm
    fit = sm.OLS(d["body_mass_g"], sm.add_constant(d["flipper_length_mm"])).fit()
    cooks = fit.get_influence().cooks_distance[0]
    print("largest Cook's distance:", round(cooks.max(), 3))   # 0.039
    sm.qqplot(fit.resid, line="s")                               # the QQ plot of the residuals
    save_plot("10_qq_residuals_statsmodels")
except ImportError:
    print("statsmodels is not installed, so the Cook's distance block is skipped.")


# ---------------------------------------------------------------------------
# Slide 11: reading the four plots from plot(fit)
# ---------------------------------------------------------------------------
section("Slide 11: residuals vs leverage, and Cook's distance")

# A model with some unusual points: the number of students with a disability against
# total enrollment at the 169 Metro Nashville schools. total is the sum of the 15 grade
# columns, and a missing grade count means the grade is not offered, so it adds nothing.
# statsmodels gives the leverage, standardized residual and Cook's distance for each
# school. It is optional here, and Session 11 installs it.
try:
    import statsmodels.api as sm
except ImportError:
    sm = None
    print("statsmodels is not installed, so slide 11 is skipped.")

if sm is not None:
    schools["total"] = schools.filter(like="grade_").sum(axis=1)
    fit2 = sm.OLS(schools["disability"], sm.add_constant(schools["total"])).fit()
    print(round(fit2.rsquared, 3))                      # 0.598
    print(fit2.params.round(4).tolist())                # intercept 8.2973, slope 0.1097

    infl = fit2.get_influence()
    leverage = infl.hat_matrix_diag
    std_resid = infl.resid_studentized_internal
    cooks = infl.cooks_distance[0]

    # Residuals vs leverage: the panel R draws fourth. Look at the right-hand side for
    # high leverage, and the top and bottom for large residuals.
    fig, axes = plt.subplots(1, 2, figsize=(9, 3.6))
    axes[0].scatter(leverage, std_resid, facecolors="none", edgecolors="black")
    axes[0].axhline(0, linestyle=":", color="grey")
    axes[0].set(xlabel="Leverage", ylabel="Standardized residual", title="Residuals vs leverage")
    # Cook's distance as bars. The rule-of-thumb lines in R's leverage plot are 0.5 and 1.
    axes[1].vlines(np.arange(1, len(cooks) + 1), 0, cooks, color="black", linewidth=0.8)
    axes[1].set(xlabel="Observation number", ylabel="Cook's distance", title="Cook's distance")
    top = np.argsort(cooks)[::-1][:3]
    for i in top:
        axes[0].annotate(str(i + 1), (leverage[i], std_resid[i]), xytext=(4, 2), textcoords="offset points")
        axes[1].annotate(str(i + 1), (i + 1, cooks[i]), xytext=(0, 3), textcoords="offset points", ha="center")
    fig.tight_layout()
    fig.savefig("demo10_figures/11_leverage_and_cooks_schools.png", dpi=150)
    plt.close(fig)
    print("saved demo10_figures/11_leverage_and_cooks_schools.png")

    # Who are the unusual points? Observation numbers start at 1, and pandas rows at 0.
    print(top + 1)                                      # 102 53 99
    print(cooks[top].round(3))                          # 0.398 0.314 0.303: none reaches 0.5
    print(schools.loc[top, ["school_name", "school_level", "total", "disability"]])
    print(pd.DataFrame({"fitted": fit2.fittedvalues[top].round(1),
                        "residual": fit2.resid[top].round(1),
                        "leverage": leverage[top].round(3)}))
    # McGavock High (102): 2276 students, leverage 0.166, the most of any school. It sits
    #   near the line (standardized residual 2.0), so its pull is modest.
    # Harris-Hillman Special Education (53): 799 students, 335 with a disability, 95.9
    #   predicted. Residual +239.1 (standardized 7.83) but leverage only 0.010.
    # Martin Luther King Jr School (99): 1262 students, 23 with a disability, residual -123.7.
    # A point needs both a large residual and high leverage to be influential. Neither has
    # enough of both to cross a contour, and all three are real schools, not entry errors.

    # What to do with an unusual point: check it, refit without it, and report both fits.
    def refit(drop):
        keep = schools.drop(index=drop)
        f = sm.OLS(keep["disability"], sm.add_constant(keep["total"])).fit()
        return round(float(f.params["total"]), 3), round(float(f.rsquared), 3)

    print(round(fit2.params["total"], 3), round(fit2.rsquared, 3))   # 0.110 0.598
    print(refit([101]))             # without McGavock:        (0.104, 0.533)
    print(refit([52]))              # without Harris-Hillman:  (0.106, 0.686)
    print(refit([52, 101]))         # without both:            (0.099, 0.627)


# ---------------------------------------------------------------------------
# Try it yourself
# ---------------------------------------------------------------------------
# 1. Replace PolyFit(order=1) with PolyFit(order=2). What changes in the lines, and when
#    would you not trust a curved fit?
# 2. Make a violin plot of body_mass_g by species with sns.violinplot(). What does it show
#    that the box plot did not?
# 3. In the lmplot() call, add col="island". How many panels are empty?
# 4. Change palette="viridis" to palette="Set2". Does the plot still read in grayscale?
# 5. Save the polished plot at figsize=(3.5, 2.5). What breaks, and how do you fix it
#    (font size, legend position)?
# 6. Fit disability ~ total again with Harris-Hillman and McGavock High dropped. How far
#    does the slope move? Would you report it?
