"""
Session 8 demo: Data Wrangling, Cleaning, Joining, Reshaping (Python)

Every code snippet from the Session 8 slides, in slide order. Each block says what
the code does and what you should see, so you can check your own output against
the comments. The slides show the dplyr names for each function. This script uses
the pandas version of each one.

It uses the same three datasets as Session 7: penguins, patients and schools.
Nothing is made up.

Put these three files next to this script, then run:  python 08_wrangling_demo.py
    penguins.csv         Brightspace
    patients.csv         Brightspace
    schools_tibble.csv   Brightspace

Needs pandas (pip install pandas).
"""
import pandas as pd


def section(title):
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


# ---------------------------------------------------------------------------
# Slide 2: load the data
# ---------------------------------------------------------------------------
section("Slide 2: load the data")

penguins = pd.read_csv("penguins.csv")
# A CSV written from R has a row-number column that pandas calls "Unnamed: 0".
# This line drops it if it is there, and does nothing for a file without it.
penguins = penguins.loc[:, ~penguins.columns.str.startswith("Unnamed")]
patients = pd.read_csv("patients.csv")
schools = pd.read_csv("schools_tibble.csv")

print(penguins.shape)    # (344, 8) with the current file, which includes year
print(patients.shape)    # (250, 9)
print(schools.shape)     # (169, 35)


# ---------------------------------------------------------------------------
# Slide 4: six functions, one way each changes a table
# ---------------------------------------------------------------------------
# The slide calls them filter, select, mutate, arrange, group_by and summarise.
# pandas does the same six things with different names. Each line prints the
# size of the result, so you can see what changed: rows, columns, or both.
section("Slide 4: six functions (pandas names)")

df = penguins    # a short name, the same one the slide uses

# filter: keep the rows that match a condition.
# df.species == "Gentoo" gives True or False for every row. The square brackets
# keep the True rows. The rows go down and the columns stay the same.
gentoo = df[df.species == "Gentoo"]
print("filter   ", gentoo.shape)           # (124, 8)

# select: keep or drop columns. The columns go down and the rows stay the same.
two_cols = df[["species", "body_mass_g"]]
print("select   ", two_cols.shape)         # (344, 2)

# mutate: create or change a column. assign() adds one column and keeps every row.
with_kg = df.assign(kg=df.body_mass_g / 1000)
print("mutate   ", with_kg.shape)          # (344, 9)

# arrange: sort the rows. The size does not change, only the order.
# sort_values() sorts from smallest to largest. ascending=False flips it,
# which is what desc() does in R.
lightest_first = df.sort_values("body_mass_g")
print("arrange  ", lightest_first.shape, "lightest:", lightest_first.body_mass_g.iloc[0])   # (344, 8), 2700.0

# group_by: mark rows as belonging to groups. On its own it changes nothing you can
# see. It makes a GroupBy object that waits for the next step.
by_species = df.groupby("species")
print(type(by_species).__name__)           # DataFrameGroupBy

# summarise: collapse each group to one row. size() counts the rows in each group.
print(by_species.size())                   # Adelie 152, Chinstrap 68, Gentoo 124


# ---------------------------------------------------------------------------
# Slide 5: R has two pipes (R only)
# ---------------------------------------------------------------------------
# Slide 5 compares R's two pipes, |> and %>%. Python has no pipe operator. Method
# chaining plays the same role: each method works on the result of the line above.
# The next block is the pandas version of the pipeline.


# ---------------------------------------------------------------------------
# Slide 6: chain the functions and check the size after each step
# ---------------------------------------------------------------------------
section("Slide 6: a pipeline, one step at a time")

# In pandas, a pipeline is method chaining: one method per line, each one working
# on the result of the line above. The parentheses let the chain span lines.
result = (
    penguins
    .query("species == 'Adelie'")                  # filter: keep Adelie penguins
    .assign(kg=lambda d: d.body_mass_g / 1000)     # mutate: add body mass in kilograms
    .groupby("island")                             # group_by: one group per island
    .agg(mean_kg=("kg", "mean"))                   # summarise: one row per island
)
print(result.round(2))
# Biscoe 3.71, Dream 3.69, Torgersen 3.71. pandas skips missing values when it
# takes a mean, so there is no na.rm argument here.

# The same chain, run one step at a time, with the size printed after each step.
step1 = penguins.query("species == 'Adelie'")
step2 = step1.assign(kg=lambda d: d.body_mass_g / 1000)
step3 = step2.groupby("island").agg(mean_kg=("kg", "mean"))
print(penguins.shape, "->", step1.shape, "->", step2.shape, "->", step3.shape)
# (344, 8) -> (152, 8) -> (152, 9) -> (3, 1)
# mutate kept every row (152 in, 152 out). summarise collapsed each group to one
# row (152 in, 3 out). Printing the size after each step is how you catch the two
# getting mixed up.

# Verb order matters. In a chain, each step only sees what the step before it
# kept. Here the select step drops body_mass_g, so the filter step has nothing to test.
try:
    penguins[["species", "island"]].query("body_mass_g > 4000")
except Exception as err:
    print("wrong order:", type(err).__name__)      # UndefinedVariableError


# ---------------------------------------------------------------------------
# Slide 7: the payoff. Fix group and sex in patients.csv.
# ---------------------------------------------------------------------------
section("Slide 7: clean group and sex")

# Count first, before you change anything. Finding the problem is the real work.
print(patients.group.value_counts())     # B 125, A 85, "A " 40: three groups, not two
print(patients.sex.value_counts())       # M 119, F 112, m 10, f 9: four groups, not two

# The fix is one line per column.
# str.strip() removes spaces at the start and end of each value, so "A " becomes "A".
# str.upper() makes every letter uppercase, so "m" becomes "M".
patients["group"] = patients["group"].str.strip()
patients["sex"] = patients["sex"].str.upper()

# Count again to check the fix worked.
print(patients.group.value_counts())     # A 125, B 125: the 40 rows rejoined group A
print(patients.sex.value_counts())       # M 129, F 121


# ---------------------------------------------------------------------------
# Slide 8: decide what each missing value means
# ---------------------------------------------------------------------------
section("Slide 8: missing values")

# 1. "unknown" becomes NA. age loads as text because six rows say "unknown".
print(patients.age.dtype)                # object (text)
# errors="coerce" tells pandas to turn anything that is not a number into NaN
# (pandas' marker for a missing value), instead of stopping with an error.
patients["age"] = pd.to_numeric(patients["age"], errors="coerce")
print(patients["age"].dtype)             # float64
print(patients["age"].isna().sum())      # 6: the "unknown" rows are now missing values

# 2. Not offered. A middle school has no grade 9, so the cell is empty by design.
middle = schools[schools.school_level == "Middle School"]
print(middle.grade_9.isna().sum(), "of", len(middle))   # 31 of 31
# Filling these with 0 would say "zero students in grade 9". The truth is that
# the grade does not exist there, so leave them missing.

# 3. Not measured. Two penguins have no bill length and eleven have no sex.
print(penguins.bill_length_mm.isna().sum(), penguins.sex.isna().sum())   # 2 11

# pandas skips missing values when it takes a mean, unless you tell it not to.
print(penguins["bill_length_mm"].mean())                  # 43.92
print(penguins["bill_length_mm"].mean(skipna=False))      # nan
# R does the opposite: mean() returns NA unless you add na.rm = TRUE. In either
# language, skipping rows is a decision about your data. Ask whether the
# values are missing at random before you make it.


# ---------------------------------------------------------------------------
# Slide 9: two tables, one shared key
# ---------------------------------------------------------------------------
section("Slide 9: joins")

# Two small tables built from the penguins data. The slide calls them L and R.
# They share one key column, species, but only Adelie appears in both.
species_means = penguins.groupby("species", as_index=False).agg(
    mean_mass=("body_mass_g", "mean"), mean_bill=("bill_length_mm", "mean"))
L = species_means[species_means.species.isin(["Adelie", "Gentoo"])][["species", "mean_mass"]].round(0)
R = species_means[species_means.species.isin(["Adelie", "Chinstrap"])][["species", "mean_bill"]].round(1)
print(L)    # Adelie 3701, Gentoo 5076
print(R)    # Adelie 38.8, Chinstrap 48.8

# left join: every row of L. NaN where R has no match.
print(L.merge(R, on="species", how="left"))     # Adelie, Gentoo (bill is NaN for Gentoo)

# inner join: only the rows that match in both tables.
print(L.merge(R, on="species", how="inner"))    # Adelie only

# full join: every row from both tables. pandas calls it "outer".
print(L.merge(R, on="species", how="outer"))    # Adelie, Chinstrap, Gentoo (pandas sorts the keys; R lists Chinstrap last)

# pandas merge() uses an inner join when you leave how out. dplyr has no default:
# you choose left_join, inner_join or full_join by name.
print(len(L.merge(R, on="species")))            # 1, the inner join

# The sanity check: after every join, look at the row count.
island_means = penguins.groupby("island", as_index=False).agg(
    mean_mass=("body_mass_g", "mean")).round(0)                       # 3 rows
species_by_island = (penguins.groupby(["species", "island"], as_index=False)
                     .size().rename(columns={"size": "n"}))           # 5 rows
joined = island_means.merge(species_by_island, on="island", how="left")
print(len(island_means), "->", len(joined))     # 3 -> 5
print(joined)
# Biscoe and Dream each appear twice in species_by_island, so they appear twice
# in the result. More rows than the left table means the key repeats on the right.


# ---------------------------------------------------------------------------
# Slide 10: wide to long, the grade columns from Session 7
# ---------------------------------------------------------------------------
section("Slide 10: wide to long")

# The four high schools shown on the slide, in wide form.
four = ["Antioch High School", "Cane Ridge High School", "Glencliff High School", "Hillsboro High"]
wide4 = schools[schools.school_name.isin(four)][["school_name", "grade_9", "grade_10", "grade_11", "grade_12"]]
print(wide4)

# melt() makes the table long. id_vars stay as columns. Every column in
# value_vars becomes rows. var_name is the new column that holds the old column
# names, and value_name holds the numbers.
long4 = wide4.melt(id_vars="school_name", var_name="grade", value_name="students")
print(long4)                  # 16 rows: 4 schools x 4 grades
# melt lists the rows grade by grade. R's pivot_longer lists them school by
# school. The rows are the same, only the order differs.

# The same call on the whole file: all 15 grade columns.
grade_cols = schools.filter(like="grade_").columns
schools_long = (
    schools.melt(id_vars="school_name",
                 value_vars=grade_cols,
                 var_name="grade", value_name="students")
           .dropna(subset=["students"])        # drop grades a school does not offer
)
print(len(schools_long))                       # 868 rows, not 169 x 15
print(int(schools_long.students.sum()))        # 86527 students, the same total as male + female


# ---------------------------------------------------------------------------
# Slide 11: long to wide, a table a person can read
# ---------------------------------------------------------------------------
section("Slide 11: long to wide")

# value_counts() counts the penguins in each species and island combination.
# The result is long: one row per combination.
counts = penguins.value_counts(["species", "island"])
print(counts)

# unstack() moves the island level into columns. fill_value=0 fills the
# combinations that never occur, such as Gentoo on Dream.
print(counts.unstack(fill_value=0))
# Adelie 44, 56, 52 / Chinstrap 0, 68, 0 / Gentoo 124, 0, 0 (Biscoe, Dream, Torgersen)
# pivot() does the same job on a table that is already in long form.


# ---------------------------------------------------------------------------
# Try it yourself
# ---------------------------------------------------------------------------
# 1. Change how="left" to how="right" in the island join. Predict the row count first.
# 2. Remove .dropna(...) from the schools reshape. How many rows do you get now?
# 3. Add .round(2) to the island averages in the pipeline. What changes?
# 4. Run the group_by on slide 4 with "island" instead of "species".
