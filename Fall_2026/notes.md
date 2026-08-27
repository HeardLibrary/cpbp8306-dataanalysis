I'll start by exploring the repository structure to understand what's here.

I have the full picture. Let me set up a task list and start building.

One scope note before I build: `course_overview.md` calls weeks 1–6 the "Python default" section, but lectures 1–6 as written teach Python *and* R side-by-side in every segment. I'm building the decks Python-first with R kept as an explicitly-labeled "same idea, different syntax" comparison — that matches the lectures you have while honoring the Python framing. Flagging it in the review too.

Framework built. Now the six decks — starting with Session 1.

Let me verify the engine works before writing five more.

Good — engine works, but content overflows. Let me add an autofit safety net so no slide can ever clip.

Now the overview and print rules need to match the new `.inner` box, plus the autofit logic:

Highlighting and autofit both work. Now decks 2 through 6.

All six decks written. Let me check each for overflow warnings.

Two minor overflows — let me trim them properly rather than rely on auto-shrink.

The preview pane serves a cached snapshot for files outside the project root, so I can't re-verify those two trims through the browser — but autofit guarantees they can't clip either way. Moving on to supporting materials.

Full stack available. Building the shared teaching dataset with deliberate, teachable defects.

The defects reproduce, but the effect is too weak to make the Session 1 hook land. Let me strengthen the story — the dropped rows should be systematically different, which is also more realistic.

Buggy analysis says p = 0.22 ("no difference"); the correct analysis says p = 0.0064. That's a clean false-negative story. Updating deck 1 to the real numbers.

Now the live-coding demo scripts the decks reference.

The `value_counts()` output showing two indistinguishable "A" rows is a bonus teaching moment. Now the remaining demos.

42× speedup, measured live. Now the functions demo and the Git walkthrough.

Now the setup-check scripts and the Git walkthrough.

All demos verified against real interpreters. Now the written materials.

Both setup checks verified. Now the instructor and student documents.

Let me verify the numeric claims in the diagnosis bank rather than assert them.

One answer in the bank was wrong — the example data didn't actually expose the bug. Fixing it.

Confirmed. Now the two READMEs to tie it together.

Now the review pass. Let me read the rest of the course content.

Let me check the two `.docx` files — one appears to contain instructions for this work.

I have full context now, including the original brief. Let me verify a few R claims before asserting them in the review.

All confirmed — including two genuine errors in the quiz answer key. Now the review.

Let me see if I can close the `penguins.csv` gap rather than just flag it.

Vendored — 344 rows. One wrinkle: this copy has 7 columns, but `lectures/07` states `(344, 8)`. Let me document that.

Finally, a top-level index so the new material is discoverable.

Done. Start with [TEACHING_MATERIALS.md](CPBP_8306_data_analysis/TEACHING_MATERIALS.md).

## Slide decks — Sessions 1–6

Six self-contained HTML decks in [slides/](CPBP_8306_data_analysis/slides). Double-click and they work offline — no CDN, no build step, nothing to install on a classroom machine. Arrow keys navigate, **`s`** shows speaker notes, `b` blanks the projector when you go to the whiteboard, `p` exports PDF.

Every slide carries speaker notes with timing cues, answers to the predict-first exercises, and explicit "don't reveal this yet" markers. The engine auto-shrinks any slide that runs long rather than clipping it, and logs a console warning so you can trim it properly.

## The thing that ties it together

The lectures each invented fresh toy data. I built one dataset used throughout: [data/patients.csv](CPBP_8306_data_analysis/data/patients.csv), 250 synthetic patients with six deliberate, realistic defects.

The flagship one drives Session 1's hook. 40 rows have `group` = `"A "` with a trailing space — and they aren't a random 40, they're a second site with lower blood pressures. So `df["group"] == "A"` turns a real difference (p = 0.0064) into a null result (p = 0.2152), silently. It's a false negative, the kind nobody re-examines. `value_counts()` shows two rows both labeled `A`, because the display hides the space.

All six [demos/](CPBP_8306_data_analysis/demos) are runnable and verified against Python 3.11 and R 4.4.1 — including the Session 4 timing comparison, which measured 42× on 5M rows on this machine.

## Review — five things to fix before teaching

Full detail in [review_notes.md](CPBP_8306_data_analysis/instructor/review_notes.md). Two are errors in the quiz answer key:

- **B2** says `if (mean(xs) = 3)` "assigns 3 to `mean(xs)`." It doesn't — R won't parse the line at all. Verified.
- **B5**'s reasoning conflates rows with patients. An inner join emits one row per matching *pair*, so 2500 labs across ≤1000 patients should yield *more* than 1000 rows. 800 rows means almost nothing matched, which points at a key-format mismatch — a better question than the one currently keyed.
- The quiz's 50 points have nowhere to live; participation is already fully allocated to the 12 weekly activities.
- The student-facing "no partial credit, so guess" rule contradicts the Section B/C rubrics.
- `lectures/02`'s operator table calls `%%` Python's modulo (it's R's), and an unescaped `|` breaks the table rendering.

Structurally, the largest gap is **nine weeks with no project milestone** between Session 9 and the presentation — that's where projects go quiet and arrive underdone. Two cheap yes/no checkpoints at Sessions 10 and 12 would surface the students in trouble while there's still time.

Two notes on judgment calls I made:

The overview calls weeks 1–6 "Python default," but the lectures teach both languages side by side throughout — and Session 3 makes the *differences* its core content. I followed the lectures rather than the overview, because `bp[-1]` meaning opposite things in the two languages is one of the best AI-trap examples in the course. §2.1 argues for rewording the overview to match.

I also vendored `penguins.csv`, which Sessions 7–12 reference but the repo never contained. That surfaced a real discrepancy: `lectures/07` says `df.shape` is `(344, 8)`, which is the R package's shape. This copy has 7 columns. Worth reconciling, since it's the first line students run in Unit 2.