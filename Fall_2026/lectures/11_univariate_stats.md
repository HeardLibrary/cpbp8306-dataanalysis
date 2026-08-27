# Session 11 — Univariate Statistics

**Unit:** 3 (Analysis)
**Duration:** 30-minute lecture + 20-minute activity
**Companion tutor:** `assistants_per_lecture/11_univariate_stats_gpt.md`

---

## Framing

This is the session where students most often want to skip the concept and just paste the code. Do not let them. **The hardest part of a statistical test is not running it — it is choosing it and interpreting it.** The command to run a t-test is one line. The judgment to know a t-test is the right test, and to know what the p-value it produces actually means, is the entire semester of a statistics course. We cannot replace that course, but we can teach the *decision framework* and the *AI-verification* muscle: what does the test assume, and does your data satisfy those assumptions?

---

## Learning objectives

Students should be able to:

1. Match a research question to a candidate statistical test based on the types of the variables involved.
2. State the assumptions of a t-test, ANOVA, chi-square, and linear regression.
3. Interpret a p-value, an effect size, and a confidence interval.
4. Read the output of `t.test`, `aov`, `chisq.test`, and `lm` in R (and equivalents in Python's `scipy.stats` and `statsmodels`).
5. Recognize when AI has proposed a test whose assumptions their data violates.

---

## 30-minute outline

| Time     | Segment                                                    |
|----------|------------------------------------------------------------|
| 0–3      | Recap: EDA + visualization                                 |
| 3–8      | The decision tree: what test do I run?                     |
| 8–15     | t-test, ANOVA, chi-square: the classic three               |
| 15–22    | Linear regression                                          |
| 22–27    | Interpreting p, effect size, CI                            |
| 27–30    | Assumption failures + robust alternatives                  |

---

## Segment 1 (0–3 min): Recap

Ask: someone name three things you can learn from a histogram before running a t-test. Reinforce that plotting comes before testing.

---

## Segment 2 (3–8 min): The decision tree

The most useful figure you will ever put on a whiteboard:

```
What is the outcome variable?
├─ Continuous
│   ├─ One group, compare to a fixed value → one-sample t-test
│   ├─ Two groups → t-test (paired if same subjects, unpaired otherwise)
│   ├─ 3+ groups → ANOVA
│   └─ Continuous predictor(s) → linear regression
└─ Categorical
    ├─ 2×2 or larger contingency → chi-square (or Fisher's exact if small)
    └─ Binary outcome + predictors → logistic regression (foreshadow S12)
```

Key questions to answer before choosing:

1. **What is the outcome type?** (continuous vs categorical)
2. **How many groups / conditions?**
3. **Are observations independent, or paired/repeated?**
4. **Is my sample large enough that CLT saves me from non-normality?**

The point of the tree: **you should be able to draw it before you touch code.** Then the code is trivial.

---

## Segment 3 (8–15 min): The classic three

**t-test** — comparing two group means:

```r
# is bill length different between Adelie and Chinstrap?
adelie   <- df$bill_length_mm[df$species == "Adelie"]
chinstrap <- df$bill_length_mm[df$species == "Chinstrap"]
t.test(adelie, chinstrap)     # Welch's t-test by default (unequal variances)
# or formula interface — often clearer:
t.test(bill_length_mm ~ species,
       data = df |> filter(species %in% c("Adelie", "Chinstrap")))
```

```python
from scipy import stats
adelie   = df.loc[df.species == "Adelie", "bill_length_mm"].dropna()
chinstrap = df.loc[df.species == "Chinstrap", "bill_length_mm"].dropna()
stats.ttest_ind(adelie, chinstrap, equal_var=False)  # Welch's
```

Assumptions:
- Independent observations (or paired if using paired t-test).
- Approximately normal distribution within each group (matters more for small n).
- Variances are similar (or use Welch's t-test, which relaxes this).

**ANOVA** — extending t-test to 3+ groups:

```r
fit <- aov(bill_length_mm ~ species, data = df)
summary(fit)
# significant? do a post-hoc pairwise test:
TukeyHSD(fit)
```

```python
import statsmodels.api as sm
from statsmodels.formula.api import ols
fit = ols("bill_length_mm ~ C(species)", data=df).fit()
sm.stats.anova_lm(fit, typ=2)
```

Important: **a significant ANOVA doesn't tell you *which* groups differ.** You need a post-hoc test (Tukey's HSD, Bonferroni-corrected pairwise t-tests) to figure that out. This is where p-hacking enters — do the correction.

**Chi-square** — testing association between two categorical variables:

```r
tbl <- table(df$species, df$island)
chisq.test(tbl)
```

```python
from scipy.stats import chi2_contingency
tbl = pd.crosstab(df.species, df.island)
chi2_contingency(tbl)
```

Assumption: **expected count in each cell ≥ 5.** If not, use Fisher's exact test (`fisher.test` in R, `scipy.stats.fisher_exact` in Python).

---

## Segment 4 (15–22 min): Linear regression

Bread-and-butter of research statistics.

```r
fit <- lm(body_mass_g ~ bill_length_mm + species, data = df)
summary(fit)
```

```python
from statsmodels.formula.api import ols
fit = ols("body_mass_g ~ bill_length_mm + C(species)", data=df).fit()
fit.summary()
```

Reading the output — this is the segment worth slowing down on. Walk through the output panel-by-panel:

1. **Coefficients table.** For each predictor: estimate, standard error, t-value, p-value.
2. **The intercept** is the predicted value when all predictors are 0 (or, for factors, at the reference level).
3. **A coefficient's sign** tells you direction; its magnitude tells you effect size *in the units of the outcome*.
4. **R²** — the fraction of variance in the outcome explained by the model.
5. **Residual diagnostic plots.** `plot(fit)` in R produces four of them. Look at them.

Assumptions of linear regression:
- Linear relationship between predictors and outcome.
- Residuals are normally distributed.
- Residuals have constant variance (homoscedasticity).
- Observations are independent.

The last assumption is the one most often silently violated — repeated measures on the same patient, samples from the same lab batch, etc. Mixed-effects models are the fix; those are beyond this course but flag them.

---

## Segment 5 (22–27 min): Interpreting output

**p-value.** The probability, *assuming the null hypothesis is true*, of seeing a test statistic as extreme as or more extreme than the one you observed.

- **A small p-value does not mean a large effect.** With n = 1 million, a trivial effect will have p < 0.001.
- **A p-value is not "the probability the null is true."** It is not "the probability your result is a fluke."
- **α = 0.05 is a convention, not a law.** For preclinical or exploratory work, apply stricter cutoffs. For multiple comparisons, correct.

**Effect size.** How big is the effect, in interpretable units?
- Cohen's d for t-tests.
- η² for ANOVA.
- Odds ratio for chi-square.
- Regression coefficients in the outcome's units.

**Report both p and effect size, always.** A p-value with no effect size is uninterpretable.

**Confidence interval.** A range that would contain the true parameter in 95% of hypothetical replications. More informative than a p-value in most cases. Report it.

---

## Segment 6 (27–30 min): When assumptions fail

Common problems and their fixes:

| Problem                                | Fix                                              |
|----------------------------------------|--------------------------------------------------|
| Heavy tails / non-normal small sample  | Use Wilcoxon / Mann-Whitney (rank-based test)    |
| Unequal variances                      | Use Welch's t-test                               |
| Non-linear relationship in regression  | Transform (log, sqrt) or use a spline / GAM      |
| Heteroscedastic residuals              | Robust standard errors, or transform outcome     |
| Repeated measures on same subject      | Mixed-effects model (`lme4::lmer`)               |
| Small counts in chi-square             | Fisher's exact test                              |

When an AI proposes a test, **check the assumption list.** If your data violates any of them, either fix the data, pick a robust alternative, or note the caveat in your write-up. Do not proceed as if the assumption holds when it doesn't.

---

## Key vocabulary

- **Null hypothesis / H₀** — the "nothing is going on" default.
- **p-value** — probability of a result at least this extreme under H₀.
- **Effect size** — how big the effect is (Cohen's d, R², coefficient).
- **Confidence interval** — plausible range for the true parameter.
- **Assumptions** — the conditions under which a test is valid.
- **Post-hoc test** — pairwise test done after a significant omnibus test.
- **Multiple comparisons correction** — adjusting α when running many tests.

---

## Common student mistakes

- Running a t-test on ordinal data (Likert-scale). Use Wilcoxon.
- Interpreting p as "probability the result is real." It is not.
- Not correcting for multiple comparisons after running 30 tests.
- Trusting an ANOVA F-test but never running Tukey's HSD.
- Fitting a regression and never looking at residual plots.

---

## Handoff to tutor activity

`assistants_per_lecture/11_univariate_stats_gpt.md` — the tutor gives research scenarios and asks the student to (a) pick a test, (b) list its assumptions, (c) predict what could go wrong, and finally (d) run it.
