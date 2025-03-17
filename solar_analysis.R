# Data Preparation ------------------------------------------------------

# Set working directory (change this to your actual directory)
setwd("path_to_directory/solar_data")

# List files in the solar_data directory
files <- list.files(pattern = "*.txt")

# Read each file, skip the first 10 lines, rename columns, and assign to a variable
for (file in files) {
  file_name <- gsub(".txt", "", file)  # Remove .txt extension for variable naming
  assign(file_name, read.table(file, header = TRUE, sep = "", skip = 10, stringsAsFactors = FALSE))
}

# Verify variables created
ls()

# Examine data structure of individual tables
str(`2014_DSD`)
str(`2015_DSD`)
str(`2016_DSD`)
str(`2017_DSD`)
str(`2018_DSD`)
str(`2019_DSD`)
str(`2020_DSD`)
str(`2021_DSD`)
str(`2022_DSD`)
str(`2023_DSD`)

# Part B: Combine Data ------------------------------------------------------

# Create an empty data frame
combined <- data.frame()

# Append all data sets into one
for (file in files) {
  file_name <- gsub(".txt", "", file)
  combined <- rbind(combined, get(file_name))
}

# Generate summary statistics
summary(combined)

# Analysis of summary statistics --------------------------

# Outliers detection function (IQR method)
find_outliers <- function(data) {
  outliers <- list()
  
  for (col_name in names(data)) {
    if (is.numeric(data[[col_name]])) {
      Q1 <- quantile(data[[col_name]], 0.25, na.rm = TRUE)
      Q3 <- quantile(data[[col_name]], 0.75, na.rm = TRUE)
      IQR <- Q3 - Q1
      lower_bound <- Q1 - 1.5 * IQR
      upper_bound <- Q3 + 1.5 * IQR
      outlier_indices <- which(data[[col_name]] < lower_bound | data[[col_name]] > upper_bound)
      
      if (length(outlier_indices) > 0) {
        outliers[[col_name]] <- outlier_indices
      }
    }
  }
  return(outliers)
}

# Find outliers
outliers <- find_outliers(combined)
print(outliers)

# Remove negative Radio_Flux values
combined <- combined[combined$Radio_Flux >= 0, ]

# Finding Specific Values -------------------------------------------------

# Highest Radio Flux
max_flux_day <- combined[combined$Radio_Flux == max(combined$Radio_Flux), c("Year", "Month", "Day")]
print(max_flux_day)

# Lowest Radio Flux
min_flux_day <- combined[combined$Radio_Flux == min(combined$Radio_Flux), c("Year", "Month", "Day")]
print(min_flux_day)

# Solar Flares Analysis -------------------------------------------------

# Calculate total flares (sum of C, M, and X)
combined$Total_Flares <- combined$Flares_XR_C + combined$Flares_XR_M + combined$Flares_XR_X

# Find day with the most solar flares
max_flares_day <- combined[combined$Total_Flares == max(combined$Total_Flares), c("Year", "Month", "Day")]
print(max_flares_day)

# Count number of days with no solar flares
no_flares_days <- nrow(combined[combined$Total_Flares == 0, ])
print(no_flares_days)

# Generate Boxplot ------------------------------------------------------
library(ggplot2)

ggplot(combined, aes(x = as.factor(Year), y = Radio_Flux)) +
  geom_boxplot(fill = "lightblue", color = "darkblue") +
  labs(title = "Boxplot of Solar Radio Flux by Year",
       x = "Year", y = "Solar Radio Flux") +
  theme_minimal()

# Train-Test Split ------------------------------------------------------
library(caret)

set.seed(123) # Reproducibility
train_index <- createDataPartition(combined$Radio_Flux, p = 0.8, list = FALSE)
train <- combined[train_index, ]
test <- combined[-train_index, ]

# Train Linear Model ---------------------------------------------------
lm_model <- lm(Radio_Flux ~ Sunspot_Number + Flares_XR_C + Flares_XR_M + Flares_XR_X + Optical1 + Optical2 + Optical3, data = train)
summary(lm_model)

# Predictions and Model Evaluation --------------------------------------
# Make predictions on test set
test$Predicted_Radio_Flux <- predict(lm_model, test)

# Calculate evaluation metrics
MAE <- mean(abs(test$Predicted_Radio_Flux - test$Radio_Flux))
RMSE <- sqrt(mean((test$Predicted_Radio_Flux - test$Radio_Flux)^2))
R2 <- summary(lm_model)$r.squared

# Print metrics
print(paste("Mean Absolute Error (MAE):", MAE))
print(paste("Root Mean Squared Error (RMSE):", RMSE))
print(paste("R-Squared:", R2))

