####################
# K-Means Clustering
####################
# Plot iris sepal dimensions
sepal_plot <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point(size = 2) +
  scale_color_discrete(name = "Cluster") +
  labs(
    title = "K-Means Clustering of Iris Dataset",
    x = "Sepal Length",
    y = "Sepal Width"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )
sepal_plot

# Plot iris petal dimensions
petal_plot <- ggplot(iris, aes(x = Petal.Length, y = Petal.Width, color = Species)) +
  geom_point(size = 2) +
  scale_color_discrete(name = "Cluster") +
  labs(
    title = "K-Means Clustering of Iris Dataset",
    x = "Petal Length",
    y = "Petal Width"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )
petal_plot
sepal_plot + petal_plot

# Perform k-means clustering with various values of k
k2 <- kmeans(iris[, 1:4], centers = 2, nstart = 25)
k3 <- kmeans(iris[, 1:4], centers = 3, nstart = 25)
k4 <- kmeans(iris[, 1:4], centers = 4, nstart = 25)
k5 <- kmeans(iris[, 1:4], centers = 5, nstart = 25)

# plots to compare
p1 <- fviz_cluster(k2, geom = "point", data = iris[, 1:4]) + ggtitle("k = 2")
p2 <- fviz_cluster(k3, geom = "point",  data = iris[, 1:4]) + ggtitle("k = 3")
p3 <- fviz_cluster(k4, geom = "point",  data = iris[, 1:4]) + ggtitle("k = 4")
p4 <- fviz_cluster(k5, geom = "point",  data = iris[, 1:4]) + ggtitle("k = 5")

# Make grid plot
grid.arrange(p1, p2, p3, p4, nrow = 2)

# Compute optimal number of clusters
fviz_nbclust(iris[, 1:4], kmeans, method = "wss")
fviz_nbclust(iris[, 1:4], kmeans, method = "silhouette")
gap_stat <- clusGap(iris[, 1:4], FUN = kmeans, nstart = 25,
                    K.max = 10, B = 50)
fviz_gap_stat(gap_stat)

# Setting random number to same value for consistent clusters
set.seed(123)

# Run k-means
k <- 3
km_model <- kmeans(iris[, 1:4], centers = k, iter.max = 10, nstart = 1)

# Print cluster assignments
print(km_model$cluster)

# Visualize the clusters
fviz_cluster(km_model, data = iris[, 1:4])

# Compare the cluster assignments with the actual species
table(iris$Species, km_model$cluster)

# Compute the silhouette score
silhouette_score <- silhouette(km_model$cluster, dist(iris[, 1:4]))

# Plot the silhouette plot
fviz_silhouette(silhouette_score)

# Compute the within-cluster sum of squares
km_model$tot.withinss
# Compute the between-cluster sum of squares
km_model$betweenss
# Compute the total sum of squares
km_model$totss
# Compute the proportion of variance explained
km_model$betweenss / km_model$totss
# Compute the within-cluster sum of squares for each cluster
km_model$withinss
# Compute the size of each cluster
km_model$size
# Compute the centers of each cluster
km_model$centers

# Create the ggplots of sepal and petal dimensions
data <- cbind(iris[, 1:5], cluster = as.factor(km_model$cluster))
sepal_plot <- ggplot(data, aes(x = Sepal.Length, y = Sepal.Width, color = cluster)) +
  geom_point(size = 2) +
  scale_color_discrete(name = "Cluster") +
  labs(
    title = "K-Means Clustering of Iris Dataset",
    x = "Sepal Length",
    y = "Sepal Width"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )
sepal_plot

petal_plot <- ggplot(data, aes(x = Petal.Length, y = Petal.Width, color = cluster)) +
  geom_point(size = 2) +
  scale_color_discrete(name = "Cluster") +
  labs(
    title = "K-Means Clustering of Iris Dataset",
    x = "Petal Length",
    y = "Petal Width"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )
petal_plot

#########################################
# Gaussian Mixture Model (GMM) Clustering
#########################################
# Fit the GMM model
gmm_model <- Mclust(iris[, 1:4], G = 3)

# Print cluster assignments
print(gmm_model$classification)

# Visualize the clusters
fviz_cluster(gmm_model, data = iris[, 1:4])

# Compare the cluster assignments with the actual species
table(iris$Species, gmm_model$classification)

# Compute the centers of each cluster
gmm_model$parameters$mean

# Compute the Bayesian Information Criterion (BIC)
gmm_model$BIC

# Compute the silhouette score
silhouette_score <- silhouette(gmm_model$classification, dist(iris[, 1:4]))

# Plot the silhouette plot
fviz_silhouette(silhouette_score)

# Create the ggplots of sepal and petal dimensions
sepal_plot <- ggplot(data, aes(x = Sepal.Length, y = Sepal.Width, color = as.factor(gmm_model$classification))) +
  geom_point(size = 2) +
  scale_color_discrete(name = "Cluster") +
  labs(
    title = "GMM Clustering of Iris Dataset",
    x = "Sepal Length",
    y = "Sepal Width"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )
sepal_plot

######################################################
# Hierarchical Clustering (agglomerative and divisive)
######################################################
# Calculate the distance matrix
dist_matrix <- dist(iris[, 1:4])

# Perform agglomerative clustering
hc_model <- hclust(dist_matrix)

# Cut the dendrogram to get the clusters
hc_clusters <- cutree(hc_model, k = 3)

# Perform divisive clustering
dc_model <- diana(iris[, 1:4])

# Cut the dendrogram to get the clusters
dc_clusters <- cutree(dc_model, k = 3)

# Visualize the dendrograms
plot(hc_model)
rect.hclust(hc_model, k = 3, border = c("red", "blue", "green"))
plot(dc_model)
rect.hclust(dc_model, k = 3, border = c("red", "blue", "green"))

# Visualize the clusters
fviz_cluster(list(data = iris[, 1:4], cluster = hc_clusters))
fviz_cluster(list(data = iris[, 1:4], cluster = dc_clusters))

# Compare the cluster assignments with the actual species
table(iris$Species, hc_clusters)
table(iris$Species, dc_clusters)

# Compute the silhouette score
silhouette_score_hc <- silhouette(hc_clusters, dist(iris[, 1:4]))
fviz_silhouette(silhouette_score_hc)
silhouette_score_dc <- silhouette(dc_clusters, dist(iris[, 1:4]))
fviz_silhouette(silhouette_score_dc)

# Create the ggplot of the dendrogram
ggdendrogram(hc_model, rotate = TRUE) +
  geom_hline(yintercept = hc_model$height[which.max(diff(hc_model$height))], 
             color = "grey50", linetype = "dashed") +
  theme_dendro() +
  labs(title = "Hierarchical Clustering Dendrogram",
       x = "Observations",
       y = "Height")

###################
# DBSCAN Clustering
###################
# DBSCAN Clustering
# Define the parameters
eps <- 0.5
min_samples <- 5

# Perform DBSCAN clustering
db_model <- dbscan(iris[, 1:4], eps = eps, minPts = min_samples)

# Print cluster assignments
print(db_model$cluster)

# Visualize the clusters
fviz_cluster(list(data = iris[, 1:4], cluster = db_model$cluster))

# Compare the cluster assignments with the actual species
table(iris$Species, db_model$cluster)

# Compute the silhouette score
silhouette_score <- silhouette(db_model$cluster, dist(iris[, 1:4]))

# Plot the silhouette plot
fviz_silhouette(silhouette_score)

# Create the ggplots of sepal and petal dimensions
data <- cbind(iris[, 1:5], cluster = as.factor(db_model$cluster))
sepal_plot <- ggplot(data, aes(x = Sepal.Length, y = Sepal.Width, color = cluster)) +
  geom_point(size = 2) +
  scale_color_discrete(name = "Cluster") +
  labs(
    title = "DBSCAN Clustering of Iris Dataset",
    x = "Sepal Length",
    y = "Sepal Width"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )
sepal_plot

###############################
# Compare clustering Algorithms
###############################
table(iris$Species, km_model$cluster)
table(iris$Species, gmm_model$classification)
table(iris$Species, hc_clusters)
table(iris$Species, dc_clusters)
table(iris$Species, db_model$cluster)

