# Slide decks — Sessions 1–6

Lecture decks for Unit 1.

```
slides/
├── assets/deck.css    shared styling
├── assets/deck.js     the slide engine (~250 lines, no dependencies)
├── CPBP8306_Session1_Thinking_Like_a_Coder.pptx   ← Session 1 (PowerPoint)
├── CPBP8306_Session2_Variables_and_Types.pptx    ← Session 2 (PowerPoint)
├── 03_collections_indexing.pptx
├── 03_collections_indexing.html
├── 04_control_flow.html
├── 05_functions_modular.html
└── 06_projects_git.html
```

## Session 1 is PowerPoint

`CPBP8306_Session1_Thinking_Like_a_Coder.pptx` — 20 slides, 16:9, speaker notes
on every slide. Run it in **Presenter View** (Alt+F5) so the notes stay off the
projector. `B` blanks the screen. It replaces the old
`01_intro_setup_thinking.html`, which has been removed.

**It is install-led.** Slides 7 and 9–13 walk the room through installing
Python, VS Code, R, and RStudio, because no pre-work went out this year. The
tutor activity moved to homework. See `../instructor/run_of_show_unit1.md`.

**Session 2 has been merged too** (17 slides). Its two variants — a 13-slide
HTML deck with speaker notes and a 9-slide PowerPoint without them — have been
combined into one PowerPoint file and removed.

Session 3 still exists in **both** formats and has not been merged. Pick one and
open only that one, or the slide numbers in
`../instructor/run_of_show_unit1.md` will not match what is on the projector.

## Using the HTML decks

Double-click any `.html` file. That's it — it opens in your browser and works
**completely offline**. No network, no CDN, no build step, no install. This is
deliberate: classroom wifi is not something to bet a lecture on.

Keep the `assets/` folder next to the decks. If you move a deck, move the folder.

| Key | Does |
|---|---|
| `→` `↓` `space` | next slide |
| `←` `↑` | previous |
| **`s`** | **speaker notes** — every slide has them |
| `o` | overview grid; click a thumbnail to jump |
| `f` | fullscreen |
| `b` | black out the screen |
| `p` | print / save as PDF |
| `?` | help |

Press **`b`** rather than alt-tabbing when you move to the whiteboard — it
blanks the projector instead of showing your desktop.

### Speaker notes

Notes live inside each slide's HTML, so a slide and its notes can never drift
apart. They contain the timing cues, the "don't reveal this yet" warnings, the
answers to the predict-first exercises, and the demo instructions. **Read them
before you teach** — several slides only make sense with the note attached.

### PDF / handouts

Press `p` and choose "Save as PDF". Set margins to none and enable background
graphics. One slide per page, 1280×720.

Speaker notes do not print. That's intentional — this is the student-facing
version.

## Companion materials

| | |
|---|---|
| `../instructor/run_of_show_unit1.md` | per-session prep, what to cut, exit tickets |
| `../demos/` | the live-coding scripts the decks reference |
| `../data/patients.csv` | the shared teaching dataset |
| `../handouts/unit1_cheatsheet.md` | student reference card |
| `../instructor/code_diagnosis_bank.md` | 20 broken snippets with answers |

## Editing

Plain HTML. To add a slide, copy an existing `<section class="slide">` and edit
it. Useful classes:

| Class | Effect |
|---|---|
| `title` / `statement` | dark full-bleed slides |
| `mid` / `center` | vertical / horizontal centering |
| `cols` / `cols3` / `cols-3-2` | column layouts |
| `box` + `gold`/`warn`/`ok`/`ai` | callout boxes |
| `qcard` | the "question to the room" card |
| `pipeline` | the numbered step strip |
| `pre.py` / `pre.r` / `pre.bad` / `pre.good` / `pre.term` | code blocks |
| `sm` / `xs` / `big` | type size adjustments |
| `tag py` / `tag r` / `tag warn` / `tag ok` | inline labels |

Python and R code inside `<pre>` is syntax-highlighted automatically. Add
`class="plain"` to opt out (useful for ASCII diagrams and folder trees).

**Overflow:** if a slide's content is too tall, the engine shrinks it to fit
rather than clipping it, and logs a warning to the browser console naming the
slide. Open the console (F12) after editing — if you see a warning, trim the
slide rather than relying on the shrink.

## A note on scope

`course_overview.md` describes Sessions 1–6 as the Python-first section, but the
Session 1–6 lecture notes teach Python and R side by side throughout. These
decks follow the lecture notes: **Python leads, R appears as an explicitly
labeled comparison**, with the differences (0- vs 1-indexing, silent coercion,
vectorization) taught as content rather than glossed over. See the review notes
for a fuller discussion of that tension.
