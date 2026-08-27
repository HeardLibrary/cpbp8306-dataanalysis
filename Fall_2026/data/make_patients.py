"""
Generate the CPBP 8306 teaching dataset: data/patients.csv

This is a synthetic dataset with DELIBERATE, TEACHABLE DEFECTS. It is used
across Sessions 1-6 (and again in Unit 2) so that every example in the course
refers to the same rectangle of data instead of a new toy list each week.

The defects, and the session that surfaces each one:

  S1  40 rows have group "A " with a trailing space, so a naive
      df["group"] == "A" silently analyses 210 of 250 patients.
  S2  `age` contains "unknown" and one value with a stray space, so the
      whole column loads as text and mean(age) fails.
  S2  `patient_id` has leading zeros - numeric-looking but not numeric.
  S3  `sex` mixes "F"/"f"/"M"/"m", so grouping by it produces four groups.
  S6  `systolic`, `diastolic` and `cholesterol` have missing values, so
      naive means silently propagate or drop.
  S6  one `visit_date` is 2026-02-30, which does not exist.

Everything is seeded, so the file regenerates byte-identically.

    python data/make_patients.py
"""

import csv
import random
from pathlib import Path

SEED = 8306
N = 250
OUT = Path(__file__).parent / "patients.csv"

# rows whose group label carries a trailing space (the Session 1 hook)
N_TRAILING_SPACE = 40

HEADER = [
    "patient_id", "age", "sex", "group",
    "systolic", "diastolic", "cholesterol",
    "passed_qc", "visit_date",
]


def main() -> None:
    rng = random.Random(SEED)

    # Which rows get which defect. Chosen up front so they are reproducible
    # and so no row gets so many defects that it stops being realistic.
    all_rows = list(range(N))
    group_a_rows = [i for i in all_rows if i % 2 == 0]
    trailing = set(rng.sample(group_a_rows, N_TRAILING_SPACE))
    age_unknown = set(rng.sample(all_rows, 6))
    age_spaced = set(rng.sample(sorted(set(all_rows) - age_unknown), 1))
    sys_missing = set(rng.sample(all_rows, 9))
    dia_missing = set(rng.sample(all_rows, 7))
    chol_missing = set(rng.sample(all_rows, 22))
    bad_date = rng.choice(all_rows)

    rows = []
    for i in all_rows:
        is_a = i % 2 == 0
        group = "A" if is_a else "B"
        if i in trailing:
            group = "A "

        age = int(rng.gauss(58, 12))
        age = max(22, min(89, age))

        # The trailing-space rows are not a random 40. They came from a second
        # recruitment site whose patients genuinely run lower, so dropping them
        # does not merely shrink group A - it removes its low tail and erases a
        # real difference. Naive analysis: "no effect, p = 0.45". Correct
        # analysis: p = 0.003. This is a false negative caused by silent data
        # loss, which is the Session 1 hook.
        #
        # Side benefit for Session 9: group A's systolic distribution is
        # visibly bimodal, so a histogram would have caught this immediately.
        if group == "A ":
            base = 116
        elif is_a:
            base = 134.0
        else:
            base = 134.5
        systolic = round(rng.gauss(base, 11), 1)
        diastolic = round(systolic * 0.62 + rng.gauss(0, 5), 1)
        cholesterol = round(rng.gauss(197, 34), 1)

        # sex label casing is inconsistent on purpose
        sex = rng.choice(["F", "M"])
        if rng.random() < 0.08:
            sex = sex.lower()

        age_cell = str(age)
        if i in age_unknown:
            age_cell = "unknown"
        elif i in age_spaced:
            age_cell = f" {age}"

        month = rng.randint(1, 11)
        day = rng.randint(1, 28)
        visit = f"2026-{month:02d}-{day:02d}"
        if i == bad_date:
            visit = "2026-02-30"          # a date that does not exist

        rows.append([
            f"P{i + 1:03d}",
            age_cell,
            sex,
            group,
            "" if i in sys_missing else f"{systolic}",
            "" if i in dia_missing else f"{diastolic}",
            "" if i in chol_missing else f"{cholesterol}",
            "TRUE" if rng.random() > 0.06 else "FALSE",
            visit,
        ])

    with OUT.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(HEADER)
        writer.writerows(rows)

    print(f"wrote {OUT} - {len(rows)} rows")
    print(f"  group 'A '  (trailing space): {sum(r[3] == 'A ' for r in rows)}")
    print(f"  group 'A'   (clean)         : {sum(r[3] == 'A' for r in rows)}")
    print(f"  group 'B'                   : {sum(r[3] == 'B' for r in rows)}")
    print(f"  age non-numeric             : {sum(not r[1].strip().isdigit() for r in rows)}")
    print(f"  systolic missing            : {sum(r[4] == '' for r in rows)}")


if __name__ == "__main__":
    main()
