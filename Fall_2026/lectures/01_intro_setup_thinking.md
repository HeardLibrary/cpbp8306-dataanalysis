# Session 1 — Course Intro, Setup, and Thinking Like a Coder

**Unit:** 1 (Foundations)
**Date:** 08/27/2026
**Duration:** 55-minute session — install-led (see the note below)
**Companion deck:** `slides/CPBP8306_Session1_Thinking_Like_a_Coder.pptx` (20 slides)
**Companion tutor:** `assistants_per_lecture/01_intro_setup_thinking_tutor.md`
**Companion demo:** `demos/01_the_hook.py` (run from the repo root)
**Student handout:** `handouts/install_guide.md`

---

## ⚠ Read this first — the shape of this session changed

**No pre-work install instructions were sent out this year.** Assume nobody
arrives with Python, R, VS Code, or RStudio on their laptop.

So Session 1 is **install-led**: minutes 12–40 are a guided, everyone-together
install, and the tutor activity moves out of class and becomes homework due
before Session 2. The lecture content that survives in full is the hook demo,
the course contract, and decomposition — which is the right set, because
decomposition needs no working laptop.

Three consequences to hold onto while teaching:

- **Downloads before installers.** The first thing that happens at minute 12 is
  everyone starting all four downloads at once. On classroom wifi the download
  is the slow part; the tool tour is what you do *while* they run.
- **A half-finished room is the expected outcome**, not a failure. Slide 13 is
  the escape hatch — say out loud that nothing after minute 40 needs a laptop.
- **Do not debug individual machines from the front.** The TA triages; you keep
  the room moving.

---

## Framing

Every student in this room will, at some point this semester, ask ChatGPT to write code for them. That is fine. The problem is not *that* they use AI — it is that most first-time programmers cannot tell whether the code the AI produced does what they need. This course exists to fix that. We are going to teach you how to *think* like a programmer, so that when you paste code out of an AI, you can look at it and know whether to trust it.

---

## Learning objectives

By the end of this session, students should be able to:

1. Install Python, VS Code, R, and RStudio on their own laptop, and run a one-line program in each of Python and R. (Realistically: *most* of the room. See the triage segment.)
2. State — in one sentence, in their own words — what a program *is*.
3. Take an English research question and break it into a numbered list of sub-tasks a computer could do.
4. Name one thing AI coding assistants are reliably good at, and one thing they are reliably bad at.

---

## Session outline

| Time     | Segment                                                        | Slides |
|----------|----------------------------------------------------------------|--------|
| 0–3      | Why this course exists (the AI honesty conversation)           | 1–2    |
| 3–9      | Live demo: code that ran and was still wrong                   | 3–4    |
| 9–12     | The course contract + roadmap                                  | 5–6    |
| 12–14    | **Start all four downloads**                                   | 7      |
| 14–18    | Tool tour — delivered *while* the downloads run                | 8      |
| 18–34    | Guided install: Python → VS Code → R → RStudio                 | 9–11   |
| 34–38    | Hello world in both languages — the install checkpoint         | 12     |
| 38–40    | Triage: who is stuck, and what happens to them                 | 13     |
| 40–48    | Decomposition (whiteboard)                                     | 14–15  |
| 48–53    | What AI is (and isn't) good at; the verify loop                | 16–17  |
| 53–55    | Handoff: the tutor activity, now homework                      | 18–20  |

---

## Segment 1 (0–3 min): Why this course exists

Talking points:

- The old version of this course taught syntax. That is now free — an LLM will produce syntactically valid Python in a second. So teaching syntax is no longer the job.
- The new job is teaching the *logic* underneath the syntax, because that is what an LLM cannot do reliably. LLMs are word-completion engines. They do not know what your data means. They will happily run a t-test on ordinal data.
- Corollary: **you** are the scientist. The code has your name on it. If an AI wrote a bug and the paper is wrong, that is your bug and your paper.
- One-sentence contract: *in this course we do not care whether you memorize syntax. We care whether you can read a block of code and tell us what it does and whether it is right.*

---

## Segment 2 (3–9 min): Code that ran and was still wrong — the demo

This is the hook, and it is the reason the rest of the hour has stakes. **Run it
live** — do not screenshot it:

```bash
python demos/01_the_hook.py
```

Sequence (the demo script is written in these three parts):

1. **PART ONE.** The code an AI hands you when you ask it to compare two groups.
   It runs. No error, no warning. `p = 0.2152` — "no significant difference."
   Ask the room: *would you write that up?* Take a show of hands. Most will say yes.
2. **PART TWO.** `df["group"].value_counts()` shows **three** categories, two of
   them displayed as `A`. Forty rows carry `"A "` with a trailing space — a second
   recruitment site — and `df["group"] == "A"` discarded every one of them.
   201 of 250 rows made it into the test.
3. **PART THREE.** One `.str.strip()` and the same test gives A = 129.4, B = 134.2,
   `p = 0.0064`. There *was* a difference. The first version threw it away.

The framing that matters: **the AI was not wrong.** It answered the question it
was asked; the question was under-specified. Catching this needs knowledge of the
data that is not in the code — and that knowledge is yours.

Say the words *false negative* out loud. A null result is the easiest place in
science for a silent error to hide, because nobody re-examines it.

Do not go deeper than this today. The nine missing `systolic` values, the
equal-variance assumption in `ttest_ind`, and effect size are Sessions 9 and 11.

---

## Segment 3 (9–12 min): The course contract

Two columns — what this course is, and what it isn't.

**It is:** the logic underneath the syntax · reading code critically · knowing
what to ask for in the right vocabulary · knowing how to check an answer ·
owning the analysis that carries your name.

**It isn't:** memorizing function signatures · a ban on AI · a software
engineering course · a statistics course · a course you can pass by pasting.

State the success criterion in the syllabus's own words: *not "can you write code
from scratch," but "can you look at a block of AI-generated code and explain what
it does, whether it is correct, and how you would fix it."* That is also the
format of the final project write-up.

Then the corollary, which takes ten seconds and is the ethical core of the
course: **you are the scientist. The code has your name on it. If an AI wrote a
bug and the paper is wrong, that is your bug and your paper.**

---

## Segment 4 (12–14 min): Start all four downloads

Nothing else happens until this does. Put the Brightspace links page on the
projector *before* you explain anything, and say it in this order:

1. Go to Brightspace, Session 1.
2. Click all four download links. All of them, now.
3. **Do not run anything yet.** We are only getting the files coming down.
4. Come back to me.

| | Link | Size |
|---|---|---|
| **Python 3.11+** | https://www.python.org/downloads/ | ~30 MB |
| **VS Code** | https://code.visualstudio.com/ | ~100 MB |
| **R** | https://cran.r-project.org/ | ~90 MB |
| **RStudio Desktop** | https://posit.co/download/rstudio-desktop/ | ~250 MB |

Walk the room for sixty seconds and confirm downloads are actually moving.
Anyone whose wifi is dead gets paired with a neighbour — do not troubleshoot
networking, you will lose the hour.

**If the room's bandwidth collapses**, stagger it: back half starts R and
RStudio, front half starts Python and VS Code, then they swap.

GitHub Copilot is **not** part of today. It needs a GitHub account and .edu
student verification, and it will eat ten minutes you do not have. It is on the
homework slide.

---

## Segment 5 (14–18 min): Tool tour — while the downloads run

This is the same tool tour as always; it just has a new job, which is to use
download time productively. Four minutes maximum, and watch the progress bars
rather than the clock — if downloads finish early, cut it short and start
installing.

Walk through each tool and *what problem it solves*:

| Tool             | What it is                                                             | When you use it                                   |
|------------------|------------------------------------------------------------------------|---------------------------------------------------|
| Python           | The interpreter (the thing that runs `.py` files)                      | Anywhere you run Python code                      |
| R                | The interpreter for R                                                  | Anywhere you run R code                           |
| VS Code          | A text editor. That is all.                                            | Writing/editing Python files, notebooks           |
| RStudio          | An editor + console + plot pane + package manager built for R          | Writing/editing R scripts, everything R           |
| Jupyter notebook | A document that mixes code, its output, and prose                      | Exploratory analysis, sharing analysis narratives |
| Copilot          | An AI that autocompletes code                                          | While you are typing, in either editor            |
| ChatGPT / Claude | An AI conversation partner                                             | Asking "how do I do X" or "why is this broken"    |

Two confusions to name explicitly here, because they cost the most later:
**Python is not VS Code** (the interpreter is the engine, the editor is the
dashboard, and any dashboard can sit in front of the engine), and **Copilot is
not ChatGPT** (one is autocomplete, the other is a conversation).

---

## Segment 6 (18–34 min): The guided install

Install on the projector, at the room's pace, in this order. The order is not
arbitrary: **R must be installed before RStudio.**

### 18–23 — Python (slide 9)

The whole segment is one checkbox. On Windows, **"Add python.exe to PATH"** is
at the bottom of the installer's first screen, in small text, unticked by
default. Say it twice. Missing it is the single most common cause of a broken
Session 2.

Verify with `python --version` (Windows) or `python3 --version` (macOS). Any
3.11 or newer is fine — tell them not to chase the latest.

macOS has nothing to get wrong, so send Mac users ahead to VS Code while you
work the Windows room.

### 23–27 — VS Code (slide 10)

Accept the defaults. Then two extensions, **both published by Microsoft**:
Python and Jupyter. Make them check the publisher line — there are lookalikes.

This is the moment to land the confusion from the tool tour, concretely:
*installing VS Code did not install Python.*

Anyone finished early should be helping a neighbour. Say it out loud — it
genuinely halves this block.

### 27–34 — R, then RStudio (slide 11)

R first, accepting every default. Do not open R itself; there is nothing to see
and it invites questions you do not have time for.

RStudio second, and only once R has finished. RStudio installed first will
launch and announce that it cannot find R — which reads as catastrophic to a
beginner and is a thirty-second fix.

RStudio is the 250 MB download. Anyone who has not started it will not finish in
class; tell them that now, not at minute 34.

**Hard stop at 34**, wherever the room is.

---

## Segment 7 (34–38 min): Hello world — the install checkpoint

Everyone types both lines on their own machine. This is the verification, not
just a demo.

```python
# in a new file hello.py
print("hello, research")
```

```r
# in a new .R script
print("hello, research")
```

Point out: **the code is essentially the same.** Both languages are giving one
command — "run the `print` function on the string `hello, research`." The
differences between Python and R are 90% cosmetic. The concepts we teach in this
course transfer.

Do it on the projector in three places: a `.py` file in VS Code, a Jupyter cell,
and an `.R` script in RStudio. Ninety seconds.

Deliberately make one typo (`prnt`) and show the error: *"you will see a lot of
these; they are not a sign that you are bad at this."*

Walk the room. This is where you find out who is actually working — note names
and hand them to the TA.

Then the 60-second checkpoint on the slide: **in one sentence, what is a
program?** Take two answers out loud and do not correct them.

---

## Segment 8 (38–40 min): Triage

Two minutes, and they are the most important two minutes for the students who
are struggling.

Say the second half slowly and mean it: **nothing else today needs a laptop.** A
student whose install failed is, right now, deciding whether this course is for
them. Do not let anyone leave believing they are behind on day one.

- Hands up if it is not working. The TA takes names; you keep the room moving.
- Write down where you got to, so you can pick it up tonight.
- The written guide on Brightspace (`handouts/install_guide.md`) has every step.
- Study hall is **Monday 10:00–11:00, Light Hall 439** — bring the broken laptop.
- If you fix only one thing tonight, make **Python** run. Session 2 is Python;
  R can wait a week if it has to.

Then: "laptops closed." The decomposition segment is better without screens.

---

## Segment 9 (40–48 min): Decomposition — the actual skill

This is the load-bearing segment. Say it out loud: *the hard part of programming is not the code. The hard part is turning a research question into a sequence of unambiguous steps.*

Live example. Take this research question:

> *"Is average blood pressure different between patients on drug A versus drug B?"*

Ask the room: what are the steps? Write them on the board as students call them out. Aim for something like:

1. Get the data (from a file, a database, wherever).
2. Look at the data — how many patients, what columns, any missing values?
3. Split the patients into a Drug A group and a Drug B group.
4. Compute the mean blood pressure of each group.
5. Ask whether the difference is bigger than we'd expect from chance (a statistical test).
6. Report the result — a number and a plot.

Now the reveal: **each of those steps is a chunk of code we will write this semester.** Step 1 is Session 6–7 (reading files, dataframes). Step 2 is Session 9 (EDA). Step 3 is Session 8 (filtering). Step 4 is Session 7 (summaries). Step 5 is Session 11 (stats). Step 6 is Session 10 (viz). The syllabus *is* the decomposition of a research analysis.

Emphasize the meta-point: **when a student asks an AI "analyze my data," the AI has to guess all six of those steps.** When a student who has taken this course asks the AI, they specify step 3 or step 5 with the right vocabulary and get the right answer. That is the entire value proposition of learning to code in the AI era.

Also say out loud: **step 2 is exactly where the trailing-space bug from the demo
would have been caught.**

> **Cut from the in-class deck.** The second decomposition question (20,000
> genes across 100 tumour and 100 healthy samples) used to run here as a pairs
> exercise. The install block took its time. It survives as **Problem 4 of the
> tutor activity**, which students now do as homework — so do not try to squeeze
> it back in. If the room is somehow ahead of schedule, ask it verbally rather
> than reinstating the exercise.

---

## Segment 10 (48–53 min): What AI is and is not good at

Two-column list on the board:

**AI is reliably good at:**
- Boilerplate (imports, plot styling, argument parsing)
- Syntax you forgot ("how do I open a CSV in pandas")
- Explaining unfamiliar code line by line
- Suggesting library names
- Refactoring code you already understand

**AI is unreliable at:**
- Anything requiring knowledge of *your* data
- Choosing the right statistical test
- Catching that a column is stored as a string when it should be a number
- Knowing whether a p-value is meaningful for your design
- Small numerical errors (off-by-one, log vs log10, degrees vs radians)
- Package hallucinations (inventing functions that don't exist)

Name the pattern in the bottom bar of the slide: **everything on the good list is about the *form* of the code. Everything on the bad list is about the *meaning* of your data.** AI has read every line of code ever written. It has never seen your spreadsheet.

### The verify loop (31–33 min) — name it, it recurs weekly

Corollary: **you must always verify.** Concretely, four steps:

1. **Expect** — before running, say what the output should look like. Roughly how big? What shape? What sign?
2. **Run** — actually execute it. Never reason about code you have not run.
3. **Compare** — does it match what you expected? If not, which one of you is wrong?
4. **Explain** — can you say line by line why it produced that? If not, you do not own it yet.

If you have no expectation, you are not doing science, you are doing typing.

**Step 1 is the one they will skip, and it is the only one that catches a silent
error** — like the one that opened the class. This loop reappears in every tutor
activity all semester and on the Unit 1 cheat sheet, so name it now.

---

## Segment 11 (53–55 min): Handoff — the tutor activity

**The activity is homework this week.** The install block took the 35–55 slot.
Say that as a plan, not an apology.

Introduce the tutor (link on Brightspace) and explain the rules now, because you
will not be in the room when they hit them — students who are not warned that
the tutor refuses to hand over code get frustrated and rate it badly:

- The tutor will *not* give you code. It asks questions. That is deliberate and it will not budge — frame it as respect, not obstruction.
- Full participation credit comes from engaging with the tutor's questions, not from getting the "right" answer. Paste the transcript as-is, including anywhere you went in circles.
- Twenty minutes. Paste the transcript to Brightspace **before Session 2**.

The tutor covers six problems in 20 minutes: hello world in both languages ·
what a program is · two decomposition problems · an AI reality check · the code
that ran and was still wrong. Problems 3 and 6 are the protected ones.

Point them at the vocabulary slide (19) — the tutor sends students back to it by
name, and it is on Brightspace.

Tell the students whose installs failed to **do the tutor anyway**. Only its
first problem needs a working laptop; everything else is a conversation.

Source: `assistants_per_lecture/01_intro_setup_thinking_tutor.md`.

---

## Key vocabulary introduced this session

- **Program / script** — a text file the interpreter reads and executes top to bottom.
- **Interpreter** — the software that reads code and does what it says (`python`, `R`).
- **Editor** — the software you type code in (VS Code, RStudio).
- **REPL** — Read-Eval-Print Loop. The interactive prompt.
- **Notebook** — a document mixing code cells and prose (Jupyter, Quarto).
- **Decomposition** — breaking a question into steps small enough to code.

---

## Common student mistakes to preempt

- Confusing "Python the language" with "VS Code the editor." (You can edit Python in any text editor.)
- Thinking Copilot is the same as ChatGPT. (Copilot autocompletes as you type; ChatGPT is a chat.)
- Assuming a program that runs is a program that is correct. It is not.
- Copy-pasting AI code without ever reading it.

---

## Before you go — assign at slide 20

**Required — a heavier week than planned, and worth saying so honestly:**

- Finish your installs. `handouts/install_guide.md` has every step from class.
- Run `handouts/check_setup.py` and `check_setup.R` and fix whatever they name.
- Do the Session 1 tutor activity and post the transcript. This is your participation grade.
- Set up Copilot: create a GitHub account, apply for student access, then install the extension in VS Code (and RStudio: Tools → Global Options → Copilot).
- Take the pre-test on Brightspace. (Graded on completion, not correctness.)

**Start thinking about the project:**

- Choose a dataset by Session 4 (09/17); register it on Brightspace by Session 6 (10/01).
- Dataset options are on the course research guide and in the syllabus.
- The best option by far is data you already have, or already want.

**Next week — Session 2 (09/03):** variables and types, where most of your bugs
will come from, including how to read a `TypeError` traceback without panicking.

---

## Exit ticket

*In one sentence: what is a program?* — run as the 60-second checkpoint on slide
12 rather than at the very end, since the last two minutes are the handoff.

A second one worth collecting on the way out, given the day: *what is still not
installed on your laptop?* It tells you exactly what Monday's study hall is for.
