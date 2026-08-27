# Session 5 — Functions and Modular Code

**Unit:** 1 (Foundations)
**Duration:** 30-minute lecture + 20-minute activity
**Companion tutor:** `assistants_per_lecture/05_functions_modular_gpt.md`

---

## Framing

You have already been using functions all semester (`print`, `sum`, `mean`, `type`, `length`). This session you learn to write your own. That may sound modest, but it is the single biggest quality-of-life improvement in a research codebase. Copy-pasted code is where bugs come from. Named, tested functions are where reproducibility comes from. This is also where AI collaboration gets interesting: **the smallest useful unit for an AI to write correctly is one well-scoped function.** If you can decompose your analysis into small named functions, you can ask AI to write each one, and check each one, in isolation.

---

## Learning objectives

Students should be able to:

1. Define a function in Python and R with named parameters and a return value.
2. Explain the difference between arguments (values passed in) and parameters (variables in the definition).
3. State what "scope" means and predict whether a variable is available inside vs. outside a function.
4. Recognize when code should be turned into a function ("I copy-pasted this three times").
5. Write a docstring / roxygen comment explaining what a function does.

---

## 30-minute outline

| Time     | Segment                                       |
|----------|-----------------------------------------------|
| 0–3      | Recap: control flow, vectorization            |
| 3–12     | Defining and calling functions                |
| 12–18    | Return values and side effects                |
| 18–24    | Scope: local vs global                        |
| 24–30    | When to write a function + docstrings         |

---

## Segment 1 (0–3 min): Recap

Show a copy-pasted block from Session 4:

```python
count_high = 0
for bp in bp_list_group_A:
    if bp >= 140: count_high += 1
count_high_a = count_high

count_high = 0
for bp in bp_list_group_B:
    if bp >= 140: count_high += 1
count_high_b = count_high
```

Ask: "what's wrong with this?" Answer: we've written the same logic twice. Every time you copy-paste, you double the surface area for bugs. Functions fix this.

---

## Segment 2 (3–12 min): Defining and calling

Python:

```python
def count_high(bps, threshold=140):
    count = 0
    for bp in bps:
        if bp >= threshold:
            count += 1
    return count

count_high(bp_list_group_A)                 # uses default 140
count_high(bp_list_group_B, threshold=150)  # override
```

R:

```r
count_high <- function(bps, threshold = 140) {
    count <- 0
    for (bp in bps) {
        if (bp >= threshold) count <- count + 1
    }
    count      # last expression is the return value in R
}

count_high(bp_list_group_A)
count_high(bp_list_group_B, threshold = 150)
```

Anatomy on the board:

- `def` (Python) / `function` (R) — keyword that says "I am defining a function."
- `count_high` — the *name* of the function.
- `(bps, threshold=140)` — the **parameters**. `threshold` has a default.
- The **body** — indented in Python, curly-braced in R.
- `return` — Python is explicit. R returns the last expression by default, though you can write `return()` for clarity.

Distinguish **parameter** (the name inside the function's definition — `bps`, `threshold`) from **argument** (the value you pass when calling — `bp_list_group_A`, `150`). Students often get these words swapped; the vocabulary matters when reading AI-generated error messages.

Named vs. positional arguments — a subtle bug source:

```python
count_high(bp_list_group_A, 150)                # positional — threshold = 150
count_high(bp_list_group_A, threshold=150)      # named — clearer, safer
```

Encourage students to use named arguments whenever the meaning is not obvious. `t.test(x, y, TRUE, 0.99)` is unreadable; `t.test(x, y, paired = TRUE, conf.level = 0.99)` isn't.

---

## Segment 3 (12–18 min): Return values and side effects

Two things a function can do:

1. **Return a value** — this is the point of most functions. `mean(bp)` returns the mean.
2. **Side effect** — the function *does something to the world*: prints, writes a file, mutates a global. Fewer of these is better.

The instructive contrast:

```python
def print_high_count(bps):        # side effect only, no return
    n = sum(bp >= 140 for bp in bps)
    print(n)

def count_high(bps):              # returns a value
    return sum(bp >= 140 for bp in bps)

x = print_high_count(bps)   # x is None. You cannot use it.
y = count_high(bps)         # y is the number. You can use it in more code.
```

The rule of thumb: **compute → return, don't print.** Printing is for humans looking at output. Returning is so the *next* piece of code can use the result. This distinction is worth twenty minutes of debugging later — students who mostly print will constantly rewrite the same values.

---

## Segment 4 (18–24 min): Scope

Every function has its own little world for variable names. Variables defined *inside* the function are invisible outside it, and vice versa (with some subtlety).

```python
def demo():
    x = 5
    print(x)

demo()          # prints 5
print(x)        # NameError: name 'x' is not defined — x is local to demo()
```

Why we care: **scope is what makes functions safe.** A function you wrote yesterday cannot accidentally clobber a variable in today's script, because its `x` is a different `x`.

Subtle point (mention briefly, don't belabor): a function *can* read variables from the outer scope, but by convention you should pass everything you need as an argument. Relying on global variables is how you make code that "works on my machine" and nowhere else.

Show the anti-pattern:

```python
threshold = 140          # global
def count_high_bad(bps):
    return sum(bp >= threshold for bp in bps)   # reads global — fragile
```

vs. the good version:

```python
def count_high_good(bps, threshold=140):
    return sum(bp >= threshold for bp in bps)   # explicit — clean
```

---

## Segment 5 (24–30 min): When to write a function + docstrings

Rules of thumb for "is this code function-worthy":

1. **I have copied it more than once.** Convert.
2. **I want to unit-test one piece of my analysis.** Wrap it.
3. **I want to hand this to ChatGPT without pasting my whole analysis.** Write a function with a clear signature so the AI has minimal context to hallucinate around.
4. **The block does one describable thing.** If you can name it in three words, it's a function.

Docstrings — the short prose blurb at the top of a function:

```python
def count_high(bps, threshold=140):
    """
    Count how many blood pressure readings meet or exceed the threshold.

    Parameters
    ----------
    bps : list of numeric
        Blood pressure readings.
    threshold : numeric, default 140
        Cutoff at or above which a reading is 'high'.

    Returns
    -------
    int
        Number of readings >= threshold.
    """
    return sum(bp >= threshold for bp in bps)
```

R equivalent (roxygen2 style, above the definition):

```r
#' Count high blood pressure readings
#'
#' @param bps  numeric vector of BP values
#' @param threshold  cutoff, default 140
#' @return integer count
count_high <- function(bps, threshold = 140) {
    sum(bps >= threshold)
}
```

Point out: a good docstring is *itself* a specification. If you can write the docstring first, you can hand it to ChatGPT and get a body that matches. That is a legit AI workflow — spec first, code second, you verify. Do not skip the verify step.

---

## Key vocabulary

- **Function** — a named block of code that takes inputs and (usually) returns a value.
- **Parameter** — a variable in the function's definition.
- **Argument** — a value passed when calling the function.
- **Default argument** — a parameter with a preset value used when the caller doesn't provide one.
- **Return value** — the result of a function call.
- **Side effect** — anything a function does other than return (print, write a file, plot).
- **Scope** — the region of code where a variable is visible.
- **Docstring** — a prose description of what a function does, embedded in the code.

---

## Common student mistakes

- Printing where they should return. Then the next line of code can't use the result.
- Copy-pasting a function body four times instead of parameterizing.
- Reaching into a global variable from inside a function → breaks reusability.
- Writing a 200-line function. If yours is long, it's really 3–4 smaller functions in a trench coat.

---

## Handoff to tutor activity

`assistants_per_lecture/05_functions_modular_gpt.md` — the tutor gives students a wall of copy-pasted code (like AI often produces) and asks them to refactor it into named functions.
