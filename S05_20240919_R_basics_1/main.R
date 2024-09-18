#####################
##### Libraries #####
#####################
#install.packages("pacman")
#library(pacman)
pacman::p_load(tidyverse, 
               devtools,
               janitor)

# install_github("mvuorre/exampleRPackage")
# help(exampleRPackage)

#####################
##### Load data #####
#####################
#data("mtcars")
#data("iris")
#schools_tibble <- read.csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/gis/wg/Metro_Nashville_Schools.csv", stringsAsFactors = FALSE)
schools_tibble <- read_csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/gis/wg/Metro_Nashville_Schools.csv")
schools_tibble <- read_csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/gis/wg/Metro_Nashville_Schools.csv") %>% clean_names()
#str(schools_tibble)

#####################
###### Scripts ######
#####################
## Clean raw_data file.csv and write to data/clean_file.csv
source("scripts/0_vectors.R")
source("scripts/1_dataframes.R")


