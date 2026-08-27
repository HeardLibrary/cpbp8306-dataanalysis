# Session 6 — Projects, Files, and Version Control

**Unit:** 1 (Foundations)
**Duration:** 30-minute lecture + 20-minute activity
**Companion tutor:** `assistants_per_lecture/06_projects_git_gpt.md`

---

## Framing

You now have all the language pieces to write real analysis code. This session is about the shape of the container that code lives in: a folder on your computer, structured predictably; a copy of that folder on GitHub, versioned so you can undo your mistakes and show your work. Every reproducibility crisis you have read about in science comes down to *someone lost track of which version of the code produced which figure.* We are going to fix that for your project.

---

## Learning objectives

Students should be able to:

1. Read a file from disk (CSV) into Python and into R.
2. Explain what a working directory is and why relative paths are preferred over absolute paths.
3. Structure a research project folder in a way another human could navigate.
4. Initialize a Git repository, stage/commit changes, and push to GitHub.
5. Read a `git log` to see what changed and when.
6. Recognize when they should commit (before AI rewrites everything).

---

## 30-minute outline

| Time     | Segment                                          |
|----------|--------------------------------------------------|
| 0–3      | Recap: functions                                 |
| 3–8      | Reading files; paths and working directories     |
| 8–14     | Project folder structure                         |
| 14–24    | Git: what it is and the four commands you need   |
| 24–30    | GitHub + when to commit + `.gitignore`           |

---

## Segment 1 (0–3 min): Recap

Ask: someone name a case where writing a function paid off. Reinforce.

---

## Segment 2 (3–8 min): Reading a file

Every analysis starts with data. Every dataset starts as a file.

```python
import pandas as pd
df = pd.read_csv("data/patients.csv")
df.head()
```

```r
library(readr)
df <- read_csv("data/patients.csv")
head(df)
```

Point out `"data/patients.csv"` is a **relative path**. It means "starting from wherever this script is running, go into the folder `data` and open `patients.csv`." Compare to an absolute path: `/Users/josh/Desktop/CPBP_2026/data/patients.csv` — which will *not* work on the TA's computer. Never hard-code absolute paths in a shared project.

The "wherever this script is running" is the **working directory**. Both `os.getcwd()` (Python) and `getwd()` (R) tell you where you are. In RStudio, projects (`.Rproj` files) set the working directory automatically. In VS Code with Jupyter, you can trip on this — the notebook's working directory is where the notebook file lives.

Rule: **use relative paths from the project root.** Always.

---

## Segment 3 (8–14 min): Project folder structure

Show a canonical layout and explain the reasoning:

```
your-project/
├── README.md              ← what is this? how do I run it?
├── .gitignore             ← files Git should ignore
├── data/
│   ├── raw/               ← original files, never edited
│   └── processed/         ← cleaned versions you produce
├── scripts/               ← .py or .R files
│   ├── 01_clean.R
│   ├── 02_eda.R
│   └── 03_stats.R
├── notebooks/             ← .ipynb for exploration
├── figures/               ← output plots
└── output/                ← everything else your code produces
```

Rules to state out loud:

1. **Never edit files in `data/raw`.** Ever. That is your source of truth. If you need to clean them, produce a *new* file in `data/processed`. Session 8 covers this.
2. **Number your scripts if they run in order.** `01_clean.R` before `02_eda.R`. This is documentation for future-you.
3. **A `README.md` is not optional.** If a stranger clones this repo, they need to know: (a) what is this project, (b) how to run it, (c) what data they need. Three paragraphs is enough.
4. **Figures and outputs are derived.** In principle you could delete `figures/` and regenerate it from the scripts. That is a good test — if you can't, your scripts aren't reproducible yet.

---

## Segment 4 (14–24 min): Git — the four commands you need

Draw the mental model on the board:

```
working directory   ---->   staging area   ---->   local repo   ---->   GitHub
  (your files)        add        (queued)     commit  (versioned)   push
```

Four commands is all you need for 90% of what this course requires:

```bash
git status                          # what's changed since last commit
git add .                           # stage all changed files
git commit -m "clean patient data"  # snapshot with a message
git push                            # send snapshot to GitHub
```

Live demo. Take a folder with one script and:

1. `git init` — turns the folder into a Git repo.
2. Make a change to the script.
3. `git status` — Git tells you the file is modified.
4. `git add scripts/01_clean.R` — stage that one file.
5. `git commit -m "add outlier filter"` — snapshot.
6. `git log` — show the history.
7. Make another change, break something on purpose.
8. `git diff` — Git tells you what changed since the last commit.
9. `git checkout scripts/01_clean.R` — restore the last committed version.

That last step is the whole point of Git: **you can always get back to a known-good version.** This matters *especially* in the AI era. When ChatGPT rewrites half your script and it stops working, `git checkout` is your undo button.

Commit-message hygiene:

- Present tense, imperative: "add outlier filter", not "added outlier filter" or "adding outlier filter."
- Short but informative. "fix bug" is useless. "fix mean-BP calculation to skip NA" is useful.
- One logical change per commit. Don't commit "clean data + change plot colors + fix typo" as one commit.

---

## Segment 5 (24–30 min): GitHub, `.gitignore`, when to commit

GitHub is *just a place to keep a copy of your Git repo on the internet*. It is not Git itself. It is Google Drive for code, with the addition that anyone can see it (if public), collaborate on it, and see the whole history.

Setup (one-time, on GitHub):

1. Sign in to https://github.com/.
2. New repo → give it a name matching your local folder.
3. Do NOT check "add README" — you'll conflict with your local repo.
4. Copy the `git remote add origin ...` command GitHub shows you.
5. Back in terminal: paste, then `git push -u origin main`.

`.gitignore` — a plain-text file listing patterns of files Git should ignore:

```
# .gitignore example
.DS_Store
__pycache__/
*.pyc
.Rhistory
.Rproj.user/
data/raw/*.csv          # don't commit raw data if it's private/big
env/
.env
*.log
```

Rule: **never commit** — patient data, API keys, huge files, or files that change with every run (like `.Rhistory`).

When to commit (a heuristic):

- Before you start a new feature or refactor. "Good state."
- **Before you paste an AI-generated block that touches more than a few lines.** If it breaks things, `git checkout` is instant undo.
- When you get something working — capture it.
- Before you close your laptop for the day.

Frequency: 3–10 commits per productive hour is normal for exploratory research code. Not one commit per week.

---

## Key vocabulary

- **Working directory** — the folder your interpreter thinks it's running in.
- **Relative path** — a file path starting from the working directory (not `/`).
- **Repository / repo** — a folder Git is tracking.
- **Commit** — a snapshot of the repo at a point in time.
- **Staging area** — the set of changes queued for the next commit.
- **`.gitignore`** — a file listing what Git should ignore.
- **Remote** — the online copy of your repo (GitHub, GitLab, etc.).
- **Push / pull** — send changes to the remote / get changes from the remote.

---

## Common student mistakes

- Hard-coding absolute paths, then wondering why the TA can't run their script.
- Committing raw patient data or API keys to a public GitHub repo. (Reversing this is *hard*.)
- Committing 100 MB files. GitHub has a size limit; use Git LFS or store data elsewhere.
- Committing once a week. If you AI-generate something huge and it breaks, you can only undo to a week ago.
- Editing files in `data/raw/`.

---

## Handoff to tutor activity

`assistants_per_lecture/06_projects_git_gpt.md` — the tutor walks students through a scenario: AI just refactored their whole script and something broke. What Git commands do they run to diagnose and recover?

---

## Milestone

**By end of Session 6:** every student should have a GitHub repository named for their project, committed a `README.md`, a `.gitignore`, and at least one script. Post the repo URL on Brightspace.
