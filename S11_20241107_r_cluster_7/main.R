## tidymodels
# https://www.tidymodels.org/

## Libraries
# install.packages("pacman")
# library(pacman)
pacman::p_load(tidyverse, 
               cluster, 
               factoextra, 
               dbscan,
               mclust,
               ggdendro,
               patchwork,
               gridExtra)

## Load data
data(iris)

## Scripts
source("scripts/0_cluster.R")