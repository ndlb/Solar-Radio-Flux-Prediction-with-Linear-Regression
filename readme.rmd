# Overview
This project analyzes solar activity data collected over ten years. The dataset includes various measurements related to solar flares, sunspots, and radio flux. The goal is to preprocess, explore, and model the data to predict solar radio flux.

# Data Processing Steps
The project follows these key steps:

1. **Load Data**: Read 10 `.txt` files containing solar activity data.
2. **Clean Data**:
   - Skip unnecessary header lines.
   - Rename columns for consistency.
   - Merge data into a single dataset.
3. **Exploratory Data Analysis**:
   - Summary statistics (`summary()`).
   - Identify outliers using the IQR method.
   - Filter out incorrect values (e.g., negative Radio Flux).
4. **Visualization**:
   - Generate boxplots for solar radio flux across years.
   - Identify trends in solar flares.
5. **Model Training**:
   - Partition the dataset into **80% training** and **20% testing**.
   - Train a linear regression model to predict **Radio Flux**.
6. **Model Evaluation**:
   - Compute **MAE (Mean Absolute Error)**, **RMSE (Root Mean Squared Error)**, and **R² (coefficient of determination)**.
   - Predict the solar radio flux for a given set of inputs.

# Required Libraries
Before running the script, ensure you have the following R packages installed:
```r
install.packages(c("ggplot2", "caret"))
