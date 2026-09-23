# Problem Set 01 — Course Intro, Setup, and Thinking Like a Coder

**Session:** 1 (Unit 1 — Foundations)
**Pairs with:** `cpbp8306-dataanalysis/Fall_2026/slides/CPBP8306_Session1_Thinking_Like_a_Coder.pptx`, `demos/01_the_hook.py`
**Course data:** `cpbp8306-dataanalysis/Fall_2026/data/patients.csv`
**Use with:** `general_tutor_gpt.md`
**Time target:** ~20–25 minutes, worked through with the tutor

---

## Instructions for students

Paste this whole file into the Course Tutor and work through the problems together, in order. You'll need `data/patients.csv` (from the `Fall_2026/data/` folder) for problems 1–3 — either run the code yourself and report back what you see, or ask the tutor to run it with you. Try each problem yourself first if you'd like, but if you're stuck, just ask the tutor to show you.

---

## Problems

1. **The code an AI hands you.** Load `patients.csv` and run a t-test comparing `systolic` between `group == "A"` and `group == "B"` (drop missing values first). **Expect** first: do you think there will be a big difference? Then **run** it. What p-value do you get? Would you write this up as "no significant difference"?

2. **What's actually in the `group` column?** Run `df["group"].value_counts()`. Now run `sorted(repr(g) for g in df["group"].unique())`. Do these two outputs tell you the same thing? What does the second one reveal that the first one hides?

3. **Redo it correctly.** Strip whitespace from the `group` column (`df["group"].str.strip()`) and re-run the same t-test from problem 1. What's the new p-value? How many rows were silently excluded from the first (wrong) analysis, and why does that matter more than a typical outlier would?

4. **Why this is the dangerous kind of bug.** Nothing in problem 1 raised an error or a warning. Explain in your own words why a "silent" data problem like this is more dangerous to a research project than a bug that crashes the program.

5. **Tool check.** Now that you've set up your environment: in one sentence each, what's the difference between (a) Python/R and (b) VS Code/RStudio? What's the difference between Copilot and ChatGPT/Claude?

---

## Coverage (for instructor reference)

| # | Concept |
|---|---------|
| 1–3 | The flagship "hook" — a naive analysis that runs cleanly and is wrong |
| 2 | `value_counts()` vs. `repr()`/`unique()` for spotting hidden characters |
| 4 | Why silent failures are more dangerous than crashes |
| 5 | Tool tour: language vs. editor vs. AI assistant |
