# Session 4 — Control Flow: Conditionals and Loops

**Unit:** 1 (Foundations)
**Duration:** 30-minute lecture + 20-minute activity
**Companion tutor:** `assistants_per_lecture/04_control_flow_gpt.md`

---

## Framing

Everything we have written so far runs top to bottom, once, in order. Real analyses need to *make decisions* ("if this patient is treated, do X") and *repeat work* ("do this for every sample"). That's control flow. This is the session where students go from "typing commands" to "writing programs." It is also the session where students most often reach for a `for` loop when the language already has a better idiom — and that's a habit AI-generated code will happily reinforce if you don't know to override it.

---

## Learning objectives

Students should be able to:

1. Write an `if / elif / else` statement to branch on a condition.
2. Write a `for` loop to iterate over the elements of a list/vector.
3. Explain **vectorization** and identify when a `for` loop is unnecessary because the operation is already vectorized.
4. Recognize an infinite loop and stop it.
5. Explain why loops are usually the *wrong* first tool for data cleaning in R.

---

## 30-minute outline

| Time     | Segment                                       |
|----------|-----------------------------------------------|
| 0–3      | Recap: collections                            |
| 3–10     | Conditionals: if / elif / else                |
| 10–20    | For loops                                     |
| 20–27    | Vectorization: the "no-loop" version          |
| 27–30    | Infinite loops and when to use `while`        |

---

## Segment 1 (0–3 min): Recap

Ask: how do I get every element of `bp_systolic` that's above 130? Someone will say "a for loop." Good — hold that thought, we'll do it their way first, then show them the better way.

---

## Segment 2 (3–10 min): Conditionals

The plain `if`:

```python
bp = 145
if bp >= 140:
    print("high")
elif bp >= 120:
    print("elevated")
else:
    print("normal")
```

```r
bp <- 145
if (bp >= 140) {
    print("high")
} else if (bp >= 120) {
    print("elevated")
} else {
    print("normal")
}
```

Structural teaching points:

- **Python uses indentation** to define the body of the `if`. Four spaces. Consistent. If you mix tabs and spaces, Python will yell.
- **R uses curly braces** and is whitespace-forgiving.
- **The condition must evaluate to a boolean.** `if bp` (no comparison) will also work but is a common ChatGPT slip: "truthy" values differ subtly between Python and R.

Cover the common structure: nested conditions vs. chained `elif`. Students who write

```python
if bp >= 140:
    ...
if bp >= 120:
    ...
if bp < 120:
    ...
```

are missing the point of `elif`. Multiple `if` runs each branch independently. `elif` says "only if the previous didn't fire." This matters for both correctness and performance.

---

## Segment 3 (10–20 min): For loops

The basic pattern — do something once for each element:

```python
bp_list = [117, 122, 141, 130, 118]
for bp in bp_list:
    if bp >= 140:
        print(f"{bp} is high")
```

```r
bp_list <- c(117, 122, 141, 130, 118)
for (bp in bp_list) {
    if (bp >= 140) {
        print(paste(bp, "is high"))
    }
}
```

Reading the loop aloud helps: "for each blood pressure in the list, if it's at least 140, print it."

Variations to introduce briefly:

- **Iterating with index** — `for i, bp in enumerate(bp_list)` in Python, `for (i in seq_along(bp_list))` in R.
- **Accumulator pattern** — building up a result:

```python
count_high = 0
for bp in bp_list:
    if bp >= 140:
        count_high += 1
print(count_high)
```

Point out: you are essentially writing your own counter. The language often has this built in — foreshadow the vectorized version.

---

## Segment 4 (20–27 min): Vectorization

This is the segment students most need to internalize. Now do the same task, no loop:

```python
# Python with a comprehension (still technically a loop, but idiomatic)
count_high = sum(bp >= 140 for bp in bp_list)

# Python with numpy (truly vectorized)
import numpy as np
bp_array = np.array(bp_list)
count_high = (bp_array >= 140).sum()
```

```r
# R — completely vectorized, no loop
count_high <- sum(bp_list >= 140)
```

Draw attention to the R version. `bp_list >= 140` is not a scalar operation — it applies element-wise to every value in the vector, producing a vector of booleans. `sum` on a boolean vector counts the trues. **This is the R idiom, and it is what R was built for.**

Why this matters:

1. **Correctness.** Fewer lines, fewer places to introduce bugs.
2. **Speed.** Vectorized operations are 10–1000× faster on large data. When you have a million rows, this is the difference between 0.01s and 10s.
3. **AI collaboration.** If you ask ChatGPT "how do I count patients with high BP" and it hands you a for loop in R, that is a code smell. R has `sum(bp >= 140)`. Push back on the AI.

Two more vectorized idioms to name-drop:
- Python: `[x * 2 for x in xs]` (list comprehension), `np.where(cond, a, b)` (conditional array).
- R: `ifelse(cond, a, b)`, `apply` family (`sapply`, `lapply`, `map` from purrr).

We will use `dplyr::mutate` and `pandas.assign` — the dataframe versions of vectorized operations — from Session 7 onward.

---

## Segment 5 (27–30 min): `while` and infinite loops

`for` runs a known number of times. `while` runs *until a condition is false* — which means you can accidentally make it run forever.

```python
i = 0
while i < 5:
    print(i)
    i = i + 1   # forget this line and you have an infinite loop
```

If you write an infinite loop:
- In terminal: `Ctrl-C`.
- In VS Code / Jupyter: hit the stop button.
- In RStudio: the red stop-sign icon in the console.

`while` is rare in research code. If you find yourself writing one, ask "is this really unbounded, or do I know in advance how many times I need to iterate?" — usually a `for` fits better.

---

## Key vocabulary

- **Conditional / branch** — `if / else` — code that runs only when a condition is true.
- **Loop / iteration** — running the same code once per element.
- **Iterable** — anything you can `for x in` over (list, vector, dict keys, dataframe rows).
- **Vectorization** — applying an operation to a whole container at once without an explicit loop.
- **Comprehension** — Python's `[expr for x in xs]` shorthand.
- **Accumulator** — a variable you update inside a loop to build up a result.

---

## Common student mistakes

- Writing a `for` loop when the language has a vectorized primitive. This is the single biggest habit AI reinforces, because loops read "obvious" to an LLM.
- Forgetting to update the loop variable inside `while` → infinite loop.
- Mutating a list while iterating over it. Weird bugs. Don't.
- Using `=` instead of `==` inside `if`. (Same trap from Session 2, still costing people.)

---

## Handoff to tutor activity

`assistants_per_lecture/04_control_flow_gpt.md` — the tutor will hand students a for-loop-heavy piece of code (of the kind AI often produces) and ask them to rewrite it in vectorized form.
