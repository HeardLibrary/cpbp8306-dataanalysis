# Problem Set 05 — Functions and Modular Code

**Session:** 5 (Unit 1 — Foundations)
**Pairs with:** `demos/05_functions_demo.py`
**Course data:** `cpbp8306-dataanalysis/Fall_2026/data/patients.csv`
**Use with:** `general_tutor_gpt.md`
**Time target:** ~20–25 minutes, worked through with the tutor

---

## Instructions for students

Paste this whole file into the Course Tutor and work through the problems together, in order. Problem 6 needs `data/patients.csv`.

---

## Problems

1. **Spot the duplication.** Here's code that counts high blood pressure readings in two groups:
   ```python
   count_high = 0
   for bp in group_a:
       if bp >= 140: count_high += 1
   count_high_a = count_high

   count_high = 0
   for bp in group_b:
       if bp >= 140: count_high += 1
   count_high_b = count_high
   ```
   What's the actual risk here if someone later needs to change the threshold from 140 to 130?

2. **Write the function.** Turn the logic above into one function `count_high_bp(bps, threshold=140)` that returns a count. What's the parameter name, and what's the default value?

3. **The ten-second test.** Before trusting your function, run it on inputs whose answers you already know: `count_high_bp([100, 200])` should be 1, `count_high_bp([])` should be 0, and `count_high_bp([140])` should be 1 (the boundary — `>=`, not `>`). Why is that last boundary case exactly the kind of thing an AI-written function gets wrong?

4. **Return, don't print.** Given a version of the function that only `print`s its count instead of returning it, and code `x = print_count(group_a)` — what is `x`? Why can't you use it in the next line?

5. **The global-variable trap.** Given a function that reads a global `threshold` variable instead of taking it as a parameter, what happens if some other part of the script changes `threshold` forty lines away? Why is this described as "no error, no warning — that's what an irreproducible result looks like"?

6. **Apply it to real data.** Load `patients.csv` and call your `count_high_bp` function on the real `systolic` column. Then run your ten-second test again — does it still behave the same on the real data?

---

## Coverage (for instructor reference)

| # | Concept |
|---|---------|
| 1 | Why copy-pasted logic is risky |
| 2 | Defining a function with a default parameter |
| 3 | Testing a function against known inputs, including boundary cases |
| 4 | Return value vs. side effect (printing) |
| 5 | Scope — the danger of reading a global variable |
| 6 | Applying a written function to the real course data |
