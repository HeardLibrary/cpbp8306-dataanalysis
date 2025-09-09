#####################
##### Libraries #####
#####################
#install.packages("pacman")
#library(pacman)
pacman::p_load(tidyverse, 
               devtools,
               janitor)

#####################
##### Load data #####
#####################
schools_tibble <- read_csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/gis/wg/Metro_Nashville_Schools.csv") %>% clean_names()

#####################
###### Scripts ######
#####################
## Clean raw_data file.csv and write to data/clean_file.csv
source("scripts/0_clean_data.R")
