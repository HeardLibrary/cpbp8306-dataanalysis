# Unit 1 — instructor run-of-show (Sessions 1–6)

Everything you need in the room, per session: what to have open, where the
demo breaks, what to cut when you're behind, and the exit ticket.

**Standing shape of every session (55 min):**

| Time | What |
|---|---|
| 0–5 | Recap + framing question |
| 5–35 | Lecture — the Session N deck in `slides/` |
| 35–55 | Tutor activity — `assistants_per_lecture/NN_*.md` |

**Deck formats differ.** Session 1 is PowerPoint
(`slides/CPBP8306_Session1_Thinking_Like_a_Coder.pptx`); Sessions 2–6 are the
self-contained HTML decks. Sessions 2 and 3 also have `.pptx` versions — decide
which one you are teaching from before class and open only that one.

**Standing rule:** you will not finish the deck if you take every question.
Each session below has a "cut this first" line. Decide before class, not at
minute 32.

---

## Driving the decks

### Session 1 — PowerPoint

Open `slides/CPBP8306_Session1_Thinking_Like_a_Coder.pptx`. 16 slides, 16:9.
Speaker notes are on every slide — use **Presenter View** (Slide Show →
Presenter View, or Alt+F5) so they land on your screen and not the projector.

| Key | Does |
|---|---|
| → ↓ space | next |
| ← ↑ | previous |
| **B** | black out the screen (use this when you go to the whiteboard) |
| Ctrl+P / Ctrl+A | pen / back to arrow |
| Esc | end the show |

Presenter View gives you the notes, a timer, and the next-slide preview. Set it
up on the classroom machine *before* students arrive — it is the one thing that
goes wrong on a projector you have not used before.

### Sessions 2–6 — HTML

Open `slides/NN_*.html` in a browser. Everything is offline — no network, no CDN.

| Key | Does |
|---|---|
| → ↓ space | next |
| ← ↑ | previous |
| **s** | **speaker notes** — every slide has them |
| o | overview grid; click a thumbnail to jump |
| f | fullscreen |
| b | black out the screen (use this when you go to the whiteboard) |
| p | print / save as PDF |
| ? | help |

Notes are in the HTML, not a separate file, so a slide and its notes never
drift apart. Press **b** rather than switching windows when you move to the
board — it keeps the projector from showing your desktop.

---

## Before Session 1 — post to Brightspace tonight

Session 1 is install-led and every one of these is load-bearing in the room.
**`instructor/brightspace_session1.md` has the paste-ready copy for each item.**

- [ ] **The four download links**, on the Session 1 page, in this order:
      Python <https://www.python.org/downloads/> ·
      VS Code <https://code.visualstudio.com/> ·
      R <https://cran.r-project.org/> ·
      RStudio <https://posit.co/download/rstudio-desktop/>
- [ ] `handouts/install_guide.md` — the written version of the whole install block
- [ ] `handouts/check_setup.py` and `handouts/check_setup.R`
- [ ] The Session 1 tutor link, with the submission set to accept **pasted text**
- [ ] The deck, `CPBP8306_Session1_Thinking_Like_a_Coder.pptx`
- [ ] `handouts/unit1_cheatsheet.md`

---

## Before the semester

- [ ] Post `handouts/check_setup.py` and `handouts/check_setup.R` to Brightspace
- [ ] Post `handouts/unit1_cheatsheet.md` (students will use it all semester)
- [ ] Generate the dataset: `python data/make_patients.py`, and post `data/patients.csv`
- [ ] Deploy the six per-lecture tutors and the Unit 1 tutor; put the links in Brightspace
- [ ] Decide and publish the participation rubric (`instructor/participation_rubric.md`)

---

## Session 1 — Thinking Like a Coder

> **This session is install-led.** No pre-work install instructions went out this
> year, so assume nobody arrives with anything on their laptop. Minutes 12–40 are
> a guided install and the tutor activity has moved to homework. The deck is 20
> slides and already reflects this; so does `lectures/01_intro_setup_thinking.md`.

**Post to Brightspace the night before** — see the checklist at the top of this
file. The four download links must be on the Session 1 page before you walk in,
because minute 12 depends on them.

**Open before class:** the deck in Presenter View · `demos/01_the_hook.py` in a
terminal at the repo root · the Brightspace Session 1 page with the four download
links, on a second tab you can project instantly · `hello.py` in VS Code and
`hello.R` in RStudio for the checkpoint.

**The demo that carries the session (3–9):** `python demos/01_the_hook.py`. Run
PART ONE only, ask "would you write this up?", then PART TWO. The
`value_counts()` output shows two rows both labeled `A` — the space is
invisible — which is the whole lesson in one screenshot. Then PART THREE.

### The install block (12–40) — how it actually goes

**Minute 12 is downloads, not installs.** Project the Brightspace links and make
everyone start all four before anyone runs anything. On classroom wifi the
download is the slow part, and they download in parallel. The tool tour (slide 8)
exists to fill that time — watch the progress bars, not the clock.

**If the room's bandwidth collapses:** stagger it. Back half starts R and RStudio
(the big ones), front half starts Python and VS Code, then swap.

**Install order is Python → VS Code → R → RStudio.** Only one ordering constraint
is real: **R before RStudio.** RStudio installed first launches and announces it
cannot find R, which reads as catastrophic and is a thirty-second fix.

**The one thing to say twice:** on Windows, "Add python.exe to PATH" is at the
bottom of the installer's first screen, unticked by default, in small text. It is
the most common cause of a broken Session 2.

**Do not debug individual laptops from the front.** The TA triages; you keep the
room moving. Anyone finished early should be helping a neighbour — say it out
loud, it genuinely halves the block.

**Hard stop at minute 34** regardless of where the room is. Slide 12 is the
checkpoint, slide 13 is the escape hatch, and both are built for a half-finished
room.

**Slide 13 is the slide that matters most for the students who are struggling.**
Say "nothing else today needs a laptop" slowly and mean it. A student whose
install failed is deciding right now whether this course is for them.

**Cut this first:** the tool tour (slide 8) — if downloads finish fast, drop it to
two minutes and start installing. After that, compress the verify loop (slide 17)
to 60 seconds. Do not cut it entirely.

**Protect at all costs:** **slides 14–15**, decomposition. It is the thesis of the
course, it needs no laptop, and it is the part of today that is not plumbing. If
the installs run long, take the time from slides 16–17, not from here.

**Already cut:** the in-class pairs exercise on gene expression. It is Problem 4
of the tutor, which students now do as homework. Do not reinstate it.

**Deck timings:** slide 6 carries the agenda — be there at minute 9, gone by 12.
Slide 7 (downloads) at 12. Slide 12 (checkpoint) at 34. Slide 18 (handoff) at 53.

**Also do not leave without:** the project dataset deadlines — choose by Session
4, register on Brightspace by Session 6 (slide 20). Students who pick late
produce weak projects.

**Exit tickets:** *In one sentence: what is a program?* — run it as the 60-second
checkpoint on slide 12 rather than at the end. And, given the day: *what is still
not installed on your laptop?* That one tells you exactly what Monday's study
hall is for.

---

## Session 2 — Variables and Types

**Open before class:** `demos/02_types_demo.py`, the deck.

**The demo:** run the sections as you reach them. The last section loads the real
`patients.csv` and produces a genuinely instructive `TypeError` — pandas
concatenates every age value into one absurd string. Students remember it.

**Where it goes wrong:** nothing technical. The risk is pace — this deck is
dense and you will be tempted to lecture the operator table. Don't. Point at
the bottom three rows and connect them to booleans.

**Cut this first:** the operator table (slide 12) — it's a reference slide, tell
them so and move.

**Protect:** slide 11 (predict-before-you-run) and slide 16 (the AI fix that
silences rather than solves).

**Exit ticket:** *You load a CSV and `mean(age)` fails. Name the first thing you check.*

---

## Session 3 — Collections and Indexing

**Open before class:** `demos/03_collections_demo.py` AND `demos/03_collections_demo.R`,
side by side in two consoles. Whiteboard clear.

**The demo:** run the matching sections in both consoles alternately. This is the
one session where side-by-side is non-negotiable — the `bp[-1]` divergence has
to be seen, not described.

**Draw on the board first:** the index ruler from slide 7, before you show the slide.

**Where it goes wrong:** students conflate the two languages and leave more
confused than they arrived. Antidote: say which language you're in, out loud,
every single time you type.

**Cut this first:** slide 13 (choosing the container) — it's on the cheat sheet.

**Protect:** slide 11, boolean masks. Build it in three stages live: print the
mask alone, then use it, then count with it. Students cannot see the mask until
you print it by itself.

**Exit ticket:** *In R, `xs <- c(10,20,30)`. What does `xs[-1]` give you, and why?*

---

## Session 4 — Control Flow

**Open before class:** `demos/04_loops_demo.py`, the deck. **Collect project
dataset choices today.**

**The demo:** the timing comparison at the end of the demo script is the
persuasive part — roughly 40× on five million rows, measured live on your
machine. Assert nothing you can measure.

**Where it goes wrong:** the timing block allocates a 5M-element list and takes
a few seconds. Run it once before class so it's warm and you know your number.

**Cut this first:** the `while` segment (slide 13) — 90 seconds, or skip and put
it on the cheat sheet.

**Protect:** slides 8–11, vectorization. This is the "aha" of Unit 1.

**Exit ticket:** *Write one line of R that counts how many values in `bp` are over 140.*

---

## Session 5 — Functions and Modular Code

**Open before class:** `demos/05_functions_demo.py`, the deck.

**The demo:** do the refactor *live*. Start with the duplicated block on screen
and edit it into a function while narrating: "what changes between the two
copies? That's a parameter." Performing it beats showing the finished version.

**Where it goes wrong:** students conclude functions are bureaucratic overhead.
The antidote is the ten-second test (slide 15) — make them actually run
`count_high([140])` and discover the boundary question. That converts functions
from ceremony into leverage.

**Cut this first:** the roxygen slide (13) — mention it exists, move on.

**Protect:** slides 14–15, docstring-as-specification. It's the AI-collaboration
payload of the whole unit.

**Exit ticket:** *Your function prints the result instead of returning it. What breaks?*

---

## Session 6 — Projects, Files, and Version Control

**Highest-risk session of the unit.** Budget for it.

**Before class:** confirm by email that everyone has (a) a GitHub account,
already verified, and (b) `git --version` working. Do this a week out, not the
night before. Post `demos/06_git_walkthrough.md` authentication instructions.

**Open before class:** a throwaway demo repo, rehearsed once. Read
`demos/06_git_walkthrough.md` — it has the exact command sequence, what to say
while typing, and the three questions students ask every time.

**The demo:** steps 7–9 (break the file, `git diff`, `git restore`) are the
emotional core. Delete a whole function visibly, then bring it back.

**Where it goes wrong:** GitHub authentication eats the room. Personal access
tokens confuse everyone. Recommend `gh auth login`. If more than a third of the
room is stuck, stop the demo, let the TA run auth triage, and finish the lecture
content — pushing can happen in office hours.

**Cut this first:** the GitHub setup steps (slide 14) — put them on Brightspace
as a written walkthrough and let students follow at their own pace.

**Protect:** slide 11 (commit before you paste AI code) and slide 15 (the Unit 1
retrospective — it's what makes Session 7 feel continuous rather than a reset).

**Milestone — do not let anyone leave without it:** repo URL posted to
Brightspace, containing a README, a `.gitignore`, and one script. Chasing this
later costs far more than fifteen minutes now.

**Exit ticket:** *You just pasted AI code and everything broke. What do you type?*

---

## Exit tickets — how to use them

Thirty seconds at the end, on an index card or a one-question Brightspace poll.
Not graded. You are looking for the *distribution* of answers, not individual
performance.

They're also your recap slide for the following week: open with the two most
common wrong answers and resolve them in ninety seconds. That's the highest-value
90 seconds in the whole session, and it costs no prep.

---

## Timing reality check

Thirty minutes of lecture is roughly 16–20 slides at a comfortable pace with
questions. Every deck in this unit is 15–22 slides, so **you are at or slightly
over budget on all of them.** That's deliberate — the "cut this first" line
above is the release valve. Use it early rather than rushing the last third,
which is where the AI-collaboration content lives in every single deck.
