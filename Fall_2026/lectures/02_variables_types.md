# Session 2 — Variables, Types, and Expressions

**Unit:** 1 (Foundations)
**Duration:** 30-minute lecture + 20-minute activity
**Companion tutor:** `assistants_per_lecture/02_variables_types_gpt.md`

---

## Framing

Every piece of data your computer sees has a **type**. A number is a different kind of thing than a word, which is a different kind of thing than a yes/no. Most bugs students hit in their first year of coding — and most subtle errors that AI makes and slips past students — are type bugs. You wrote `"5"` when you meant `5`. You compared a string to a number. You averaged a column that was accidentally text. This session teaches you to *see* types, because once you can see them, you can debug them.

---

## Learning objectives

Students should be able to:

1. Declare a variable in Python and R and explain what "assignment" means.
2. Name the four common primitive types (integer, float, string, boolean) and describe when each is used in research data.
3. Predict the result of a mixed-type expression, including surprising ones (`"3" + "4"`, `True + 1`).
4. Read a `TypeError` traceback and identify which line and which value caused it.

---

## 30-minute outline

| Time     | Segment                                       |
|----------|-----------------------------------------------|
| 0–3      | Recap: decomposition, tool tour               |
| 3–10     | What is a variable? Assignment vs equality    |
| 10–18    | The four types + type-checking                |
| 18–25    | Expressions and operator surprises            |
| 25–30    | Reading a `TypeError` traceback               |

---

## Segment 1 (0–3 min): Recap

Ask: last week we decomposed a blood pressure analysis into steps. Someone name one step. → data cleaning, group split, t-test, etc. Reinforce the map.

---

## Segment 2 (3–10 min): Variables and assignment

Whiteboard the difference between mathematical `=` and programming `=`:

- Math: `x = 5` is a *claim* about the world. `5 = x` means the same thing.
- Programming: `x = 5` is a *command*. "Store the value 5 in a location I will call `x`." `5 = x` is a syntax error.

Live demo, side by side:

```python
# Python
patient_id = 42
patient_id = patient_id + 1   # now it's 43
print(patient_id)              # 43
```

```r
# R — same idea, two syntaxes
patient_id <- 42
patient_id <- patient_id + 1
print(patient_id)              # 43
```

Point out: R uses `<-` by convention (though `=` also works). The mental model is identical.

Naming rules (both languages):
- Start with a letter, use letters, digits, and underscore. No spaces.
- Case-sensitive: `Patient` and `patient` are different variables.
- Use descriptive names. `bp_systolic` is 100× more useful than `x1`.

Anti-pattern to call out: `data <- data`. Overwriting is fine; naming everything `data` is a way to lose track of what step you're on.

---

## Segment 3 (10–18 min): The four primitive types

Walk through a table and give a research example of each:

| Type          | Python name | R name       | Research example                            |
|---------------|-------------|--------------|---------------------------------------------|
| Integer       | `int`       | `integer`    | Number of trials, patient count             |
| Floating point| `float`     | `numeric`    | Blood pressure (117.3), gene expression     |
| String        | `str`       | `character`  | Patient ID "P042", sample name, group label |
| Boolean       | `bool`      | `logical`    | Passed QC? (True/False)                     |

How to check a type — this is the single most useful debugging skill of the course:

```python
type(patient_id)      # <class 'int'>
type("P042")          # <class 'str'>
type(True)            # <class 'bool'>
```

```r
class(patient_id)     # "numeric"
class("P042")         # "character"
class(TRUE)           # "logical"
```

Two research-relevant gotchas:

1. **Booleans behave like numbers.** `True + True == 2` in Python. `sum(c(TRUE, FALSE, TRUE))` is `2` in R. This is why `mean(passed_qc)` gives you the fraction of samples that passed — the booleans are being averaged as 1s and 0s. Useful.

2. **A number stored as a string is a common Excel-CSV bug.** `"5" + "3"` in Python is `"53"`, not `8`. This is *the* first bug students hit when their spreadsheet exported IDs as text. We will hit this repeatedly this semester.

---

## Segment 4 (18–25 min): Expressions and operator surprises

An expression is a piece of code that evaluates to a value. `2 + 3` is an expression. `"hello" + " world"` is an expression. Variables can hold expression results:

```python
n_treated = 47
n_control = 43
n_total = n_treated + n_control    # 90
```

Operators to introduce:

| Operator   | Meaning                | Example                    |
|------------|------------------------|----------------------------|
| `+ - * /`  | arithmetic             | `bp / weight`              |
| `**` (Py) / `^` (R) | exponent          | `sd**2` / `sd^2`           |
| `%%`       | modulo (remainder)     | Useful for even/odd checks |
| `==`       | equality *test* (returns boolean) | `group == "treated"` |
| `!=`       | not-equal              | `pvalue != NA`             |
| `< > <= >=`| comparisons            | `age >= 65`                |
| `and or not` (Py) / `& | !` (R) | logical combos    | `age >= 65 and treated`    |

Big teaching moment: **`=` is assignment, `==` is comparison.** This is the single most common beginner typo. `if x = 5` is an error; `if x == 5` is a test.

Demo the classic surprises:

```python
"3" + "4"      # "34"           — string concatenation
3 + 4          # 7
3 + "4"        # TypeError      — Python refuses to guess
True + 1       # 2              — booleans are numeric
0.1 + 0.2      # 0.30000000000000004  — floats are approximate
```

Emphasize the floating-point one. Do **not** use `==` to compare two floats. This will bite students later; foreshadow.

---

## Segment 5 (25–30 min): Reading a `TypeError`

Show a real traceback on screen. Something like:

```python
Traceback (most recent call last):
  File "analysis.py", line 12, in <module>
    total_age = ages_str + 10
TypeError: can only concatenate str (not "int") to str
```

Walk through it:

- **Bottom line first.** `TypeError: can only concatenate str (not "int") to str` tells you Python saw a string on the left of `+` and doesn't know how to add an integer to it.
- **File and line.** `analysis.py`, line 12 — go there.
- **The offending code.** `total_age = ages_str + 10`. Now you know `ages_str` is (probably) a string when you thought it was a number.
- **The fix.** Convert first: `int(ages_str) + 10`, or better, fix wherever `ages_str` was assigned so it isn't a string in the first place.

Teach the phrase: **"read from the bottom up."** This is worth saying out loud twice.

Mention that when you paste an error into ChatGPT, this is exactly what ChatGPT is looking at too — but ChatGPT doesn't know what your variable *should have been*. You do.

---

## Key vocabulary

- **Variable** — a named location that stores a value.
- **Assignment** — the act of putting a value into a variable (`=` in Python, `<-` in R).
- **Type** — the kind of value (int, float, string, bool).
- **Expression** — a piece of code that evaluates to a value.
- **TypeError** — Python's complaint that you tried to combine incompatible types.
- **Traceback** — the error message the interpreter prints when something breaks.

---

## Common student mistakes

- Using `=` instead of `==` inside `if`.
- Assuming numbers loaded from CSV are numeric. (They may be strings.)
- Comparing floats with `==`.
- Reading only the top of a traceback. The useful info is on the bottom.

---

## Handoff to tutor activity

Send students to `assistants_per_lecture/02_variables_types_gpt.md`. The tutor will hand them broken code and ask them to predict its type behavior and diagnose type errors.
