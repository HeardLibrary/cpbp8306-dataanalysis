#####################
##### Libraries #####
#####################
pacman::p_load(tidyverse,
               stats,
               patchwork)

#####################
##### Load data #####
#####################
#schools_data <- read.csv("https://raw.githubusercontent.com/HeardLibrary/digital-scholarship/master/data/gis/wg/Metro_Nashville_Schools.csv")
#human_data <- read.csv("https://gist.githubusercontent.com/baskaufs/1a7a995c1b25d6e88b45/raw/4bb17ccc5c1e62c27627833a4f25380f27d30b35/t-test.csv")
#write.csv(schools_data, "data/schools_data.csv", row.names = FALSE)
#write.csv(human_data, "data/human_data.csv", row.names = FALSE)
schools_data <- read_csv("data/schools_data.csv")
human_data <- read_csv("data/human_data.csv")

#####################
###### Scripts ######
#####################
## Clean raw_data file.csv and write to data/clean_file.csv
source("scripts/0_stats_ggplot2_basics.R")


