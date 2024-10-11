library(readr)
data <- read_csv("/Users/lli247/bios611/bios611-project/fossil-fuel-co2-emissions-by-nation.csv")
head(data)

library(dplyr)
# Group the data by Year and calculate the global totals for each year
global_totals <- data %>%
  group_by(Year) %>%
  summarise(
    Total_Emissions = sum(Total, na.rm = TRUE),
    Solid_Fuel_Emissions = sum(`Solid Fuel`, na.rm = TRUE)
  )
# Calculate year-to-year change in emissions
global_totals <- global_totals %>%
  mutate(
    Change_in_Total_Emissions = c(NA, diff(Total_Emissions)),
    Change_in_Solid_Fuel_Emissions = c(NA, diff(Solid_Fuel_Emissions))
  )
library(ggplot2)
# Plotting the change in emissions over time
change_in_emissions <- ggplot(global_totals, aes(x = Year)) +
  geom_bar(aes(y = Change_in_Solid_Fuel_Emissions, fill = "Solid Fuels"), stat = "identity") +
  geom_bar(aes(y = Change_in_Total_Emissions, fill = "Global Totals"), stat = "identity", alpha = 0.7) +
  geom_hline(yintercept = 0, color = "black", size = 0.8) +  # Add horizontal line at y=0
  labs(title = "Change in Emissions Over Time",
       x = "Year",
       y = "Change in Emissions (MtC)") +
  scale_fill_manual(name = "Emissions", values = c("Solid Fuels" = "steelblue", "Global Totals" = "orange")) +
  theme_minimal()
ggsave("figure/change_in_emissions.png", plot = change_in_emissions)
# Group the data by Year and sum emissions for each source
global_emissions <- data %>%
  group_by(Year) %>%
  summarise(
    Cement = sum(Cement, na.rm = TRUE),
    Gas_Flaring = sum(`Gas Flaring`, na.rm = TRUE),
    Gas = sum(`Gas Fuel`, na.rm = TRUE),
    Liquids = sum(`Liquid Fuel`, na.rm = TRUE),
    Solids = sum(`Solid Fuel`, na.rm = TRUE)
  )
library(tidyr)
# Convert data to long format for easier plotting with ggplot2
global_emissions_long <- global_emissions %>%
  pivot_longer(cols = c(Cement, Gas_Flaring, Gas, Liquids, Solids), 
               names_to = "Source", 
               values_to = "Emissions")

# Plot the stacked area chart
global_emissions <- ggplot(global_emissions_long, aes(x = Year, y = Emissions, fill = Source)) +
  geom_area(alpha = 0.8, size = 0.5, colour = "white") +
  scale_fill_manual(values = c("Cement" = "grey", 
                               "Gas_Flaring" = "purple", 
                               "Gas" = "yellow", 
                               "Liquids" = "orange", 
                               "Solids" = "black")) +
  labs(title = "Global Fossil Fuel CO2 Emissions by Source",
       x = "Year",
       y = "Emissions (GtC)",
       fill = "Sources") +
  theme_minimal() +
  theme(legend.position = "right")
ggsave("figure/global_emissions.png", plot = global_emissions)

# Load necessary libraries
library(dplyr)
library(knitr)
#install.packages("kableExtra")
library(kableExtra)
# Select data for 2016 and 2017 to calculate changes
df_2013 <- data %>% filter(Year == 2013)
df_2014 <- data %>% filter(Year == 2014)

# Merge 2016 and 2017 data to calculate changes
df_change <- merge(df_2013, df_2014, by = "Country", suffixes = c("_2013", "_2014"))

# Calculate total emissions change, population change, and per capita CO2 emissions
top_emitters <- df_change %>%
  mutate(
    Emissions_Change = ((Total_2014 - Total_2013) / Total_2013) * 100,
    Population_2014 = `Per Capita_2014`*Total_2014,
    Population_2013 = `Per Capita_2013`*Total_2013,
    `Population_Change(%)` = ((Population_2014 - Population_2013) / Population_2013) * 100
  ) %>%
  arrange(desc(Total_2014)) %>%  # Sort by Total CO2 emissions in 2014
  mutate(Rank = row_number()) %>%  # Assign rank based on sorted emissions
  select(
    Rank,
    Country,
    Total_CO2_Emissions_MtC = Total_2014,
    Population_Millions = Population_2014,
    Emissions_Change,
    `Population_Change(%)`,
    `Per Capita_2014`
  ) %>%
  head(10)  # Select top 10 countries
write_csv(top_emitters, "data/top_emitters.csv")
# Create a formatted table
top_emitters %>%
  kable("html", col.names = c("Rank", "Nation", "Total CO2 Emissions", "Population", 
                              "Emissions Change 2013-2014 (%)", "Population Change 2013-2014 (%)", 
                              "Per Capita CO2 Emissions (t C per person)")) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed"))

#alternative
# Load necessary libraries
library(dplyr)
library(ggpubr)
# Generate a table plot
table_plot <- ggtexttable(top_emitters, rows = NULL, 
                          theme = ttheme("light", 
                                         base_size = 15,
                                         padding = unit(c(4, 4), "mm")))
ggsave("figure/table_plot.png", plot = table_plot, height = 6, width = 18)
