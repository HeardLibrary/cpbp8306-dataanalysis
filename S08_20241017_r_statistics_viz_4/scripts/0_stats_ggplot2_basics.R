# --------------------
# Base stats
# --------------------
# Single variables
mean(na.omit(schools_data$Grade.1)) # Calculates the arithmetic mean of a numeric vector.
median(na.omit(schools_data$Grade.1)) # Calculates the median of a numeric vector.
sd(na.omit(schools_data$Grade.1)) # Calculates the standard deviation of a numeric vector.
var(na.omit(schools_data$Grade.1)) # Calculates the variance of a numeric vector.
min(na.omit(schools_data$Grade.1)) # Finds the minimum value in a numeric vector.
max(na.omit(schools_data$Grade.1)) # Finds the maximum value in a numeric vector.
sum(na.omit(schools_data$Grade.1)) # Calculates the sum of the elements in a numeric vector.

# Relationships between variables
## Combine variables into data.frame
school_demographics <- na.omit(data.frame(subset(schools_data, select = c(School.Level, Zip.Code, White, Economically.Disadvantaged, Hispanic.Latino, Limited.English.Proficiency))))
school_demographics$School.Level <- as.factor(as.character(school_demographics$School.Level))
school_demographics$Zip.Code <- as.factor(as.character(school_demographics$Zip.Code))
## Correlation
cor(school_demographics$Economically.Disadvantaged, school_demographics$Limited.English.Proficiency, method = "spearman") # Calculates the correlation between two numeric vectors.
## t-test
t.test(school_demographics$Economically.Disadvantaged) # Performs a t-test on a numeric vector or two numeric vectors.
t.test(Economically.Disadvantaged ~ School.Level, data=subset(school_demographics, School.Level %in% c("High School", "Elementary School"))) # Performs a two sided t-test
## Chi-square test
chisq.test(school_demographics$Economically.Disadvantaged, school_demographics$School.Level) # Performs a chi-square test of independence on a contingency table.
school_demographics %>% group_by(School.Level) %>% summarise(count = n()) # Summarizes the number of observations in each group.
## Linear regression
model1 <- lm(Economically.Disadvantaged ~ Hispanic.Latino + Limited.English.Proficiency, data = school_demographics) # Performs linear regression on a dataset.
model1
summary(model1) # Summarizes the output of a linear regression model.
# ANOVA
anova(model1) # Performs analysis of variance (ANOVA) on a statistical model.

# --------------------
# stats package aov()
# --------------------
model2 <- lm(White ~ School.Level, data = school_demographics) # Performs linear regression on a dataset.
aov(model2) # Performs analysis of variance (ANOVA) on a statistical model.
TukeyHSD(aov(model2)) # Performs Tukey's Honest Significant Differences (HSD) test on a dataset.

# --------------------
# Plots
# --------------------
# **One-dimensional plot (histogram)**

# Generic R hist() function for histograms
hist(schools_data$Female)

# Create a histogram using ggplot
ggplot(data = schools_data) + geom_histogram(mapping = aes(x = Female), binwidth = 100)

# Assigning one of the functions to a variable
base_plot <- ggplot(data = schools_data)
base_plot + geom_histogram(mapping = aes(x = Female), binwidth = 100)

# For multiline, must have a trailing + sign.
ggplot(data = schools_data) +
  geom_histogram(mapping = aes(x = Female), binwidth = 100)

# **Two-dimensional plot: box and whisker**
# A simple way to compare two categories of data is a box and whisker plot.
# The category x is a discontinuous factor and the measurement y is a continuous variable. 
# The generic R function uses the form:
# plot(y ~ x)
# This only works for a data frame where characters are read in as factors, NOT for tibbles.
# So read.csv() must be used, not read_csv().

str(human_data) 
# Notice that characters were read in as factors (normal for generic dataframes but not tibbles)

plot(human_data$height ~ as.factor(human_data$grouping))

# ggplot typically uses tibbles, but doesn't seem to have a problem with a generic data frame
ggplot(data = human_data) +
  geom_boxplot(mapping = aes(x = grouping, y = height))

# **Two-dimensional plot: scatterplot**

# The standard R scatterplot uses the same syntax as for box and whisker:
# plot(y ~ x)
# with x as the limited English proficiency variable
# and y as the economically disadvantaged variable
# Both x and y must be continuous numeric values.
plot(schools_data$Economically.Disadvantaged ~ schools_data$Limited.English.Proficiency)
plot(schools_data$Economically.Disadvantaged ~ schools_data$Limited.English.Proficiency, 
     col = "blue", main = "Economically Disadvantaged vs Limited English Proficiency", 
     xlab = "Limited English Proficiency", ylab = "Economically Disadvantaged")

# Create a similar scatterplot using ggplot
ggplot(data = schools_data) +
  geom_point(mapping = aes(x = Limited.English.Proficiency, y = Economically.Disadvantaged))

# Fit these two data to a linear model using
# model <- lm(y ~ x)

model <- lm(schools_data$Economically.Disadvantaged ~ schools_data$Limited.English.Proficiency)

# We can add the best fit line to our plot using the abline() function:

plot(schools_data$Economically.Disadvantaged ~ schools_data$Limited.English.Proficiency)
abline(model)

# Create a scatterplot using ggplot that includes the best fit line through the data
ggplot(data = schools_data, aes(x = Limited.English.Proficiency, y = Economically.Disadvantaged)) +
  geom_point() +
  geom_smooth(method = "lm")

# Annotate the plot with the R2 value and p-value
ggplot(data = schools_data, aes(x = Limited.English.Proficiency, y = Economically.Disadvantaged)) +
  geom_point() +
  geom_smooth(method = "lm") +
  annotate("text", x = 600, y = 100, label = paste("R2 = ", round(summary(model)$r.squared, 2), "\n", 
                                                   "p = ", round(summary(model)$coefficients[8], 4)))

# -------------------------
# Loading in data to ggplot
# -------------------------
# Create a scatterplot using ggplot that includes the best fit line through the data
# universal mapping to reduce redundancy
ggplot(data = schools_data, aes(x = Limited.English.Proficiency, y = Economically.Disadvantaged)) +
  geom_point() +
  geom_smooth(method = "lm")
# local mapping to specify different data and aesthetics
ggplot() +
  geom_point(data = schools_data, mapping = aes(x = Limited.English.Proficiency, y = Economically.Disadvantaged)) +
  geom_smooth(data = schools_data, mapping = aes(x = Limited.English.Proficiency, y = Economically.Disadvantaged), method = "lm")
# piping in data using dplyr
schools_data %>%
  ggplot(aes(x = Limited.English.Proficiency, y = Economically.Disadvantaged)) +
  geom_point() +
  geom_smooth(method = "lm")

# -------------------------
# Combine and export plots
# -------------------------

english_distadvantage_plot <- ggplot(data = subset(schools_data, School.Level %in% c("Charter", "Elementary School", "High School", "Middle School")), 
                                     aes(x = Limited.English.Proficiency, y = Economically.Disadvantaged)) +
                                     geom_point() +
                                     geom_smooth(method = "lm")
english_distadvantage_level_plot <- ggplot(data = subset(schools_data, School.Level %in% c("Charter", "Elementary School", "High School", "Middle School")), 
                                                         aes(x = Limited.English.Proficiency, y = Economically.Disadvantaged, color = School.Level)) +
                                    geom_point() +
                                    geom_smooth(method = "lm") + 
                                    theme(legend.position = "bottom")
# patchwork package to combine plots
combo_plot <- english_distadvantage_plot + english_distadvantage_level_plot
combo_plot
combo_plot <- english_distadvantage_plot | english_distadvantage_level_plot
combo_plot
combo_plot <- english_distadvantage_plot / english_distadvantage_level_plot
combo_plot
# Annotate plot
combo_plot <- english_distadvantage_plot / english_distadvantage_level_plot
combo_plot <- combo_plot + plot_annotation(tag_levels = "a")
combo_plot
# Export plot
ggsave("output/combo_plot.png", plot = combo_plot, width = 6, height = 10, units = "in", dpi = 300)

# -------------------------
# Exercise
# -------------------------
# Find a significant correlation (p<=0.05) between two variables in the schools_data dataset using lm()
# Which variables are related? What is the R2 value? What is the p-value?

# Plot the relationship between these two variables using ggplot2
# Add the best fit line to the plot
# Annotate the plot with the R2 value and p-value


