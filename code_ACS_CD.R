# script to pull ACS data from the Census API, clean, and then export to GIS

library(tidyverse)
library(tidycensus)
library(dplyr)

setwd("Your directory")

#key to call data from Census API
census_api_key("Your key")

#find a list of variable codes
ACS22variablelist <- load_variables(2023, "acs5", cache = TRUE)
write.csv(ACS22variablelist, file = "ACSvariablelist.csv")

#define counties and variables for API
counties <- c("Bronx", "Kings", "Queens", "New York", "Richmond")
variables <- c(
  Pop_sum = "B02001_001",
  Households_sum = "B25003_001",
  HouseUnits_sum = "B25001_001",
  OccupiedHU_sum = "B25002_002",
  VacantHU_sum = "B25002_003",
  OwnerHU_sum = "B25003_002",
  RenterHU_sum = "B25003_003",
  Employed_sum = "C24030_001",
  Hispanic_sum = "B03002_012",
  NotHispanic_sum = "B03002_002",
  AIAN_NotHisp_sum = "B03002_005",
  AIAN_Hisp_sum = "B03002_015",
  Asian_NotHisp_sum = "B03002_006",
  Asian_Hisp_sum = "B03002_016",
  Black_NotHisp_sum = "B03002_004",
  Black_Hisp_sum = "B03002_014",
  NHPI_NotHisp_sum = "B03002_007",
  NHPI_Hisp_sum = "B03002_017",
  Other_NotHisp_sum = "B03002_008",
  Other_Hisp_sum = "B03002_018",
  TwoOrMore_NotHisp_sum = "B03002_011",
  TwoOrMore_Hisp_sum = "B03002_021",
  White_NotHisp_sum = "B03002_003",
  White_Hisp_sum = "B03002_013",
  Poverty_sum = "B17001B_002",
  Poverty_AIAN_sum = "B17001C_002",
  Poverty_Asian_sum = "B17001D_002",
  Poverty_Black_sum = "B17001B_002",
  Poverty_NHPI_sum = "B17001E_002",
  Poverty_Hispanic_sum = "B17001I_002",
  Poverty_Other_sum = "B17001F_002",
  Poverty_TwoOrMore_sum = "B17001G_002",
  Poverty_White_sum = "B17001A_002",
  HHInc_agg = "B19025_001",
  GrossRent_agg = "B25065_001",
  rent_burdened_30_34_9 = "B25070_007",
  rent_burdened_35_39_9 = "B25070_008",
  rent_burdened_40_49_9 = "B25070_009",
  rent_burdened_50_plus = "B25070_010",
  overcrowded_ownerHU_1to15_sum = "B25014_005", 
  overcrowded_ownerHU_15to2_sum = "B25014_006", 
  overcrowded_ownerHU_over2_sum = "B25014_007", 
  overcrowded_renterHU_1to15_sum = "B25014_011", 
  overcrowded_renterHU_15to2_sum = "B25014_012", 
  overcrowded_renterHU_over2_sum = "B25014_013", 
  occ_construction_M_sum = "C24030_006",
  occ_construction_F_sum = "C24030_033",
  occ_education_M_sum = "C24030_022",
  occ_education_F_sum = "C24030_049",
  occ_healthcare_M_sum = "C24030_023",
  occ_healthcare_F_sum = "C24030_050",
  occ_hotelfood_M_sum = "C24030_026",
  occ_hotelfood_F_sum = "C24030_053",
  occ_publicadmin_M_sum = "C24030_028",
  occ_publicadmin_F_sum = "C24030_055",
  occ_transportation_M_sum = "C24030_011",
  occ_transportation_F_sum = "C24030_038",
  occ_utilities_M_sum = "C24030_032",
  occ_utilities_F_sum = "C24030_039"
)

#pull data from API
data <- get_acs(geography = "tract",
                state = "New York",
                county = counties,
                variables = variables,
                output = "wide",
                year = 2023)


#clean data
data <- data %>% select(-ends_with("M"))
data <- data %>% rename_with(~ gsub("E$", "", .))
data <- data %>% rename(Poverty_Black_sum = B17001B_002)
data <- data %>% select(GEOID, sort(setdiff(names(.), "GEOID")))
ls(data)


#aggregate by Community Districts
tract_CDinfo <- read.csv("tracts_byCD.csv")
data <- merge(data, tract_CDinfo)
data <- data %>% 
  group_by(boro_cd) %>%
  summarize(across(where(is.numeric), sum, na.rm = TRUE))


#calculate derivative metrics
data <- within(data, {
  ## Race
  AIAN_NotHisp_pct <- (AIAN_NotHisp_sum / Pop_sum) * 100
  AIAN_Hisp_pct <- (AIAN_Hisp_sum / Pop_sum) * 100
  Asian_NotHisp_pct <- (Asian_NotHisp_sum / Pop_sum) * 100
  Asian_Hisp_pct <- (Asian_Hisp_sum / Pop_sum) * 100
  Black_NotHisp_pct <- (Black_NotHisp_sum / Pop_sum) * 100
  Black_Hisp_pct <- (Black_Hisp_sum / Pop_sum) * 100
  NHPI_NotHisp_pct <- (NHPI_NotHisp_sum / Pop_sum) * 100
  NHPI_Hisp_pct <- (NHPI_Hisp_sum / Pop_sum) * 100
  Other_NotHisp_pct <- (Other_NotHisp_sum / Pop_sum) * 100
  Other_Hisp_pct <- (Other_Hisp_sum / Pop_sum) * 100
  TwoOrMore_NotHisp_pct <- (TwoOrMore_NotHisp_sum / Pop_sum) * 100
  TwoOrMore_Hisp_pct <- (TwoOrMore_Hisp_sum / Pop_sum) * 100
  White_NotHisp_pct <- (White_NotHisp_sum / Pop_sum) * 100
  White_Hisp_pct <- (White_Hisp_sum / Pop_sum) * 100
  Hispanic_pct <- (Hispanic_sum / Pop_sum) * 100
  
  ## Poverty
  Poverty_pct <- (Poverty_sum / Pop_sum) * 100
  Poverty_AIAN_pct <- (Poverty_AIAN_sum / (AIAN_NotHisp_sum + AIAN_Hisp_sum)) * 100
  Poverty_Asian_pct <- (Poverty_Asian_sum / (Asian_NotHisp_sum + Asian_Hisp_sum)) * 100
  Poverty_Black_pct <- (Poverty_Black_sum / (Black_NotHisp_sum + Black_Hisp_sum)) * 100
  Poverty_NHPI_pct <- (Poverty_NHPI_sum / (NHPI_NotHisp_sum + NHPI_Hisp_sum)) * 100
  Poverty_Hispanic_pct <- (Poverty_Hispanic_sum / Hispanic_sum) * 100
  Poverty_Other_pct <- (Poverty_Other_sum / (Other_NotHisp_sum + Other_Hisp_sum)) * 100
  Poverty_TwoOrMore_pct <- (Poverty_TwoOrMore_sum / (TwoOrMore_NotHisp_sum + TwoOrMore_Hisp_sum)) * 100
  Poverty_White_pct <- (Poverty_White_sum / (White_NotHisp_sum + White_Hisp_sum)) * 100
  
  ## Income
  HHInc_mean <- HHInc_agg / Households_sum
  
  ## Housing characteristics
  GrossRent_mean <- GrossRent_agg / RenterHU_sum
  RentBurdened_sum <- rent_burdened_30_34_9 + rent_burdened_35_39_9 + rent_burdened_40_49_9 + rent_burdened_50_plus
  RentBurdened_pct <- (RentBurdened_sum / RenterHU_sum) * 100
  Vacant_pct <- (VacantHU_sum / HouseUnits_sum) * 100
  overcrowdedHU_sum <- overcrowded_ownerHU_1to15_sum + overcrowded_ownerHU_15to2_sum +
    overcrowded_ownerHU_over2_sum + overcrowded_renterHU_1to15_sum + 
    overcrowded_renterHU_15to2_sum + overcrowded_renterHU_over2_sum 
  overcrowdedHU_pct <- (overcrowdedHU_sum / OccupiedHU_sum) * 100
  
  ## Occupations
  occ_construction_sum <- occ_construction_F_sum + occ_construction_M_sum
  occ_construction_pct <- ((occ_construction_F_sum + occ_construction_M_sum) / Employed_sum) * 100
  occ_education_sum <- occ_education_F_sum + occ_education_M_sum
  occ_education_pct <- ((occ_education_F_sum + occ_education_M_sum) / Employed_sum) * 100
  occ_healthcare_sum <- occ_healthcare_F_sum + occ_healthcare_M_sum
  occ_healthcare_pct <- ((occ_healthcare_F_sum + occ_healthcare_M_sum) / Employed_sum) * 100
  occ_hotelfood_sum <- occ_hotelfood_F_sum + occ_hotelfood_M_sum
  occ_hotelfood_pct <- ((occ_hotelfood_F_sum + occ_hotelfood_M_sum) / Employed_sum) * 100
  occ_publicadmin_sum <- occ_publicadmin_F_sum + occ_publicadmin_M_sum
  occ_publicadmin_pct <- ((occ_publicadmin_F_sum + occ_publicadmin_M_sum) / Employed_sum) * 100
  occ_transportation_sum <- occ_transportation_F_sum + occ_transportation_M_sum
  occ_transportation_pct <- ((occ_transportation_F_sum + occ_transportation_M_sum) / Employed_sum) * 100
  occ_utilities_sum <- occ_utilities_F_sum + occ_utilities_M_sum
  occ_utilities_pct <- ((occ_utilities_F_sum + occ_utilities_M_sum) / Employed_sum) * 100
})


#export data to table
data <- data %>% select(boro_cd, sort(setdiff(names(.), "boro_cd")))
write.csv(data, file = "data_ACS22_CD.csv", na="")
