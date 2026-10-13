"""
1_data_cleaning.py  |  Sessions 7 and 8, plus S02, S04 and S06 from 2025

This script shows how real data is loaded, inspected, subset, renamed, changed,
combined, reshaped, cleaned and saved. Parts 1 to 8 are labeled examples. Each
one starts from a fresh copy of the raw data, so you can run any part on its
own. Part 9 is the actual cleaning pipeline. It writes cleaned files to
data/clean/ and leaves data/raw/ untouched.

Contents
  Part 1  Inspect the data                       (Session 7)
  Part 2  Subset: pick columns, rows and cells   (Session 7, S02, S04)
  Part 3  Change column headings                 (S02, S04, S06)
  Part 4  Change values                          (Session 8, S04)
  Part 5  The six functions and method chaining  (Session 8, S04)
  Part 6  Missing values                         (Session 8, S02, S06)
  Part 7  Combine tables: concat and merge       (Session 8, S06)
  Part 8  Reshape: long and wide                 (Session 8, S06)
  Part 9  The cleaning pipeline and saving       (all of the above)

The rule for the whole script: raw data is read-only. Examples change copies.
The pipeline in Part 9 writes new files and never overwrites the originals.

The R version of this script uses dplyr names (filter, select, mutate...). The
pandas name for each one is shown next to it.

Needs these objects from main.py: patients_raw, penguins_raw, schools_raw,
and the imports np and pd.
"""
import os
import re

try:
    patients_raw
except NameError:
    raise SystemExit("Run main.py first. It loads the data this script uses.")


# Helpers -------------------------------------------------------------------
def section(title):
    """A heading for the printed output."""
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def show(table, label):
    """Print a one-line summary of a table's size, so you can see what a step did."""
    print(f"{label:<58} {table.shape[0]:>4} rows x {table.shape[1]:>2} columns")


def clean_names(data):
    """
    Turn messy column headings into tidy ones: lower case, underscores, no symbols.
    This is the same job as pyjanitor's clean_names(), written by hand (Lecture 5).
    """
    data = data.copy()
    data.columns = [re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_") for name in data.columns]
    return data


# =============================================================================
# PART 1: Inspect the data  (Session 7)
# =============================================================================
section("Part 1: inspect the data")

# Before you change anything, look. These commands answer: how big is it, what
# are the columns called, what type is each one, and what do the first rows look like?

# .shape gives (rows, columns).
print(penguins_raw.shape)                 # (344, 9): the 9th column is the row number
print(patients_raw.shape)                 # (250, 9)
print(schools_raw.shape)                  # (169, 35)

# .columns lists the column headings.
print(penguins_raw.columns.tolist())      # the first heading is "Unnamed: 0", an unnamed row number
print(patients_raw.columns.tolist())

# .info() shows one line per column: its type and how many values are not missing.
# This is where you spot the age column that loaded as text.
penguins_raw.info()
patients_raw.info()

# .head() and .tail() show the first and last rows (5 by default).
print(penguins_raw.head(3))
print(penguins_raw.tail(3))

# .describe() gives count, mean, spread and quartiles for numeric columns.
print(penguins_raw[["bill_length_mm", "body_mass_g"]].describe())

# .dtypes gives the type of every column in one line.
print(schools_raw.dtypes.head(8))


# =============================================================================
# PART 2: Subset: pick columns, rows and cells  (Session 7, S02, S04)
# =============================================================================
section("Part 2: subset columns, rows and cells")

penguins_demo = penguins_raw.copy()
schools_demo = schools_raw.copy()

# --- Columns -----------------------------------------------------------------
print(penguins_demo["species"].head().tolist())   # one column, by name (a Series)
show(penguins_demo[["species"]], "penguins_demo[['species']]  (double brackets, a table)")
show(penguins_demo[["species", "body_mass_g"]], "penguins_demo[['species', 'body_mass_g']]")
show(penguins_demo.iloc[:, 1:4], "penguins_demo.iloc[:, 1:4]  (by position, end excluded)")
show(penguins_demo.loc[:, "species":"body_mass_g"], "penguins_demo.loc[:, 'species':'body_mass_g']  (by name)")

# pandas can also pick columns by pattern or by type. (dplyr: select())
show(penguins_demo.filter(like="bill"), "filter(like='bill')  (select starts_with)")
show(penguins_demo.select_dtypes("number"), "select_dtypes('number')  (select where is.numeric)")
show(penguins_demo.iloc[:, 1:], "iloc[:, 1:]  (drop the first column)")
grade_range = schools_demo.loc[:, "grade_1":"grade_12"].columns
show(schools_demo.drop(columns=grade_range), "drop(columns=grade_1 to grade_12)  (drop a range)")

# Reorder columns: name the ones you want first, then all the others.
first = ["school_name", "zip_code", "school_level"]
reordered = schools_demo[first + [c for c in schools_demo.columns if c not in first]]
print(reordered.columns[:5].tolist())

# --- Rows --------------------------------------------------------------------
print(penguins_demo.iloc[0])                      # the first row
show(penguins_demo.iloc[0:3], "penguins_demo.iloc[0:3]  (rows 0 to 2, end excluded)")
show(penguins_demo[penguins_demo["species"] == "Adelie"], "penguins_demo[species == 'Adelie']  (a boolean mask)")
show(penguins_demo.head(3), "head(3)")
show(penguins_demo.query("species == 'Adelie'"), "query(\"species == 'Adelie'\")")

# --- Cells -------------------------------------------------------------------
print(penguins_demo.loc[0, "bill_length_mm"])     # row label 0, column by NAME
print(penguins_demo.iloc[0, 3])                   # row 0, column 3, by POSITION
print(penguins_demo["bill_length_mm"].iloc[0])    # the column, then position 0

# --- Subsetting with conditions (S04 used subset() in R) ---------------------
# Put each condition in parentheses and join them with  &  (and)   |  (or)   ~  (not).
#   ==  equal   !=  not equal   >=  at least   .isin()  one of
level = schools_demo["school_level"]
show(schools_demo[level == "High School"], "[school_level == 'High School']")
show(schools_demo[level != "Elementary School"], "[school_level != 'Elementary School']")
show(schools_demo[(level == "High School") & (schools_demo["grade_9"] >= 300)], "[High School & grade_9 >= 300]")
show(schools_demo[(schools_demo["zip_code"] == 37013) | (schools_demo["zip_code"] == 37211)], "[zip_code == 37013 | zip_code == 37211]")
show(schools_demo[schools_demo["zip_code"].isin([37013, 37211])], "[zip_code.isin([37013, 37211])]  (same result)")
show(schools_demo[schools_demo["school_name"].str.contains("high", case=False)], "[school_name.str.contains('high')]  (text search)")
show(schools_demo[schools_demo["grade_pre_k_3yrs"].isna()], "[grade_pre_k_3yrs.isna()]")
show(schools_demo[schools_demo["grade_pre_k_3yrs"].notna()], "[grade_pre_k_3yrs.notna()]  (the opposite)")

# --- The same with .query() --------------------------------------------------
show(schools_demo.query("school_level == 'High School' and grade_9 >= 300"), "query(High School and grade_9 >= 300)")
top3 = (schools_demo[level == "High School"][["school_name", "grade_9"]]
        .sort_values("grade_9", ascending=False).head(3))
print(top3)


# =============================================================================
# PART 3: Change column headings  (S02, S04, S06)
# =============================================================================
section("Part 3: change column headings")

penguins_demo = penguins_raw.copy()
print(penguins_demo.columns[:3].tolist())         # ['Unnamed: 0', 'species', 'island']

# rename(columns={old: new}) changes headings by name. Several at once is fine.
penguins_demo = penguins_demo.rename(columns={"Unnamed: 0": "row_number",
                                              "body_mass_g": "body_mass",
                                              "bill_length_mm": "bill_length"})
print(penguins_demo.columns.tolist())

# Or assign a whole new list of headings, in order. The list must be the right length.
upper_demo = penguins_raw.copy()
upper_demo.columns = upper_demo.columns.str.upper()          # change every heading at once (S04)
print(upper_demo.columns.tolist())

# clean_names() (defined at the top) turns messy headings into tidy ones.
messy = pd.DataFrame({"Bill Length (mm)": [39.1, 39.5], "Body Mass (g)": [3750, 3800]})
print(messy.columns.tolist())
print(clean_names(messy).columns.tolist())

# Drop a column you do not need. The unnamed row-number column carries no data.
penguins_demo = penguins_demo.drop(columns="row_number")
print(penguins_demo.columns[:3].tolist())         # ['species', 'island', 'bill_length']


# =============================================================================
# PART 4: Change values  (Session 8, S04)
# =============================================================================
section("Part 4: change values")

patients_demo = patients_raw.copy()
schools_demo = schools_raw.copy()

# Count the values first. Finding the problem is most of the work.
print(patients_demo["group"].value_counts())      # B 125, A 85, "A " 40
print(patients_demo["sex"].value_counts())        # M 119, F 112, m 10, f 9

# --- Text functions ----------------------------------------------------------
# Python's own text methods work on one value. pandas applies them to a whole
# column through .str.
print("A ".strip())                               # "A"
print("m".upper())                                # "M"
print(patients_demo["group"].str.strip().head(3).tolist())
print(" - Hybrid".join(["Non-Traditional", ""]).replace(" - Hybrid", ""))   # "Non-Traditional"

# Assign the cleaned column back. This is the cleaning step from Session 8.
patients_demo["group"] = patients_demo["group"].str.strip()
patients_demo["sex"] = patients_demo["sex"].str.upper()
print(patients_demo["group"].value_counts())      # A 125, B 125
print(patients_demo["sex"].value_counts())        # M 129, F 121

# --- Replace values by rule --------------------------------------------------
# np.where(test, value_if_True, value_if_False) decides row by row.
patients_demo["qc_label"] = np.where(patients_demo["passed_qc"], "pass", "fail")
# .map() swaps specific values for others. A value not in the dictionary becomes NaN.
patients_demo["sex_label"] = patients_demo["sex"].map({"F": "female", "M": "male"})
# np.select() handles several conditions, in order. default= means "everything else".
conditions = [patients_demo["systolic"].isna(),
              patients_demo["systolic"] >= 140,
              patients_demo["systolic"] >= 120]
patients_demo["bp_category"] = np.select(conditions, ["missing", "high", "elevated"], default="normal")
print(patients_demo["bp_category"].value_counts())
# .replace() swaps values. This changes a copy, not the data.
print(patients_demo["group"].replace({"A": "Group A"}).head().tolist())

# --- One category with two labels --------------------------------------------
# school_level has "Non-Traditional" and "Non-Traditional - Hybrid". They mean
# the same thing. .replace() maps the old label onto the new one. A categorical
# column (R's factor) then lists the allowed values.
before = schools_demo["school_level"].nunique()
merged_level = schools_demo["school_level"].replace({"Non-Traditional - Hybrid": "Non-Traditional"})
schools_demo["school_level_clean"] = merged_level.astype("category")
print(before)                                                   # 10 labels before
print(schools_demo["school_level_clean"].nunique())             # 9 labels after
print(schools_demo["school_level_clean"].value_counts().sort_index())

# --- Gluing text together (S04 used paste() and paste0()) --------------------
print("Hello" + " " + "world!")                  # "Hello world!"
print("_".join(["Hello", "world!"]))             # "Hello_world!"   you choose the separator
print("Hello" + "world!")                        # "Helloworld!"    no separator
print(("20" + schools_demo["school_year"]).head(3).tolist())     # "2018-19" ...
patients_demo["label"] = patients_demo["patient_id"] + "_" + patients_demo["group"]
print(patients_demo["label"].head().tolist())

# --- Split one column into two, and join them back (S04) ---------------------
# .str.split() splits school_year ("18-19") at the dash into two columns.
years = schools_demo["school_year"].str.split("-", expand=True)
years.columns = ["year_start", "year_end"]
print(pd.concat([schools_demo["school_name"], years], axis=1).head(3))
# Join them back with +.
print((years["year_start"] + "-" + years["year_end"]).head(3).tolist())

# mapped_location stores latitude and longitude as ONE text value, "(36.02, -86.66)".
# Session 7 called this two values in one cell. Split it, then convert to numbers.
location = schools_demo["mapped_location"].str.strip("()").str.split(", ", expand=True).astype(float)
location.columns = ["lat_new", "lon_new"]
# The result matches the latitude and longitude columns the file already has.
print(np.allclose(location["lat_new"], schools_demo["latitude"], equal_nan=True))   # True

# --- Arithmetic on columns ---------------------------------------------------
penguins_demo = penguins_raw.assign(body_mass_kg=penguins_raw["body_mass_g"] / 1000)
print(penguins_demo[["body_mass_g", "body_mass_kg"]].head(3))

# --- Change a column's type --------------------------------------------------
# age is text because of the word "unknown". pd.to_numeric(errors="coerce") turns
# text into numbers and anything that is not a number into NaN.
patients_demo["age"] = pd.to_numeric(patients_demo["age"], errors="coerce")
print(patients_demo["age"].dtype)                 # float64


# =============================================================================
# PART 5: The six functions and method chaining  (Session 8, S04)
# =============================================================================
section("Part 5: the six functions and the pipe")

# Cleaned patients, used by the examples below.
patients_ok = patients_raw.copy()
patients_ok["group"] = patients_ok["group"].str.strip()
patients_ok["sex"] = patients_ok["sex"].str.upper()
patients_ok["age"] = pd.to_numeric(patients_ok["age"], errors="coerce")

# Each function changes a table in one way. show() prints the size after each.
# The dplyr name is on the left, the pandas version on the right.
show(patients_ok[patients_ok["systolic"] > 130], "filter(systolic > 130)             rows go down")
show(patients_ok[["patient_id", "systolic", "group"]], "select(patient_id, systolic, group)  columns go down")
show(patients_ok.assign(pulse_pressure=patients_ok["systolic"] - patients_ok["diastolic"]), "mutate(pulse_pressure = ...)           one column added")
show(patients_ok.sort_values("systolic", ascending=False), "arrange(desc(systolic))               same size, new order")
# groupby() marks the groups. .agg() collapses each group to one row.
print(patients_ok.groupby("group").agg(n=("group", "size"), mean_systolic=("systolic", "mean")))

# Method chaining is pandas' pipe: one method per line, each working on the
# result of the line above. Run it one step at a time, and look at the size after
# each step.
step1 = penguins_raw.query("species == 'Adelie'")
step2 = step1.assign(kg=lambda d: d["body_mass_g"] / 1000)
step3 = step2.groupby("island").agg(mean_kg=("kg", "mean"))
print(len(penguins_raw), "->", len(step1), "->", len(step2), "->", len(step3), "rows")   # 344 -> 152 -> 152 -> 3
print(step3.round(2))
# assign (mutate) kept every row. groupby + agg (summarise) collapsed each group.

# Order matters. The select step drops body_mass_g, so the query has nothing to test.
try:
    penguins_raw[["species", "island"]].query("body_mass_g > 4000")
except Exception as error:
    print("wrong order:", type(error).__name__)   # UndefinedVariableError


# =============================================================================
# PART 6: Missing values  (Session 8, S02, S06)
# =============================================================================
section("Part 6: missing values")

# Count them. .isna().sum() gives the number of NaN in every column.
print(penguins_raw.isna().sum())                  # 2 in each measurement, 11 in sex
print(patients_ok["age"].isna().sum())            # 6, the "unknown" ages
print(patients_ok[["systolic", "diastolic", "cholesterol"]].isna().sum())

# pandas skips NaN when it takes a mean. R's mean() does not.
print(penguins_raw["bill_length_mm"].mean())                  # 43.92
print(penguins_raw["bill_length_mm"].mean(skipna=False))      # nan, if you ask for it
print(penguins_raw["bill_length_mm"].dropna().mean())         # drop first, same answer

# Find the rows with a missing value.
print(penguins_raw.loc[penguins_raw["sex"].isna(), ["species", "island", "sex"]].head(3))

# Two ways to drop rows that have any NaN. Each gives 333 penguins.
print(len(penguins_raw.dropna()))                             # drops rows with ANY missing value
print(penguins_raw.notna().all(axis=1).sum())                 # a count of complete rows
# .dropna(subset=["sex"]) drops only the rows where sex is missing.

# Dropping rows is a decision about your data. Not every NaN means "unknown":
#   patients age         "unknown" became NaN: the age exists but was not recorded
#   schools grade_9      NaN for a middle school: the grade does not exist there
#   penguins sex         NaN: the penguin was not sexed
# Filling the schools NaN values with 0 would be wrong. Leave them missing.
middle = schools_raw[schools_raw["school_level"] == "Middle School"]
print(middle["grade_9"].isna().sum(), "of", len(middle), "middle schools have no grade 9")


# =============================================================================
# PART 7: Combine tables: concat and merge  (Session 8, S06)
# =============================================================================
section("Part 7: combine tables")

# --- Stack tables: bind rows (S06) -------------------------------------------
# Split the patients by group, then put the pieces back together.
group_a = patients_ok[patients_ok["group"] == "A"]
group_b = patients_ok[patients_ok["group"] == "B"]
show(group_a, "group_a")
show(group_b, "group_b")
show(pd.concat([group_a, group_b]), "pd.concat([group_a, group_b])  (rbind, bind_rows)")
# pd.concat does NOT stop when the columns differ. It fills the gap with NaN.
# R's rbind() raises an error here.
mismatch = pd.concat([group_a, group_b.drop(columns="age")])
print(mismatch["age"].isna().sum(), "ages are NaN because group_b had no age column")   # 131 (125 + 6)

# --- Put tables side by side: bind columns -----------------------------------
ids = patients_ok[["patient_id", "age"]]
bps = patients_ok[["systolic", "diastolic"]]
show(pd.concat([ids, bps], axis=1), "pd.concat([ids, bps], axis=1)  (cbind, bind_cols)")
# Binding columns lines the rows up by their index. A merge checks a key instead.

# --- Joins: match rows by a shared key ---------------------------------------
# Two small tables built from the penguins data, called L and R. They share the
# key column species, but only Adelie appears in both.
species_means = (penguins_raw.groupby("species", as_index=False)
                 .agg(mean_mass=("body_mass_g", "mean"), mean_bill=("bill_length_mm", "mean"))
                 .round({"mean_mass": 0, "mean_bill": 1}))
L = species_means[species_means["species"].isin(["Adelie", "Gentoo"])][["species", "mean_mass"]]
R = species_means[species_means["species"].isin(["Adelie", "Chinstrap"])][["species", "mean_bill"]]
print(L)
print(R)

# merge() takes how= to choose the join. Leave how out and you get an inner join.
print(L.merge(R, on="species", how="inner"))      # only rows in both: Adelie
print(L.merge(R, on="species", how="left"))       # every row of L: Adelie, Gentoo (NaN for bill)
print(L.merge(R, on="species", how="right"))      # every row of R: Adelie, Chinstrap (NaN for mass)
print(L.merge(R, on="species", how="outer"))      # every row of both: all three species

# pandas has no semi_join or anti_join. Use .isin() for the same job.
print(L[L["species"].isin(R["species"])])         # semi join: rows of L that HAVE a match
print(L[~L["species"].isin(R["species"])])        # anti join: rows of L with NO match: Gentoo
print(R[~R["species"].isin(L["species"])])        # the other direction: Chinstrap
# merge(..., indicator=True) adds a column that says where each row came from.
print(L.merge(R, on="species", how="outer", indicator=True))

# --- Build a combined table step by step (S06) -------------------------------
# Add each penguin's species average to its own row. A left join keeps every
# penguin, so the row count should not change.
penguins_plus = penguins_raw.merge(species_means, on="species", how="left")
first = ["species", "island", "body_mass_g", "mean_mass"]
penguins_plus = penguins_plus[first + [c for c in penguins_plus.columns if c not in first]]
print(len(penguins_raw), "->", len(penguins_plus), "rows")                 # 344 -> 344
penguins_plus = penguins_plus.rename(columns={"mean_mass": "species_mean_mass"})
print(penguins_plus.iloc[:3, :4])

# The sanity check: after every join, compare the row counts.
island_means = (penguins_raw.groupby("island", as_index=False)
                .agg(mean_mass=("body_mass_g", "mean")).round({"mean_mass": 0}))      # 3 rows
species_by_island = (penguins_raw.groupby(["species", "island"], as_index=False)
                     .size().rename(columns={"size": "n"}))                           # 5 rows
too_many = island_means.merge(species_by_island, on="island", how="left")
print(len(island_means), "->", len(too_many), "rows")                      # 3 -> 5
# Biscoe and Dream appear twice in species_by_island, so they appear twice in
# the result. More rows than the left table means the key repeats on the right.


# =============================================================================
# PART 8: Reshape: long and wide  (Session 8, S06)
# =============================================================================
section("Part 8: reshape")

# A table is WIDE when one variable is spread across column headings. The
# schools file has one column per grade: grade_9, grade_10, and so on.
four_schools = ["Antioch High School", "Cane Ridge High School",
                "Glencliff High School", "Hillsboro High"]
wide4 = schools_raw[schools_raw["school_name"].isin(four_schools)][
    ["school_name", "grade_9", "grade_10", "grade_11", "grade_12"]]
print(wide4)

# melt() makes it long. id_vars stay as columns, value_vars become rows,
# var_name is the new column for the old headings, value_name for the numbers.
long4 = wide4.melt(id_vars="school_name", var_name="grade", value_name="students")
print(long4)                                      # 16 rows: 4 schools x 4 grades
# melt lists the rows grade by grade. R's pivot_longer lists them school by school.
# The rows are the same, only the order differs.

# The same on the whole file. All 15 grade columns are melted. .dropna() drops the
# grades a school does not offer (the NaN that means "not offered").
grade_cols = schools_raw.filter(like="grade_").columns
schools_long_demo = (
    schools_raw.melt(id_vars=["school_id", "school_name"], value_vars=grade_cols,
                     var_name="grade", value_name="students")
    .dropna(subset=["students"])
)
schools_long_demo["grade"] = schools_long_demo["grade"].str.replace("grade_", "", regex=False)
print(len(schools_long_demo), "rows, not", len(schools_raw) * 15)          # 868, not 2535
print(int(schools_long_demo["students"].sum()))                            # 86527, the same total as male + female
print(int((schools_raw["male"] + schools_raw["female"]).sum()))            # 86527

# The new grade column holds text such as "9", "10", "k" and "pre_k_3yrs".
# pd.to_numeric(errors="coerce") converts the ones that are numbers and gives NaN for the rest.
grade_numbers = pd.to_numeric(schools_long_demo["grade"], errors="coerce")
print(grade_numbers.isna().value_counts())
# The 2025 lecture did the same with substr() on column names such as "x2020".
# In Python, slicing a string does it:
print(int("x2020"[1:5]))                                                    # 2020

# pivot() goes the other way: long back to wide.
schools_wide_again = (schools_long_demo
                      .pivot(index=["school_id", "school_name"], columns="grade", values="students")
                      .reset_index())
show(schools_wide_again, "pivot(): back to one row per school")

# Wide is easier for a person to read. Count penguins by species and island,
# then spread the islands into columns. fill_value / fillna(0) fills the empty combinations.
penguin_counts = (penguins_raw.groupby(["species", "island"]).size()
                  .reset_index(name="n"))
print(penguin_counts)                             # long: one row per combination
print(penguin_counts.pivot(index="species", columns="island", values="n").fillna(0).astype(int))
# value_counts(...).unstack(fill_value=0) is a shorter way to the same table.


# =============================================================================
# PART 9: The cleaning pipeline and saving  (all of the above)
# =============================================================================
section("Part 9: the cleaning pipeline")

# Everything above was practice on copies. This part applies the cleaning
# decisions once, from the raw data, and saves the results.
#
# Decisions, and why:
#   patients  group: strip the trailing space.  sex: one case.  age: numbers, with
#             "unknown" as NaN. visit_date is left as text, because the impossible
#             date 2026-02-30 is a Session 9 problem.
#   penguins  drop the unnamed row-number column. Keep NaN values: whether to drop
#             them depends on the analysis.
#   schools   merge the two Non-Traditional labels. Make zip_code text, because
#             it is an identifier. Drop mapped_location, which repeats latitude and
#             longitude. Keep NaN in the grade columns.

os.makedirs("data/clean", exist_ok=True)

patients_clean = patients_raw.copy()
patients_clean["group"] = patients_clean["group"].str.strip()
patients_clean["sex"] = patients_clean["sex"].str.upper()
patients_clean["age"] = pd.to_numeric(patients_clean["age"], errors="coerce")

penguins_clean = penguins_raw.iloc[:, 1:].copy()      # drop the unnamed row-number column

schools_clean = schools_raw.copy()
schools_clean["school_level"] = schools_clean["school_level"].replace(
    {"Non-Traditional - Hybrid": "Non-Traditional"})
schools_clean["zip_code"] = schools_clean["zip_code"].astype(str)
schools_clean = schools_clean.drop(columns="mapped_location")

# A long version of the schools table, one row per school per grade. The rows are
# sorted school by school, the same order R's pivot_longer uses.
grade_cols = schools_clean.filter(like="grade_").columns
schools_long = (
    schools_clean.reset_index()
    .melt(id_vars=["index", "school_id", "school_name", "school_level", "zip_code"],
          value_vars=grade_cols, var_name="grade", value_name="students")
    .dropna(subset=["students"])
    .sort_values("index", kind="stable")
    .drop(columns="index")
    .reset_index(drop=True)
)

# Check the result before you save it. assert stops with an error if any of
# these is False, so a mistake cannot slip into the saved files.
assert len(patients_clean) == 250
assert (patients_clean["group"] == "A").sum() == 125
assert (patients_clean["sex"] == "M").sum() == 129
assert patients_clean["age"].isna().sum() == 6
assert penguins_clean.shape[1] == 8
assert len(schools_clean) == 169
assert schools_clean["school_level"].nunique() == 9
assert len(schools_long) == 868
assert int(schools_long["students"].sum()) == 86527
print("All checks passed.")

# Save to data/clean/. to_csv(path, index=False) creates the file, or replaces it
# if it already exists. na_rep="NA" writes missing values as the text NA, the same
# way R does. index=False stops pandas from writing its row numbers as a column.
patients_clean.to_csv("data/clean/patients_clean.csv", index=False, na_rep="NA")
penguins_clean.to_csv("data/clean/penguins_clean.csv", index=False, na_rep="NA")
schools_clean.to_csv("data/clean/schools_clean.csv", index=False, na_rep="NA")
schools_long.to_csv("data/clean/schools_long.csv", index=False, na_rep="NA")
print("Saved:", ", ".join(sorted(f for f in os.listdir("data/clean") if f.endswith(".csv"))))

# 2_statistics.py will read these files with pd.read_csv("data/clean/...").

print("\nDone: 1_data_cleaning.py")
