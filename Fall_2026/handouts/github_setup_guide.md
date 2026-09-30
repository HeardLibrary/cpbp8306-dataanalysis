# Getting your project onto GitHub

Everything from "I have a folder on my laptop" to "the code is on GitHub and I
can push to it." Follow this in order.

**The part that trips everyone up is authentication** — GitHub will *not* accept
your account password from the command line. Section 4 is the fix, and it is
the section to read first if you are already stuck.

Stuck for more than ten minutes? Stop. Bring it to **study hall, Mondays
10:00–11:00, Light Hall 439**, or flag an instructor or the TA. Do not lose an
evening to this.

---

## 0. Before you start — do these two things first

Both of these eat ten minutes if you leave them to the last moment.

1. **Create a GitHub account** at <https://github.com> and **verify your email
   address.** GitHub will not let you create a repository until the address is
   confirmed — check your inbox for the verification link.
2. **Check Git is installed.** In a terminal (Command Prompt, Terminal, or Git
   Bash):

```bash
git --version
```

You should see a version number. If you get "command not found," install Git
from <https://git-scm.com/downloads> and reopen the terminal.

---

## 1. Tell Git who you are — once per machine

Git stamps your name and email on every commit. Do this once and never again:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@vanderbilt.edu"
```

> **Note:** on a **public** repository this email is visible in your commit
> history. If you would rather it were not, GitHub can supply a no-reply
> address: Settings → Emails → "Keep my email addresses private", then use the
> `…@users.noreply.github.com` address it shows you.

---

## 2. Make the repository on GitHub

1. Sign in at <https://github.com> and click **New repository** (green button,
   or the `+` at top right).
2. **Name it to match your local folder.** If your folder is `bp-analysis`, name
   the repo `bp-analysis`.
3. **Private is fine** — and is the right default if your data is at all
   sensitive. You can add the instructors as collaborators later.
4. **Do NOT check "Add a README file."** You already have one locally, and
   having both creates a conflict that is annoying to untangle on day one.
   Leave "Add .gitignore" and "Choose a license" alone too.
5. Click **Create repository.**

GitHub now shows you a page of setup commands. Keep that tab open.

---

## 3. Connect your folder to it

In a terminal, `cd` into your project folder, then:

```bash
git init
git add .
git commit -m "initial project skeleton"
```

> **Write your `.gitignore` BEFORE that first commit.** It is far easier than
> repairing history later — see section 6.

Then connect the local folder to the GitHub repo and push. Use the URL from
*your* repository page, not the example below:

```bash
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO.git
git push -u origin main
```

Three notes on those commands:

- `git branch -M main` renames your branch to `main`. Older versions of Git
  create a branch called `master`, while GitHub expects `main` — this lines them
  up. Harmless if it is already `main`.
- `git remote add origin …` only happens once. `origin` is just a nickname for
  "the copy on GitHub."
- The `-u origin main` flags are only needed on the **first** push. After that,
  plain `git push` works.

**This is the step where authentication happens.** Keep reading.

---

## 4. Authentication — the part that actually blocks people

When you run `git push`, GitHub needs to know it is really you. **Your account
password will be rejected** — GitHub removed password authentication for Git
operations in 2021. You have two options.

### Option A — GitHub CLI (recommended)

Far smoother than managing tokens, and it handles everything for you.

1. Install the GitHub CLI from <https://cli.github.com>.
2. Run:

```bash
gh auth login
```

3. Answer the prompts:
   - *What account do you want to log into?* → **GitHub.com**
   - *What is your preferred protocol?* → **HTTPS**
   - *Authenticate Git with your GitHub credentials?* → **Yes**
   - *How would you like to authenticate?* → **Login with a web browser**
4. It shows you a one-time code. Copy it, press Enter, and your browser opens.
   Paste the code, approve the access, and return to the terminal.

That is it. `git push` will now work, and keep working.

### Option B — a personal access token

Use this if you cannot or would rather not install the CLI. A token is a long
string that acts as a password for Git only.

1. On GitHub: click your avatar → **Settings** → scroll to **Developer
   settings** (bottom of the left sidebar) → **Personal access tokens** →
   **Tokens (classic)**.
2. **Generate new token (classic).**
3. Fill in:
   - **Note:** something you will recognise, e.g. `CPBP 8306 laptop`
   - **Expiration:** 90 days is sensible. You will be asked to renew it.
   - **Scopes:** tick **`repo`**. That is the only one you need. Do not tick
     others "just in case."
4. **Generate token**, then **copy it immediately.** GitHub shows it exactly
   once; if you navigate away, you have to make a new one.
5. Run `git push`. When it asks for a **username**, enter your GitHub username.
   When it asks for a **password**, **paste the token.**

> **Treat the token like a password.** Do not paste it into a script, a
> notebook, a commit, or a chat with an AI assistant. If you ever paste one
> somewhere public, delete it on GitHub immediately and generate a new one.

### Will it remember?

Usually yes, after the first time:

- **Windows** — Git for Windows ships with Git Credential Manager, which stores
  it and often just opens a browser window for you instead of prompting at all.
- **macOS** — stored in the Keychain.
- **Linux** — you may be prompted every push. To cache it:
  `git config --global credential.helper store` (this writes the token to a
  plain file in your home directory, so only do it on a machine you control).

---

## 5. Check it worked

```bash
git status
```

Should say "Your branch is up to date with 'origin/main'" and "nothing to
commit, working tree clean."

Then **reload your repository page on github.com.** Your files should be there.
That is the real test — if you can see `README.md` in the browser, you are done.

---

## 6. Your `.gitignore` — write it before the first commit

Create a file called exactly `.gitignore` (the leading dot matters) in the top
level of your project. A reasonable starting point:

```gitignore
# operating system noise
.DS_Store
Thumbs.db

# Python
__pycache__/
*.pyc
.ipynb_checkpoints/
env/
venv/

# R
.Rhistory
.RData
.Rproj.user/

# secrets — never commit these
.env
*_secret*
*token*

# large or private data
data/raw/*.csv
```

**Never commit:** patient or otherwise identifiable data · API keys and
passwords · files over about 100 MB · files that change every time you run your
code.

> **Deleting a file in a later commit does not remove it from the history.** If
> you commit a private data file or an API key and push it, treat it as
> permanently exposed: rotate the key, and tell your PI. Cleaning it out of
> history properly is genuinely hard, which is why the `.gitignore` goes in
> first.
>
> **If your project involves real patient data, talk to an instructor before you
> create any repository — public or private.**

---

## 7. When something goes wrong

| What you see | What it means | What to do |
|---|---|---|
| `remote: Support for password authentication was removed` | You typed your account password | Section 4 — use `gh auth login` or a token |
| `Authentication failed for 'https://github.com/...'` | Wrong username, or an expired/mistyped token | Generate a fresh token, or run `gh auth login` |
| `fatal: not a git repository` | You are in the wrong folder | `pwd` to see where you are, then `cd` into your project |
| `error: remote origin already exists` | You ran `git remote add` twice | `git remote set-url origin <the-correct-url>` |
| `src refspec main does not match any` | No commits yet, or the branch is named something else | Commit first, then `git branch -M main` |
| `Updates were rejected because the remote contains work that you do not have` | You checked "Add a README" when creating the repo | `git pull origin main --allow-unrelated-histories`, resolve, push again |
| `Please tell me who you are` | First-time setup on this machine | Section 1 |
| `git: command not found` | Git is not installed | Section 0 |

---

## 8. Undoing things — the three you need, and the one to avoid

Problem Set 06 asks about these, and they are the reason Git is worth the setup.

### You broke a file and have not committed yet

```bash
git diff scripts/01_clean.py      # see exactly what changed
git restore scripts/01_clean.py   # throw the changes away, back to last commit
```

`git checkout -- scripts/01_clean.py` does the same thing. `restore` is the
newer, clearer spelling; `checkout` is what older tutorials, Stack Overflow, and
the final quiz use. Both work.

**This is the one that matters for AI-assisted work.** Commit *before* you paste
a large AI-generated edit, and this command is instant, total, guaranteed undo
if the rewrite breaks something.

### You want to undo a commit you already made

```bash
git log --oneline        # find the hash of the commit, e.g. a1b2c3d
git revert a1b2c3d       # makes a NEW commit that undoes that one
```

`revert` is safe. It does not erase anything — it adds a commit that reverses
the change, so the history stays honest and nothing is lost.

### The one to avoid

**Do not use `git reset --hard`.** You will see it recommended constantly online
and an AI assistant may well suggest it. It rewrites history and **permanently
destroys uncommitted work** — there is no undo for it, and it is the single most
common way beginners lose a day's work to Git.

If you find yourself about to run it, that is the moment to ask for help
instead. `git revert` almost always does what you actually wanted.

---

## What "done" looks like

- [ ] `git --version` prints a version number.
- [ ] Your name and email are set (`git config --global --list` shows them).
- [ ] A repository exists on github.com, named to match your folder.
- [ ] `git push` completes without asking for a password every time.
- [ ] You can see your `README.md` on the GitHub website.
- [ ] Your repo contains a `README.md`, a `.gitignore`, and at least one script.
- [ ] You have posted the repository URL to Brightspace.
