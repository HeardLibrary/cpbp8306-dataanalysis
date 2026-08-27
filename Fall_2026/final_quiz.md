# CPBP 8306 — Final Concept Quiz

**When given:** Session 13, ~20 minutes, in-class before presentations.
**Format:** Written / on Brightspace. Closed-notebook (but not closed-brain — reasoning is graded, not memorization).
**Purpose:** Verify students understand the *logic* of coding-for-research concepts and can reason about AI-generated code. Syntax memorization is deliberately NOT tested.
**Total:** 50 points. Suggested weighting: contributes to Participation (see grading rubric).

---

## Rules for students (post at top)

- You may not consult ChatGPT, Copilot, or any other AI during this quiz.
- You may not consult lecture notes, textbooks, or peers.
- You may leave any question blank. **A blank answer gets 0 points; a wrong answer also gets 0 points; so guess if you have an idea.**
- Full credit rewards *reasoning*, not exact wording.

---

## Section A — Concept multiple choice (10 questions × 2 pts = 20 pts)

Circle the best answer. Some are subtle — read carefully.

**A1.** A p-value of 0.03 means:

  (a) There is a 3% probability that the null hypothesis is true.
  (b) There is a 97% probability that the alternative hypothesis is true.
  (c) If the null hypothesis were true, we would see a result at least this extreme 3% of the time.
  (d) The result has a 3% chance of being a fluke.

**A2.** In R, given `xs <- c(10, 20, 30, 40, 50)`, what does `xs[-1]` return?

  (a) `50` — the last element.
  (b) `10 20 30 40` — all elements except the first.
  (c) An error, because -1 is not a valid index in R.
  (d) `NA`.

**A3.** Which of the following is a violation of the tidy-data rules?

  (a) A data frame with 500 rows and 10 columns.
  (b) A data frame where one column is called `bp_2020`, another `bp_2021`, another `bp_2022`.
  (c) A data frame where every row is one patient at one visit.
  (d) A data frame with a mix of numeric and character columns.

**A4.** Which of these is TRUE about `dplyr::group_by() |> mutate()` versus `dplyr::group_by() |> summarise()`?

  (a) `mutate` returns the same number of rows as the input; `summarise` collapses to one row per group.
  (b) `summarise` returns the same number of rows; `mutate` collapses.
  (c) They are identical in behavior.
  (d) Only `mutate` respects the grouping; `summarise` ignores it.

**A5.** You have 60 predictors and you want to build a regression model that keeps only the useful ones. The best fit is:

  (a) Ordinary least squares (lm / statsmodels ols).
  (b) LASSO regression with cross-validated lambda.
  (c) K-means clustering with K = 60.
  (d) PCA with 60 components.

**A6.** In pandas, `df.merge(other, on="id")` with no other arguments defaults to:

  (a) A left join.
  (b) A right join.
  (c) An inner join.
  (d) A full (outer) join.

**A7.** Which of the following is TRUE about scaling in PCA?

  (a) PCA output does not depend on the scale of the input variables.
  (b) You should scale (standardize) input variables before running PCA when they are on different scales.
  (c) Scaling should be done AFTER running PCA, not before.
  (d) Scaling is only necessary for K-means, not PCA.

**A8.** After making unstaged changes to `analysis.R`, you want to restore the last committed version. The correct Git command is:

  (a) `git commit analysis.R`
  (b) `git reset --hard HEAD`  (a global reset)
  (c) `git checkout -- analysis.R`
  (d) `git status`

**A9.** You run a t-test comparing two group means, get p < 0.001, and a mean difference of 0.02 mmHg. n = 5000 per group. The most reasonable interpretation is:

  (a) A large and important effect.
  (b) A statistically significant but scientifically trivial effect.
  (c) A statistically insignificant effect.
  (d) The test is invalid.

**A10.** Which of these tasks is AI (ChatGPT / Copilot) reliably GOOD at?

  (a) Choosing the right statistical test for your data.
  (b) Detecting a column that was supposed to be numeric but was accidentally stored as a string.
  (c) Writing boilerplate for reading a CSV and printing summary statistics.
  (d) Verifying that a p-value in your paper is reproducible.

---

## Section B — Diagnose the code (5 questions × 4 pts = 20 pts)

Look at each snippet and write ONE SENTENCE describing what is wrong (or what would surprise the writer). If there is more than one problem, name the most important.

**B1.**
```python
ages = ["47", "52", "31", "60"]
mean_age = sum(ages) / len(ages)
print(mean_age)
```

**B2.**
```r
xs <- c(1, 2, 3, 4, 5)
if (mean(xs) = 3) {
    print("balanced")
}
```

**B3.**
```r
result <- df |>
  select(bill_length_mm, species) |>
  filter(species == "Adelie")
print(result$body_mass_g)
```

**B4.**
```python
from sklearn.linear_model import LassoCV
X = df[["age", "weight", "height", "bmi", "bp"]]
y = df["outcome"]
model = LassoCV(cv=10).fit(X, y)
print("R² on training data:", model.score(X, y))
```

**B5.**
```r
patients_with_labs <- patients |> inner_join(labs, by = "patient_id")
# patients had 1000 rows.
# labs had 2500 rows (some patients have multiple labs).
# The join gave us 800 rows.
```
*(What's the surprise, and what has probably happened?)*

---

## Section C — Short answer (2 questions × 5 pts = 10 pts)

Answer in 2–4 sentences each.

**C1.** You paste code from ChatGPT into your RStudio session. The code loads a CSV, runs a t-test, and prints a p-value. The p-value looks reasonable. Describe THREE specific things you would check before trusting the result.

**C2.** In your own words: what is the point of a train/test split in machine learning, and what goes wrong if you tune your model on the same data you evaluate it on?

---

## Answer key + rubric (for instructor use only — do not distribute)

### Section A (2 pts each, no partial credit)

| # | Answer | Notes                                                                 |
|---|--------|-----------------------------------------------------------------------|
| A1 | **c** | The p-value fallacy is the most common. (a) and (d) are Bayesian misreadings. |
| A2 | **b** | R negative indices DROP elements. Cross-language trap from Session 3. |
| A3 | **b** | Year is a variable smeared across columns.                           |
| A4 | **a** | Mutate preserves rows, summarise collapses.                          |
| A5 | **b** | LASSO does feature selection with many predictors.                   |
| A6 | **c** | pandas default is inner join — Session 8 gotcha.                     |
| A7 | **b** | Session 12 concept: PCA is scale-sensitive.                          |
| A8 | **c** | `git checkout --` restores a file. (b) is destructive globally.      |
| A9 | **b** | Huge n makes trivial effects "significant." Report effect size!      |
| A10 | **c** | Boilerplate is AI's strong suit; the other three require knowledge of the specific data. |

### Section B (4 pts each; award partial credit for identifying part of the issue)

**B1.** `ages` is a list of strings, not integers. `sum()` on strings concatenates them; even if it worked, division wouldn't make sense. Fix: convert to numeric first (`ages = [int(a) for a in ages]`).

**B2.** `if (mean(xs) = 3)` uses `=` (assignment) instead of `==` (comparison). In R this actually assigns 3 to `mean(xs)` — an error or unexpected behavior. Fix: use `==`.

**B3.** `select(bill_length_mm, species)` drops `body_mass_g`. The `print(result$body_mass_g)` will return NULL — the column no longer exists.

**B4.** Reporting R² on training data for a LASSO fit is meaningless (optimistically biased). Must evaluate on held-out data — either a separate test set or via cross-validation.

**B5.** `inner_join` dropped patients who had no labs. Since labs had 2500 rows and patients only 1000, we expected the result to have *at least* 1000 rows if every patient had a lab; 800 rows means 200 patients had no matching lab. Should have been a `left_join` if we wanted to keep all patients.

### Section C

**C1.** Look for any THREE of:
- Load the data and check `head()` / `dtypes` — do types make sense?
- Look at the raw distribution of the variables being compared (histogram, box plot).
- Check what the AI's code is actually testing — is it the right test for the data type and design?
- Verify the p-value makes sense given the effect size and sample size.
- Read every line of the code and confirm each does what you expected.
- Re-run with a slightly different filtering / cleaning and see if the answer moves.
- Check that packages referenced actually exist (AI hallucinations).

**5 pts** = names three distinct checks clearly, at least one specific to the AI-code context.
**3 pts** = names two solid checks, or three vague ones.
**1 pt** = names one check.
**0 pts** = blank or "run the code."

**C2.** Answer should include:
- Fitting a model on all data will overfit — the model memorizes noise as well as signal.
- Test set is held-out data the model has never seen; performance on it is an honest estimate of how the model will do on new data.
- If you tune (choose hyperparameters) on the test set, you contaminate it — you have now fit the tuning to the test set, and your reported performance is again optimistic.
- Best practice: cross-validate on the training set to tune; touch the test set only once, at the end.

**5 pts** = mentions overfitting, honest evaluation, and the contamination risk from peeking.
**3 pts** = describes the split but misses one of the three ideas.
**1 pt** = describes the mechanics vaguely.
**0 pts** = blank or wrong.

---

## Notes for instructor

- **Total possible: 50 points.** Instructor may normalize into the Participation category or replace one weekly activity's score with the quiz score, per preference.
- **Preview during Session 12:** consider showing the *format* of the quiz (not the questions) in Session 12 so students can practice with the Unit 4 tutor without surprise.
- **The Unit 4 tutor** intentionally rehearses concept-question style answering as its Level 7. Students who used it will feel more prepared. This is by design.
