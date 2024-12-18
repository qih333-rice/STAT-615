# STAT-615
Modeling Environmental Factors Influencing Dissolved Oxygen Levels in Water Bodies Based on a Regression Analysis


## Project Overview

This project analyzes the environmental factors influencing **Dissolved Oxygen (DO)** levels in aquatic ecosystems. Using statistical models such as **Linear Regression**, **Logistic Regression**, and **Lasso Regression**, the script identifies key predictors (e.g., water temperature, pH, salinity) and evaluates their impact on DO levels. The analysis also explores **seasonal variations** in DO levels and compares the performance of different regression models using metrics like AUC and ROC curves.


## Prerequisites

To successfully run the script, ensure you have:

1. R Installed: Download and install R from [CRAN](https://cran.r-project.org/).  
2. Required R Libraries: Install the following libraries if they are not already installed

   ```r
   install.packages(c("tidyverse", "caret", "glmnet", "MASS", "lubridate", "pROC", "car"))
   ```
4. Dataset: The script uses the file `BKB_WaterQualityData.csv`. Place the file in the same directory as the script, or update the file path in the code.

## How to Run the Code

Follow these steps to run the `regression_code.R` file

### 1. Set Up the Working Directory
Update the working directory to the location where your dataset (`BKB_WaterQualityData.csv`) is stored. You can do this using the `setwd()` function

```r
setwd("/path/to/your/directory")
```
Replace `/path/to/your/directory` with the actual path to your folder.


### 2. Load the Required Libraries
Ensure that all the necessary libraries are loaded. The script automatically loads the libraries

```r
library(tidyverse)
library(caret)
library(glmnet)
library(MASS)
library(lubridate)
library(pROC)
library(car)  
```

If you encounter any errors about missing libraries, use the `install.packages()` function to install them (as shown above).


### 3. Run the Script
Run the script file **`regression_code.R`** in **RStudio** or another R environment. The script performs the following tasks:

1. Load the Dataset**: Reads `BKB_WaterQualityData.csv`

   ```r
   data <- read.csv("/path/to/your/BKB_WaterQualityData.csv")
   ```

3. Data Cleaning
   Checks for missing values.
   Removes rows with missing data using `na.omit()`.

4. Exploratory Data Analysis (EDA):
   Generates scatter plots for:
     Temperature vs DO
     pH vs DO
     Secchi Depth vs DO

   Example plot
   
   ```r
   ggplot(data, aes(x = `Water.Temp...C.`, y = `Dissolved.Oxygen..mg.L.`)) + 
     geom_point() + 
     geom_smooth(method = "lm") +
     labs(title = "Temperature vs Dissolved Oxygen", x = "Temperature (°C)", y = "DO (mg/L)")
   ```

5. Regression Models
   Linear Regression: Identifies significant predictors and calculates the model's Adjusted R².
   Logistic Regression: Predicts hypoxia (DO < 5 mg/L) and calculates the AUC value.
   Lasso Regression: Regularizes the model and selects the most important predictors.
   Generalized Linear Models (GLM): Adds interaction terms to capture complex relationships.

6. Model Evaluation
   Calculates ROC Curves and AUC Values for comparison
   
     ```r
     plot(logistic_roc, col = "blue", lwd = 2, main = "ROC Curves for Multiple Models")
     lines(glm_roc, col = "green", lwd = 2)
     lines(lasso_roc, col = "red", lwd = 2)
     legend("bottomright", legend = c("Logistic Regression", "GLM", "Lasso Regression"),
            col = c("blue", "green", "red"), lwd = 2)
     ```

7. **Seasonal Analysis**:
   - Creates a new categorical variable `Season` based on the sampling dates.
   - Visualizes seasonal variations in DO levels using **boxplots**.

   Example:
   ```r
   ggplot(data, aes(x = Season, y = `Dissolved.Oxygen..mg.L.`, fill = Season)) + 
     geom_boxplot(outlier.color = "red") +
     labs(title = "Seasonal Variation in DO Levels", x = "Season", y = "DO (mg/L)")
   ```

### 4. View the Outputs
After running the script, you will obtain the following outputs
  Scatter Plots**: Visualize relationships between predictors and DO levels.
    Regression Results: Summaries of linear, logistic, and Lasso models.
    ROC Curves: Compare model performance using AUC metrics.
    Boxplots: Show seasonal variations in DO levels.

