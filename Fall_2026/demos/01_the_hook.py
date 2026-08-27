"""
Session 1, slides 3-4 - "Syntax is free now" / "It ran. It was still wrong."

Run this live. The numbers printed here are the numbers on the slides.

    python demos/01_the_hook.py

Teaching sequence:
  1. Show only PART ONE. Let them see a clean p-value and no error.
  2. Ask: "are we done? would you write this up?"
  3. Then run PART TWO and let the group counts land.
  4. Then PART THREE - the corrected analysis.
"""

import pandas as pd
from scipy import stats

DATA = "data/patients.csv"


def rule(title):
    print("\n" + "=" * 62)
    print(title)
    print("=" * 62)


# --------------------------------------------------------------- PART ONE
# Exactly what an AI hands you when you ask it to compare two groups.

rule("PART ONE - the code the AI wrote")

df = pd.read_csv(DATA)

group_a = df[df["group"] == "A"]["systolic"].dropna()
group_b = df[df["group"] == "B"]["systolic"].dropna()

t, p = stats.ttest_ind(group_a, group_b)
print(f"group A mean: {group_a.mean():.2f} mmHg")
print(f"group B mean: {group_b.mean():.2f} mmHg")
print(f"p = {p:.4f}")
print("\n--> No significant difference. Do we write that up?")


# --------------------------------------------------------------- PART TWO
# The thing nobody looked at.

rule("PART TWO - what is actually in the group column?")

print(df["group"].value_counts())
print()
print("Note the repr - the quotes make the trailing space visible:")
print(sorted(repr(g) for g in df["group"].unique()))
print()
print(f"rows in the file      : {len(df)}")
print(f"rows in the analysis  : {len(group_a) + len(group_b)}")
print(f"rows silently dropped : {len(df) - len(group_a) - len(group_b)}")


# ------------------------------------------------------------- PART THREE
# One line of cleaning changes the conclusion.

rule("PART THREE - the same test, done right")

df["group"] = df["group"].str.strip()

a = df[df["group"] == "A"]["systolic"].dropna()
b = df[df["group"] == "B"]["systolic"].dropna()

t2, p2 = stats.ttest_ind(a, b)
print(f"group A mean: {a.mean():.2f} mmHg   (n = {len(a)})")
print(f"group B mean: {b.mean():.2f} mmHg   (n = {len(b)})")
print(f"p = {p2:.4f}")
print("\n--> There WAS a difference. The first version threw it away,")
print("    and nothing errored, warned, or looked wrong.")
