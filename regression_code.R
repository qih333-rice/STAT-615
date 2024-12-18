library(tidyverse)
library(caret)
library(glmnet)
library(MASS)
library(lubridate)
library(pROC)

data <- read.csv("/Users/qihao/Downloads/Regression and Linear Models/Project/Data/BKB_WaterQualityData.csv")
data$DO_binary <- ifelse(data$`Dissolved.Oxygen..mg.L.` < 5, 0, 1)

summary(data)
str(data)
sum(is.na(data))
data <- na.omit(data)

ggplot(data, aes(x = `Water.Temp...C.`, y = `Dissolved.Oxygen..mg.L.`)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  labs(title = "Temperature vs Dissolved Oxygen", x = "Temperature (°C)", y = "Dissolved Oxygen (mg/L)")

ggplot(data, aes(x = `pH..standard.units.`, y = `Dissolved.Oxygen..mg.L.`)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  labs(title = "pH vs Dissolved Oxygen", x = "pH (Standard Units)", y = "Dissolved Oxygen (mg/L)")

ggplot(data, aes(x = `Secchi.Depth..m.`, y = `Dissolved.Oxygen..mg.L.`)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  labs(title = "Water Clarity vs Dissolved Oxygen", x = "Secchi Depth (m)", y = "Dissolved Oxygen (mg/L)")

# Linear Regression
linear_model <- lm(`Dissolved.Oxygen..mg.L.` ~ `Water.Temp...C.` + `pH..standard.units.` + `Secchi.Depth..m.` + `Salinity..ppt.`, data = data)
summary(linear_model)

vif <- car::vif(linear_model)
print(vif)

# Stepwise regression for variable selection
stepwise_model <- stepAIC(linear_model, direction = "both")
summary(stepwise_model)

# Logistic Regression
data$DO_binary <- ifelse(data$`Dissolved.Oxygen..mg.L.` < 5, 0, 1)
logistic_model <- glm(DO_binary ~ `pH..standard.units.` + `Secchi.Depth..m.` + `Salinity..ppt.`, 
                      data = data, family = "binomial")
summary(logistic_model)

#GLM Model
glm_model <- glm(
  DO_binary ~ `Water.Temp...C.` * `pH..standard.units.` + `Secchi.Depth..m.` * `Salinity..ppt.`, 
  family = "binomial", data = data
)

# Lasso Regression
x <- model.matrix(`Dissolved.Oxygen..mg.L.` ~ `Water.Temp...C.` + `pH..standard.units.` + `Secchi.Depth..m.` + `Salinity..ppt.`, data = data)[,-1]
y <- data$`Dissolved.Oxygen..mg.L.`
lasso_model <- cv.glmnet(x, y, alpha = 1)
print(lasso_model)
coef(lasso_model, s = "lambda.min")



logistic_predicted_prob <- predict(logistic_model, type = "response")
logistic_roc <- roc(data$DO_binary, logistic_predicted_prob)
auc_value_logistic <- auc(logistic_roc)
auc_value_logistic
glm_predicted_prob <- predict(glm_model, type = "response")
glm_roc <- roc(data$DO_binary, glm_predicted_prob)
auc_value_glm <- auc(glm_roc)
auc_value_glm
lasso_predicted_prob <- as.numeric(predict(lasso_model, s = "lambda.min", newx = x, type = "response"))
lasso_roc <- roc(data$DO_binary, lasso_predicted_prob)
auc_value_lasso <- auc(lasso_roc)
auc_value_lasso

# Plot ROC Curve
plot(logistic_roc, col = "blue", lwd = 2, main = "ROC Curves for Multiple Models")
lines(glm_roc, col = "green", lwd = 2)
lines(lasso_roc, col = "red", lwd = 2)
legend("bottomright", legend = c("Logistic Regression", "GLM", "Lasso Regression"),
       col = c("blue", "green", "red"), lwd = 2)



# Generalized Linear Model (GLM)
glm_model <- glm(`Dissolved.Oxygen..mg.L.` ~ `Water.Temp...C.` * `pH..standard.units.` + `Secchi.Depth..m.` * `Salinity..ppt.`, 
                 family = gaussian(link = "identity"), data = data)
summary(glm_model)

interaction_model <- lm(`Dissolved.Oxygen..mg.L.` ~ `Water.Temp...C.` * `pH..standard.units.` + `Secchi.Depth..m.` * `Salinity..ppt.`, data = data)
summary(interaction_model)

AIC(linear_model, glm_model, interaction_model)

# Seasonal and Temporal Analysis
data$Read_Date <- as.Date(data$Read_Date)
data$Month <- month(data$Read_Date)
data$Season <- case_when(
  data$Month %in% c(12, 1, 2) ~ "Winter",
  data$Month %in% c(3, 4, 5) ~ "Spring",
  data$Month %in% c(6, 7, 8) ~ "Summer",
  data$Month %in% c(9, 10, 11) ~ "Fall"
)

ggplot(data, aes(x = Season, y = `Dissolved.Oxygen..mg.L.`, fill = Season)) + 
  geom_boxplot(outlier.color = "red", outlier.shape = 16, outlier.size = 2, alpha = 0.7) +
  scale_fill_manual(values = c("Spring" = "#66c2a5", 
                               "Summer" = "#fc8d62", 
                               "Fall" = "#8da0cb", 
                               "Winter" = "#e78ac3")) +  
  labs(title = "Seasonal Variation in Dissolved Oxygen Levels", 
       x = "Season", 
       y = "Dissolved Oxygen (mg/L)") +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(size = 12),
    legend.position = "none"
  )
