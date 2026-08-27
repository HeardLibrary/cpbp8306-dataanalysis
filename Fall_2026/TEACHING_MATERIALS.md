# Teaching materials — Unit 1 (Sessions 1–6)

New material added alongside the existing lecture notes and tutor prompts.
Everything here is for *teaching* the Python section; the lecture `.md` files
remain the source of truth for content, and these decks follow them.

```
slides/          lecture decks — Session 1 as .pptx, Sessions 2-6 as HTML
demos/           the live-coding scripts the decks reference
data/            the shared teaching dataset (+ generator) and penguins.csv
handouts/        student-facing: setup checks, Unit 1 reference card
instructor/      run-of-show, rubric, diagnosis bank, review notes
```

---

## Start here

| If you want to… | Read |
|---|---|
| Teach Session N tomorrow | `instructor/run_of_show_unit1.md` → the Session N section |
| Project the slides | Session 1: open the `.pptx` in Presenter View (Alt+F5). Sessions 2–6: open `slides/0N_*.html` and press **`s`** for speaker notes. |
| Know what changed and what still needs your decision | `instructor/review_notes.md` |
| Grade the weekly transcripts | `instructor/participation_rubric.md` |

---

## The decks

Session 1 is `CPBP8306_Session1_Thinking_Like_a_Coder.pptx` — 20 slides, speaker
notes on every one, run it in Presenter View. It is **install-led**: no pre-work
went out this year, so minutes 12–40 install Python, VS Code, R, and RStudio
with the room, and the tutor activity is homework. Sessions 2–6 are HTML:
**double-click and they work offline** — no network, no build step, no install.
Keep `slides/assets/` next to them. Sessions 2 and 3 also have `.pptx` versions
of the same content; teach from one format or the other, not both.

HTML deck keys: `→`/`←` navigate · **`s` speaker notes** · `o` overview ·
`f` fullscreen · `b` blank the screen · `p` save as PDF · `?` help.
PowerPoint: `→`/`←` navigate · `B` blanks the screen · notes live in Presenter View.

Every slide has speaker notes containing timing cues, the answers to the
predict-first exercises, and "don't reveal this yet" warnings. **Several slides
only make sense with the note attached** — read them before teaching. Details in
`slides/README.md`.

## The demos

Runnable, and all verified against Python 3.11 and R 4.4.1.

| File | Session | The moment it exists for |
|---|---|---|
| `demos/01_the_hook.py` | 1 | Code that runs, reports "no difference," and is wrong |
| `demos/02_types_demo.py` | 2 | A real `TypeError` from the real course data |
| `demos/03_collections_demo.py` + `.R` | 3 | Run side by side — the `[-1]` divergence must be *seen* |
| `demos/04_loops_demo.py` | 4 | Loop vs vectorized, timed live (~40× on 5M rows) |
| `demos/05_functions_demo.py` | 5 | Refactoring, and the ten-second boundary test |
| `demos/06_git_walkthrough.md` | 6 | Exact command sequence, what to say, what breaks |

Run them from the repo root, e.g. `python demos/01_the_hook.py`.

## The dataset

`data/patients.csv` — 250 synthetic patients with **six deliberate, realistic
defects**, each planted for a specific session. Using one dataset all semester
means Session 4's example is recognizably Session 2's data.

The flagship defect: 40 rows have `group` = `"A "` with a trailing space, and
they're not a random 40 — they're a second site with lower blood pressures. So
`df["group"] == "A"` turns a real difference (p = 0.0064) into a null result
(p = 0.2152), with no error and no warning. Full details and the other five
defects in `data/README.md`.

Regenerate deterministically with `python data/make_patients.py`.

`data/penguins.csv` is also vendored, since Sessions 7–12 reference it and
package installs fail in class. Note the column-count discrepancy flagged in
`data/README.md`.

## Handouts

- `handouts/install_guide.md` — the written version of the Session 1 install
  block, for anyone who does not finish in class. **Post this with the deck.**
- `handouts/check_setup.py` / `check_setup.R` — students run these *after*
  Session 1. Reports what's missing and prints the fix. Changes nothing.
  **Post both alongside the install guide.**
- `handouts/unit1_cheatsheet.md` — one reference card for all six sessions.
  The 0-vs-1-indexing table alone is worth printing.

## Instructor material

- `instructor/run_of_show_unit1.md` — per session: what to open, where the demo
  breaks, **what to cut when you're behind**, what to protect, and an exit ticket.
- `instructor/participation_rubric.md` — a concrete 4-point rubric for the weekly
  transcripts, with a 30-second grading pass and the edge cases you'll actually hit.
- `instructor/code_diagnosis_bank.md` — 20 broken snippets with answers, tagged
  by session. All of them run; the dangerous ones are marked **SILENT**.
- `instructor/review_notes.md` — the review of the existing content.

---

## Decisions still waiting on you

From `instructor/review_notes.md`, the four that block nothing but shouldn't slip:

1. **Where the quiz's 50 points live.** Participation is already fully allocated.
2. **A written AI policy for the project.** Currently the only rule is "not during the quiz."
3. **Whether the quiz moves to Session 12.** Session 13 doesn't fit as scheduled.
4. **Two mid-semester project milestones** (Sessions 10 and 12) to close the nine-week gap.

And five things to fix in existing files before teaching — all in §1 of the
review notes, including two genuine errors in the `final_quiz.md` answer key.
