# [Collective Mobilities Exhibition](https://www.pratt.edu/events/collective-mobilities/)
## DeKalb Gallery 2025, Pratt Institute
#### Team: [John Lauermann](https://www.pratt.edu/people/john-lauermann/), [Alex Strada](https://www.pratt.edu/people/alex-strada), [Yuanhao Wu](https://www.linkedin.com/in/yuanhao-wu-80603723a/), [Nathan Smash](https://www.linkedin.com/in/nathan-smash-b6b93a24a/)
 
This document describes the methodology used to create maps for the [Collective Mobilities](https://www.pratt.edu/events/collective-mobilities/) exhibition in Pratt Institute's DeKalb Gallery (Feb 3-March 9, 2025). We compiled data on gentrification, housing affordability, and other neighborhood demographics in New York. We then created printed maps for the exhibition and interactive 2D and 3D maps as digital companions.

![CollectiveMobilities01](https://github.com/user-attachments/assets/b1f1000e-10ec-41de-9d00-3139bab0405a)

 
## Data Gathering

Boundary files were obtained for [NYC Community Districts](https://data.cityofnewyork.us/City-Government/Community-Districts/yfnk-k7r4) and [Census TIGER/Line tracts](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-geodatabase-file.html). Both were projected into UTM Zone 18N. Tracts in the five boroughs were extracted using a query and then water areas were clipped using district boundaries. 

### US Census
We compiled a collection of variables from the Census Bureau and NYC Open Data. See [variable documentation](https://docs.google.com/spreadsheets/d/1ocsovQU9sfGW3KTDgE4AntTEQhZ-ztR_e0dDfXoxsf8/edit?usp=sharing) here. 

Demographic variables were collected from ACS 2023 5yr estimates using the Census API via tidycensus and then joined to spatial data at the tract and community district scales. See R scripts for tract workflow and community district workflow. 


### NYC Open Data

We also pulled several datasets from NYC Open Data for calendar year 2024, including 311 calls related to homelessness, evictions filings, and homeless shelter locations. Due to the large volume of data and the 1000 record limitation that NYC Open Data places on its API, we wrote a loop to query the data via sodapy and transform it to geospatial layers with arcpy. See Python script for workflow.  


## Maps
Exhibition: https://www.pratt.edu/events/collective-mobilities/

2D Map: https://experience.arcgis.com/experience/3f555237cbc441bf94fa1f1c34d47e29

3D Map: https://experience.arcgis.com/experience/90e5f715895d44f78b9e69910ffbf062/
