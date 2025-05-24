library(dplyr)
library(caret)
library(randomForest)
library(pROC)


data <- read.csv("DOHMH_HIV_AIDS_Cleaned.csv")

# Convert x_linked_to_care_within_3_months to a categorical variable.
# Set 80% as the threshold
data <- data %>%
  mutate(linked_to_care_binary = ifelse(x_linked_to_care_within_3_months >= 0.8, "Yes", "No")) %>%
  mutate(linked_to_care_binary = as.factor(linked_to_care_binary))

# Select the variables needed for modeling
model_data <- data %>%
  select(linked_to_care_binary, 
         hiv_diagnosis_rate, 
         aids_diagnosis_rate, 
         death_rate, 
         x_viral_suppression, 
         borough, 
         uhf)

# Set the categorical variables as factors
model_data$borough <- as.factor(model_data$borough)
model_data$uhf <- as.factor(model_data$uhf)

# Split the data into training and testing sets
set.seed(123) 
train_index <- createDataPartition(model_data$linked_to_care_binary, p = 0.8, list = FALSE)
train_data <- model_data[train_index, ]
test_data <- model_data[-train_index, ]

# Build a Logistic Regression model
logit_model <- glm(linked_to_care_binary ~ ., 
                   data = train_data, 
                   family = binomial)

summary(logit_model)

# Make predictions on the test set
logit_pred_prob <- predict(logit_model, newdata = test_data, type = "response")

# Classify based on a 0.5 threshold
logit_pred_class <- ifelse(logit_pred_prob > 0.5, "Yes", "No") %>% as.factor()

# Model Evaluation
# Confusion Matrix
conf_mat <- confusionMatrix(logit_pred_class, test_data$linked_to_care_binary)
print(conf_mat)

# ROC Curve and AUC
roc_obj <- roc(test_data$linked_to_care_binary, logit_pred_prob, levels = rev(levels(test_data$linked_to_care_binary)))
plot(roc_obj, main = "ROC Curve - Logistic Regression")
auc_val <- auc(roc_obj)
print(paste("AUC =", round(auc_val, 4)))

# List of important variables (sorted by p-value)
coef_table <- summary(logit_model)$coefficients
coef_table <- as.data.frame(coef_table)
coef_table$Variable <- rownames(coef_table)
coef_table <- coef_table %>%
  arrange(`Pr(>|z|)`) 

print(coef_table)

# Conclusion
# The ROC curve for the logistic regression model displays moderate discriminatory ability, with an AUC of 0.6895. 
# The curve remains mostly above the diagonal reference line, 
# indicating that the model performs better than random guessing when distinguishing between regions with high and low timely care linkage. 
# However, the tradeoff between sensitivity and specificity suggests room for improvement, especially in identifying minority class instances.



# K-means clustering analysis
library(dplyr)
library(ggplot2)
library(cluster)
library(factoextra)

# Keep only HIV-related numerical indicators and the geographic variable (UHF)
cluster_data <- data %>%
  select(uhf,
         hiv_diagnosis_rate,
         aids_diagnosis_rate,
         x_viral_suppression,
         death_rate,
         hiv_related_death_rate) %>%
  group_by(uhf) %>%
  summarise(across(where(is.numeric), mean, na.rm = TRUE))  # Calculate the average by UHF region

# Save UHF as a region name column; use the remaining variables for clustering
uhf_labels <- cluster_data$uhf
cluster_numeric <- cluster_data %>% select(-uhf)

# Standardize the data
cluster_scaled <- scale(cluster_numeric)

# Select the number of clusters KK using the Elbow Method
fviz_nbclust(cluster_scaled, kmeans, method = "wss") +
  theme_minimal() +
  ggtitle("Elbow Method for Optimal K")

# Assume we select K=3
set.seed(123)
k3 <- kmeans(cluster_scaled, centers = 3, nstart = 25)

# Visualize the clustering results (after dimensionality reduction using PCA)
fviz_cluster(k3, data = cluster_scaled, labelsize = 10,
             main = "K-means Clustering of UHF Regions",
             geom = "point", repel = TRUE) +
  theme_minimal()

# Merge the clustering results back into the table
cluster_result <- cluster_data %>%
  mutate(cluster = factor(k3$cluster))

print(cluster_result)

# Conclusion
# We applied K-means clustering on NYC UHF regions using HIV diagnosis rate, AIDS diagnosis rate, 
# viral suppression percentage, and death rate as input features. 
# The analysis revealed three clusters of regions with distinct public health profiles.
# Cluster 1 regions, such as Central Harlem and Crotona-Tremont, exhibit high diagnosis rates and low suppression, 
# indicating high-priority areas for intervention.
# Cluster 2 includes mid-range indicators but elevated death rates, suggesting resource constraints or post-treatment barriers.
# Cluster 3 regions demonstrate better viral suppression and lower HIV impact, indicating successful care programs.
# This spatial segmentation can support targeted policy and outreach strategies.

library(dplyr)

cluster_summary <- cluster_result %>%
  filter(uhf != "All") %>%
  group_by(cluster) %>%
  summarise(
    avg_hiv_rate = round(mean(hiv_diagnosis_rate, na.rm = TRUE), 1),
    avg_suppression = round(mean(x_viral_suppression, na.rm = TRUE), 1),
    avg_death_rate = round(mean(death_rate, na.rm = TRUE), 1),
    top_regions = paste(head(uhf[order(-hiv_diagnosis_rate)], 3), collapse = ", ")
  )
for (i in 1:nrow(cluster_summary)) {
  cat(paste0("Cluster ", cluster_summary$cluster[i], ":\n"))
  cat("  Avg HIV Diagnosis Rate: ", cluster_summary$avg_hiv_rate[i], "\n")
  cat("  Avg Viral Suppression: ", cluster_summary$avg_suppression[i], "\n")
  cat("  Avg Death Rate: ", cluster_summary$avg_death_rate[i], "\n")
  cat("  Top Regions: ", cluster_summary$top_regions[i], "\n\n")
}

