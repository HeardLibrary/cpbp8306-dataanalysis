# Session 6 — Git live demo script

The exact sequence for slide 10. **Rehearse this once before class** and do it
in a throwaway folder, never in your real course repo.

## Before class

```bash
mkdir /tmp/git-demo && cd /tmp/git-demo
```

On Windows Git Bash, `~/git-demo` works fine. Put one short script in it:

```bash
mkdir -p scripts data/raw
printf 'import pandas as pd\n\ndf = pd.read_csv("data/raw/patients.csv")\nprint(df.shape)\n' > scripts/01_clean.py
printf '# Git demo\n\nA throwaway project for Session 6.\n' > README.md
```

Have a second terminal open with the folder listed, and your editor showing
`scripts/01_clean.py`. The point of the demo is that students see the file
content change on screen.

## The demo

| # | Command | Say this while you type |
|---|---------|------------------------|
| 1 | `git init` | "This folder is now a repository. Nothing else changed." |
| 2 | `git status` | "Git can see the files but isn't tracking them yet — 'untracked'." |
| 3 | `git add .` | "Staged. Queued for the next snapshot, not saved yet." |
| 4 | `git commit -m "initial project skeleton"` | "*Now* it's saved. That's a permanent point I can return to." |
| 5 | *edit the script — add an outlier filter* | Type it live. Three or four lines. |
| 6 | `git status` | "Git noticed. It says 'modified'." |
| 7 | `git diff` | "Green is added, red is removed. This is your code review." |
| 8 | `git add scripts/01_clean.py` <br> `git commit -m "add outlier filter"` | "Second snapshot." |
| 9 | `git log --oneline` | "Two commits. This is the history of the project." |

## The part that actually sells Git

Now break it visibly. **Delete most of the file** in the editor and save.

```bash
git diff                            # "look how much red"
git restore scripts/01_clean.py     # or: git checkout -- scripts/01_clean.py
```

Switch to the editor. **The file is back.** Let that sit for a second.

Then say the line from slide 11:

> Commit before you paste AI-generated code. When the model rewrites half your
> script and it stops working, this is instant, total, guaranteed undo.

## The three questions students ask, every time

**"What if I commit something and then want to undo the commit?"**
`git revert <hash>` makes a new commit that undoes it. Safe, and keeps the
history honest. Do not teach `git reset --hard` to beginners — it destroys work.

**"What's the difference between `git restore` and `git checkout`?"**
None, for this use. `restore` is the newer, clearer spelling; `checkout` is
what older tutorials, Stack Overflow, and the final quiz use. Both work.

**"Do I have to use the terminal?"**
No. VS Code and RStudio both have Git panels that do all of this by clicking.
Teach the commands anyway — the concepts are the same and the error messages
are all written in terms of the commands.

## If it goes wrong live

- **`git: command not found`** — Git isn't installed. Keep going on the projector;
  the TA triages during the activity.
- **`please tell me who you are`** — first-time setup. Run:
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "you@vanderbilt.edu"
  ```
  Warn students this email becomes public in commits on a public repo.
- **`fatal: not a git repository`** — you're in the wrong folder. `pwd`, then `cd`.
  This is a good accidental lesson about working directories.
