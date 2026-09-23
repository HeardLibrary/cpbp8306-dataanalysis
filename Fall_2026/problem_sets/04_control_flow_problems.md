# Problem Set 04 — Control Flow: Conditionals and Loops

**Session:** 4 (Unit 1 — Foundations)
**Pairs with:** `cpbp8306-dataanalysis/Fall_2026/slides/CPBP8306_Session4_Control_Flow.pptx`, `demos/04_loops_demo.py`
**Course data:** `cpbp8306-dataanalysis/Fall_2026/data/patients.csv`
**Use with:** `general_tutor_gpt.md`
**Time target:** ~20–25 minutes, worked through with the tutor

---

## Instructions for students

Paste this whole file into the Course Tutor and work through the problems together, in order. Problem 5 needs `data/patients.csv`.

---

## Problems

1. **`elif` is not the same as another `if`.** Given:
   ```python
   def categorise_wrong(bp):
       if bp >= 140:
           category = "high"
       if bp >= 120:
           category = "elevated"
       if bp < 120:
           category = "normal"
       return category
   ```
   What does `categorise_wrong(145)` return? Is that right? Now rewrite it using `if / elif / else` so it gives the correct answer, and explain in one sentence *why* the first version silently overwrites itself.

2. **Trace the accumulator.** Given `bp_list = [117, 145, 130, 150, 118]` and the accumulator pattern (`count_high = 0`, then a `for` loop that adds 1 each time `bp >= 140`), what is `count_high` at the end?

3. **Vectorize it.** Rewrite the loop from problem 2 with no explicit loop. In R this is one line: `sum(bp_list >= 140)`. What's the Python equivalent using a comprehension, and (if you have numpy) using a boolean array?

4. **Why it matters — the timing argument.** The same vectorized count on 5 million rows runs dramatically faster than the loop version — often 10–100×. Besides speed, name one *correctness* reason a vectorized line is preferred over a hand-written loop.

5. **Apply it to the real data.** Load `patients.csv` and count how many rows have `systolic >= 140`, two ways: (a) with an explicit `for` loop over the column, and (b) with one vectorized line. Do you get the same answer both ways?

---

## Coverage (for instructor reference)

| # | Concept |
|---|---------|
| 1 | `if / elif / else` vs. independent `if` statements |
| 2 | `for` loop + accumulator pattern |
| 3 | Vectorization — the no-loop version |
| 4 | Why vectorization is preferred (speed and correctness) |
| 5 | Applying loop vs. vectorized counting to real course data |
