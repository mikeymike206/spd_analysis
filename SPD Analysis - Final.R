# Load Required Libraries
library(dplyr)      # For data manipulation
library(ggplot2)    # For data visualization
library(car)        # For regression diagnostics and ANOVA tools
library(tidyr)      # For data tidying functions
library(emmeans)    # For estimated marginal means and post-hoc testing

# Ensure tidyr is installed (helpful for reproducibility)
install.packages("tidyr")
library(tidyr)

# Filter the dataset to only include Priority 1 calls and remove incomplete records
priority1_data <- spd_data %>%
  filter(priority == 1) %>%
  drop_na(first_response_time, dispatch_precinct, responding_units)

# Summarize call volume and average response time by precinct
priority1_summary <- priority1_data %>%
  group_by(dispatch_precinct) %>%
  summarise(
    call_volume = n(),
    avg_response_time_sec = mean(as.numeric(first_response_time), na.rm = TRUE)
  )

# Linear regression: Does call volume affect average response time by precinct?
priority1_lm <- lm(avg_response_time_sec ~ call_volume, data = priority1_summary)
summary(priority1_lm)

# One-way ANOVA: Test if response times significantly differ across precincts
aov_model <- aov(first_response_time ~ dispatch_precinct, data = priority1_data)
summary(aov_model)

# Tukey HSD post-hoc test to identify which precincts differ significantly
tukey_result <- TukeyHSD(aov_model)
print(tukey_result)

# Visualize Tukey HSD pairwise comparisons
plot(tukey_result, las = 1, col = "steelblue", main = "Tukey HSD: Response Time by Precinct")

# Convert categorical variables to factors for regression analysis
priority1_data <- priority1_data %>%
  mutate(
    dispatch_precinct = as.factor(dispatch_precinct),
    hour_of_day = as.factor(hour_of_day),
    Month = as.factor(Month)
  )

# Multiple linear regression: Assess effect of precinct, units dispatched, and time of day/month
model_with_month <- lm(first_response_time ~ dispatch_precinct + responding_units + hour_of_day + Month, data = priority1_data)
summary(model_with_month)

# Count number of unique levels for categorical variables (for model diagnostics)
sapply(priority1_data[, c("dispatch_precinct", "hour_of_day", "Month")], function(x) length(unique(x)))

# Simpler regression: Evaluate impact of dispatch precinct and number of responding units only
model_priority1 <- lm(first_response_time ~ dispatch_precinct + responding_units, data = priority1_data)
summary(model_priority1)
