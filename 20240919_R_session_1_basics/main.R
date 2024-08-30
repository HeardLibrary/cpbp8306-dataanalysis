#####################
##### Libraries #####
#####################
#install.packages()
#library()
pacman::p_load(readr,
               openxlsx)

#####################
##### Load data #####
#####################
schools_tibble <- read_csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/gis/wg/Metro_Nashville_Schools.csv")

#####################
###### Scripts ######
#####################
## Clean raw_data file.csv and write to data/clean_file.csv
source("scripts/0_vectors.R")
source("scripts/1_dataframes.R")


