"""
Session 5 - Functions and Modular Code.

The refactoring in PART ONE is much better PERFORMED than described. Start
with the duplicated version on screen and edit it into the function version
while they watch, narrating each decision ("what changes between the two
copies? that's a parameter").

    python demos/05_functions_demo.py
"""


def rule(title):
    print("\n" + "=" * 62)
    print(title)
    print("=" * 62)


group_a = [117, 122, 141, 130, 118, 155, 139]
group_b = [142, 128, 151, 133, 147, 121, 160]


# ---------------------------------------------- slide 2: the duplication
rule("PART ONE - what we are refactoring")

count_high = 0
for bp in group_a:
    if bp >= 140:
        count_high += 1
count_high_a = count_high

count_high = 0
for bp in group_b:
    if bp >= 140:
        count_high += 1
count_high_b = count_high

print(f"group A: {count_high_a}   group B: {count_high_b}")
print("\nSame logic twice. Change the threshold and you must remember BOTH.")
print("Fix a bug in one copy and forget the other, and you will never know.")


# ------------------------------------------------ slides 5-6: the function
rule("PART TWO - one definition, two calls")


def count_high_bp(bps, threshold=140):
    """
    Count how many blood pressure readings meet or exceed a threshold.

    Parameters
    ----------
    bps : list of numeric
        Systolic readings, in mmHg. Missing values are NOT handled.
    threshold : numeric, default 140
        Cutoff at or above which a reading counts as high.

    Returns
    -------
    int
        Number of readings >= threshold.
    """
    return sum(bp >= threshold for bp in bps)


print(f"group A: {count_high_bp(group_a)}   group B: {count_high_bp(group_b)}")
print(f"stricter cutoff: {count_high_bp(group_a, threshold=150)}")


# ----------------------------------- slide 15: the ten-second sanity test
rule("PART THREE - the test that costs ten seconds")

print("count_high_bp([100, 200])            ->", count_high_bp([100, 200]))
print("   expected 1                            ",
      "OK" if count_high_bp([100, 200]) == 1 else "WRONG")

print("count_high_bp([])                    ->", count_high_bp([]))
print("   expected 0 (empty input)              ",
      "OK" if count_high_bp([]) == 0 else "WRONG")

print("count_high_bp([140])                 ->", count_high_bp([140]))
print("   expected 1 (boundary: >= not >)       ",
      "OK" if count_high_bp([140]) == 1 else "WRONG")

print("\nThat boundary check is the one an AI gets wrong. '140 or above' vs")
print("'above 140' is a one-character difference and a real clinical one.")


# ------------------------------------------------- slide 8: return vs print
rule("Return, don't print")


def print_count(bps):
    print(sum(bp >= 140 for bp in bps))


x = print_count(group_a)      # prints, then returns nothing
print("x =", x, "  <- None. You cannot use it in the next line.")

y = count_high_bp(group_a)
print("y =", y, "     <- a number. You can keep working with it.")
print(f"      e.g. proportion high: {y / len(group_a):.2f}")


# ------------------------------------------------- slide 10: the global trap
rule("The global-variable trap")

threshold = 140


def count_high_fragile(bps):
    return sum(bp >= threshold for bp in bps)   # reads a global


print("count_high_fragile(group_a) =", count_high_fragile(group_a))

threshold = 120          # somebody changes this forty lines away
print("count_high_fragile(group_a) =", count_high_fragile(group_a),
      "  <- same call, different answer")
print("\nNo error. No warning. That is what an irreproducible result looks like.")
