"""
Session 4 - Control Flow. Includes the timing comparison from slide 11,
which is far more persuasive run live than asserted on a slide.

    python demos/04_loops_demo.py
"""

import time


def rule(title):
    print("\n" + "=" * 62)
    print(title)
    print("=" * 62)


bp_list = [117, 122, 141, 130, 118]


# ------------------------------------------- slide 5: elif vs three ifs
rule("elif is not the same as another if")

def categorise_wrong(bp):
    if bp >= 140:
        category = "high"
    if bp >= 120:
        category = "elevated"
    if bp < 120:
        category = "normal"
    return category

def categorise_right(bp):
    if bp >= 140:
        return "high"
    elif bp >= 120:
        return "elevated"
    else:
        return "normal"

for bp in (145, 130, 110):
    print(f"bp={bp:>4}   three ifs: {categorise_wrong(bp):>8}"
          f"   |   elif: {categorise_right(bp):>8}")

print("\n--> With bp=145 the wrong version sets 'high', then OVERWRITES it.")
print("    No error. Just a wrong answer. 'high' is unreachable entirely.")


# ------------------------------------------- slide 7: the accumulator
rule("The accumulator pattern")

count_high = 0                    # initialise BEFORE
for bp in bp_list:
    if bp >= 140:
        count_high += 1           # update INSIDE
print("count_high =", count_high) # use AFTER


# ------------------------------------------ slides 9-10: vectorisation
rule("The same job, no loop")

print("comprehension :", sum(bp >= 140 for bp in bp_list))

try:
    import numpy as np
except ImportError:
    np = None
    print("(numpy not installed - skipping the vectorised half)")
else:
    arr = np.array(bp_list)
    print("numpy         :", (arr >= 140).sum())
    print("\nIn R this is simply:  sum(bp_list >= 140)")


# ------------------------------------------------ slide 11: the timing
if np is not None:
    rule("Why it matters: same answer, very different cost")

    N = 5_000_000
    rng = np.random.default_rng(8306)
    big = rng.normal(130, 15, N)
    big_list = big.tolist()

    t0 = time.perf_counter()
    loop_count = 0
    for x in big_list:
        if x >= 140:
            loop_count += 1
    t_loop = time.perf_counter() - t0

    t0 = time.perf_counter()
    vec_count = int((big >= 140).sum())
    t_vec = time.perf_counter() - t0

    print(f"rows                : {N:,}")
    print(f"for loop            : {loop_count:,} in {t_loop:6.3f} s")
    print(f"vectorised          : {vec_count:,} in {t_vec:6.3f} s")
    print(f"\n--> same answer, {t_loop / t_vec:.0f}x faster")
    print("    Now imagine running your analysis fifty times while you iterate.")
