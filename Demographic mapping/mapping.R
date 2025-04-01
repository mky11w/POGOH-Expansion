library(sf)
library(ggplot2)
library(dplyr)
library(viridis)
library(tigris)


tracts <- st_read("Boundaries/Census_Tract_2020/Census_Tract_2020.shp")

minority <- read.csv("/Users/mkay11/POGOH-Expansion/disbility_percentage.csv") %>%
  rename(geoid = GEOID) %>%
  mutate(geoid = as.character(geoid))%>%
  filter(total>10)

pgh_boundary <- places(state = "PA", cb = TRUE) %>%
  filter(NAME == "Pittsburgh") %>%
  st_transform(st_crs(tracts))


tracts <- st_transform(tracts, st_crs(pgh_boundary))
pittsburgh_tracts <- st_filter(tracts, pgh_boundary)

distribution <- left_join(pittsburgh_tracts, minority, by = "geoid")


ggplot() +
  geom_sf(data = distribution, aes(fill = disbility_percentage), color = "black", size = 0.2) +
  scale_fill_viridis_c(option = "C", na.value = "lightgrey") +
  labs(
    fill ="disability_percentage"
  ) +
  theme_minimal()
