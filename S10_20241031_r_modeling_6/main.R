## tidymodels
# https://www.tidymodels.org/

## Libraries
# install.packages("pacman")
# library(pacman)
pacman::p_load(tidyverse,      # A collection of packages for data manipulation and visualization
               tidymodels,     # A framework for machine learning and modeling in R
               ranger,         # An implementation of random forests
               glmnet,         # Implements the LASSO and elastic net regularization methods
               pROC,           # Provides functions for creating and analyzing ROC curves
               kknn,           # An implementation of the k-nearest neighbors algorithm
               vip,            # Variable importance plots
               palmerpenguins) # A dataset of penguin measurements

## Load data
data(penguins, package = "palmerpenguins")

## Scripts
source("scripts/0_regression_models.R")
source("scripts/1_classification_models.R")