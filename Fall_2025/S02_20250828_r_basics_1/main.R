#####################
##### Libraries #####
#####################
pacman::p_load(tidyverse, 
               devtools,
               janitor)

#####################
##### Load data #####
#####################
schools_tibble <- read_csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/gis/wg/Metro_Nashville_Schools.csv") %>% clean_names()
#write_csv(schools_tibble, "raw_data/schools_tibble.csv")
#write_csv(schools_tibble, "data/schools_tibble.csv")
#schools_tibble <- read_csv("data/schools_tibble.csv")

#####################
###### Scripts ######
#####################
## Clean schools_tibble 
source("scripts/0_clean_data.R")


