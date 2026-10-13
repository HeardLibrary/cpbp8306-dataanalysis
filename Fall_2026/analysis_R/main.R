# =============================================================================
# main.R  |  CPBP 8306 analysis project (R version)
# =============================================================================
# This is the file you run. It does three things, in this order:
#
#   1. Installs (if needed) and loads the packages the scripts use.
#   2. Loads the three datasets from data/raw/ into R.
#   3. Runs the scripts in the scripts/ folder, in order.
#
# How to run it
#   In RStudio: set the working directory to this folder (the one that contains
#   main.R), then run the file top to bottom.
#       Session > Set Working Directory > Choose Directory...
#       or:  setwd("path/to/analysis_R")
#   From a terminal, inside this folder:  Rscript main.R
#
# Folder layout (see README.md for more)
#   data/raw/     the original files, exactly as downloaded. Never edit these.
#   data/clean/   cleaned files that 1_data_cleaning.R writes.
#   scripts/      0_language_basics.R, 1_data_cleaning.R, 2_statistics.R
#   figures/      plots saved by later scripts (empty for now).
#
# Needs R 4.1 or newer, because the scripts use the |> pipe.
# =============================================================================


# -----------------------------------------------------------------------------
# Step 0: check that R is looking in the right folder
# -----------------------------------------------------------------------------
# Every path in these scripts is relative, like "data/raw/patients.csv". That
# only works if R's working directory is this folder. getwd() tells you where
# R is looking right now.
if (!file.exists("data/raw/patients.csv")) {
  stop("R cannot find data/raw/patients.csv. Your working directory is ",
       getwd(), ". Set it to the analysis_R folder and run main.R again.")
}


# -----------------------------------------------------------------------------
# Step 1: install and load packages
# -----------------------------------------------------------------------------
# A package is a bundle of extra functions that someone else wrote. You install
# a package once per computer with install.packages(). You load it with
# library() in every session where you want to use it.
#
# The loop below installs any package that is missing, so this file works on a
# fresh computer. It needs an internet connection the first time.
packages <- c("readr", "dplyr", "tidyr", "stringr", "tibble")

for (pkg in packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}

library(readr)    # read_csv() and write_csv(): read and write CSV files as tibbles
library(dplyr)    # the six core functions (filter, select, mutate, arrange,
                  # group_by, summarise) plus the joins and the |> pipe helpers
library(tidyr)    # reshaping (pivot_longer, pivot_wider) and splitting a column
                  # into several (separate, unite)
library(stringr)  # text functions that all start with str_ (str_trim, str_to_upper)
library(tibble)   # the tibble() function, a modern kind of data frame

# Other ways to do the same job, in case you see them elsewhere:
#   library(tidyverse)          loads readr, dplyr, tidyr, stringr, tibble and
#                               several more in one line. It is a bigger install.
#   pacman::p_load(tidyverse)   installs and loads in one step. The 2025 version
#                               of this course used pacman.
#
# Optional packages that some lecture examples mention. They are commented out
# because the scripts do not need them:
#   install.packages("janitor")    clean_names() fixes messy column headings.
#                                  1_data_cleaning.R writes its own version.
#   install.packages("openxlsx")   read.xlsx() reads Excel files.
#
# Packages that 2_statistics.R will need later (not used yet):
#   ggplot2 (figures, Session 10), glmnet (LASSO, Session 12)


# -----------------------------------------------------------------------------
# Step 2: load the data
# -----------------------------------------------------------------------------
# read_csv() reads a CSV file into a tibble. The three files below are the same
# datasets used in Sessions 1 to 8. They are loaded exactly as they are on disk,
# with no cleaning, and stored in objects that end in _raw. The scripts make
# copies of these objects before they change anything, so a mistake never
# damages the raw data.
#
# show_col_types = FALSE stops readr from printing a table of column types.

# penguins: body measurements of 344 penguins from the Palmer Archipelago,
# Antarctica (Horst, Hill and Gorman, 2020, palmerpenguins package, CC0).
#   species, island                              which penguin, where it lives
#   bill_length_mm, bill_depth_mm,
#   flipper_length_mm, body_mass_g               four body measurements
#   sex, year                                    sex (lowercase) and sampling year
# Known issues: 2 penguins have no measurements and 11 have no sex. The first
# column of the file is a row number written by R's write.csv() with no heading,
# so readr names it ...1. Session 7 and 8 treat both as part of cleaning.
penguins_raw <- read_csv("data/raw/penguins.csv", show_col_types = FALSE)

# patients: 250 synthetic patients (made up, so no privacy concerns).
#   patient_id, age, sex, group                  who the patient is
#   systolic, diastolic, cholesterol             measurements
#   passed_qc, visit_date                        quality flag and visit date
# Known issues planted on purpose: group has "A" and "A " (trailing space), sex
# mixes "F", "f", "M" and "m", age contains "unknown" so it loads as text, some
# measurements are missing, and one visit_date is 2026-02-30, which does not exist.
#
# Two arguments below keep the planted defects visible, so R and Python see the
# same data:
#   trim_ws = FALSE   read_csv() normally trims spaces from the start and end of
#                     every text value. That would silently turn "A " into "A"
#                     and hide the trailing-space bug. Python keeps the space.
#   visit_date        read as text. If you let read_csv() guess, it decides the
#                     column is a date, turns 2026-02-30 into NA, and prints a
#                     warning that is easy to miss. Session 9 deals with that date.
patients_raw <- read_csv("data/raw/patients.csv", show_col_types = FALSE,
                         trim_ws = FALSE,
                         col_types = cols(visit_date = col_character()))

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
schools_raw <- read_csv("data/raw/schools_tibble.csv", show_col_types = FALSE)

# A quick check that each file loaded completely. stopifnot() does nothing when
# every condition is TRUE and stops with an error when one is FALSE.
stopifnot(nrow(penguins_raw) == 344,
          nrow(patients_raw) == 250,
          nrow(schools_raw) == 169,
          sum(patients_raw$group == "A ") == 40)   # the trailing-space rows are still there
cat("Loaded:", nrow(penguins_raw), "penguins,", nrow(patients_raw), "patients,",
    nrow(schools_raw), "schools\n")


# -----------------------------------------------------------------------------
# Step 3: run the scripts
# -----------------------------------------------------------------------------
# source() runs another R file as if you had pasted it here. The scripts share
# the objects created above, which is why they can use patients_raw and the rest.
#
# 0_language_basics.R   Sessions 1 to 6: types, vectors, loops, functions, paths.
#                       It changes nothing, so you can skip it.
# 1_data_cleaning.R     Sessions 7 and 8: subset, rename, change, combine, reshape
#                       and save. It writes the cleaned files to data/clean/.
# 2_statistics.R        Sessions 9 to 12. It only has comments so far.
source("scripts/0_language_basics.R")
source("scripts/1_data_cleaning.R")
# source("scripts/2_statistics.R")   # turn this on when the script has code
