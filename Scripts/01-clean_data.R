library(readr)
library(dplyr)

# Download Data
raw_data <- read_csv("../Data/raw.csv", na = c("NA", "N/A"))

#Create a new data frame to perform cleaning work without changing the original data frame
cleaned_data <- raw_data %>%
  mutate(Birth_Year = as.numeric(format(as.Date(`Date of Birth`), "%Y")),
         Death_Year = as.numeric(format(as.Date(`Date of Death`), "%Y"))) %>%
  select(-`Date of Birth`, -`Date of Death`)

# Check if the new data frame contains data
print(head(cleaned_data))

# Save the cleaned data to a file
write_csv(cleaned_data, "../Data/cleaned_data.csv")

# Aggregate data: break down by religion and count the number of victims
summary_data <- cleaned_data %>%
  group_by(Religion) %>%
  summarize(Number_of_Victims = n()) %>%
  ungroup() %>%
  arrange(desc(Number_of_Victims))

# Save the summarized data to a file
write_csv(summary_data, "../Data/summary_data.csv")