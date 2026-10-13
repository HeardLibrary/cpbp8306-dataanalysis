"""
main.py  |  CPBP 8306 analysis project (Python version)

This is the file you run. It does three things, in this order:

  1. Installs (if needed) and loads the libraries the scripts use.
  2. Loads the three datasets from data/raw/ into pandas.
  3. Runs the scripts in the scripts/ folder, in order.

How to run it
  From a terminal, inside this folder (the one that contains main.py):
      python main.py
  Or open it in VS Code or Jupyter and run it top to bottom, with this folder
  as the working directory.

Folder layout (see README.md for more)
  data/raw/     the original files, exactly as downloaded. Never edit these.
  data/clean/   cleaned files that 1_data_cleaning.py writes.
  scripts/      0_language_basics.py, 1_data_cleaning.py, 2_statistics.py
  figures/      plots saved by later scripts (empty for now).

Needs Python 3.9 or newer.
"""
import importlib.util
import subprocess
import sys
from pathlib import Path


# -----------------------------------------------------------------------------
# Step 0: check that Python is looking in the right folder
# -----------------------------------------------------------------------------
# Every path in these scripts is relative, like "data/raw/patients.csv". That
# only works if the working directory is this folder. Path.cwd() tells you where
# Python is looking right now.
if not Path("data/raw/patients.csv").exists():
    raise SystemExit(
        f"Python cannot find data/raw/patients.csv. Your working directory is "
        f"{Path.cwd()}. Change to the analysis_python folder and run main.py again."
    )


# -----------------------------------------------------------------------------
# Step 1: install and load libraries
# -----------------------------------------------------------------------------
# A library is a bundle of extra code that someone else wrote. You install it
# once per computer with pip. You load it with import in every script that uses it.
#
# The loop below installs any library that is missing, so this file works on a
# fresh computer. It needs an internet connection the first time.
#   module name -> name to give pip
libraries = {"pandas": "pandas", "numpy": "numpy", "scipy": "scipy"}

for module, pip_name in libraries.items():
    if importlib.util.find_spec(module) is None:
        subprocess.check_call([sys.executable, "-m", "pip", "install", pip_name])

import runpy             # runs another .py file, like R's source()
import numpy as np       # fast arrays and math. Boolean masks, np.where, np.select.
import pandas as pd      # tables (DataFrames): read_csv, filter, group, merge, melt
from scipy import stats  # statistical tests. Used once, in Lecture 1 (a t-test).

# Other libraries that some lecture examples mention. They are commented out
# because the scripts do not need them:
#   openpyxl     lets pd.read_excel() read Excel files:  pip install openpyxl
#   pyjanitor    clean_names() fixes messy column headings. 1_data_cleaning.py
#                writes its own version.
#
# Libraries that 2_statistics.py will need later (not used yet):
#   matplotlib or seaborn (figures, Session 10), statsmodels (regression),
#   scikit-learn (PCA, clustering, LASSO, Session 12)


# -----------------------------------------------------------------------------
# Step 2: load the data
# -----------------------------------------------------------------------------
# pd.read_csv() reads a CSV file into a DataFrame. The three files below are the
# same datasets used in Sessions 1 to 8. They are loaded exactly as they are on
# disk, with no cleaning, and stored in objects that end in _raw. The scripts
# make copies of these objects before they change anything, so a mistake never
# damages the raw data.

# penguins: body measurements of 344 penguins from the Palmer Archipelago,
# Antarctica (Horst, Hill and Gorman, 2020, palmerpenguins package, CC0).
#   species, island                              which penguin, where it lives
#   bill_length_mm, bill_depth_mm,
#   flipper_length_mm, body_mass_g               four body measurements
#   sex, year                                    sex (lowercase) and sampling year
# Known issues: 2 penguins have no measurements and 11 have no sex. The first
# column of the file is a row number written by R with no heading, so pandas
# names it "Unnamed: 0". Session 7 and 8 treat both as part of cleaning.
penguins_raw = pd.read_csv("data/raw/penguins.csv")

# patients: 250 synthetic patients (made up, so no privacy concerns).
#   patient_id, age, sex, group                  who the patient is
#   systolic, diastolic, cholesterol             measurements
#   passed_qc, visit_date                        quality flag and visit date
# Known issues planted on purpose: group has "A" and "A " (trailing space), sex
# mixes "F", "f", "M" and "m", age contains "unknown" so it loads as text, some
# measurements are missing, and one visit_date is 2026-02-30, which does not exist.
# pandas keeps visit_date as text and keeps the trailing spaces, which is what we
# want: the defects stay visible until the cleaning script fixes them.
patients_raw = pd.read_csv("data/raw/patients.csv")

# schools: enrollment for 169 Metro Nashville schools, 2018-19. One row per
# school, 35 columns.
#   school_name, school_level, zip_code, ...     identifying columns
#   grade_pre_k_3yrs ... grade_12                15 columns of student counts
#                                                (one variable spread across columns)
#   male, female, race and ethnicity counts      more counts
#   latitude, longitude, mapped_location         location, with the same value
#                                                stored twice (see Session 7)
# Known issues: an NA in a grade column usually means the school does not offer
# that grade, and school_level uses two labels for one category.
schools_raw = pd.read_csv("data/raw/schools_tibble.csv")

# A quick check that each file loaded completely. assert does nothing when the
# condition is True and stops with an error when it is False.
assert len(penguins_raw) == 344
assert len(patients_raw) == 250
assert len(schools_raw) == 169
assert (patients_raw["group"] == "A ").sum() == 40   # the trailing-space rows are still there
print(f"Loaded: {len(penguins_raw)} penguins, {len(patients_raw)} patients, {len(schools_raw)} schools")


# -----------------------------------------------------------------------------
# Step 3: run the scripts
# -----------------------------------------------------------------------------
# runpy.run_path() runs another Python file. init_globals=globals() hands it
# everything defined above, which is why the scripts can use patients_raw and
# the rest.
#
# 0_language_basics.py   Sessions 1 to 6: types, lists, loops, functions, paths.
#                        It changes nothing, so you can skip it.
# 1_data_cleaning.py     Sessions 7 and 8: subset, rename, change, combine,
#                        reshape and save. It writes the cleaned files to data/clean/.
# 2_statistics.py        Sessions 9 to 12. It only has comments so far.
runpy.run_path("scripts/0_language_basics.py", init_globals=globals())
runpy.run_path("scripts/1_data_cleaning.py", init_globals=globals())
# runpy.run_path("scripts/2_statistics.py", init_globals=globals())   # turn this on when the script has code
