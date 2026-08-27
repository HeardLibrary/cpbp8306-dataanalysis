# Session 13 — Synthesis: Advanced Viz, Image Analysis, Project Presentations, Post-Test

**Unit:** 4 (Synthesis)
**Duration:** Full 55 minutes (no separate 20-min activity — the activity IS the project + quiz)
**Companion tutor:** `assistants_per_lecture/13_synthesis_project_postquiz_gpt.md` (for project practice ahead of class)

---

## Framing

The last session brings the semester together. Two 5-minute topics (advanced viz, image analysis) that expand your toolkit, then project presentations, the final concept quiz, and the post-test. This is also the session where students see that everything we did was in service of one thing: a research analysis they own, from raw data to a communicated finding.

---

## Learning objectives

Students should be able to:

1. Add statistical annotations (means, error bars, significance markers) to a plot.
2. Combine multiple plots into a single figure (patchwork / cowplot / matplotlib subplots).
3. State what image data looks like as a numeric array and identify one common preprocessing step (thresholding, normalization).
4. Present a research finding in ≤ 5 minutes, framed as: question → data → method → figure → conclusion.

---

## 55-minute outline

| Time     | Segment                                                        |
|----------|----------------------------------------------------------------|
| 0–5      | Advanced viz: annotations, combining plots, maps               |
| 5–10     | Image analysis in 5 minutes                                    |
| 10–30    | Student project presentations (5 min each × 4)                 |
| 30–50    | Final concept quiz (see `final_quiz.md`)                       |
| 50–55    | Post-test + gluten-free donuts                                 |

*(Adjust presentation slots to class size. If > 8 students, run half in Session 13 and half in an extra session or as recorded videos.)*

---

## Segment 1 (0–5 min): Advanced viz

Three additions on top of Session 10:

**1. Statistical annotations.** Add means, error bars, and significance markers.

```r
library(ggpubr)
ggboxplot(df, x = "species", y = "bill_length_mm", add = "mean_se") +
  stat_compare_means(comparisons = list(c("Adelie","Chinstrap"), c("Adelie","Gentoo")))
```

```python
import seaborn as sns
from statannotations.Annotator import Annotator
ax = sns.boxplot(data=df, x="species", y="bill_length_mm")
Annotator(ax, [("Adelie","Chinstrap"), ("Adelie","Gentoo")],
          data=df, x="species", y="bill_length_mm").configure(test="t-test_ind").apply_and_annotate()
```

Warn: significance stars on plots are a communication choice, not a statistical result. Report the actual p and effect size in the write-up.

**2. Combining plots.**

```r
library(patchwork)
p1 <- ggplot(df, aes(x = bill_length_mm)) + geom_histogram()
p2 <- ggplot(df, aes(x = body_mass_g))    + geom_histogram()
p1 + p2                          # side by side
p1 / p2                          # stacked
(p1 + p2) / p3                   # arbitrary layout
```

```python
import matplotlib.pyplot as plt
fig, axes = plt.subplots(1, 2, figsize=(10, 4))
sns.histplot(df, x="bill_length_mm", ax=axes[0])
sns.histplot(df, x="body_mass_g",    ax=axes[1])
```

Rule: for a paper, combine related plots into a single figure with panels (A), (B), (C). Reviewers want to see the story assembled.

**3. Maps** — brief mention. `sf` + `ggplot2::geom_sf()` in R, `geopandas` + `plot()` in Python. If your data has lat/lon or country/state codes, geographic plotting is a whole workshop; point students to https://r-graph-gallery.com/ and https://geopandas.org/ for further reading.

---

## Segment 2 (5–10 min): Image analysis in 5 minutes

The idea students should walk out with: **an image is a numeric array.** Everything you know about arrays applies.

```python
import numpy as np
from skimage import io
img = io.imread("cell.png")     # shape (H, W, C) — height × width × channels
img.dtype                        # usually uint8, values 0-255
img.mean()                       # average brightness

# grayscale threshold
from skimage.color import rgb2gray
from skimage.filters import threshold_otsu
g = rgb2gray(img)
thresh = threshold_otsu(g)
mask = g > thresh                # True where pixel is above threshold — a binary mask

# count connected regions (e.g., cells)
from skimage.measure import label, regionprops
labeled = label(mask)
n_regions = labeled.max()        # number of connected regions
props = regionprops(labeled)     # area, centroid, etc. for each region
```

Three concepts:

1. **Preprocessing** — convert to grayscale, denoise, normalize.
2. **Segmentation** — turn continuous intensity into a binary mask (thresholding, edge detection, watershed).
3. **Feature extraction** — measurements per region (area, intensity, shape).

Point students at `scikit-image` (Python) and the `imager` / `EBImage` packages (R) for going deeper. Deep-learning-based segmentation (Cellpose, StarDist) is a further layer that we're not covering — mention it exists.

**AI caveat:** ChatGPT will happily write image-analysis code that "runs" but does the wrong thing. Verify with a known ground-truth image before trusting the pipeline on your data.

---

## Segment 3 (10–30 min): Student project presentations

Each student gets **5 minutes** for:
1. **Question** (30 sec) — what did you want to know?
2. **Data** (30 sec) — where from, how many rows/columns, any cleaning story.
3. **Method** (60 sec) — what did you do? (test, model, viz).
4. **Figure** (60 sec) — one plot that tells the story.
5. **Conclusion** (60 sec) — what did you find? What are the limitations?
6. **Q&A** (60 sec).

Grading rubric (from `course_overview.md`, expanded):

| Criterion                                    | Points |
|----------------------------------------------|--------|
| Reproducibility (code in GitHub, README, seed)| 5     |
| Cleaning documentation (decisions logged)     | 5     |
| Correct choice of analysis for the question   | 8     |
| One well-executed publication-quality figure  | 8     |
| Clear communication in write-up + talk        | 4     |
| **Total (write-up + presentation)**           | **30** |

**Presentations that fail:** copy-pasted AI output with no cleaning story; a test on data whose assumptions weren't checked; a plot without axis labels; conclusions the analysis doesn't actually support.

**Presentations that succeed:** the student can answer "what happens if I flipped this parameter?" — they show they own the analysis.

---

## Segment 4 (30–50 min): Final quiz

Administer `final_quiz.md`. 20 minutes. Closed-notebook. See that file for the full quiz + rubric.

---

## Segment 5 (50–55 min): Post-test + donuts

Post-test on Brightspace. Same Likert scale as pre-test — confidence with coding concepts, plus two open-response questions:

1. "What is the most important thing you learned in this course?"
2. "What is one thing you know you still can't do, that we didn't cover?"

Gluten-free donuts.

---

## Key vocabulary

- **Panel / composite figure** — a multi-plot figure with labeled panels (A), (B).
- **Statistical annotation** — significance markers or error bars drawn on a plot.
- **Segmentation** — turning an image into labeled regions.
- **Threshold** — a value above which a pixel is "on" and below which it is "off."
- **Reproducibility** — someone else can rerun your code on your data and get your results.

---

## Handoff to tutor activity

For the weeks *leading up to* the presentation, students should use `assistants_per_lecture/13_synthesis_project_postquiz_gpt.md` and the four unit-level tutors in `assistants_by_unit/` as study/practice partners. The unit-level tutors are especially useful for the final quiz — they don't rehearse quiz answers, but they will help the student verify their conceptual understanding.
