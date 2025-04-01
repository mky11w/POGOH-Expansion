## Household Size by Vehicles Available
### retrived from https://data.census.gov/table?q=B08201
### no vehicle available B08201_002E
### one vehicle available B08201_003E
### weighted limit access total B08201_002E*1.0+B08201_003E*0.5
### total B08201_001E
### see https://api.census.gov/data/2023/acs/acs5/variables

## Income in the past 12 months below poverty level
### retrived from https://data.census.gov/table?q=B17001
### male B17001_003E
### female B17001_0017E
### total B01003_001E

## Race distribution
### retrieved from https://data.census.gov/table?q=B03002
### black or african american B03002_004E
### hispanic or latino B03002_012E
### total B03002_001E

## Disability population
### retrieved from https://data.census.gov/table/ACSDT5Y2023.B18135?q=B18135
### B18135_003E, B18135_014E, 18135_025E
### total B18135_001E

## Household limited English speaking status
### retrieved from https://data.census.gov/table?q=B16002
### B16002_004E, B16002_007E, B16002_010E, B16002_013E, B16002_016E, B16002_019E
### B16002_022E, B16002_025E, B16002_028E, B16002_031E, B16002_034E, B16002_037E
### total B16002_001E


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
  no_vehicle_available = "B08201_002",
  one_vehicle_available = "B08201_003",
  total = "B08201_001"
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
  select(GEOID, variable, estimate, geometry) %>% ## ensure right formatting
  pivot_wider(names_from = variable, values_from = estimate)

pittsburgh_data = st_filter(detailed_data_wide, pittsburgh)
pittsburgh_attributes = st_drop_geometry(pittsburgh_data)

pittsburgh_attributes <- pittsburgh_attributes %>%
  mutate(no_vehicle_percentage = no_vehicle_available / total) %>%
  mutate(one_vehicle_percentage = one_vehicle_available / total)


write.csv(pittsburgh_attributes, "limited_vehicle_percentage.csv", row.names = FALSE)


### populaiton under poverty

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
  mutate(female_percentage = female / total)


write.csv(pittsburgh_attributes, "poverty_percentage.csv", row.names = FALSE)

### minority percentage

detailed_vars <- c(
  baa = "B03002_004",
  hl = "B03002_012",
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
  mutate(minority_percentage = (baa + hl) / total)


write.csv(pittsburgh_attributes, "minority_percentage.csv", row.names = FALSE)

#### disability percentage

detailed_vars <- c(
  age_group_1 = "B18135_003", 
  age_group_2 = "B18135_014", 
  age_group_3 ="B18135_025",
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
  select(GEOID, variable, estimate, geometry) %>% ## ensure right formatting
  pivot_wider(names_from = variable, values_from = estimate)

pittsburgh_data = st_filter(detailed_data_wide, pittsburgh)
pittsburgh_attributes = st_drop_geometry(pittsburgh_data)

pittsburgh_attributes <- pittsburgh_attributes %>%
  mutate(disbility_percentage = (age_group_1 + age_group_2 + age_group_3) / total)


write.csv(pittsburgh_attributes, "disbility_percentage.csv", row.names = FALSE)