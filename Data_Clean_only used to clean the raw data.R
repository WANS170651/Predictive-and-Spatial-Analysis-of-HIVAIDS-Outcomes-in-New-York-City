# Load packages
# install.packages("janitor")
library(dplyr)
library(tidyr)
library(janitor)
library(ggplot2)

# 1. Read data
data_raw <- read.csv("DOHMH_HIV_AIDS_Annual_Report_20250305.csv", 
                     stringsAsFactors = FALSE, 
                     na.strings = c("", "NA"))
str(data_raw)
summary(data_raw)
head(data_raw)

# 2. Clean column names
data <- data_raw %>% clean_names()

# 3. Replace 99999 with NA in numeric columns
num_vars <- sapply(data, is.numeric)
data[num_vars] <- lapply(data[num_vars], function(x) ifelse(x == 99999, NA, x))

# 4. Check missing values
missing_summary <- sapply(data, function(x) sum(is.na(x)))
print(missing_summary)

# 5. Recode key variables
if("age" %in% names(data)) {
  summary(data$age)
  data <- data %>%
    mutate(age_group = case_when(
      age < 20 ~ "<20",
      age >= 20 & age < 30 ~ "20-29",
      age >= 30 & age < 40 ~ "30-39",
      age >= 40 & age < 50 ~ "40-49",
      age >= 50 ~ "50+",
      TRUE ~ "Unknown"
    ))
  data$age_group <- factor(data$age_group, levels = c("<20", "20-29", "30-39", "40-49", "50+"))
}

if("race" %in% names(data)) {
  data$race <- as.factor(data$race)
}

# 6. Clean indicator variables (remove non-numeric chars)
rate_vars <- c("hiv_diagnosis_rate", "aids_diagnosis_rate", "death_rate", "hiv_related_death_rate", "x_viral_suppression")
for (var in rate_vars) {
  if(var %in% names(data)) {
    data[[var]] <- as.numeric(gsub("[^0-9\\.]", "", data[[var]]))
  }
}

# 7. Fix x_viral_suppression out-of-range values
if("x_viral_suppression" %in% names(data)) {
  data <- data %>%
    mutate(x_viral_suppression = ifelse(x_viral_suppression > 100 | x_viral_suppression < 0, NA, x_viral_suppression))
}

# 8. Create new variable: diagnosis_to_death_ratio
if(all(c("hiv_diagnosis_rate", "death_rate") %in% names(data))) {
  data <- data %>%
    mutate(diagnosis_to_death_ratio = hiv_diagnosis_rate / death_rate)
}

# 9. Pivot data if diagnosis_* columns exist
diagnoses_cols <- grep("^diagnoses_", names(data), value = TRUE)
if(length(diagnoses_cols) > 0) {
  data_long <- data %>%
    pivot_longer(cols = all_of(diagnoses_cols), 
                 names_to = "year", 
                 values_to = "diagnoses") %>%
    mutate(year = gsub("diagnoses_", "", year))
  print(head(data_long))
}

# 10. Final data check
summary(data)
head(data)

# 11. Export cleaned data
write.csv(data, "DOHMH_HIV_AIDS_Cleaned.csv", row.names = FALSE)
