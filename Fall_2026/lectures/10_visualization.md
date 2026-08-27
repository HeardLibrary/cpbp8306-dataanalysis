# Session 10 — Data Visualization

**Unit:** 3 (Analysis)
**Duration:** 30-minute lecture + 20-minute activity
**Companion tutor:** `assistants_per_lecture/10_visualization_gpt.md`

---

## Framing

A good plot is the moment your data speaks to a reader. A bad plot is the moment they close the tab. This session teaches the **grammar of graphics** — a way of thinking about plots as compositions of components rather than as canned "plot types." Once you can describe a plot in that grammar, you can build any plot you can imagine, and you can direct AI to build it too. Prompting "make a nice bar chart" is a bad prompt. Prompting "geom_col, x = species, y = mean_mass, fill = sex, position dodge, error bars from sd_mass" is a great prompt.

---

## Learning objectives

Students should be able to:

1. Describe any plot in five components: **data, aesthetics, geometry, statistics, coordinates.**
2. Build a plot in ggplot2 and in matplotlib/seaborn using this grammar.
3. Choose the right plot for the question they're asking.
4. Add faceting to compare across a categorical variable.
5. Identify three common plotting sins (chart junk, unlabeled axes, misleading scales).

---

## 30-minute outline

| Time     | Segment                                             |
|----------|-----------------------------------------------------|
| 0–3      | Recap: EDA                                          |
| 3–10     | The grammar of graphics                             |
| 10–20    | Building plots in ggplot2 / seaborn                 |
| 20–26    | Choosing the right plot                             |
| 26–30    | Faceting + three plotting sins                      |

---

## Segment 1 (0–3 min): Recap

Ask: what's the difference between EDA plotting and publication plotting? Answer: audience. EDA is for you. Publication is for readers who have three seconds to understand the plot.

---

## Segment 2 (3–10 min): Grammar of graphics

Write the five components on the board:

1. **Data** — the tidy dataframe you're plotting.
2. **Aesthetics** — the mapping from data columns to visual properties (x, y, color, size, shape).
3. **Geometry** — the type of mark (point, line, bar, box).
4. **Statistics** — any summarization the plot performs (mean, count, smooth).
5. **Coordinates** — the axes (linear, log, polar) and facets (subplots).

Every plot you make is a choice about each of these. Once you internalize that, plotting stops being memorization.

---

## Segment 3 (10–20 min): Building plots

Same plot in both languages. Palmer penguins, bill length vs body mass, colored by species.

```r
library(ggplot2)
ggplot(df, aes(x = bill_length_mm, y = body_mass_g, color = species)) +
  geom_point() +
  labs(
    title = "Body mass vs bill length by species",
    x = "Bill length (mm)",
    y = "Body mass (g)",
    color = "Species"
  ) +
  theme_minimal()
```

```python
import seaborn as sns
import matplotlib.pyplot as plt

sns.scatterplot(
    data=df,
    x="bill_length_mm",
    y="body_mass_g",
    hue="species"
)
plt.xlabel("Bill length (mm)")
plt.ylabel("Body mass (g)")
plt.title("Body mass vs bill length by species")
plt.tight_layout()
plt.show()
```

Walk through it in grammar terms:
- Data = `df`.
- Aesthetics = `x=bill_length_mm, y=body_mass_g, color=species`.
- Geometry = `geom_point()` / `scatterplot`.
- Statistics = none (raw data).
- Coordinates = default linear.

Now change one thing at a time. Replace `geom_point()` with `geom_smooth(method = "lm")` — same data, same aesthetics, different geometry: now you have regression lines. Add `+ geom_point()` back and you have both. **The plot is composable.** This is the whole point.

Common geoms to introduce:

| ggplot2                | seaborn / matplotlib          | Use for                       |
|------------------------|--------------------------------|-------------------------------|
| `geom_point()`         | `scatterplot`                  | Two continuous variables      |
| `geom_line()`          | `lineplot`                     | Time series / trajectories    |
| `geom_col()`           | `barplot` (or matplotlib `bar`)| Discrete categories, one number each |
| `geom_bar()`           | `countplot`                    | Counts of a categorical       |
| `geom_boxplot()`       | `boxplot`                      | Distribution across groups    |
| `geom_violin()`        | `violinplot`                   | Distribution across groups, more detail |
| `geom_histogram()`     | `histplot`                     | Distribution of one continuous |
| `geom_density()`       | `kdeplot`                      | Smoothed distribution         |
| `geom_smooth()`        | `regplot` / `lmplot`           | Trend line with CI            |

---

## Segment 4 (20–26 min): Choosing the right plot

The decision tree, memorable version:

- **One continuous variable** → histogram or density plot.
- **One categorical variable** → bar chart of counts.
- **Two continuous** → scatter plot.
- **Two continuous + time** → line plot.
- **Continuous by categorical** → box plot or violin plot. (Bar chart of means loses information — dot/box shows the distribution.)
- **Two categorical** → mosaic plot, or a grouped/stacked bar chart, or a heatmap of counts.
- **More than two variables** → use color, shape, size, or **facets** (see below).

Anti-pattern to name explicitly: **the bar chart of means with a t-test asterisk.** It hides everything (distribution, sample size, outliers). If you have < 30 points per group, plot the raw points. If you have more, box plot at minimum.

---

## Segment 5 (26–30 min): Faceting + three sins

**Faceting** — split into subplots by a categorical variable:

```r
ggplot(df, aes(x = bill_length_mm, y = body_mass_g)) +
  geom_point() +
  facet_wrap(~ species)
```

```python
sns.relplot(data=df, x="bill_length_mm", y="body_mass_g", col="species")
```

Faceting is often better than color when you have more than 3-4 groups — human eyes can't distinguish 8 shades of color, but they can look at 8 small plots.

Three plotting sins to preempt:

1. **Chart junk.** 3D bar charts. Drop shadows. Unnecessary gridlines. Every pixel that isn't data is a distraction. Default `theme_minimal()` in ggplot2.
2. **Unlabeled or ambiguously labeled axes.** "value" is not a label. "Body mass (g)" is.
3. **Misleading scales.** A y-axis starting at 0.9 to make a 1% change look huge. A log scale with no annotation. Truncated axes for effect. Don't.

AI-generated plot code often includes chart junk (it was trained on Stack Overflow). Delete the junk. Ask yourself: what is *one thing* this plot needs to show? Anything not helping tell that story goes.

---

## Key vocabulary

- **Grammar of graphics** — data / aes / geom / stat / coord.
- **Aesthetic mapping** — data column → visual property.
- **Geometry / geom** — the type of mark (point, line, bar).
- **Facet** — a subplot split by a categorical variable.
- **Chart junk** — visual decoration that isn't data.

---

## Common student mistakes

- Trying to plot wide data. It won't work; go back to Session 8's `pivot_longer`.
- Encoding too many aesthetics at once (color + shape + size + alpha + facet). 3+ layers of information overwhelm readers.
- Not writing meaningful axis labels. This alone will get your project docked at grading.
- Copying a ggplot from ChatGPT that uses functions from a library you haven't loaded.

---

## Handoff to tutor activity

`assistants_per_lecture/10_visualization_gpt.md` — the tutor gives students an ugly ChatGPT-produced plot and asks them to describe (in grammar-of-graphics language) how they'd fix it before writing any code.
