# Unit 1 code-diagnosis bank

Twenty snippets for the course's central skill: *look at a block of code and say
what it does, whether it's right, and how you'd fix it.*

Use these as warm-ups, as extra tutor problems, as make-up work, as final-quiz
Section B replacements, or as a written midterm if you ever want one. Each is
tagged with the session that covers it.

**All of them run.** None throws a syntax error at parse time. Several produce a
plausible wrong answer and no warning at all — those are marked **SILENT**, and
they are the ones worth the most class time.

---

## Format for students

> One sentence: what is wrong, or what would surprise the person who wrote this?
> If there's more than one problem, name the most important.

---

### 1 — S2 — SILENT

```python
ages = ["47", "52", "31", "60"]
mean_age = sum(ages) / len(ages)
```

**Answer:** `ages` holds strings. `sum()` on a list of strings raises a
`TypeError` — so this one actually fails loudly. The real lesson is *why* the
data is like that: this is what a CSV column looks like after one cell said
"unknown". Fix upstream, at load time, not here.

---

### 2 — S2 — SILENT

```python
p_value = 0.1 + 0.2 - 0.25
if p_value == 0.05:
    print("exactly at threshold")
```

**Answer:** floats are approximate; this is `0.050000000000000044` and the
comparison is `False`. Never `==` two floats. Use `abs(a - b) < 1e-9`.

---

### 3 — S2

```r
xs <- c(1, 2, 3, 4, 5)
if (mean(xs) = 3) {
    print("balanced")
}
```

**Answer:** `=` is assignment, `==` is comparison. You cannot assign to
`mean(xs)`. Error, not a silent bug — but it's the most common beginner typo.

---

### 4 — S3 — SILENT

```r
readings <- c(117, 122, 141, 130, 118)
last_reading <- readings[-1]
```

**Answer:** in R, `-1` **drops** the first element, so `last_reading` is four
values, not one. The author was thinking in Python. Use `tail(readings, 1)`.
Nothing errors.

---

### 5 — S3 — SILENT

```r
ages <- c(45, 62, "unknown", 71)
mean(ages)
```

**Answer:** the single string coerces the whole vector to character, silently.
`mean()` then returns `NA` with a warning. The vector was already broken one
line earlier.

---

### 6 — S3 — SILENT

```python
bp = [117, 122, 141, 130, 118]
middle_three = bp[1:4]
print(f"middle three: {middle_three}")
```

**Answer:** it does return three elements, but they're indices 1, 2, 3 —
`[122, 141, 130]`. Whether that's "the middle three" of a five-element list is
arguable; the deeper point is the author needs to know the stop is exclusive.
Ask students to predict `len(bp[1:4])` first.

---

### 7 — S3 — SILENT

```python
patients = {"P001": 61, "P002": 47, "P003": 55}
oldest = patients[0]
```

**Answer:** dicts are keyed by name, not position. `patients[0]` raises
`KeyError: 0`. To get the oldest you need `max(patients, key=patients.get)`.

---

### 8 — S4 — SILENT

```python
bp = 145
if bp >= 140:
    category = "high"
if bp >= 120:
    category = "elevated"
if bp < 120:
    category = "normal"
```

**Answer:** three independent `if`s, so `bp = 145` sets `"high"` and then
overwrites it with `"elevated"`. `"high"` is unreachable for every input. Needs
`elif`. No error, wrong answer.

---

### 9 — S4

```python
i = 0
while i < 10:
    print(i)
```

**Answer:** `i` is never updated — infinite loop. `Ctrl-C` to stop.

---

### 10 — S4 — SILENT

```r
total <- 0
for (bp in bp_list) {
    total <- bp
}
mean_bp <- total / length(bp_list)
```

**Answer:** `total <- bp` overwrites instead of accumulating (`total <- total + bp`).
The result is the *last* reading divided by n. Runs fine, returns a number,
completely wrong.

---

### 11 — S4

```python
readings = [117, 118, 141, 130, 122]
for r in readings:
    if r < 120:
        readings.remove(r)
print(readings)
```

**Answer:** modifying a list while iterating over it skips elements. Removing
`117` shifts everything left, so the loop's next step jumps straight past `118`
— which survives the filter despite being under 120. Output is
`[118, 141, 130, 122]`. Build a new list instead:
`[r for r in readings if r >= 120]`.

*(Note the ordering matters for this to be visible. Swap `118` and `122` and the
same bug produces a correct-looking answer — which is a good second question to
ask: "why did it work that time?")*

---

### 12 — S5 — SILENT

```python
def compute_bmi(weight_kg, height_m):
    bmi = weight_kg / height_m ** 2
    print(bmi)

patient_bmi = compute_bmi(70, 1.75)
if patient_bmi > 30:
    print("obese")
```

**Answer:** the function prints but doesn't `return`, so `patient_bmi` is `None`.
The comparison then raises `TypeError`. Classic print-vs-return.

---

### 13 — S5 — SILENT

```python
threshold = 140

def count_high(bps):
    return sum(bp >= threshold for bp in bps)

count_a = count_high(group_a)
threshold = 120
count_b = count_high(group_b)
```

**Answer:** the function reads a global. `count_a` and `count_b` were computed
against different thresholds and are not comparable. Nothing errors. Pass
`threshold` as a parameter.

---

### 14 — S5 — SILENT

```python
def count_high(bps, threshold=140):
    """Count readings at or above the threshold."""
    return sum(bp > threshold for bp in bps)
```

**Answer:** docstring says "at or above", code says `>`. A reading of exactly 140
is not counted. One character, and it's a clinical boundary. This is exactly the
kind of thing AI gets wrong and the ten-second test catches:
`count_high([140])` should be `1`.

---

### 15 — S5

```r
count_high <- function(bps, threshold = 140) {
    result <- sum(bps >= threshold)
}

n <- count_high(c(150, 130, 145))
print(n)
```

**Answer:** the last expression is an *assignment*, which returns invisibly in R.
`print(n)` shows nothing useful. Drop the `result <-` so the `sum()` is the last
expression, or use `return(result)`.

---

### 16 — S6 — SILENT

```python
import pandas as pd
df = pd.read_csv("/Users/josh/Desktop/project/data/patients.csv")
```

**Answer:** absolute path. Works on exactly one machine. Use
`"data/raw/patients.csv"` relative to the project root.

---

### 17 — S6

```bash
git add .
git commit -m "stuff"
git push
```

**Answer:** two problems. `"stuff"` tells future-you nothing — the message
should say what changed and why. And `git add .` with no `.gitignore` may have
just staged raw patient data, `.Rhistory`, and a 200 MB file.

---

### 18 — S6 — SILENT

```python
df = pd.read_csv("data/raw/patients.csv")
df["age"] = df["age"].fillna(0)
mean_age = df["age"].mean()
```

**Answer:** filling missing ages with **0** and then averaging drags the mean
down and invents newborns in your cohort. Missing is not zero. Either drop those
rows explicitly or impute deliberately — and say which you did in the write-up.

---

### 19 — S1/S6 — SILENT — *the course's flagship example*

```python
df = pd.read_csv("data/patients.csv")
group_a = df[df["group"] == "A"]["systolic"].dropna()
group_b = df[df["group"] == "B"]["systolic"].dropna()
t, p = stats.ttest_ind(group_a, group_b)
```

**Answer:** 40 rows have `"A "` with a trailing space and are silently excluded.
On the course dataset this turns a real difference (p = 0.0064) into a null
result (p = 0.2152). Diagnose with `df["group"].unique()` — and note that
`value_counts()` will *not* reveal it, because the display hides the space. Fix
with `.str.strip()` at load time.

---

### 20 — S2/S4 — SILENT

```python
qc_flags = ["TRUE", "FALSE", "TRUE", "TRUE"]
pass_rate = sum(qc_flags) / len(qc_flags)
```

**Answer:** these are the *strings* `"TRUE"`/`"FALSE"`, not booleans, so `sum()`
raises a `TypeError`. And if they'd been coerced with `bool()`, every non-empty
string is truthy — including `"FALSE"` — giving a pass rate of 1.0 with no
error at all. That second version is the genuinely dangerous one; show it.

---

## Suggested groupings

| Use | Snippets |
|---|---|
| Session 2 warm-up | 1, 2, 3, 20 |
| Session 3 warm-up | 4, 5, 6, 7 |
| Session 4 warm-up | 8, 9, 10, 11 |
| Session 5 warm-up | 12, 13, 14, 15 |
| Session 6 warm-up | 16, 17, 18 |
| Unit 1 review / quiz prep | 5, 8, 13, 14, 19 |
| "AI wrote this" set | 4, 8, 13, 14, 19 |
| The silent-failure set (best discussion) | 4, 8, 10, 13, 14, 19, 20 |
