# Data for Original 2025 Exhibition

Boundary files were obtained for [NYC Community Districts](https://data.cityofnewyork.us/City-Government/Community-Districts/yfnk-k7r4) and [Census TIGER/Line tracts](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-geodatabase-file.html). Both were projected into UTM Zone 18N. Tracts in the five boroughs were extracted using a query and then water areas were clipped using district boundaries. 

### Census/ American Community Survey
We compiled a collection of variables from the Census Bureau and NYC Open Data. See [variable documentation](https://docs.google.com/spreadsheets/d/1ocsovQU9sfGW3KTDgE4AntTEQhZ-ztR_e0dDfXoxsf8/edit?usp=sharing) here. Demographic variables were collected from ACS 2023 5yr estimates using the Census API via tidycensus and then joined to spatial data at the tract and community district scales. See R scripts for tract workflow ([`code_ACS_tract.r`](code_ACS_tract.R)) and community district ([`code_ACS_CD.r`](code_ACS_CD.R)) workflows. 


### NYC Open Data
We also pulled several datasets from NYC Open Data for calendar year 2024, including 311 calls related to homelessness, evictions filings, and homeless shelter locations. We query the data via `sodapy` and transform it to geospatial layers with `arcpy`. See [`code_NYCOpenData.ipynb`](code_NYCOpenData.ipynb) for workflow. 
