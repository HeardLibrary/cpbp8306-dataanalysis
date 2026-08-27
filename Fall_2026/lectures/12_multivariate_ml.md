# Session 12 — Multivariate Statistics & Introductory ML

**Unit:** 3 (Analysis)
**Duration:** 30-minute lecture + 20-minute activity
**Companion tutor:** `assistants_per_lecture/12_multivariate_ml_gpt.md`

---

## Framing

Univariate stats answer questions about one outcome at a time. Multivariate methods deal with the reality of research data: many variables at once, some correlated, some redundant, some noisy. This session is a *survey* — you will not become an expert in PCA or LASSO in 30 minutes. You will learn what these methods *do*, what problem each solves, when to use each one, and how to read the output. That is enough to (a) direct AI to run one for you, and (b) tell whether the output makes sense.

---

## Learning objectives

Students should be able to:

1. Explain what **dimensionality reduction** is and why it's useful.
2. Run a PCA and interpret the scree plot and the first two components.
3. Run K-means clustering and choose K (elbow method / silhouette).
4. State what **regularization** does and when LASSO is preferred over ordinary regression.
5. Distinguish supervised (regression, classification) from unsupervised (PCA, clustering) methods.
6. Recognize the difference between correlation among predictors (multicollinearity) and prediction quality.

---

## 30-minute outline

| Time     | Segment                                                       |
|----------|---------------------------------------------------------------|
| 0–3      | Recap: univariate stats                                       |
| 3–6      | Supervised vs unsupervised — the big split                    |
| 6–14     | PCA (unsupervised, continuous)                                |
| 14–20    | K-means (unsupervised, clustering)                            |
| 20–26    | LASSO & regularization (supervised, feature selection)        |
| 26–30    | The train/test split — the ML mindset                         |

---

## Segment 1 (0–3 min): Recap

Reinforce: univariate stats = one outcome, few predictors, hypothesis test. Today = many variables at once, often no single "outcome."

---

## Segment 2 (3–6 min): Supervised vs unsupervised

Chalkboard split:

- **Supervised** — you have a labeled outcome. You want to predict it or explain it. → Regression, classification, LASSO, random forests.
- **Unsupervised** — no labels. You want to describe structure. → PCA, clustering, factor analysis.

The label matters because it defines what "success" means:
- Supervised: predict the label well (measured by held-out accuracy, R², AUC).
- Unsupervised: no ground truth. Success is more subjective — does the structure make sense scientifically?

---

## Segment 3 (6–14 min): PCA

The problem: you have 30 correlated variables. You suspect there's really only a few "underlying dimensions." PCA finds them.

Intuition first:
- PCA finds new axes (**principal components**) that are (a) linear combinations of your original variables and (b) uncorrelated with each other and (c) ordered by how much variance in the data they explain.
- The first PC captures the most variance. The second captures the next most, given that it's orthogonal to the first. Etc.

Code:

```r
library(dplyr)
X <- df |>
  select(where(is.numeric)) |>
  drop_na() |>
  scale()                          # PCA is scale-sensitive — always scale first
pc <- prcomp(X)
summary(pc)                        # % variance explained per PC
biplot(pc)                         # first-two-PC scatter with variable loadings
```

```python
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
X = StandardScaler().fit_transform(df.select_dtypes("number").dropna())
pc = PCA().fit(X)
pc.explained_variance_ratio_       # array of % variance per PC
scores = pc.transform(X)           # each sample's coordinates in PC space
```

Two outputs to read:

1. **Scree plot / explained variance.** If the first two PCs explain > 70%, you can plot the data in 2D and lose little. If they explain 20%, PCA isn't helping much.
2. **Loadings.** Each PC is a weighted sum of original variables. The weights tell you what the PC "means." A PC with big positive weights on bill length + body mass + flipper length is essentially a "size" axis.

Common misuses:
- **Applying PCA to categorical variables.** Don't. Use MFA (multiple factor analysis) or MCA instead.
- **Running PCA without scaling.** The variable with the largest raw variance will dominate. This is why we `scale()`.
- **Interpreting PC1 as "the answer."** PC1 is just the direction of maximum variance. That is not necessarily what you care about scientifically.

---

## Segment 4 (14–20 min): K-means clustering

The problem: you have unlabeled samples. You suspect they fall into K groups. Find them.

The algorithm (worth writing on the board):
1. Pick K random centers.
2. Assign each point to the nearest center.
3. Update each center to be the mean of the points assigned to it.
4. Repeat until nothing changes.

Code:

```r
km <- kmeans(scale(X), centers = 3, nstart = 25)
km$cluster                        # which cluster each row is in
```

```python
from sklearn.cluster import KMeans
km = KMeans(n_clusters=3, n_init=25, random_state=0).fit(X)
km.labels_
```

The hard part: **how do you choose K?**

- **Elbow method.** Plot total within-cluster variance vs K. Look for the "elbow" where adding another cluster stops helping much.
- **Silhouette score.** A measure of how well each point fits its cluster vs the next-best. Average across all points. Try K = 2, 3, 4, 5, pick the best.
- **Domain knowledge.** If your dataset is "cell types," you might know biologically there are ~5 types.

Caveats:
- K-means assumes clusters are roughly spherical and equally sized. If they're not, use DBSCAN or hierarchical clustering.
- K-means is sensitive to the initial random seed. Always use `nstart = 25` in R / `n_init = 25` in Python.
- Scaling matters (same as PCA).

---

## Segment 5 (20–26 min): LASSO and regularization

The problem: you have a supervised model with 50 predictors. Some are useful, most aren't. Ordinary regression will use them all and overfit. **Regularization** shrinks small coefficients toward zero, and LASSO shrinks them *all the way to* zero — effectively picking a subset of useful predictors.

Code:

```r
library(glmnet)
X <- model.matrix(~ . - body_mass_g, data = df)[, -1]  # design matrix, no intercept
y <- df$body_mass_g
fit <- cv.glmnet(X, y, alpha = 1)     # alpha=1 is LASSO; alpha=0 is Ridge
plot(fit)                              # cross-validated error vs log(lambda)
coef(fit, s = "lambda.min")            # non-zero coefficients at best lambda
```

```python
from sklearn.linear_model import LassoCV
from sklearn.preprocessing import StandardScaler
Xs = StandardScaler().fit_transform(X)
fit = LassoCV(cv=10, n_alphas=100).fit(Xs, y)
fit.coef_                              # many will be exactly zero
```

Key ideas:

- **Lambda (α in sklearn)** — the regularization strength. Zero = ordinary regression. Very large = all coefficients pushed to zero.
- **Cross-validation** — split your data into folds, use each fold as a held-out test set, average the errors. Pick the lambda that minimizes CV error.
- **LASSO vs Ridge.** LASSO zeros out coefficients (feature selection). Ridge shrinks them but rarely to zero. Elastic net is a mix.

When to reach for LASSO: **you have many predictors and suspect most are irrelevant.** Genomics, questionnaires, high-dimensional imaging features.

---

## Segment 6 (26–30 min): The train/test split

The one habit that separates statistical practice from ML practice:

- Never evaluate a model's performance on the same data you fit it on. It will look better than it is.
- Split into **train** and **test** *once, at the start.* Fit on train, predict on test, report metrics from the test set only.
- For hyperparameter tuning (choosing K, lambda), use **cross-validation on the training set.** Do not touch the test set until the end.

```python
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)
```

```r
set.seed(0)
idx <- sample(seq_len(nrow(df)), size = 0.8 * nrow(df))
train <- df[idx, ]; test <- df[-idx, ]
```

This is the ML mindset. Even if you're doing a regression for scientific inference (not prediction), it is often a great sanity check to fit on 80% and see how the coefficients change on the other 20%.

---

## Key vocabulary

- **Dimensionality reduction** — projecting high-dimensional data into fewer dimensions while preserving structure.
- **Principal component** — a direction in variable space that captures variance.
- **Loadings** — the weights defining a principal component.
- **Cluster** — a group of similar samples.
- **Elbow / silhouette** — heuristics for choosing K in K-means.
- **Regularization** — a penalty added to a loss function to prevent overfitting.
- **LASSO / Ridge / Elastic net** — L1, L2, and combined regularization.
- **Cross-validation** — repeatedly splitting data into train/validation folds.
- **Train/test split** — the honest evaluation protocol.

---

## Common student mistakes

- Running PCA / K-means without scaling. Bad results.
- Interpreting a K-means cluster as if it corresponds to a biological reality without checking.
- Fitting a LASSO and then computing its R² on the training data. Meaningless.
- Peeking at the test set to tune hyperparameters. That defeats the point.
- Reporting cluster labels without any measure of stability. Try `nstart = 25` and confirm results are reproducible.

---

## Handoff to tutor activity

`assistants_per_lecture/12_multivariate_ml_gpt.md` — the tutor gives high-dimensional data scenarios and walks the student through picking a method, applying it, and interpreting the output.
