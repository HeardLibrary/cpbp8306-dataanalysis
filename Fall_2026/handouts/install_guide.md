# CPBP 8306 — Getting your laptop set up

We install all four of these together in Session 1. This guide is the same
steps in writing, so you can finish at home if class ran out of time — which it
probably did, and which is completely normal.

**If you only get one thing working tonight, make it Python.** Session 2 is
Python. R can wait a week if it has to.

**Order matters in one place only: install R *before* RStudio.** Everything else
can be done in any order.

Stuck? Bring the laptop to study hall — **Mondays 10:00–11:00, Light Hall 439** —
or flag an instructor or the TA. Do not spend an evening fighting an installer.

---

## 0. Download all four first

Start all four downloads before you run any of them. The download is the slow
part, and they download happily in parallel.

| | Where | Size |
|---|---|---|
| Python | https://www.python.org/downloads/ | ~30 MB |
| VS Code | https://code.visualstudio.com/ | ~100 MB |
| R | https://cran.r-project.org/ | ~90 MB |
| RStudio Desktop | https://posit.co/download/rstudio-desktop/ | ~250 MB |

---

## 1. Python — the engine

Python is the thing that actually runs your code. It has no window of its own.

### Windows

1. Run the installer you downloaded.
2. **Stop on the first screen.** At the bottom there is a checkbox: **"Add
   python.exe to PATH."** It is unticked by default. **Tick it.**
3. Click **Install Now** and accept everything else.
4. Check it worked: open **Command Prompt** (press Start, type `cmd`) and type:

```bash
python --version
```

You should see something like `Python 3.13.2`. Any version 3.11 or newer is
fine — do not chase the newest one.

> **That checkbox is the single most common reason Week 2 does not work.** If
> you missed it, just run the installer again and tick it. Nothing is broken.

### macOS

1. Open the `.pkg` file you downloaded.
2. Continue → Agree → Install. There are no choices to make.
3. Enter your Mac password when it asks.
4. Check it worked: open **Terminal** (Cmd+Space, type `Terminal`) and type:

```bash
python3 --version
```

On a Mac the command is `python3`, not `python`. That is normal and not a
mistake on your part.

### When it goes wrong

| What you see | What it means |
|---|---|
| `'python' is not recognized...` | The PATH checkbox was missed. Re-run the installer and tick it. |
| The Microsoft Store opens instead | Same cause, same fix. |
| `command not found: python` on a Mac | You typed `python`. Try `python3`. |
| `Python 2.7.x` on an older Mac | That is the ancient built-in one, not yours. Use `python3`. |

---

## 2. VS Code — where you type

VS Code is a text editor. **Installing it does not install Python** — they are
two separate things, and this trips up nearly everyone in week one.

1. Run the installer and accept the defaults. On Windows, leave every checkbox
   ticked — especially "Add to PATH."
2. Open VS Code. You will get a Welcome tab. Ignore it.
3. Click the **Extensions** icon in the left-hand bar — the four little squares.
4. Search for **Python**. Install the one **published by Microsoft**.
5. Search for **Jupyter**. Install that one too, also **by Microsoft**.
6. Stop there. Extensions are a rabbit hole and you do not need any others.

> There are lookalike extensions with similar names. Check the publisher line
> says Microsoft, and that it has millions of downloads.

If VS Code asks you to "Select Interpreter," choose the Python 3.1x you just
installed.

---

## 3. R — the other engine

Same idea as Python: R is the thing that runs the code, and its own window is
plain and ugly. That is correct. You will not use it directly.

- **Windows:** run the `.exe` and accept every default.
- **macOS:** open the `.pkg` and click through.

There is nothing to configure, and you do not need to open it.

**Install R before RStudio.** If you have already installed RStudio, that is
fine — just install R now and then restart RStudio.

---

## 4. RStudio — where you type R

Only once R has finished installing.

1. Run the installer and accept the defaults.
2. Open RStudio. It finds R by itself.
3. You will see four panes. The bottom-left one is the **console** — that is
   where code runs.

### When it goes wrong

| What you see | What it means |
|---|---|
| RStudio says it cannot find R | You installed RStudio first. Install R, then restart RStudio. |
| You installed R but RStudio still cannot see it | Quit RStudio completely and reopen it. |

RStudio is **not** R. It is a dashboard bolted onto the R engine — the same way
VS Code is a dashboard for Python.

---

## 5. Check everything at once

Download `check_setup.py` and `check_setup.R` from Brightspace and run them.
They change nothing on your computer — they only report what is missing and
print the exact command that fixes it.

**Python check** — in VS Code, open `check_setup.py` and press the ▶ Run button.
Or from a terminal:

```bash
python handouts/check_setup.py
```

**R check** — open `check_setup.R` in RStudio and click **Source**.

The Python script will probably tell you a few packages are missing. Install
them all with one command:

```bash
pip install pandas numpy matplotlib scipy scikit-learn seaborn jupyter
```

On a Mac, if `pip` is not found, use `pip3` instead.

> Some of those packages are not needed until later in the semester, so do not
> panic if one fails. `pandas` and `numpy` are the ones that matter soon.

---

## 6. GitHub Copilot — do this last

Copilot is free for students, but it takes a few steps and it is not urgent.
Leave it until everything above works.

1. Create a GitHub account at https://github.com if you do not have one.
2. Apply for student access at https://education.github.com/students — you will
   need your Vanderbilt email address, and approval is not instant.
3. Once approved, in **VS Code**: Extensions → search **GitHub Copilot** →
   Install → sign in with your GitHub account.
4. In **RStudio**: Tools → Global Options → Copilot → enable, then sign in.

If your student application is still pending, that is fine. Nothing in the
course requires Copilot.

---

## What "done" looks like

You are finished when all four of these are true:

- [ ] `python --version` (or `python3 --version`) prints a 3.11+ version number.
- [ ] VS Code opens, with the Microsoft Python and Jupyter extensions installed.
- [ ] RStudio opens and shows four panes without complaining about R.
- [ ] `print("hello, research")` runs in both a `.py` file and an `.R` script.

That last one is the real test. Do it in both.
