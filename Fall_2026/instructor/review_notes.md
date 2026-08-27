# Review of existing course content

A pass over `course_overview.md`, all 13 lecture files, the 13 per-lecture
assistants, the 4 unit assistants, and `final_quiz.md`.

**Overall:** this is strong material — genuinely better than most "intro coding
for researchers" courses, and the AI-literacy thread is well conceived and
consistently carried. The framing ("can you read a block of code and tell me
whether it's right") is the correct target and it's held throughout.

Most of what follows is tightening. But there are **five things I'd fix before
teaching**, listed first, because they're in answer keys and student-facing
material where being wrong is expensive.

Every code claim below was executed against R 4.4.1 and Python 3.11 before
being asserted.

---

## 1. Must fix

### 1.1 `final_quiz.md` B2 — the answer key is wrong

The key says:

> `if (mean(xs) = 3)` uses `=` instead of `==`. **In R this actually assigns 3
> to `mean(xs)` — an error or unexpected behavior.**

It does not assign anything. It is a **parse error** — R refuses to parse the
line at all:

```
Error: unexpected '=' in "if (mean(xs) ="
```

Nothing executes, so there's no "unexpected behavior" to reason about. Suggested
replacement:

> `=` is assignment, `==` is comparison. R cannot parse `if (mean(xs) = 3)` at
> all — it's a syntax error before anything runs. Fix: `==`. (Contrast with a
> language like C, where the analogous line compiles and silently misbehaves —
> which is why the habit matters even where the compiler saves you.)

### 1.2 `final_quiz.md` B5 — the reasoning doesn't follow

The key says 800 result rows means "200 patients had no matching lab." That
conflates rows with patients. An inner join returns **one row per matching
(patient, lab) pair**. With 2500 lab rows and some patients having several labs,
a correct join would return *more* than 1000 rows, not fewer. 800 rows means
only 800 matching pairs existed — so the surprise is that **the vast majority of
lab rows matched no patient at all.**

That points at a different diagnosis, and a more interesting one: the keys
probably don't agree in format (`"P001"` vs `"P1"` vs `1`, or whitespace). This
is a better question than the current one — keep it, fix the key:

> Both counts are surprising. An inner join emits one row per matching pair, so
> with 2500 labs across ≤1000 patients you'd expect *more* than 1000 rows. Getting
> 800 means almost nothing matched — which usually means the key columns don't
> agree in type or format (`"P001"` vs `1`, or a trailing space). Check
> `setdiff(labs$patient_id, patients$patient_id)` before assuming a join type is
> the problem. A `left_join` would also have been the right choice if the goal
> was to keep all patients.

### 1.3 `final_quiz.md` — the "no partial credit" rule contradicts the rubric

Student-facing rules say:

> A blank answer gets 0 points; a wrong answer also gets 0 points; so guess.

But the Section B rubric says "award partial credit for identifying part of the
issue," and Section C has explicit 5/3/1/0 bands. The all-or-nothing rule is only
true for Section A.

Fix the student-facing line:

> Section A is multiple choice with no partial credit — always guess. Sections B
> and C award partial credit for partial reasoning, so **write down your thinking
> even if you're not sure of the conclusion.**

That's also better pedagogy: it tells them the reasoning is what's being graded,
which is the whole point of the quiz.

### 1.4 The quiz's 50 points have nowhere to go

`course_overview.md` allocates 100 points: pre-test 10, project 30, post-test 10,
participation 50 — with participation defined as the 12 weekly tutor transcripts.
`final_quiz.md` then adds 50 points and says they "contribute to Participation."
Participation is already fully spent.

Pick one and write it down:

- **(a)** Quiz replaces the two weakest weekly activities (fits the existing drop-lowest logic; costs nothing).
- **(b)** Rebalance to participation 40 / quiz 10.
- **(c)** Quiz is ungraded and diagnostic, given alongside the post-test.

I'd take **(a)** — it keeps the stakes low, matches the stated philosophy, and
requires no change to the point table. Whichever you pick, it needs to be in the
syllabus before week 1, not decided in December.

### 1.5 `lectures/02_variables_types.md` — the operator table has two errors

Line 129 lists `%%` as "modulo (remainder)" in a table that otherwise marks
language differences explicitly. **`%%` is R. Python's modulo is `%`.** As
written, students will write `%%` in Python and get a syntax error.

Line 131 breaks the table rendering. The row is:

```
| `and or not` (Py) / `& | !` (R) | logical combos | ... |
```

The `|` inside the backticks still splits the cell in GitHub-flavored markdown —
inline code does not protect pipes in tables. It renders as a mangled extra
column. Escape it as `\|`.

---

## 2. Structural issues

### 2.1 "Weeks 1–6 are Python" isn't what the lectures do

`course_overview.md` says:

> **Python** is the default for early concept teaching (weeks 1–6).

But lectures 1–6 present Python and R side by side in essentially every segment,
and Session 3 makes the *differences between them* the core content. That's not
a Python-first unit; it's a comparative unit.

I don't think the lectures are wrong — the `bp[-1]` divergence and R's silent
coercion are genuinely among the best AI-trap examples in the whole course, and
you'd lose them by going Python-only. But the overview should describe what's
actually happening, because the current wording sets a student expectation the
first six weeks then violate.

Suggested replacement:

> **Sessions 1–6 lead in Python** and show the R equivalent alongside it. Where
> the two languages genuinely disagree — 0- vs 1-indexing, negative indices,
> silent type coercion, vectorization — that disagreement is taught as content,
> because those are exactly the places AI-generated code fails silently when
> translated. **Sessions 9–13 lead in R.** Sessions 7–8 are fully bilingual.

The decks I built follow this reading.

### 2.2 Session numbering in the overview table

The fall-break row is numbered `8`, and so is the wrangling session after it —
two rows labeled 8. Should be `—` for the break, matching how Thanksgiving and
the buffer week are handled two rows down.

Also worth adding a note that the 13 numbered sessions correspond exactly to
`lectures/01`–`13`, since the table's row order doesn't make that obvious.

### 2.3 Milestones stop after Session 9

There are explicit milestones at Session 4 (choose dataset), 6 (repo + register),
and 9 (cleaned data). Then nothing until the presentation in Session 13 — a
**nine-week gap** covering visualization, stats, and ML, ending in the single
largest graded deliverable.

That's where projects go quiet and then arrive underdone. Add two:

| After | Milestone |
|---|---|
| **Session 10** | One draft figure of your own data pushed to the repo. Any quality. |
| **Session 12** | Analysis run end-to-end; a one-paragraph "here's what I found" on Brightspace. |

Both are cheap to grade (did it appear: yes/no) and both surface the students in
trouble while there's still time. The Session 10 one especially — a student who
can't produce *any* figure from their own data by week 10 needs an intervention,
and right now you won't find out until December.

### 2.4 There is no written AI policy

For a course whose entire thesis is responsible AI use, the only stated rule is
"no AI during the quiz." Nothing says what's permitted on the **project** — which
is 30% of the grade and the thing most likely to generate an academic-integrity
question.

You don't need a restrictive policy; you need an explicit one. Something like:

> **AI use in this course.** You may use AI assistants for any part of your
> project, including generating code you then edit. You are responsible for
> everything you submit: if you cannot explain what a line does and why it's
> there, do not submit it. Include a short "AI use" note in your write-up saying
> which tools you used and for what — the same way you'd cite a package. The only
> hard restrictions are the final quiz (no AI) and the weekly tutor sessions
> (engage with the tutor, don't route it through a second model).

The "explain any line" standard is the course's own success criterion, applied
as policy. It's also enforceable in a 60-second conversation.

### 2.5 Study Hall disappeared

The 2025 syllabus lists a Study Hall in Light Hall 439. The 2026 overview
doesn't mention it. If it still exists it should be in the overview (it's the
natural place to send students with install problems, which Session 6 will
generate). If it was dropped, no action — but confirm it's intentional.

### 2.6 Session 13 is over-subscribed

The outline allots 20 minutes for "5 min each × 4" presentations, plus a 20-minute
quiz, in 55 minutes. The parenthetical acknowledges >8 students is a problem, but
the arithmetic is tight even at 4: a 5-minute slot with 1 minute of Q&A built in
runs 6–7 minutes in practice, every time.

Also, 20 minutes for 10 multiple-choice + 5 code diagnoses + 2 short answers is
fast. The code-diagnosis questions each require reading a snippet carefully;
budget 90 seconds each and Section B alone is 7–8 minutes.

Concrete suggestion: **move the quiz to Session 12's activity slot.** It fits
naturally (Session 12 already suggests previewing the format), frees 20 minutes
in Session 13, and means students take it while the material is freshest rather
than after a two-week project sprint. Session 13 then becomes presentations +
post-test + donuts, which is the right shape for a last day.

---

## 3. Per-file technical notes

### `lectures/03_collections_indexing.md`

The Python boolean-indexing example builds a mask and then never uses it:

```python
high = [x > 130 for x in bp]    # [False, False, True, False, False]
# with numpy or pandas this is much cleaner — Session 7
```

The R block right below shows `bp[high]` and `bp[bp > 130]`. Students will
immediately try `bp[high]` in Python and get `TypeError`. Either show the numpy
version (three lines, and it motivates why numpy exists) or show
`[x for x in bp if x > 130]` and say explicitly that plain lists can't do the R
thing. Leaving the mask unused is the one place in the file where the
side-by-side symmetry breaks without acknowledgement.

### `lectures/11_univariate_stats.md`

The lecture correctly notes R's `t.test` defaults to Welch, and correctly passes
`equal_var=False` in the scipy example. But it never says **the defaults differ**
— R defaults to Welch, scipy defaults to Student's.

That's one of the best AI-trap examples available and it's sitting right there
unused. Suggested addition to Segment 6:

> `t.test(a, b)` in R gives you Welch's by default. `stats.ttest_ind(a, b)` in
> Python gives you Student's by default. **The same "translate this to Python"
> request will silently change your test.** Ask any AI that translates statistical
> code: "did any default change?"

### `lectures/12_multivariate_ml.md`

**Two `alpha`s on one page.** The lecture uses `alpha = 1` in `cv.glmnet` (where
alpha is the elastic-net *mixing* parameter) and then says "**Lambda (α in
sklearn)** — the regularization strength." Both are true and they are different
quantities sharing a symbol. As written, a student reading top to bottom will
conclude `alpha=1` set the penalty strength.

Fix with an explicit callout:

> **Naming trap.** In `glmnet`, `alpha` chooses *which* penalty (1 = LASSO,
> 0 = Ridge) and `lambda` is *how much*. In scikit-learn, `alpha` is *how much*,
> and you choose the penalty by picking the class (`Lasso` vs `Ridge`). Same
> letter, different jobs. Read the docs, not the letter.

**The `model.matrix` line has a real bug.** This:

```r
X <- model.matrix(~ . - body_mass_g, data = df)[, -1]
y <- df$body_mass_g
```

drops rows containing `NA` from `X` but not from `y`, so the two silently
misalign. Verified on a 5-row frame with two NAs: `nrow(X)` is 3 while
`length(y)` is 5. `glmnet` then errors, or worse, recycles.

Given that Session 9 is all about missingness, this is a good teaching moment
rather than just a fix:

```r
d <- df |> select(body_mass_g, where(is.numeric)) |> tidyr::drop_na()
X <- model.matrix(body_mass_g ~ ., data = d)[, -1]
y <- d$body_mass_g
stopifnot(nrow(X) == length(y))     # cheap, catches the whole class of bug
```

The `stopifnot` line is worth teaching in its own right — it's the R version of
the "ten-second test."

### `lectures/09_eda.md`

Uses `use = "pairwise.complete.obs"` in one example and `use = "pairwise"` in the
next. Both work (partial matching), but showing two spellings of the same
argument in adjacent code blocks invites a question you don't want to spend time
on. Pick one.

### `lectures/07_dataframes_tidy.md` and the penguins dataset

Sessions 7–12 reference `penguins.csv` repeatedly, and it is not in the repo. The
2025 course presumably had students install `palmerpenguins`. Two problems: the R
package doesn't help the pandas examples, and package installs fail in class.

**Vendored.** `data/penguins.csv` is now in the repo alongside `patients.csv`,
so nobody needs a package install or a network connection mid-class.

**One correction that follows from it:** the lecture says `df.shape` gives
`(344, 8)`. That's the R `palmerpenguins` shape, which includes a `year`
column. The vendored copy has **7 columns** (the seaborn distribution drops
`year`). Change the lecture to `(344, 7)`, or add a `year` column if you prefer
the R shape — but the two need to agree, because this line is the first thing
students will run and a mismatch on slide one of Unit 2 undermines the
"always check what you loaded" habit you're trying to build.

### `assistants_per_lecture/02_variables_types_gpt.md`

Problem 2's aside — "if they were writing R (where `"42" + 8` would also fail
differently)" — is vague enough that the tutor may improvise something wrong. R
gives `Error in "42" + 8 : non-numeric argument to binary operator`, which is
the *same* outcome as Python (a loud refusal), not a different one. Worth
tightening, because the interesting contrast is elsewhere: R refuses on `+` but
silently coerces inside `c()`. That's the comparison with teeth.

### `assistants_by_unit/unit1_foundations_gpt.md`

Level 5 question 14 — "In R, `c(1, 2, 'three')[1]` returns what type?" — is
good. Consider adding the follow-up "and what if you'd written `list(1, 2,
'three')[[1]]`?" (answer: `numeric` — lists don't coerce). That's the cleanest
way to show that coercion is a *vector* property, not an R property, and it
prevents the overgeneralization "R always ruins your types."

---

## 4. Gaps worth filling

Things that don't exist yet and that the course assumes:

| Gap | Why it matters | Status |
|---|---|---|
| A teaching dataset | Every lecture invents fresh toy data; nothing carries across weeks | **Added** — `data/patients.csv` |
| Runnable demo scripts | Live demos are described in prose; they fail differently every time | **Added** — `demos/` |
| Environment check | Session 6 will lose 20 minutes to broken installs | **Added** — `handouts/check_setup.{py,R}` |
| Participation rubric | 50% of the grade specified as "full credit for engaging" | **Added** — `instructor/participation_rubric.md` |
| Slide decks | Lecture notes are prose; you can't project them | **Added** — `slides/` |
| `penguins.csv` | Referenced from Session 7 on, not present | **Added** — see note below |
| Written AI policy | See 2.4 | Not done — needs your decision |
| Late / makeup policy | 12 weekly submissions, no stated policy | Not done — "drop two" in my rubric is one answer |
| Accessibility statement | Standard Vanderbilt boilerplate | Not done |

---

## 5. Smaller things

- **`final_quiz.md`** says "Closed-notebook." Probably "closed-note" — as written
  it reads like a rule about Jupyter.
- **`final_quiz.md` A8** — `git checkout -- analysis.R` is correct, but `git restore`
  is the modern spelling and is what students will see if they use recent
  documentation. Consider accepting both, or adding a distractor that tests
  knowing they're equivalent.
- **`lectures/06_projects_git.md`** teaches `git checkout <file>`; worth adding
  `git restore <file>` alongside it for the same reason. (The Session 6 deck
  does this.)
- **`lectures/13_synthesis_project_postquiz.md`** — the presentation rubric sums
  to 30, matching the overview. Good. But `course_overview.md` describes the
  project only as "~2 pages"; the detailed rubric lives only in the Session 13
  file, which students won't read until week 13. **Move or duplicate the rubric
  into the overview**, and hand it out at Session 6 when they register the
  dataset. Students should see how they'll be graded when they start, not when
  they finish.
- **Session 4 recap** in the overview ("choose a dataset by Session 4") is stated
  in `course_overview.md` but never repeated in `lectures/04_control_flow.md`.
  The lecture files are what you teach from, so deadlines should appear in them.
  (Added to the decks.)
- **Tutor deployment drift.** The assistants are prompts in markdown, deployed by
  hand into custom GPTs. Once deployed there's no link between the deployed
  version and the file. Add a line at the top of each — `<!-- v2026.1 -->` — and
  put the same string in the GPT's description, so a student reporting odd
  behavior can tell you which version they used.
- **`assistants_per_lecture/01_intro_setup_thinking_gpt.md` rule 5** tells the
  tutor to send students to the TA after three refusals. Make sure Peyton knows
  that's in there and roughly how often to expect it, especially weeks 1–2.

---

## 6. What I'd leave alone

Worth saying explicitly, since the list above is long:

- **The Socratic tutor design is the strongest thing here.** The ironclad rules,
  the "predict before you run" gate, and the refusal to give code are exactly
  right, and the escalation valve (three refusals → TA) keeps it from being cruel.
- **The concept-first reorganization** away from alternating Python/R weeks is a
  clear improvement over the 2025 structure and the reasoning in the overview is
  sound.
- **Session 1's decomposition segment** is the best-designed 10 minutes in the
  course. Don't cut it, don't shorten it, don't move it later.
- **`final_quiz.md` Section B** (diagnose the code) is precisely the right
  assessment for the course's stated goal. If anything, make it longer and Section
  A shorter — Section A tests recall, Section B tests the thing you actually claim
  to teach.
- **The "you are the scientist, the code has your name on it" framing.** It
  recurs at the right moments and it's the ethical spine of the whole design.
