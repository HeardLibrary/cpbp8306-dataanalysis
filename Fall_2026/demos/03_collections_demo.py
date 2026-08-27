"""
Session 3 - Collections and Indexing. Python side.

Run this ALONGSIDE demos/03_collections_demo.R, one section at a time, with
both consoles visible. The comparison IS the lesson.

    python demos/03_collections_demo.py
"""


def rule(title):
    print("\n" + "=" * 62)
    print(title)
    print("=" * 62)


# ------------------------------------------------- slide 5: build a list
rule("Lists")

bp = [117, 122, 141, 130, 118]
print(bp)
print("length:", len(bp))


# ------------------------------------ slide 6: Python refuses to coerce
rule("Python does NOT silently coerce")

mixed = [1, 2, "three"]
print(mixed, "-> stays mixed, each element keeps its own type")
print("types:", [type(x).__name__ for x in mixed])
print("\nCompare with R, which turns the whole thing into text without a word.")


# ------------------------------------------------ slides 7-9: indexing
rule("Indexing: Python counts from 0")

print("bp[0]  ->", bp[0], "  (first)")
print("bp[1]  ->", bp[1], "  (second)")
print("bp[-1] ->", bp[-1], "  <- the LAST one. In R this drops the first.")

print("\nbp[1:4] ->", bp[1:4], " (stop is EXCLUSIVE - indices 1,2,3)")
print("bp[:3]  ->", bp[:3], " (first three)")
print("bp[-2:] ->", bp[-2:], "      (last two)")
print("bp[:0]  ->", bp[:0], "           (empty - not an error!)")

print("\nWhy exclusive? So these two split the list with no overlap and no gap:")
print("  bp[:3] + bp[3:] ==", bp[:3] + bp[3:])
print("  and len(bp[1:4]) == 4 - 1 ==", len(bp[1:4]))


# ------------------------------------- slide 11: masks need numpy/pandas
rule("Boolean indexing needs numpy in Python")

print("Plain lists do not vectorise:")
try:
    print(bp >= 130)
except TypeError as e:
    print("  bp >= 130  -> TypeError:", e)
print("\n--> THIS is why numpy and pandas exist, and why Session 7 starts there.")

try:
    import numpy as np
except ImportError:
    print("\n(numpy not installed - skipping the vectorised half)")
else:
    arr = np.array(bp)
    print("\nWith numpy:")
    print("  arr >= 130       ->", arr >= 130)
    print("  arr[arr >= 130]  ->", arr[arr >= 130])
    print("  (arr >= 130).sum() ->", (arr >= 130).sum())
    print("\nIn R this works with no imports at all. Same idea, different packaging.")


# ------------------------------------------------------ slide 12: dicts
rule("Dicts - lookup by name, not position")

patient = {"id": "P042", "age": 61, "systolic": 141, "treated": True}

print('patient["age"]  ->', patient["age"])
patient["age"] = 62
print("after update    ->", patient["age"])
patient["dx"] = "HTN"
print("keys            ->", list(patient.keys()))

print("\nA dataframe row is essentially one of these. See you in Session 7.")
