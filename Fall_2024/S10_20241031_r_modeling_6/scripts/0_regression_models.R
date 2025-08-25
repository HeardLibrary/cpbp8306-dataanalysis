# Split the data into training and testing sets
data_split <- initial_split(na.omit(penguins), prop = 0.8)
train_data <- training(data_split)
test_data <- testing(data_split)

###################
# Linear regression
###################
# Fit the linear regression model to the training data
lin_reg_fit <- linear_reg() %>% set_engine("lm") %>%
  fit(body_mass_g ~ bill_length_mm + bill_depth_mm + flipper_length_mm, data = train_data)
tidy(lin_reg_fit)

# Make predictions on the test data using the trained linear regression model
lin_reg_pred <- predict(lin_reg_fit, new_data = test_data)

# Evaluate the linear regression model performance on the test data
rmse_vec(test_data$body_mass_g, lin_reg_pred$.pred)
rsq_vec(test_data$body_mass_g, lin_reg_pred$.pred)

###################
# Decision tree
###################
# Define the decision tree regression model
tree_model <- decision_tree() %>%
  set_engine("rpart") %>%
  set_mode("regression")

# Fit the decision tree model to the training data
tree_fit <- tree_model %>%
  fit(body_mass_g ~ bill_length_mm + bill_depth_mm + flipper_length_mm, data = train_data)

# Make predictions on the test data using the trained decision tree model
tree_pred <- predict(tree_fit, new_data = test_data)

# Print the variable importance plot
vip(tree_fit)

# Evaluate the decision tree model performance on the test data
rmse_vec(test_data$body_mass_g, tree_pred$.pred)
rsq_vec(test_data$body_mass_g, tree_pred$.pred)

###################
# Random forest
###################
# Define the random forest model
rf_model <- rand_forest() %>%
  set_engine("ranger", importance = "impurity") %>%
  set_mode("regression")

# Fit the random forest model to the training data
rf_fit <- rf_model %>%
  fit(body_mass_g ~ bill_length_mm + bill_depth_mm + flipper_length_mm, data = train_data)

# Make predictions on the test data using the trained random forest model
rf_pred <- predict(rf_fit, new_data = test_data)

# Print the variable importance plot
vip(rf_fit)

# Evaluate the random forest model performance on the test data
rmse_vec(test_data$body_mass_g, rf_pred$.pred)
rsq_vec(test_data$body_mass_g, rf_pred$.pred)

###################
# LASSO Regression
###################
# Define the LASSO regression model
# The penalty parameter controls the amount of shrinkage applied to the model coefficients
# We'll tune this parameter later
lasso_model <- linear_reg(penalty = tune(), mixture = 1) %>%
  set_engine("glmnet")

# Define the parameter grid to tune the LASSO model
# We'll try 20 different values of the penalty parameter
lasso_grid <- grid_regular(penalty(range = c(-4, -1)), levels = 20)

# Tune the LASSO model using 5-fold cross-validation
# This will help us find the optimal value of the penalty parameter
lasso_tune <- tune_grid(
  lasso_model,
  body_mass_g ~ bill_length_mm + bill_depth_mm + flipper_length_mm,
  resamples = vfold_cv(train_data, v = 5),
  grid = lasso_grid
)

# Select the best LASSO model based on the lowest RMSE during tuning
best_lasso <- select_best(lasso_tune, metric = "rmse")

# Fit the final LASSO model on the full training data
# Using the optimal penalty parameter found during tuning
final_lasso <- finalize_model(lasso_model, best_lasso) %>%
  fit(body_mass_g ~ bill_length_mm + bill_depth_mm + flipper_length_mm, data = train_data)

# Print the variable names and coefficients
lasso_coefs <- coef(final_lasso$fit, s = best_lasso$penalty)
lasso_coefs

# Make predictions on the test data using the trained LASSO model
# Get the predicted probabilities instead of just the predictions
lasso_pred <- predict(final_lasso, new_data = test_data)

# Evaluate the LASSO model performance on the test data
rmse_vec(test_data$body_mass_g, lasso_pred$.pred)
rsq_vec(test_data$body_mass_g, lasso_pred$.pred)

#####################
# K-Nearest Neighbors
#####################
# Define the k-nearest neighbors regression model
knn_model <- nearest_neighbor(neighbors = tune()) %>%
  set_engine("kknn") %>%
  set_mode("regression")

# Tune the k-nearest neighbors model using 5-fold cross-validation
knn_tune <- tune_grid(
  knn_model,
  body_mass_g ~ bill_length_mm + bill_depth_mm + flipper_length_mm,
  resamples = vfold_cv(train_data, v = 5),
  grid = grid_regular(neighbors(range = c(1, 15)), levels = 5)
)

# Select the best k-nearest neighbors model based on the lowest RMSE during tuning
best_knn <- select_best(knn_tune, metric = "rmse")

# Fit the final k-nearest neighbors model on the full training data
final_knn <- finalize_model(knn_model, best_knn) %>%
  fit(body_mass_g ~ bill_length_mm + bill_depth_mm + flipper_length_mm, data = train_data)

# Make predictions on the test data using the trained k-nearest neighbors model
knn_pred <- predict(final_knn, new_data = test_data)

# Evaluate the k-nearest neighbors model performance on the test data
rmse_vec(test_data$body_mass_g, knn_pred$.pred)
rsq_vec(test_data$body_mass_g, knn_pred$.pred)

###########################
# Compare Model Performance
###########################
# Compare the performance of the models
results <- tibble(
  model = c("Linear Regression", "Decision Tree", "Random Forest", "LASSO Regression", "K-Nearest Neighbors"),
  rmse = c(
    rmse_vec(test_data$body_mass_g, lin_reg_pred$.pred),
    rmse_vec(test_data$body_mass_g, tree_pred$.pred),
    rmse_vec(test_data$body_mass_g, rf_pred$.pred),
    rmse_vec(test_data$body_mass_g, lasso_pred$.pred),
    rmse_vec(test_data$body_mass_g, knn_pred$.pred)
  ),
  r_squared = c(
    rsq_vec(test_data$body_mass_g, lin_reg_pred$.pred),
    rsq_vec(test_data$body_mass_g, tree_pred$.pred),
    rsq_vec(test_data$body_mass_g, rf_pred$.pred),
    rsq_vec(test_data$body_mass_g, lasso_pred$.pred),
    rsq_vec(test_data$body_mass_g, knn_pred$.pred)
  )
)

# Print the model performance summary
print(results)

####################
# Diagnostic Plots
####################
# Residuals vs Fitted
par(mfrow = c(3, 2))
plot(lin_reg_pred$.pred, lin_reg_pred$.pred - test_data$body_mass_g, main = "Residuals vs Fitted - Linear Regression")
plot(tree_pred$.pred, tree_pred$.pred - test_data$body_mass_g, main = "Residuals vs Fitted - Decision Tree")
plot(rf_pred$.pred, rf_pred$.pred - test_data$body_mass_g, main = "Residuals vs Fitted - Random Forest")
plot(lasso_pred$.pred, lasso_pred$.pred - test_data$body_mass_g, main = "Residuals vs Fitted - LASSO Regression")
plot(knn_pred$.pred, knn_pred$.pred - test_data$body_mass_g, main = "Residuals vs Fitted - K-Nearest Neighbors")

# QQ Plot
par(mfrow = c(3, 2))
qqnorm(lin_reg_pred$.pred - test_data$body_mass_g, main = "QQ Plot - Linear Regression")
qqline(lin_reg_pred$.pred - test_data$body_mass_g)
qqnorm(tree_pred$.pred - test_data$body_mass_g, main = "QQ Plot - Decision Tree")
qqline(tree_pred$.pred - test_data$body_mass_g)
qqnorm(rf_pred$.pred - test_data$body_mass_g, main = "QQ Plot - Random Forest")
qqline(rf_pred$.pred - test_data$body_mass_g)
qqnorm(lasso_pred$.pred - test_data$body_mass_g, main = "QQ Plot - LASSO Regression")
qqline(lasso_pred$.pred - test_data$body_mass_g)
qqnorm(knn_pred$.pred - test_data$body_mass_g, main = "QQ Plot - K-Nearest Neighbors")
qqline(knn_pred$.pred - test_data$body_mass_g)

# Scale-Location Plot
par(mfrow = c(3, 2))
plot(lin_reg_pred$.pred, sqrt(abs(lin_reg_pred$.pred - test_data$body_mass_g)), main = "Scale-Location Plot - Linear Regression")
plot(tree_pred$.pred, sqrt(abs(tree_pred$.pred - test_data$body_mass_g)), main = "Scale-Location Plot - Decision Tree")
plot(rf_pred$.pred, sqrt(abs(rf_pred$.pred - test_data$body_mass_g)), main = "Scale-Location Plot - Random Forest")
plot(lasso_pred$.pred, sqrt(abs(lasso_pred$.pred - test_data$body_mass_g)), main = "Scale-Location Plot - LASSO Regression")
plot(knn_pred$.pred, sqrt(abs(knn_pred$.pred - test_data$body_mass_g)), main = "Scale-Location Plot - K-Nearest Neighbors")

