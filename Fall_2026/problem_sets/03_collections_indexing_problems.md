# Problem Set 03 — Lists, Vectors, and Dictionaries

**Session:** 3 (Unit 1 — Foundations)
**Pairs with:** `cpbp8306-dataanalysis/Fall_2026/slides/CPBP8306_Session3_Collections_and_Indexing.pptx`, `demos/03_collections_demo.py`, `demos/03_collections_demo.R`
**Course data:** `cpbp8306-dataanalysis/Fall_2026/data/patients.csv`
**Use with:** `general_tutor_gpt.md`
**Time target:** ~20–25 minutes, worked through with the tutor

---

## Instructions for students

Paste this whole file into the Course Tutor and work through the problems together, in order. Problem 2 needs `data/patients.csv`.

---

## Problems

1. **Create and measure.** Given `bp = [117, 122, 141, 130, 118]` (Python list) / `bp <- c(117, 122, 141, 130, 118)` (R vector), what does `len(bp)` / `length(bp)` return? Now: Python does **not** silently coerce a mixed list like `[1, 2, "three"]` — each element keeps its own type. What does R do instead with `c(1, 2, "three")`, and why is that more dangerous?

2. **The real `sex` column.** Load `patients.csv` and look at the unique values in the `sex` column. How many distinct categories does R (or pandas) think there are, and why is that more than the two you'd expect? (Hint: this is the same *kind* of problem as the `group` column from Session 1 — just a different symptom.)

3. **0-indexed vs. 1-indexed.** Using `bp` above: what is `bp[0]` in Python? What is `bp[1]` in R? Are they the same element? Now the genuine trap: what does `bp[-1]` mean in Python, and what does it mean in R?

4. **Slicing.** Predict `bp[1:4]` in Python and `bp[2:4]` in R. Why do these produce the same three values even though the numbers in the brackets are different? (Hint: is the stop value included, in each language?)

5. **Boolean masks.** In R, `bp > 130` and `bp[bp > 130]` work with no extra packages. In plain Python, `bp >= 130` on a list raises a `TypeError`. What do you need to make Python's lists support this — and once you have it, what does `arr[arr >= 130]` return?

6. **Dict or list?** A single patient's record — id, age, systolic, treated — has mixed types, each with a name. Should this be a list/vector or a dict/named list? Now: a column of 250 patients' ages, all the same type — which container fits that?

---

## Coverage (for instructor reference)

| # | Concept |
|---|---------|
| 1 | Python heterogeneous lists vs. R's silent vector coercion |
| 2 | The real `sex` casing defect in the course data |
| 3 | 0-indexed (Python) vs. 1-indexed (R); the `-1` trap |
| 4 | Slicing — exclusive vs. inclusive stop |
| 5 | Boolean indexing; why Python needs numpy/pandas for it |
| 6 | Dict / named list vs. list / vector |
