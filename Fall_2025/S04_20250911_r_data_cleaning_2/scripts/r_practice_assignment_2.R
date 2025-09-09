# Practice assignment 2.

# Make sure `schools_tibble` is available in your environment to run each exercise and that you load dplyr.

# Exercise 1: Conditional Statements & Loops
# Task: Write a function called `check_threshold` that accepts a dataset, a column name, 
# and a threshold number. The function should print "Below threshold" if all values in the 
# specified column are below the threshold, "Above threshold" if all values exceed the threshold, 
# or "Mixed values" otherwise. Use a `for` loop to iterate over the values in the specified column.


# Exercise 2: Piping with dplyr
# Task: Use `dplyr` functions to filter the dataset for schools with more than 100 students 
# in `grade_1`. Then, select only the `school_name` and `grade_1` columns and sort the results 
# by `grade_1` in descending order.


# Exercise 3: Subsetting & Renaming Columns
# Task: Subset the dataset to include only the `school_name`, `zip_code`, and `grade_1` columns. 
# Rename the `grade_1` column to `first_grade`. Use `dplyr` for renaming.


# Exercise 4: Summarizing Data
# Task: Use `dplyr` to group the data by `school_level` and calculate the average and standard deviation 
# for the `grade_1` column. 
