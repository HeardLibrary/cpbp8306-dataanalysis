# Session 8 — Data Wrangling: Cleaning, Joining, Reshaping

**Unit:** 2 (Data Wrangling)
**Duration:** 30-minute lecture + 20-minute activity
**Companion tutor:** `assistants_per_lecture/08_wrangling_join_reshape_gpt.md`

---

## Framing

You will spend more time on data wrangling than on any other kind of code in this course, and than on any other kind of code in your research career. This session is a *vocabulary* session — six verbs in each language that do 90% of the cleaning you will ever need. Once you own these verbs, you can direct AI precisely: "pipe this through group_by, summarise, and filter" is a much more effective prompt than "clean this data."

---

## Learning objectives

Students should be able to:

1. Name and use the six core verbs: **filter, select, mutate, arrange, group_by, summarise** in R and their pandas equivalents.
2. Chain multiple verbs using the pipe (`|>` in R, method chaining or `.pipe()` in pandas).
3. Handle missing values (`NA`, `NaN`) explicitly.
4. Join two dataframes on a shared key column.
5. Reshape data between long and wide with `pivot_longer` / `pivot_wider`.
6. Explain the **split-apply-combine** pattern.

---

## 30-minute outline

| Time     | Segment                                                |
|----------|--------------------------------------------------------|
| 0–3      | Recap: tidy data                                       |
| 3–13     | The six verbs + piping                                 |
| 13–20    | Split-apply-combine (group_by + summarise)             |
| 20–25    | Joining tables                                         |
| 25–30    | Long ↔ wide reshaping                                  |

---

## Segment 1 (0–3 min): Recap

Ask the room: what are the three rules of tidy data? Ring it again — it's the foundation for today.

---

## Segment 2 (3–13 min): The six verbs

Write these on the board and keep them there all class:

| Verb        | What it does                          | dplyr (R)                       | pandas (Python)                 |
|-------------|---------------------------------------|---------------------------------|---------------------------------|
| filter      | keep rows matching a condition        | `filter(bp > 130)`              | `df[df.bp > 130]` / `df.query("bp > 130")` |
| select      | keep or drop columns                  | `select(id, bp, group)`         | `df[["id", "bp", "group"]]`     |
| mutate      | create / change a column              | `mutate(bp_z = scale(bp))`      | `df.assign(bp_z=(df.bp - df.bp.mean())/df.bp.std())` |
| arrange     | sort rows                             | `arrange(desc(bp))`             | `df.sort_values("bp", ascending=False)` |
| group_by    | mark rows as belonging to groups      | `group_by(group)`               | `df.groupby("group")`           |
| summarise   | collapse each group to one row        | `summarise(mean_bp=mean(bp))`   | `.agg(mean_bp=("bp","mean"))`   |

**Piping** — chain verbs so each output feeds the next input:

```r
# R — native pipe |>  (or magrittr %>%, same idea)
df |>
  filter(species == "Adelie") |>
  select(species, bill_length_mm, body_mass_g) |>
  mutate(bill_length_cm = bill_length_mm / 10) |>
  arrange(desc(body_mass_g))
```

```python
# pandas — method chaining
(df
  .query("species == 'Adelie'")
  [["species", "bill_length_mm", "body_mass_g"]]
  .assign(bill_length_cm = lambda d: d.bill_length_mm / 10)
  .sort_values("body_mass_g", ascending=False)
)
```

The reason to teach piping is not aesthetics — it's *diagnosability*. When something goes wrong in a five-verb pipeline, you can comment out one verb at a time and see where the shape changed. Loud-and-clear rule: **build pipelines one verb at a time and inspect after each step.** Do not write a 20-line pipe and hope.

Two things AI often gets wrong here:
1. **Wrong verb order.** `select` before `filter` on a column you filtered on. Push back.
2. **`mutate` when you meant `summarise`, or vice versa.** `mutate` returns the same number of rows. `summarise` collapses.

---

## Segment 3 (13–20 min): Split-apply-combine

The pattern is:
- **Split** the data into groups.
- **Apply** a computation to each group.
- **Combine** the results into a table.

Canonical example — mean bill length by species:

```r
df |>
  group_by(species) |>
  summarise(
    n = n(),
    mean_bill = mean(bill_length_mm, na.rm = TRUE),
    sd_bill = sd(bill_length_mm, na.rm = TRUE)
  )
```

```python
(df
  .groupby("species")
  .agg(
    n = ("bill_length_mm", "size"),
    mean_bill = ("bill_length_mm", "mean"),
    sd_bill = ("bill_length_mm", "std")
  )
  .reset_index()
)
```

This idiom is Session 11's regression, Session 12's clustering-by-group, Session 10's grouped-color plots. Learn it here.

**Missing values.** Most real datasets have them. R's `NA`, Python's `NaN`. Rules:

- `mean(x)` on a vector with `NA` returns `NA` in R unless you say `mean(x, na.rm = TRUE)`. In pandas, `.mean()` skips NaN by default — the *opposite* convention. Know this.
- Filter them explicitly if you want to drop them: `filter(!is.na(bp))` in R, `df.dropna(subset=["bp"])` in Python.
- **Do not silently drop missingness.** Ask: is this missing at random? Would dropping it bias your analysis? This is a scientific question, not a coding one.

---

## Segment 4 (20–25 min): Joining tables

You often have two tables that share a key. Patients + labs. Genes + annotations. Countries + populations.

```r
# R — dplyr
patients_with_labs <- patients |> left_join(labs, by = "patient_id")
```

```python
# pandas
patients_with_labs = patients.merge(labs, on="patient_id", how="left")
```

Four join types to know:

| Type       | Behavior                                                    |
|------------|-------------------------------------------------------------|
| left join  | Keep all rows of the left table; add columns from right where key matches; NA otherwise. |
| right join | Symmetric: keep all rows of the right.                      |
| inner join | Keep only rows with a match in both tables.                 |
| full join  | Keep all rows from both; NA for unmatched columns.          |

Default in dplyr is `left_join`. Default in pandas `.merge()` is inner. Know your defaults; ChatGPT will not always pick the right one.

Sanity check after every join: **did the row count change unexpectedly?** If you did a left join and now have *more* rows than the left table, you have duplicate keys in the right table — a real bug 90% of the time.

---

## Segment 5 (25–30 min): Long ↔ wide reshaping

Two verbs:

```r
# wide -> long
df_long <- df_wide |> pivot_longer(
  cols = c(bp_2020, bp_2021, bp_2022),
  names_to = "year",
  values_to = "bp"
)

# long -> wide
df_wide <- df_long |> pivot_wider(
  names_from = year,
  values_from = bp
)
```

```python
# wide -> long
df_long = df_wide.melt(
  id_vars="patient_id",
  value_vars=["bp_2020", "bp_2021", "bp_2022"],
  var_name="year",
  value_name="bp"
)

# long -> wide
df_wide = df_long.pivot(index="patient_id", columns="year", values="bp")
```

Rule of thumb:

- **For plotting and modeling:** you almost always want *long*.
- **For displaying in a table for humans to read:** you often want *wide*.

You will pivot back and forth constantly. This is normal.

---

## Key vocabulary

- **Verb** — a single wrangling operation (filter, select, mutate, etc.).
- **Pipe** — the operator that feeds output of one verb into the next (`|>`, `%>%`, method chaining).
- **Split-apply-combine** — the group_by + summarise pattern.
- **NA / NaN** — missing value markers.
- **Join / merge** — combining two tables on a shared key.
- **Pivot / reshape** — converting between long and wide shapes.

---

## Common student mistakes

- Not looking at intermediate output between pipe steps.
- Assuming `mean()` ignores missing values in R (it doesn't; pass `na.rm = TRUE`).
- Silently doing an inner join when they meant left. Row count drops without warning.
- Reshaping wide-to-long when they meant long-to-wide. Symptom: your plot is empty or has 1 point.

---

## Handoff to tutor activity

`assistants_per_lecture/08_wrangling_join_reshape_gpt.md` — the tutor gives a scenario with two dirty tables and walks the student through choosing verbs to answer a research question.
