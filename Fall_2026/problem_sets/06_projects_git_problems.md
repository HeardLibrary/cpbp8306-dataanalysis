# Problem Set 06 — Projects, Files, and Version Control

**Session:** 6 (Unit 1 — Foundations)
**Pairs with:** `demos/06_git_walkthrough.md`
**Use with:** `general_tutor_gpt.md`
**Time target:** ~20–25 minutes, worked through with the tutor

---

## Instructions for students

Paste this whole file into the Course Tutor and work through the problems together, in order. If you have Git installed, problems 2–3 are worth actually doing in a throwaway folder — ask the tutor to walk you through it live.

---

## Problems

1. **Relative paths.** A demo script reads data with `pd.read_csv("data/raw/patients.csv")`. Why is that a relative path, and why would `"/Users/yourname/Desktop/project/data/raw/patients.csv"` break the script on someone else's computer?

2. **The four commands, in order.** Put these in the order you'd use them to save a change you just made, and say in one phrase what each does: `git push`, `git commit -m "..."`, `git add .`, `git status`.

3. **Break it, then undo it.** You edit a script and delete most of its contents by accident, then save the file. What command shows you how much changed (`git diff`)? What command gets your last-committed version back? (There are two equivalent spellings from the lecture — name one.)

4. **Commit message quality.** Which is the better commit message: `"fix bug"` or `"add outlier filter"`? What tense/mood should a good commit message use?

5. **`.gitignore`.** Given these files — the raw patient-data CSV, `.DS_Store`, a Python analysis script, a file containing an API key — which should go in `.gitignore`, and why?

6. **When to commit.** You're about to paste a large ChatGPT-rewritten block into your analysis script. What should you do *right before* that, and why does `git restore` (or `git checkout --`) matter more once you've done it?

7. **The dangerous command.** Why does the lecture specifically warn against teaching `git reset --hard` to beginners, and recommend `git revert <hash>` instead if you need to undo a commit you already made?

---

## Coverage (for instructor reference)

| # | Concept |
|---|---------|
| 1 | Relative vs. absolute paths |
| 2 | The four core Git commands and their order |
| 3 | `git diff`, `git restore` / `git checkout --` |
| 4 | Commit message hygiene |
| 5 | `.gitignore` — what never to commit |
| 6 | Committing before large AI-assisted edits |
| 7 | `git revert` vs. `git reset --hard` |
