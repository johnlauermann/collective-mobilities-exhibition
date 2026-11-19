
# Compile data ------------------------------------------------------------
# this script compiles data from Census API for use in data visualization. 

library(here)
library(tidyverse)
library(socratadata)
library(stringr)
library(sf)



# Set up environment ------------------------------------------------------

# set environment
i_am("code/compile_data_NYCOpenData.r")

# define api key
soc_api_key_id = "your key here"

# query some metadata to verify
dataset_query <- soc_discover(domains = "data.cityofnewyork.us", query = "eviction")



# Shelter counts ----------------------------------------------------------
shelters <- soc_read(url = "https://data.cityofnewyork.us/d/3qem-6v3v", 
                      query = soc_query(where = "report_date between '2026-01-01T00:00:00' 
                                        and '2026-10-31T23:59:59'
                                        and community_district is not null"), 
                      page_size = 5000)


# Eviction ----------------------------------------------------------------
evictions <- soc_read(url = "https://data.cityofnewyork.us/d/6z8x-wfk4", 
                      query = soc_query(where = "executed_date between '2026-01-01T00:00:00' 
                                        and '2026-10-31T23:59:59'
                                        and latitude is not null"), 
                      page_size = 5000) 

evictions <- evictions %>%
  filter(!is.na(latitude) & !is.na(longitude)) %>%
  mutate(latitude = as.numeric(latitude), 
         longitude = as.numeric(longitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  st_transform(crs = 26918)


# 311 calls ---------------------------------------------------------------
calls311 <- soc_read(url = "https://data.cityofnewyork.us/d/erm2-nwe9", 
                     query = soc_query(where = "created_date between '2026-01-01T00:00:00' 
                                       and '2026-10-31T23:59:59' 
                                       and caseless_contains(complaint_type, 'homeless')"), 
                     page_size = 5000)

calls311 <- calls311 %>%
  filter(!is.na(latitude) & !is.na(longitude) & !is.na(created_date)) %>%
  mutate(latitude = as.numeric(latitude), 
         longitude = as.numeric(longitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  st_transform(crs = 26918)



# Aggregate data ----------------------------------------------------------

# load boundaries
block_groups <- st_read(dsn = here("data/map_data.gpkg"),
                        layer = "block_groups") %>% 
  select(GEOID)
tracts <- st_read(dsn = here("data/map_data.gpkg"), 
                        layer = "tracts") %>%
  select(GEOID)
cds <- st_read(dsn = here("data/map_data.gpkg"), 
                  layer = "cds") %>%
  select(cdta2020) 


# aggregate shelter data
## summarize by CD
summary <- shelters %>%
  # fix primary key
  mutate(
    community_district = str_pad(
      string = as.character(community_district), 
      width = 2,
      side = "left", 
      pad = "0"), 
    community_district = if_else(
      str_length(community_district) == 3, 
      str_sub(community_district, 2, -1), 
      as.character(community_district)), 
    community_district = case_when(
      borough == "Brooklyn" ~ paste0("BK", community_district), 
      borough == "Bronx" ~ paste0("BX", community_district),
      borough == "Manhattan" ~ paste0("MN", community_district),
      borough == "Queens" ~ paste0("QN", community_district),
      borough == "Staten Island" ~ paste0("SI", community_district))) %>%
  
  # summarize by CD
  group_by(community_district) %>%
  summarize(
    across(where(is.numeric), 
           \(x) if (all(is.na(x))) NA_real_ else max(x, na.rm = TRUE))) %>%
  rename_with(~ paste0(.x, "_max"), where(is.numeric)) %>%
  
  # and generate total counts
  mutate(
    shelters_hotel_sum = rowSums(pick(adult_family_comm_hotel_max, 
                                      adult_shelter_comm_hotel_max, 
                                      fwc_comm_hotel_max),
                                 na.rm = TRUE),
    shelters_nothotels_sum = rowSums(pick(adult_family_shelter_max,
                                          adult_shelter_max, 
                                          fwc_shelter_max),
                                     na.rm = TRUE))

## link to spatial
cds <- left_join(x = cds, y = summary, by = c("cdta2020" = "community_district"))


# aggregate evictions data 
## block groups
summary <- evictions %>% 
  st_join(y = block_groups %>% select(GEOID), 
          join = st_intersects) %>%
  group_by(GEOID) %>%
  summarize(eviction_cnt = n())

block_groups <- left_join(x = block_groups, 
                          y = summary %>% st_drop_geometry(),
                          by = "GEOID")

# tracts
summary <- evictions %>% 
  st_join(y = tracts %>% select(GEOID), 
          join = st_intersects) %>%
  group_by(GEOID) %>%
  summarize(eviction_cnt = n())

tracts <- left_join(x = tracts, 
                  y = summary %>% st_drop_geometry(),
                  by = "GEOID")

# community districts
summary <- evictions %>% 
  st_join(y = cds %>% select(cdta2020), 
          join = st_intersects) %>%
  group_by(cdta2020) %>%
  summarize(eviction_cnt = n())

cds <- left_join(x = cds, 
                    y = summary %>% st_drop_geometry(),
                    by = "cdta2020")


# aggregate 311 data 
## block groups
summary <- calls311 %>% 
  st_join(y = block_groups %>% select(GEOID), 
          join = st_intersects) %>%
  group_by(GEOID) %>%
  summarize(calls311_cnt = n())

block_groups <- left_join(x = block_groups, 
                          y = summary %>% st_drop_geometry(),
                          by = "GEOID")

## tracts
summary <- calls311 %>% 
  st_join(y = tracts %>% select(GEOID), 
          join = st_intersects) %>%
  group_by(GEOID) %>%
  summarize(calls311_cnt = n())

tracts <- left_join(x = tracts, 
                    y = summary %>% st_drop_geometry(),
                    by = "GEOID")

## community districts
summary <- calls311 %>% 
  st_join(y = cds %>% select(cdta2020), 
          join = st_intersects) %>%
  group_by(cdta2020) %>%
  summarize(calls311_cnt = n())

cds <- left_join(x = cds, 
                 y = summary %>% st_drop_geometry(),
                 by = "cdta2020")



# Save results ------------------------------------------------------------

frames <- list(block_groups = block_groups, tracts = tracts, cds = cds, 
               shelters = shelters, evictions = evictions, calls311 = calls311)

for (df in seq_along(frames)) {
  
  name <- names(frames)[df]
  
  write.csv(x = frames[[df]] %>% st_drop_geometry(),
            file = paste0(here(), "/data/", name, "_NYCOpenData.csv"),
            row.names = FALSE, 
            na = "")
  
  st_write(obj = frames[[df]], 
           dsn = here("data/map_data.gpkg"),
           layer = paste0(name, "_NYCOpenData"), 
           delete_layer = TRUE)
}




