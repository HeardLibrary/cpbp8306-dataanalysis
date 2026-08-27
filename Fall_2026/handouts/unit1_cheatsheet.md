# CPBP 8306 — Unit 1 reference card

Sessions 1–6. Print this, or keep it open in a tab. **You are not expected to
memorize any of it** — the point of the course is that you can read code, not
that you can recall syntax.

---

## The four-step loop (use this every single time)

1. **Expect** — before running, say what the output should look like. Shape? Sign? Roughly how big?
2. **Run** — actually execute it. Never reason about code you haven't run.
3. **Compare** — does it match your expectation? If not, which of you is wrong?
4. **Explain** — can you say line by line why it did that? If not, you don't own it yet.

> If you have no expectation, you are not doing science. You are doing typing.

---

## Types

| | Python | R | Check it with |
|---|---|---|---|
| whole number | `int` | `integer` | `type(x)` / `class(x)` |
| decimal | `float` | `numeric` | |
| text | `str` | `character` | |
| true/false | `bool` | `logical` | |
| missing | `NaN`, `None` | `NA`, `NULL` | |

```python
type(x)          # Python
df.dtypes        # every column of a dataframe
```
```r
class(x)         # R
str(df)          # every column of a dataframe
```

**Run the dataframe version every time you load a file.** That is where you
catch the age column that loaded as text.

### Type traps

| Trap | What happens |
|---|---|
| `"5" + "3"` | `"53"` — string glue, not addition |
| `"5" + 3` | Python: `TypeError`. Good — it refuses to guess. |
| `c(1, 2, "three")` | R: everything silently becomes text. **No warning.** |
| `0.1 + 0.2 == 0.3` | `False` in both languages. Never `==` two floats. |
| `5 == "5"` | `False` — no error, just quietly wrong |
| `True + True` | `2` — booleans are numbers |
| `mean(passed_qc)` | the **proportion** that passed. Genuinely useful. |

---

## Collections

```python
bp = [117, 122, 141, 130, 118]        # Python list
patient = {"id": "P042", "age": 61}   # Python dict
```
```r
bp <- c(117, 122, 141, 130, 118)      # R vector — c() means "combine"
patient <- list(id = "P042", age = 61)  # R named list
```

### Indexing — the one place the languages genuinely disagree

| | Python | R |
|---|---|---|
| first element | `bp[0]` | `bp[1]` |
| second | `bp[1]` | `bp[2]` |
| last | `bp[-1]` | `bp[length(bp)]` or `tail(bp, 1)` |
| **`bp[-1]` means** | **the last element** | **everything EXCEPT the first** |
| a range | `bp[1:4]` → indices 1,2,3 (**stop excluded**) | `bp[2:4]` → indices 2,3,4 (**stop included**) |
| specific ones | `[bp[i] for i in (0,2,4)]` | `bp[c(1,3,5)]` |
| by name | `patient["age"]` | `patient$age` |

An out-of-range index in R gives you an **empty result, not an error**. An
analysis that quietly runs on zero rows is a real failure mode.

### Boolean masks — the most important idiom in the course

```r
bp > 130          # FALSE FALSE TRUE FALSE FALSE   ← the mask
bp[bp > 130]      # 141        ← keep where TRUE
sum(bp > 130)     # 1          ← count them
mean(bp > 130)    # 0.2        ← what fraction
```
```python
import numpy as np
arr = np.array(bp)
arr[arr > 130]           # keep
(arr > 130).sum()        # count
```

`dplyr::filter()` is this. `df[df.age > 65]` is this. Everything is this.

---

## Control flow

```python
if bp >= 140:            # note: elif, not another if
    category = "high"
elif bp >= 120:
    category = "elevated"
else:
    category = "normal"

for bp in bp_list:
    print(bp)
```
```r
if (bp >= 140) {
    category <- "high"
} else if (bp >= 120) {
    category <- "elevated"
} else {
    category <- "normal"
}

for (bp in bp_list) {
    print(bp)
}
```

**Three separate `if`s is not the same as `elif`.** Separate `if`s all run, so
later ones overwrite earlier ones. Wrong answer, no error.

### Prefer the vectorized version

| Job | Python | R |
|---|---|---|
| transform each | `arr * 2` | `xs * 2` |
| choose per element | `np.where(c, a, b)` | `ifelse(c, a, b)` |
| keep matching | `arr[arr > 140]` | `xs[xs > 140]` |
| count | `(arr > 140).sum()` | `sum(xs > 140)` |

> If you ask an AI to count something in R and it hands you a `for` loop —
> that's a code smell. R has `sum(xs > 140)`. Push back.

---

## Functions

```python
def count_high(bps, threshold=140):
    """One line saying what this does.

    Parameters / Returns go here. Note any limitation —
    e.g. "missing values are not handled".
    """
    return sum(bp >= threshold for bp in bps)
```
```r
#' Count high blood pressure readings
#' @param bps numeric vector of systolic readings
#' @param threshold cutoff, default 140
#' @return integer count
count_high <- function(bps, threshold = 140) {
    sum(bps >= threshold)      # R returns the last expression
}
```

- **Parameter** = the name in the definition. **Argument** = the value you pass.
- **Return, don't print.** A function that prints returns `None`, and the next line can't use it.
- **Pass everything in.** Reading a global variable is how you get "works on my machine."
- **Name your arguments** when the meaning isn't obvious: `t.test(x, y, paired = TRUE)`, not `t.test(x, y, TRUE)`.

### Write it as a function when

1. You've copied it more than once
2. You want to test one piece alone
3. You can name what it does in three words
4. You want to hand exactly one thing to an AI

### The ten-second test

Call it on input whose answer you already know.

```python
count_high([100, 200], threshold=140)   # must be 1
count_high([140])                       # must be 1 — check the boundary!
count_high([])                          # must be 0
```

The boundary case is the one AI gets wrong. "140 or above" vs "above 140" is a
one-character difference and a real clinical one.

---

## Projects and Git

```
your-project/
├── README.md          what is this, how do I run it, what data do I need
├── .gitignore
├── data/raw/          original files — NEVER edited
├── data/processed/    cleaned versions your code produces
├── scripts/           01_clean.py, 02_eda.py, 03_stats.py
├── figures/           output plots (derived — deletable and regenerable)
└── output/
```

Use **relative paths** (`"data/raw/patients.csv"`), never absolute ones
(`"/Users/you/Desktop/..."`). Absolute paths don't work on anyone else's machine.

### The four commands

```bash
git status                          # what changed?
git add .                           # stage it
git commit -m "add outlier filter"  # snapshot it
git push                            # send to GitHub
```

### The one that matters

```bash
git restore scripts/01_clean.py     # undo all uncommitted changes to a file
# older spelling, same thing: git checkout -- scripts/01_clean.py
```

> **Commit before you paste AI-generated code.** That's your undo button.

Commit 3–10 times per productive hour. Messages in imperative present:
"add outlier filter", not "added stuff".

### Never commit

Patient or identifiable data · API keys or passwords · files over ~100 MB ·
anything that changes every run.

**Deleting a file in a later commit does not remove it from history.** If you
push a key, treat it as permanently exposed: rotate it and tell your PI.

---

## Reading an error

```
Traceback (most recent call last):
  File "analysis.py", line 12, in <module>
    total_age = ages_str + 10
TypeError: can only concatenate str (not "int") to str
```

1. **Bottom line first** — that's the actual complaint
2. **File and line** — go there
3. **The code** — now you know what was actually in that variable
4. **Fix the cause, not the symptom** — the bug is usually upstream

Pasting an error into ChatGPT is fine. But it doesn't know what the variable
*should* have been — so it may suggest a fix that silences the error without
fixing the bug. Tell it your intent:

> "This errors. **I expect `ages_str` to hold ages as numbers.** Where did it
> become a string?"
