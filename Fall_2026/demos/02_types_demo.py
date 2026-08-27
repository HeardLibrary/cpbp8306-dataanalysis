"""
Session 2 - Variables, Types, and Expressions.

Run the sections one at a time (or paste them into a REPL). Each section maps
to a slide. Predictions come BEFORE you run anything - that is the whole point.

    python demos/02_types_demo.py
"""

import pandas as pd


def rule(title):
    print("\n" + "=" * 62)
    print(title)
    print("=" * 62)


# ---------------------------------------------------- slide 5: assignment
rule("Assignment is a command, not a claim")

patient_id = 42
patient_id = patient_id + 1     # right side first, THEN store
print("patient_id =", patient_id)


# --------------------------------------------------- slide 8: check types
rule("The three-second habit: check the type")

for value in (42, "P042", True, 117.3):
    print(f"{value!r:>10}  ->  {type(value).__name__}")


# ----------------------------------------- slide 9: booleans are numbers
rule("Booleans are secretly numbers")

passed_qc = [True, False, True, True, False]
print("sum(passed_qc)              =", sum(passed_qc))
print("sum(passed) / len(passed)   =", sum(passed_qc) / len(passed_qc))
print("\n--> averaging true/false gives you a PROPORTION")


# --------------------------------------------- slide 10: the string traps
rule("String + string is not addition")

print('"5" + "3"  =', repr("5" + "3"))
try:
    print("5" + 3)
except TypeError as e:
    print('"5" + 3    -> TypeError:', e)
print("\n--> Python refuses to guess. That refusal is doing you a favour.")


# ------------------------------------------------ slide 11: predict first
rule("Predict before you run")

a, b, c, d = 5, "5", 5.0, True
print("a == c  ->", a == c, "   (5 equals 5.0)")
print("a == b  ->", a == b, "   <- no error. Just quietly False.")
print("d == 1  ->", d == 1, "   (booleans are numbers)")
print("b * 3   ->", repr(b * 3), " (string repetition)")


# --------------------------------------------------- slide 14: float trap
rule("Floats are approximate")

print("0.1 + 0.2        =", 0.1 + 0.2)
print("0.1 + 0.2 == 0.3 =", 0.1 + 0.2 == 0.3)
print("abs(0.1+0.2-0.3) < 1e-9 =", abs(0.1 + 0.2 - 0.3) < 1e-9)


# --------------------------------------- slide 15: a real traceback, live
rule("A real TypeError, on the real course data")

df = pd.read_csv("data/patients.csv")
print("dtype of the age column:", df["age"].dtype, " <- 'object' means TEXT")
print("\nWhy? Because of these values:")
print([v for v in df["age"].unique() if not str(v).isdigit()])
print("   (note the one with a leading space - it looks fine in Excel)")

print("\nSo this fails:")
try:
    print(df["age"].mean())
except TypeError as e:
    print("TypeError:", e)

print("\nRead it bottom-up. The bug is not on this line - it is upstream,")
print("in the six rows where age was never a number to begin with.")
