"""
Session 7 demo: Dataframes and Tidy Data (Python)

Every runnable snippet from the Session 7 slides, in slide order.

Put these three files next to this script, then run:  python 07_dataframes_tidy_demo.py
    penguins.csv         course data folder (Fall_2026/data)
    patients.csv         course data folder (Fall_2026/data)
    schools_tibble.csv   Brightspace

Needs pandas and numpy (pip install pandas numpy).
"""
import numpy as np
import pandas as pd


def section(title):
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


# ---------------------------------------------------------------------------
# Slides 1, 2 and 4: load the data, then look at it
# ---------------------------------------------------------------------------
section("Slides 1, 2, 4: load it, then look at it")

df = pd.read_csv("penguins.csv")
# A CSV written from R has a row-number column that pandas calls "Unnamed: 0".
# Drop it if it is there (this line does nothing for a file without it).
df = df.loc[:, ~df.columns.str.startswith("Unnamed")]
schools = pd.read_csv("schools_tibble.csv")

print(df.shape)        # (344, 8): the penguins file includes year
print(df.dtypes)       # each column's type
print(df.head())       # first 5 rows
df.info()              # types + missing, one call
print(df.describe())   # first EDA pass on the numeric columns

# ---------------------------------------------------------------------------
# Slide 5: column, row, cell
# ---------------------------------------------------------------------------
section("Slide 5: column, row, cell")

print(df["bill_length_mm"].head())            # a column
print(df[df.species == "Adelie"].head())      # rows matching a condition
print(df.loc[0, "bill_length_mm"])            # a cell, by name

# The boolean mask you already know from Sessions 3 and 4, on a plain array.
# (Example values, not course data.)
bp = np.array([128, 135, 142, 119, 150])
print(bp[bp > 130])                           # the values above 130
print((bp >= 140).sum())                      # how many are 140 or higher

# Positional access breaks the moment you filter. df.loc[1] is always the
# same penguin. The first row of a filtered frame is a different penguin.
females = df[df.sex.str.lower() == "female"]
print(df.iloc[0, 2], "<- first row of df")
print(females.iloc[0, 2], "<- first row after filtering (a different penguin)")
print(df.loc[1, "bill_length_mm"], "<- row label 1, same penguin either way")

# ---------------------------------------------------------------------------
# Slide 6: the reveal. What are the variables in this table?
# ---------------------------------------------------------------------------
section("Slide 6: messy vs. tidy")

messy = pd.DataFrame({
    "patient_id": ["P001"],
    "bp_2020": [130],
    "bp_2021": [128],
    "bp_2022": [125],
})
tidy = pd.DataFrame({
    "patient_id": ["P001", "P001", "P001"],
    "year": [2020, 2021, 2022],
    "bp": [130, 128, 125],
})
print(messy)           # the variable "year" is hiding in the column names
print(tidy)            # patient_id, year, bp: one variable per column

# ---------------------------------------------------------------------------
# Slide 7: three ways real tables break the rules (schools_tibble.csv)
# ---------------------------------------------------------------------------
section("Slide 7: schools_tibble.csv")

print(schools.shape)   # (169, 35)

# The four-school table on the slide comes from the high schools
high = schools[schools.school_level == "High School"][
    ["school_name", "grade_9", "grade_10", "grade_11", "grade_12", "mapped_location"]
]
print(high.head())

# 1. Headers that are values: one variable (grade) spread across 15 columns
grade_cols = [c for c in schools.columns if c.startswith("grade_")]
print(len(grade_cols))                                   # 15
print(schools[grade_cols].notna().sum().sum())           # 868 rows if made long, not 169 x 15
print(schools[grade_cols].sum().sum())                   # 86527 students across all grades
print((schools.male + schools.female).sum())             # 86527, the same total

# 2. Two values in one cell: latitude and longitude as one string
print(schools[["mapped_location", "latitude", "longitude"]].head(3))

# 3. NA that means "not offered"
print(schools.grade_pre_k_3yrs.isna().sum())             # 130 of 169 schools
middle = schools[schools.school_level == "Middle School"]
print(middle.grade_9.isna().sum(), "of", len(middle))    # all 31 middle schools have no grade 9

# school_year is a constant, not a violation
print(schools.school_year.unique())                      # ['18-19']

# ---------------------------------------------------------------------------
# Slide 8: column types and the traps you have already met
# ---------------------------------------------------------------------------
section("Slide 8: column types")

print(df.dtypes)       # check types in pandas

patients = pd.read_csv("patients.csv")
print(patients.dtypes)
print(patients.group.value_counts())                     # "A " (trailing space) is its own group: 40 rows
print((patients.age == "unknown").sum())                 # 6 rows, so age loads as text
print(round(patients.cholesterol.isna().mean() * 100, 1), "% of cholesterol is missing")  # 8.8

# One category, two labels in the schools file
print(schools.school_level.value_counts())               # Non-Traditional (5), Non-Traditional - Hybrid (2)
merged = schools.school_level.replace({"Non-Traditional - Hybrid": "Non-Traditional"})
print(schools.school_level.nunique(), "->", merged.nunique())   # 10 -> 9

# Categorical type, the pandas version of an R factor
df["species"] = df["species"].astype("category")
print(df.dtypes["species"])
