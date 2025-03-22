## Household Size by Vehicles Available
### retrived from https://data.census.gov/table?q=B08201
### no vehicle avaliable B08201_002E
### see https://api.census.gov/data/2023/acs/acs5/variables

## Median Household Income under poverty level ($21,150)
### retrived from https://data.census.gov/table/ACSDT5Y2023.B19013?q=B19013
### B19013_001
### average household size reference
### https://data.census.gov/table/DECENNIALSF22010.PCT7
### poverty level reference
### https://aspe.hhs.gov/topics/poverty-economic-mobility/poverty-guidelines

## Race distribution
### retrieved from https://data.census.gov/table?q=B03002
### total population B03002_001
### black or african american B03002_004
### hispanic or latino B03002_012
### see https://api.census.gov/data/2023/acs/acs5/variables

## Disability population
### retrieved from https://data.census.gov/table/ACSDT5Y2023.B18135?q=B18135
### B18135_003E,B18135_014E,B18135_025E
### see https://api.census.gov/data/2023/acs/acs5/variables



library(tidycensus)
library(tidyverse)
library(tigris)
library(sf)

options(tigris_use_cache = TRUE)

census_api_key("4f9ac2690cfb75b8aada27115bd1e39a2ad178be")

pittsburgh <- places(state = "PA", cb = TRUE) %>%
  filter(NAME == "Pittsburgh")

detailed_vars <- c(
  hispan_latino = "B03002_012"

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
  pivot_wider(names_from = variable, values_from = estimate)

pittsburgh_data = st_filter(detailed_data_wide, pittsburgh)
pittsburgh_attributes = st_drop_geometry(pittsburgh_data)

write.csv(pittsburgh_attributes, "minority_hispanic_latino.csv", row.names = FALSE)

