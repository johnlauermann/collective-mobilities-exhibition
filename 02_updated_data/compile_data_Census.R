
# Compile data ------------------------------------------------------------
# this script compiles data from Census/ACS. 

library(here)
library(tidyverse)
library(tidycensus)
library(sf)



# Set up  ------------------------------------------------------

# define environment
i_am("code/compile_data_Census.r")

# define api key
census_api_key("your key here")

# download metadata
variablelist <- load_variables(year = 2024, dataset = "acs5")



# Query the API ---------------------------------------------------

# define source variables
variables <- c(
  HouseUnits_sum = "B25002_001",
  VacantHU_sum = "B25002_003",
  RenterHU_sum = "B25070_001",
  rent_burdened_30_34_9 = "B25070_007",
  rent_burdened_35_39_9 = "B25070_008",
  rent_burdened_40_49_9 = "B25070_009",
  rent_burdened_50_plus = "B25070_010", 
  Pop_sum = "B02001_001"
  )

# query tract level data
tracts <- get_acs(geography = "tract",
                  state = "New York",
                  county = c("Bronx", "Kings", "New York", "Queens", "Richmond"),
                  variables = variables,
                  output = "wide",
                  year = 2024,
                  geometry = TRUE) %>%
  # change projection for consistency in spatial analysis
  st_transform(crs = 26918)

# query block group level data
block_groups <- get_acs(geography = "block group",
                  state = "New York",
                  county = c("Bronx", "Kings", "New York", "Queens", "Richmond"),
                  variables = variables,
                  output = "wide",
                  year = 2024,
                  geometry = TRUE) %>%
  st_transform(crs = 26918)



# Data cleaning -----------------------------------------------------------

# aggregate into NYC community districts
## load boundaries
cd_boundaries <- st_read("https://data.cityofnewyork.us/api/v3/views/xn3r-zk6y/query.geojson") %>%
  st_transform(crs = 26918)  

## calculate centroids & spatial join
centers <- block_groups %>%
  st_transform(crs = 26918) %>%
  st_centroid() %>%
  st_join(y = cd_boundaries, join = st_intersects)

## summarize back to CDs
cd_summary <- centers %>%
  group_by(cdta2020) %>%
  summarize(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)))

## and join
cds <- cd_boundaries %>%
  left_join(cd_summary %>% st_drop_geometry(), by = "cdta2020")
  

# clean up all frames
frames <- list(tracts = tracts, block_groups = block_groups, cds = cds)

frames <- map(frames, ~ .x %>%
                select(-ends_with("M")) %>%
                rename_with(~ str_remove(., "E$")) %>%
                filter(Pop_sum >= 100) %>%
                mutate(VacantHU_pct = if_else(HouseUnits_sum > 0,(VacantHU_sum / HouseUnits_sum) * 100, NA_real_),
                       RentBurdened_pct = if_else(RenterHU_sum > 0,((rent_burdened_30_34_9 + rent_burdened_35_39_9 +
                                                                         rent_burdened_40_49_9 +rent_burdened_50_plus) / 
                                                                      RenterHU_sum) * 100, NA_real_)))
tracts <- frames[[1]] %>%
  select(GEOID, Pop_sum, HouseUnits_sum, RentBurdened_pct, VacantHU_pct, geometry)
block_groups <- frames[[2]] %>%
  select(GEOID, Pop_sum, HouseUnits_sum, RentBurdened_pct, VacantHU_pct, geometry)
cds <- frames[[3]] %>%
  select(borocode, boroname, countyfips, cdta2020, cdtaname,
         Pop_sum, HouseUnits_sum, RentBurdened_pct, VacantHU_pct, geometry)



# Save results ------------------------------------------------------------
rm(frames)
frames <- list(tracts = tracts, block_groups = block_groups, cds = cds)

for (df in seq_along(frames)) {
  
  name <- names(frames)[df]
  
  write.csv(x = frames[[df]] %>% st_drop_geometry(),
            file = here("data", paste0(name, "_CensusData.csv")),
            row.names = FALSE, 
            na = "")
  
  st_write(obj = frames[[df]], 
           dsn = here("data/map_data.gpkg"),
           layer = paste0(name, "_CensusData"), 
           delete_layer = TRUE)
}




