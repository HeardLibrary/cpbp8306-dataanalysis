# Problem Set 02 — Variables, Types, and Expressions

**Session:** 2 (Unit 1 — Foundations)
**Pairs with:** `cpbp8306-dataanalysis/Fall_2026/slides/CPBP8306_Session2_Variables_and_Types.pptx`, `demos/02_types_demo.py`
**Course data:** `cpbp8306-dataanalysis/Fall_2026/data/patients.csv`
**Use with:** `general_tutor_gpt.md`
**Time target:** ~20–25 minutes, worked through with the tutor

---

## Instructions for students

Paste this whole file into the Course Tutor and work through the problems together, in order. Problem 6 needs `data/patients.csv` — either run it yourself or ask the tutor to run it with you.

---

## Problems

1. **Predict the type.** For `a, b, c, d = 5, "5", 5.0, True` — what does `type()` return for each? **Expect** an answer for each one before you check.

2. **Predict before you run.** Using the same `a, b, c, d` from problem 1: what is `a == c`? What is `a == b` — and why is there no error, just a quiet `False`? What is `d == 1`? What is `b * 3`?

3. **Booleans are secretly numbers.** Given `passed_qc = [True, False, True, True, False]`, predict `sum(passed_qc)` and `sum(passed_qc) / len(passed_qc)`. What does each number actually represent about this batch of samples?

4. **String glue, not addition.** Predict `"5" + "3"`. Now predict `"5" + 3` — what happens, and why does Python refuse to guess instead of just picking an answer?

5. **The float trap.** Predict whether `0.1 + 0.2 == 0.3` is `True` or `False`, then explain why — and give the line of code you'd use instead to check if two floats are "close enough."

6. **A real `TypeError`, on the real course data.** Load `patients.csv` and check `df["age"].dtype`. It's `object` — text, not numbers. Find out why: look at `df["age"].unique()` for values that aren't plain digits. Then run `df["age"].mean()` and read the resulting error. Following "read from the bottom up": what does the last line of the traceback say, and where — upstream, not on that line — is the actual bug?

---

## Coverage (for instructor reference)

| # | Concept |
|---|---------|
| 1 | The four primitive types |
| 2 | Assignment vs. equality; booleans as numbers; string repetition |
| 3 | Booleans behave like numbers in aggregate |
| 4 | String concatenation vs. numeric addition; Python refusing to coerce |
| 5 | Floating-point comparison |
| 6 | Reading a real `TypeError` bottom-up; upstream root cause |
