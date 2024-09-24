#####################
##### Libraries #####
#####################
#install.packages("pacman")
#library(pacman)
pacman::p_load(tidyverse, 
               devtools,
               janitor)

# install_github("mvuorre/exampleRPackage")
# help(janitor)

#####################
##### Load data #####
#####################
#getwd()
#setwd()
#data("mtcars")
#data("iris")
schools_tibble <- read_csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/gis/wg/Metro_Nashville_Schools.csv") %>% clean_names()

#####################
###### Scripts ######
#####################
## Clean raw_data file.csv and write to data/clean_file.csv
source("scripts/0_vectors.R")
source("scripts/1_dataframes.R")


