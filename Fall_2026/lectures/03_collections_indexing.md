# Session 3 — Collections: Lists, Vectors, and Dictionaries

**Unit:** 1 (Foundations)
**Duration:** 30-minute lecture + 20-minute activity
**Companion tutor:** `assistants_per_lecture/03_collections_indexing_gpt.md`

---

## Framing

Real research data is never one value. It is a column of blood pressures, a set of patient IDs, a table of gene expressions. Before we can analyze data, we need containers to hold *many* values, and a way to reach in and grab the ones we want. This session covers the three most important containers you will use every day this semester: lists (Python) / vectors (R), and dictionaries — the container that maps names to values.

---

## Learning objectives

Students should be able to:

1. Create a list/vector and access an element by its position.
2. Explain the difference between Python's **0-indexed** and R's **1-indexed** conventions and why this matters when translating code.
3. Create a dictionary (Python) or named list (R) mapping keys to values.
4. Predict the result of common slicing operations (`nums[2:5]`, `nums[c(2,3,4)]`).
5. Recognize when to reach for each container: sequence of values → list/vector; key→value map → dict/named list.

---

## 30-minute outline

| Time     | Segment                                     |
|----------|---------------------------------------------|
| 0–3      | Recap: types                                |
| 3–12     | Lists and vectors                           |
| 12–20    | Indexing and slicing (0- vs 1-indexed)      |
| 20–27    | Dictionaries and named lists                |
| 27–30    | Preview activity                            |

---

## Segment 1 (0–3 min): Recap

Ask the room: what's the type of `[1, 2, 3]`? Anyone who says "int" — good chance to point out that a container's type is *not* its contents. `type([1, 2, 3])` is `list`. The contents are ints. This distinction matters.

---

## Segment 2 (3–12 min): Lists and vectors

Motivation: a research dataset column is a sequence of values. We need a container.

Python **list**:

```python
bp_systolic = [117, 122, 141, 130, 118]
patient_ids = ["P001", "P002", "P003", "P004", "P005"]
mixed = [117, "high", True]           # legal but bad style
len(bp_systolic)                      # 5
```

R **vector** — created with `c()` (short for "combine"):

```r
bp_systolic <- c(117, 122, 141, 130, 118)
patient_ids <- c("P001", "P002", "P003", "P004", "P005")
length(bp_systolic)                   # 5
```

Two conceptual points:

1. **Both are ordered.** Position matters. `bp_systolic[1]` in R is 117 (the first element).
2. **R vectors are homogeneous.** All elements are the same type. `c(1, "two")` will silently convert everything to strings. Python lists are heterogeneous but you should still keep them homogeneous in practice.

The R silent-coercion behavior is a bug source. Show it live:

```r
c(1, 2, "three")     # returns "1" "2" "three" — all strings, no warning
```

Foreshadow: this is exactly what happens when your CSV has one row where "age" is `"unknown"`. The whole column becomes a string. Then `mean(age)` fails.

---

## Segment 3 (12–20 min): Indexing and slicing

This is the segment where students most often get confused. Draw it on the board.

**Python is 0-indexed. R is 1-indexed. This will bite you.**

```python
# Python: index 0 = first element
bp_systolic = [117, 122, 141, 130, 118]
bp_systolic[0]        # 117  (first)
bp_systolic[1]        # 122  (second)
bp_systolic[-1]       # 118  (last — negative indices count from end)
```

```r
# R: index 1 = first element
bp_systolic <- c(117, 122, 141, 130, 118)
bp_systolic[1]        # 117
bp_systolic[2]        # 122
bp_systolic[length(bp_systolic)]   # 118 — no negative-from-end shortcut
```

**Slicing** — grab a range of elements:

```python
bp_systolic[1:4]      # [122, 141, 130] — indices 1, 2, 3. Stop is EXCLUSIVE.
bp_systolic[:3]       # [117, 122, 141] — first three
bp_systolic[-2:]      # [130, 118]      — last two
```

```r
bp_systolic[2:4]      # 122 141 130 — indices 2, 3, 4. Stop is INCLUSIVE.
bp_systolic[c(1, 3, 5)]  # 117 141 118 — grab specific indices
bp_systolic[-1]       # 122 141 130 118 — negative means DROP element 1 (very different from Python!)
```

Emphasize: **the same syntax means completely different things.** `-1` in Python = "last element". `-1` in R = "everything except the first." When you paste code from ChatGPT written for one language into the other, this is a common silent bug.

**Boolean indexing** — the single most useful research idiom:

```python
bp = [117, 122, 141, 130, 118]
high = [x > 130 for x in bp]           # [False, False, True, False, False]
# with numpy or pandas this is much cleaner — Session 7
```

```r
bp <- c(117, 122, 141, 130, 118)
high <- bp > 130                       # FALSE FALSE TRUE FALSE FALSE
bp[high]                               # 141 — the high values only
bp[bp > 130]                           # same thing, inline
```

The R idiom `bp[bp > 130]` is the seed of every filter operation you will do this semester. Ring that bell.

---

## Segment 4 (20–27 min): Dictionaries and named lists

Motivation: sometimes you don't want position-based lookup. You want name-based lookup. "Give me the sample with ID P042."

Python **dict**:

```python
patient = {
    "id": "P042",
    "age": 61,
    "systolic": 141,
    "treated": True
}
patient["age"]              # 61
patient["age"] = 62         # update
patient["diagnosis"] = "HTN"  # add
patient.keys()              # dict_keys(['id', 'age', ...])
```

R **named list** (closest equivalent):

```r
patient <- list(
    id = "P042",
    age = 61,
    systolic = 141,
    treated = TRUE
)
patient$age                 # 61
patient[["age"]]            # same thing
patient$diagnosis <- "HTN"  # add a field
names(patient)              # "id" "age" "systolic" "treated" "diagnosis"
```

When to use a dict vs a list:

| Situation                                                       | Reach for              |
|-----------------------------------------------------------------|------------------------|
| A column of measurements (all one kind of thing)                | list / vector          |
| A single subject's attributes (mixed types, named fields)       | dict / named list      |
| A lookup table (gene name → chromosome, ID → group)             | dict / named list      |
| A stack of columns you want to line up as a table               | dataframe (Session 7)  |

The dataframe row from Session 7 onward is essentially a dict-per-row. Foreshadow this.

---

## Segment 5 (27–30 min): Preview activity

The tutor will hand students small lists/vectors and ask them to *predict* the result of various indexing operations before running them. This forces the mental model. Point out that ChatGPT can *run* the code for them but only they can *predict* it.

---

## Key vocabulary

- **List / vector** — ordered container of values.
- **Element** — one item in a list.
- **Index** — the position of an element. Python starts at 0, R starts at 1.
- **Slice** — a sub-range of a list.
- **Boolean mask** — a list of True/False the same length as the data, used to select elements.
- **Dictionary / named list** — a container mapping keys (names) to values.

---

## Common student mistakes

- Off-by-one: forgetting Python starts at 0.
- Assuming Python and R slice syntax means the same thing (`-1` is the classic trap).
- Using position when they mean name, or vice versa.
- Silently coercing an R vector to strings by including one string element.

---

## Handoff to tutor activity

`assistants_per_lecture/03_collections_indexing_gpt.md` — the tutor will give increasingly tricky indexing puzzles and cross-language translation problems.
