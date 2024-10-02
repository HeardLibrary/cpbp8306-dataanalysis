# Data 
## ND Gain: https://gain.nd.edu/our-work/country-index
## Our world in data: https://ourworldindata.org/grapher/co-emissions-per-capita 
## https://www.heritage.org/index/explore 
## Culture variables: https://github.com/damianruck/Cultural_foundations_of_modern_democracies
## Pew data: https://www.pewresearch.org/global/2021/09/14/in-response-to-climate-change-citizens-in-advanced-economies-are-willing-to-alter-how-they-live-and-work/
## WVS data: https://www.worldvaluessurvey.org/wvs.jsp

# Libraries
pacman::p_load(tidyverse,
               janitor,
               countrycode,
               DataExplorer)

# Load data
culture_data <- read_csv("data/culture.csv") %>% clean_names()
wvs_regions_data <- read_csv("data/wvs_regions.csv") %>% clean_names()
co2_data <- read_csv("data/owid_co2_data.csv") %>% clean_names()
pew_climate_data <- read_csv("data/pew_climate.csv") %>% clean_names()
population_data <- read_csv("data/population_nd_gain.csv") %>% clean_names()
vulnerability_data <- read_csv("data/vulnerability_nd_gain.csv") %>% clean_names()
gdp_capita_data <- read_csv("data/gdp_nd_gain.csv") %>% clean_names()

# Scripts
source("scripts/0_clean_combine_data.R")