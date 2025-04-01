library(tidycensus)
library(tidyverse)
library(tigris)
library(sf)

options(tigris_use_cache = TRUE)

census_api_key(Sys.getenv("API_KEY"))

pittsburgh <- places(state = "PA", cb = TRUE) %>%
  filter(NAME == "Pittsburgh")


##### Household Size by Vehicles Available

detailed_vars <- c(
  male = "B17001_003",
  female = "B17001_017",
  total = "B01003_001"
)

detailed_data <- get_acs(
  geography = "tract",
  variables = detailed_vars,
  state = "PA",
  county = "Allegheny",
  year = 2023,
  geometry = TRUE
)

detailed_data_wide <- detailed_data %>%
  select(GEOID, variable, estimate, geometry) %>% 
  pivot_wider(names_from = variable, values_from = estimate)

pittsburgh_data = st_filter(detailed_data_wide, pittsburgh)
pittsburgh_attributes = st_drop_geometry(pittsburgh_data)

pittsburgh_attributes <- pittsburgh_attributes %>%
  mutate(male_percentage = male / total)%>%
  mutate(female_percentage = female / total)%>%
  mutate(poverty_percentage = male_percentage + female_percentage)


write.csv(pittsburgh_attributes, "poverty_percentage.csv", row.names = FALSE)