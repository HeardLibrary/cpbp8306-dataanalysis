# Split the data into training and testing sets
data_split <- initial_split(na.omit(penguins), prop = 0.8)
train_data <- training(data_split)
test_data <- testing(data_split)

###################
# Random forest
###################
# Define the random forest model
rf_model <- rand_forest() %>%
  set_engine("ranger", importance = "impurity") %>%
  set_mode("classification")

# Fit the random forest model to the training data
rf_fit <- rf_model %>%
  fit(sex ~ bill_length_mm + bill_depth_mm + flipper_length_mm, data = train_data)

# Print the variable importance plot
vip(rf_fit)

# Make predictions on the test data and get the predicted probabilities
# This will allow us to evaluate the model using ROC and AUC
rf_prob <- predict(rf_fit, new_data = test_data, type = "prob")

# Calculate the ROC curve and the AUC
rf_roc_obj <- roc(test_data$sex, rf_prob$.pred_female)
rf_auc_value <- auc(rf_roc_obj)

# Plot the ROC curve
plot(rf_roc_obj)
rf_auc_value

#####################
# K-Nearest Neighbors
#####################
# Define the k-nearest neighbors regression model
knn_model <- nearest_neighbor(neighbors = tune()) %>%
  set_engine("kknn") %>%
  set_mode("classification")

# Tune the k-nearest neighbors model using 5-fold cross-validation
knn_tune <- tune_grid(
  knn_model,
  sex ~ bill_length_mm + bill_depth_mm + flipper_length_mm,
  resamples = vfold_cv(train_data, v = 5),
  grid = grid_regular(neighbors(range = c(1, 15)), levels = 5)
)

# Select the best k-nearest neighbors model based on the lowest RMSE during tuning
best_knn <- select_best(knn_tune, metric = "roc_auc")

# Fit the final k-nearest neighbors model on the full training data
final_knn <- finalize_model(knn_model, best_knn) %>%
  fit(sex ~ bill_length_mm + bill_depth_mm + flipper_length_mm, data = train_data)

# Evaluate the k-nearest neighbors model performance on the test data
# Make predictions on the test data and get the predicted probabilities
# This will allow us to evaluate the model using ROC and AUC
knn_prob <- predict(final_knn, new_data = test_data, type = "prob")

# Calculate the ROC curve and the AUC
knn_roc_obj <- roc(test_data$sex, knn_prob$.pred_female)
knn_auc_value <- auc(knn_roc_obj)

# Plot the ROC curve
plot(knn_roc_obj)
knn_auc_value

# Compare ROC plots
plot(rf_roc_obj, col = "red")
plot(knn_roc_obj, col = "blue", add = TRUE)
rf_auc_value
knn_auc_value
