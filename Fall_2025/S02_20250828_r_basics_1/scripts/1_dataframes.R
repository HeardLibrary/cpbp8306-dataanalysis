# --------------------
# Lists
# --------------------

# recreate the animals vector
animal <- c("frog", "spider", "worm", "bee")

# create a list
thing <- list(fruit_kind="apple", euler=2.71828, vector_data=animal, curse="!@#$%")

# referencing list items
thing[[2]]
thing$curse

# --------------------
# Data frames
# --------------------

# Making a data frame from vectors
group <- c("reptile", "arachnid", "annelid", "insect") # vector of strings
animal <- c("lizard", "spider", "worm", "bee")
number_legs <- c(4,8,0,6) # vector of numbers
organism_info <- data.frame(group, animal, number_legs)

# Referring to parts of a data frame
organism_info$animal # column by name
organism_info[2,1] # cell by row, column
organism_info$animal[4] # cell by column name and position in column

# --------------------
# Loading data frames from files
# --------------------

# Loading data from a CSV into a data frame

# by a file-choosing dialog:
my_data_frame <- read.csv(file.choose())  
# from a URL:
my_data_frame <- read.csv("https://gist.githubusercontent.com/baskaufs/1a7a995c1b25d6e88b45/raw/4bb17ccc5c1e62c27627833a4f25380f27d30b35/t-test.csv") 

# from a hard-coded path:
my_data_frame <- read.csv("~/test.csv")  # by a path (Mac home directory)
my_data_frame <- read.csv("c:\temp\test.csv")  # by a path (Windows C: drive)

# When you hard code a file name in a script in a script with no path, 
# R will assume the file is in your current working directory.
# If you don't know what that is, you can find out using:

getwd()

# load a file from your current working directory:
my_data_frame <- read.csv("test.csv")

# You can change the working directory using the setwd() function.  For example:
setwd("~/Documents/r/")
# would change the working directory to the "r" subdirectory of the Documents folder on a Mac.

# --------------------
# More file loading options
# --------------------

# The openxlsx package can read an Excel file into a data frame.
# To load the package then read in the file:

library(openxlsx)
data_frame <- read.xlsx(xlsxFile = "my_file.xlsx", sheet = 'name_of_sheet')

# The sheet argument is optional.
# you can also use file.choose() to select the file interactively:

data_frame <- read.xlsx(file.choose())

# ------------------
# Tibbles
# ------------------

# tidyverse packages operate on tibbles, a special type of data frame. 
# When data frames are operated upon by a tidyverse function, the output is generally a tibble.
# The readr package provides analogs to read.csv() that loads CSV data as a tibble. 
# In particular, it does not automatically turn character strings into factors

library(readr)

# compare the two data structures by clicking on their listings in the global environment pane
erg_dframe <- read.csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/r/color-anova-example.csv")
erg_tibble <- read_csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/r/color-anova-example.csv")

# They basically look the same
# Now compare their table summaries
str(erg_dframe)
str(erg_tibble)

# Notice the difference in how the block and color columns are read in.
# If the file has tab delimiters instead of commas, you can use read_tsv()

# For reference: how to write a tibble to a CSV file
write_csv(tibble_name, "file_name.csv", na = "NA", append = FALSE, col_names = TRUE, quote_escape = "double")

# Example uses common options (include column names, replace existing file if any).
# See https://readr.tidyverse.org/reference/write_delim.html for details.

# Opening a tab-separated values (TSV) file as a tibble
my_tibble <- read_tsv("test.tsv")


# ------------------
# Examining a data frame
# ------------------

# head() shows the first 6 rows
# tail() shows the last 6 rows
# names() returns the column names
# str() describes the structure of the data frame with information about each column
# How could I get a data.frame with the name below using the erg_dframe data.frame?
head(my_data_frame)
tail(my_data_frame)
names(my_data_frame)
str(my_data_frame)

# ------------------
# Subsetting dataframes
# ------------------
my_data_frame[1,] # first row
my_data_frame[,1] 
my_data_frame[1:3,]
my_data_frame[,1:3]
my_data_frame[1:3,1] 
my_data_frame$response[1]

# ------------------
# Operations on data frames
# ------------------

# Vector recycling
a <- c(1, 2)
b <- c(10, 15, 17, 5, 1)
a + b

# Recreate the organism_info data frame if necessary
number_wings <- c(0, 0, 0, 4)
number_appendages <- number_wings + organism_info$number_legs

# Recycling
calendar <- read_csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/r/calendar.csv")
weekdays <- c(0, 1, 1, 1, 1, 1, 0)
work_week_calls <- calendar$number_calls * weekdays

# ------------------
# Common errors and ways to fix them
# ------------------

# I will demonstrate these errors with the Nashville schools data
# NAs are present in the data
mean(schools_tibble$grade_1) 
class(schools_tibble$grade_1)
mean(schools_tibble$grade_1, na.rm = TRUE)
mean(na.omit(schools_tibble$grade_1))

# Wrong class/type
mean(schools_tibble$school_year)
str(schools_tibble$school_year)
str(schools_tibble)

# Changing numeric, characters, and factor data types
# Change int/numeric to character
schools_tibble$zip_code <- as.character(schools_tibble$zip_code)
class(schools_tibble$zip_code)
unique(schools_tibble$zip_code)
# Change character or numeric to factor
schools_tibble$zip_code <- as.factor(schools_tibble$zip_code)
class(schools_tibble$zip_code)
schools_tibble$zip_code <- factor(schools_tibble$zip_code, levels = c("37013", "37189", "37115", "37138", "37221", "37207", "37208", "37210", "37203", 
                                                                      "37211", "37209", "37206", "37218", "37220", "37216", "37076", "37214", "37212", 
                                                                      "37204", "37217", "37072", "37027", "37205", "37215", "37080", "37228"))
# Change factor to character or numeric
as.numeric(schools_tibble$zip_code)   
as.numeric(as.character(schools_tibble$zip_code)) 
