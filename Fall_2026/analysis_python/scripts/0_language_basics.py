"""
0_language_basics.py  |  Lectures 1 to 6, plus the 2025 R basics (S02) in Python

This script collects the commands from the first six lectures and tries them on
real data. It does not clean anything and does not save anything. It works on
copies, so you can run it, change it, and break it without harming the data.

Contents
  Lecture 1   Look at the data before you test it
  Lecture 2   Types: what kind of value is this?
  Lecture 3   Collections: lists, dictionaries, indexing, boolean masks
  Lecture 4   Control flow: if, for, while
  Lecture 5   Functions
  Lecture 6   Projects, paths and reading files

Run it from main.py, or open it and run one section at a time. Before you run a
line, say out loud what you expect it to print. Then run it and compare.

Needs these objects from main.py: patients_raw, penguins_raw, schools_raw,
and the imports np, pd and stats.
"""
import math
import os
import re

try:
    patients_raw
except NameError:
    raise SystemExit("Run main.py first. It loads the data this script uses.")


def section(title):
    """Print a heading, so the output is easy to read."""
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


# Working copies. Everything below changes these, never the _raw objects.
patients_demo = patients_raw.copy()
penguins_demo = penguins_raw.copy()
schools_demo = schools_raw.copy()


# =============================================================================
# LECTURE 1: Look at the data before you test it
# =============================================================================
section("Lecture 1: look at the data before you test it")

# The scenario from Session 1: compare systolic blood pressure between group A
# and group B. An AI would write this without looking at the group column.
a_values = patients_demo.loc[patients_demo["group"] == "A", "systolic"].dropna()
b_values = patients_demo.loc[patients_demo["group"] == "B", "systolic"].dropna()

# stats.ttest_ind() compares two means. Session 11 explains it. Here it only
# shows how one bad value changes the answer.
t_stat, p_value = stats.ttest_ind(a_values, b_values)
print(f"Group A mean: {a_values.mean():.1f}  (n = {len(a_values)})")
print(f"Group B mean: {b_values.mean():.1f}  (n = {len(b_values)})")
print(f"p = {p_value:.4f}  -> no significant difference?")

# Nobody looked at the group column. Count what is in it:
print(patients_demo["group"].value_counts())          # three values, not two: A, "A " and B
print(sorted(repr(g) for g in patients_demo["group"].unique()))   # repr() shows the trailing space

# 40 rows say "A " (with a space). They were silently left out of group A.
# .str.strip() removes spaces from both ends of a text value.
patients_demo["group"] = patients_demo["group"].str.strip()
print(patients_demo["group"].value_counts())          # now two groups: A 125 and B 125

# Same test, on the corrected data:
a_fixed = patients_demo.loc[patients_demo["group"] == "A", "systolic"].dropna()
b_fixed = patients_demo.loc[patients_demo["group"] == "B", "systolic"].dropna()
t_fixed, p_fixed = stats.ttest_ind(a_fixed, b_fixed)
print(f"Corrected group A mean: {a_fixed.mean():.1f}  (n = {len(a_fixed)})")
print(f"p = {p_fixed:.4f}  -> a real difference")
# One line of cleaning changed the conclusion. The code ran without an error
# both times. That is why you look before you test.


# =============================================================================
# LECTURE 2: Types: what kind of value is this?
# =============================================================================
section("Lecture 2: types")

# Assignment stores a value under a name. The right side is worked out first.
patient_count = 42
patient_count = patient_count + 1
print(patient_count)                      # 43

# type() tells you the type of a value. Check it whenever a result surprises you.
for value in (42, 117.3, "P042", True):
    print(f"{value!r:>8}  ->  {type(value).__name__}")   # int, float, str, bool

# The three-second habit: check the type of EVERY column right after you load a file.
print(patients_demo.dtypes)               # age is "object" (text), not a number
patients_demo.info()                      # types, plus how many values are not missing

# Why is age text? Look at the values that are not numbers.
not_numbers = pd.to_numeric(patients_demo["age"], errors="coerce").isna()
print(patients_demo.loc[not_numbers, "age"].unique())     # ['unknown']

# Booleans are secretly numbers: True counts as 1 and False as 0.
print(patients_demo["passed_qc"].sum())                   # how many patients passed QC
print(patients_demo["passed_qc"].mean())                  # the proportion that passed

# String traps
print("5" + "3")                          # "53": gluing two pieces of text, not adding
try:
    "5" + 3
except TypeError as error:
    print("TypeError:", error)            # Python refuses to guess
print(5 == "5")                           # False, with no error. Different types are never equal.

# Decimal numbers are stored approximately.
print(0.1 + 0.2 == 0.3)                   # False
print(math.isclose(0.1 + 0.2, 0.3))       # True: isclose() allows a tiny difference

# --- Changing a column's type (S02, "Changing numeric, character and factor") ---
# zip_code is an identifier, not a quantity. You would never add two zip codes.
print(schools_demo["zip_code"].dtype)                         # int64
schools_demo["zip_code"] = schools_demo["zip_code"].astype(str)
print(schools_demo["zip_code"].dtype)                         # object (text)

# A categorical column is pandas' version of an R factor: text with a fixed set
# of allowed values, called categories.
schools_demo["zip_code"] = schools_demo["zip_code"].astype("category")
print(schools_demo["zip_code"].dtype)                         # category
print(list(schools_demo["zip_code"].cat.categories[:5]))

# The categorical trap: .cat.codes gives each value's POSITION in the category
# list, not its label. This is the same mistake as as.numeric() on an R factor.
print(schools_demo["zip_code"].cat.codes.head().tolist())     # 0, 7, 5 ... wrong
print(schools_demo["zip_code"].astype(str).astype(int).head().tolist())   # the real zip codes

# --- Common errors and their fixes (S02) ---
# 1. Missing values. pandas skips them when it takes a mean. R does not.
print(schools_demo["grade_1"].mean())                         # 81.9
print(schools_demo["grade_1"].mean(skipna=False))             # nan, if you ask for it
print(schools_demo["grade_1"].dropna().mean())                # drop them first, same answer
# 2. The wrong type. school_year is text like "18-19", so a mean makes no sense.
try:
    schools_demo["school_year"].mean()
except TypeError as error:
    print("TypeError: a mean needs numbers, and this column is text")


# =============================================================================
# LECTURE 3: Collections: lists, dictionaries, indexing, boolean masks
# =============================================================================
section("Lecture 3: collections")

# A list is an ordered collection. [ ] makes one.
bp = [117, 122, 141, 130, 118]            # five systolic readings from the lecture
print(len(bp))                            # 5
print(type(bp).__name__)                  # list

# Mixing types: a Python list keeps each value as it is. No silent changes.
mixed = [1, 2, "three"]
print([type(x).__name__ for x in mixed])  # ['int', 'int', 'str']
# R would turn all three into text. This is what happens to a column of ages
# when one row says "unknown".

# Sequences
print(list(range(3, 10)))                 # 3 to 9. range() stops BEFORE the end value.
print(list(range(10, -1, -1)))            # counts down
print(list(np.arange(0, 101, 25)))        # 0 25 50 75 100

# Indexing. Python counts from 0, and square brackets pick elements.
print(bp[0])                              # the first element
print(bp[1:4])                            # elements 1, 2 and 3 (the end is EXCLUDED)
print([bp[i] for i in (0, 2, 4)])         # pick specific elements
print(bp[-1])                             # the LAST element (in R, -1 means "drop the first")
try:
    bp[10]
except IndexError as error:
    print("IndexError:", error)           # past the end IS an error in Python
bp[1] = 120                               # change one element
print(bp)
bp[1] = 122                               # put it back

# Boolean masks: the most important idea in the course. A list cannot be masked
# directly, so turn it into a numpy array first.
bp_array = np.array(bp)
print(bp_array > 130)                     # step 1: True or False for every element
print(bp_array[bp_array > 130])           # step 2: keep the elements where it is True
print((bp_array > 130).sum())             # step 3: count them (True counts as 1)
print((bp_array > 130).mean())            # or take the fraction
# df[df["age"] > 65] in pandas and filter() in R's dplyr are this same idea.

# The same mask on a real column. pandas skips missing values in comparisons.
systolic = patients_demo["systolic"]
print(systolic.isna().sum())                       # 9 missing
print((systolic > 130).sum())                      # readings above 130 (NaN counts as False)
print(systolic[systolic > 130].head().tolist())    # the first few of them

# A dictionary holds values of different types, looked up by name (R's named list).
patient = {"id": "P042", "age": 61, "systolic": 141, "treated": True}
print(patient["age"])                     # lookup by name
patient["age"] = 62                       # change a value
print(list(patient.keys()))

# A dictionary can hold a whole list (S02).
species_info = {"name": "Adelie", "n": 152, "islands": ["Biscoe", "Dream", "Torgersen"]}
print(species_info["islands"])            # the whole list
print(species_info["islands"][1])         # one element inside it: "Dream"

# --- A DataFrame is a set of equal-length columns (S02) ---
species = ["Adelie", "Chinstrap", "Gentoo"]
n_penguins = [152, 68, 124]
mean_mass_g = [3701, 3733, 5076]
species_table = pd.DataFrame({"species": species, "n_penguins": n_penguins,
                              "mean_mass_g": mean_mass_g})
print(species_table)

print(species_table["species"].tolist())              # a column, by name
print(species_table.iloc[1, 0])                       # a cell: row 1, column 0 (counting from 0)
print(species_table["mean_mass_g"].iloc[2])           # a cell: column by name, then position

# Arithmetic works on whole columns at once.
species_table["total_mass_kg"] = species_table["n_penguins"] * species_table["mean_mass_g"] / 1000
print(species_table)

# R recycles a short vector to fit a long one. numpy refuses unless the lengths match.
short = np.array([1, 2])
long = np.array([10, 15, 17, 5, 1])
try:
    short + long
except ValueError as error:
    print("ValueError:", error)           # shapes (2,) and (5,) do not match


# =============================================================================
# LECTURE 4: Control flow: if, for, while
# =============================================================================
section("Lecture 4: control flow")

# if / elif / else chooses ONE path. Only the first True condition runs.
bp_value = 130
if bp_value >= 140:
    category = "high"
elif bp_value >= 120:
    category = "elevated"
else:
    category = "normal"
print(category)                           # "elevated"

# A common bug: three separate if statements instead of elif. Each one runs.
for reading in (145, 130, 110):
    wrong = None
    if reading >= 140:
        wrong = "high"
    if reading >= 120:
        wrong = "elevated"                # runs AGAIN for 145 and overwrites "high"
    if reading < 120:
        wrong = "normal"
    print(f"bp = {reading} -> three ifs says: {wrong}")
# 145 comes out "elevated". No error, just a wrong answer.

# A for loop repeats a block once for each item. This one labels the first ten
# patients. pd.isna() handles the missing readings.
first_ten = patients_demo["systolic"].iloc[:10].tolist()
labels = []                               # an empty result to fill in
for reading in first_ten:
    if pd.isna(reading):
        labels.append("missing")
    elif reading >= 140:
        labels.append("high")
    elif reading >= 120:
        labels.append("elevated")
    else:
        labels.append("normal")
print(pd.DataFrame({"systolic": first_ten, "label": labels}))

# The accumulator pattern: set up BEFORE the loop, update INSIDE, use AFTER.
count_high = 0
for reading in patients_demo["systolic"].dropna():
    if reading >= 140:
        count_high += 1
print(count_high)

# The same job with no loop (vectorized). This is shorter and much faster.
print((patients_demo["systolic"] >= 140).sum())       # same number

# Vectorized if/else: np.where() decides for a whole column at once.
bp_label = np.where(patients_demo["systolic"] >= 140, "high", "not high")
print(pd.Series(bp_label).value_counts())

# Loop over the columns of a data frame (S04) and report each one's type.
for col_name in patients_demo.columns:
    print(col_name, ":", patients_demo[col_name].dtype)

# A while loop repeats as long as a condition is True. You must change something
# inside the loop that eventually makes the condition False.
i = 0
while i < 5:
    print("schools column", i + 1, "is called", schools_demo.columns[i])
    i += 1                                # without this line the loop never ends


# =============================================================================
# LECTURE 5: Functions
# =============================================================================
section("Lecture 5: functions")


# A function packages a piece of code so you can reuse it. The pieces:
#   def name(inputs):   steps   return the answer
# threshold=140 gives the input a default, so you can leave it out.
def count_high_bp(bps, threshold=140):
    """
    Count how many blood pressure readings meet or exceed a threshold.

    bps        a list or column of systolic readings, in mmHg
    threshold  the cutoff. At or above it counts as high.
    Missing readings are skipped. Returns a whole number.
    """
    values = pd.Series(bps).dropna()
    return int((values >= threshold).sum())


print(count_high_bp(patients_demo["systolic"]))                  # uses the default of 140
print(count_high_bp(patients_demo["systolic"], threshold=130))   # a different cutoff
# Change the threshold in ONE place and every call follows it.


def categorize_bp(bp):
    """Turn one reading into a label."""
    if pd.isna(bp):
        return "missing"
    if bp >= 140:
        return "high"
    if bp >= 120:
        return "elevated"
    return "normal"


print(categorize_bp(145))                 # "high"

# .apply() runs a function on every element and collects the results.
patients_demo["bp_category"] = patients_demo["systolic"].apply(categorize_bp)
print(patients_demo["bp_category"].value_counts())


def check_threshold(data, column, threshold):
    """From the 2025 practice assignment: are all values below, above, or mixed?"""
    values = data[column].dropna()
    if (values < threshold).all():
        return "Below threshold"
    elif (values > threshold).all():
        return "Above threshold"
    return "Mixed values"


print(check_threshold(patients_demo, "systolic", 140))            # "Mixed values"


def capitalize_colnames(data):
    """From S04: return a copy of the data with upper-case column names."""
    data = data.copy()
    data.columns = data.columns.str.upper()
    return data


print(list(capitalize_colnames(patients_demo).columns[:4]))


def clean_names(data):
    """
    Turn messy column headings into tidy ones. This is the same job as
    janitor::clean_names() in R, written by hand so you can see what it does.
      1. make everything lower case   2. turn spaces and symbols into underscores
      3. trim underscores from the ends
    """
    data = data.copy()
    new_names = [re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_") for name in data.columns]
    data.columns = new_names
    return data


messy = pd.DataFrame({"Bill Length (mm)": [39.1, 39.5], "Body Mass (g)": [3750, 3800]})
print(list(messy.columns))                # ['Bill Length (mm)', 'Body Mass (g)']
print(list(clean_names(messy).columns))   # ['bill_length_mm', 'body_mass_g']


# =============================================================================
# LECTURE 6: Projects, paths and reading files
# =============================================================================
section("Lecture 6: projects, paths and reading files")

# A project keeps everything for one analysis in one folder, with the same
# layout every time (see README.md). Paths are RELATIVE to that folder, so the
# project works on any computer and in any location.
print(os.getcwd())                                    # where Python is looking right now
print(os.listdir("data/raw"))                         # the files in a folder
print(os.path.exists("data/raw/patients.csv"))        # True if the path is right

# A relative path:  "data/raw/patients.csv"
# An absolute path: "/Users/yourname/Desktop/project/data/raw/patients.csv"
# The absolute path breaks on every computer except yours.
# os.chdir("path/to/folder") changes the working directory. Avoid it inside scripts.
# Start Python from the project folder and use relative paths.

# --- pd.read_csv() (S02 compared read.csv and read_csv in R) ---
# pandas has one reader. It returns a DataFrame and keeps text exactly as it is.
schools_again = pd.read_csv("data/raw/schools_tibble.csv")
print(type(schools_again).__name__)                   # DataFrame
print(schools_again.iloc[:3, :4])

# Dates. pandas keeps visit_date as text, so the impossible date 2026-02-30 is
# still there. You decide when to turn text into dates. errors="coerce" turns
# anything that is not a real date into NaT, pandas' missing-date marker.
visit_dates = pd.to_datetime(patients_raw["visit_date"], errors="coerce")
print(visit_dates.isna().sum())                       # 1: the impossible date
print(patients_raw.loc[visit_dates.isna(), "visit_date"].tolist())   # ['2026-02-30']

# Whitespace. pandas keeps spaces at the start and end of text values. R's
# read_csv() trims them by default, which would hide the trailing-space bug.
print(patients_raw["group"].value_counts())           # A 85, "A " 40, B 125

# Other ways to read data (commented out, because they need a file or a network).
# From a web address:
#   pd.read_csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/gis/wg/Metro_Nashville_Schools.csv")
# A tab-separated file:                      pd.read_csv("file.tsv", sep="\t")
# An Excel file (needs pip install openpyxl): pd.read_excel("file.xlsx", sheet_name="name")

# Writing a file. table.to_csv("path/file.csv", index=False) creates or replaces
# the file. index=False stops pandas from writing its row numbers as a column.
# 1_data_cleaning.py does this at the end, and writes into data/clean/, never
# into data/raw/.
#   my_table.to_csv("data/clean/my_table.csv", index=False)

# Version control. Git is a terminal tool, so it is not part of this script.
# See the "Version control" section of README.md for the commands.

print("\nDone: 0_language_basics.py")
