"""
CPBP 8306 - environment check.

Run this after Session 1, once you have worked through the install guide.
It tells you what is working and what is missing, and changes nothing on
your computer.

    python handouts/check_setup.py

If a line says MISSING, the fix is printed right underneath it. If you are
stuck for more than ten minutes, stop - bring it to study hall or to the TA
rather than losing an evening to it.
"""

import importlib
import shutil
import subprocess
import sys

OK, BAD = "  ok   ", "MISSING"

# package import name -> (pip name, why the course needs it, session)
PACKAGES = {
    "pandas":     ("pandas",            "dataframes",              "7"),
    "numpy":      ("numpy",             "vectorised arrays",       "4"),
    "matplotlib": ("matplotlib",        "plotting",               "10"),
    "scipy":      ("scipy",             "statistical tests",      "11"),
    "sklearn":    ("scikit-learn",      "machine learning",       "12"),
    "seaborn":    ("seaborn",           "statistical graphics",   "10"),
    "jupyter":    ("jupyter",           "notebooks",               "1"),
}

problems = []


def report(status, label, detail=""):
    print(f"[{status}] {label}{('  - ' + detail) if detail else ''}")


print("=" * 66)
print("CPBP 8306 environment check")
print("=" * 66)

# ---------------------------------------------------------------- Python
print("\nPython")
v = sys.version_info
if (v.major, v.minor) >= (3, 11):
    report(OK, f"Python {v.major}.{v.minor}.{v.micro}")
else:
    report(BAD, f"Python {v.major}.{v.minor}.{v.micro}", "the course needs 3.11 or newer")
    problems.append("Install Python 3.11+ from https://www.python.org/downloads/")

print(f"        interpreter: {sys.executable}")

# -------------------------------------------------------------- packages
print("\nPython packages")
for module, (pip_name, why, session) in PACKAGES.items():
    try:
        importlib.import_module(module)
    except ImportError:
        report(BAD, f"{module:<12}", f"needed for {why} (Session {session})")
        problems.append(f"pip install {pip_name}")
    else:
        report(OK, f"{module:<12}", why)

# --------------------------------------------------------------- R + Git
print("\nOther tools")

for exe, label, fix in [
    ("R",    "R interpreter", "Install R from https://cran.r-project.org/"),
    ("git",  "Git",           "Install Git from https://git-scm.com/downloads"),
]:
    path = shutil.which(exe)
    if path:
        try:
            out = subprocess.run([exe, "--version"], capture_output=True,
                                 text=True, timeout=20).stdout.strip().splitlines()
            report(OK, f"{label:<14}", out[0] if out else path)
        except Exception:
            report(OK, f"{label:<14}", path)
    else:
        report(BAD, f"{label:<14}", f"not found on your PATH")
        problems.append(fix)

# ---------------------------------------------------------------- summary
print("\n" + "=" * 66)
if problems:
    print(f"{len(problems)} thing(s) to fix:\n")
    for p in dict.fromkeys(problems):        # de-duplicated, order preserved
        print("   " + p)
    print("\nIf several Python packages are missing, one command does them all:")
    print("   pip install pandas numpy matplotlib scipy scikit-learn seaborn jupyter")
    print("\nStill stuck after ten minutes? Stop, and bring it to study hall -")
    print("Mondays 10:00-11:00, Light Hall 439 - or ask an instructor or the TA.")
else:
    print("Everything checks out. Nothing to do - see you in class.")
print("=" * 66)
