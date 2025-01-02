# Homeless Data Exhibition, DeKalb Gallery 2025
#### Team: [John Lauermann]([url](https://www.pratt.edu/people/john-lauermann/)), [Alex Strada]([url](https://www.pratt.edu/people/alex-strada)), [Yuanhao Wu]([url](https://www.linkedin.com/in/yuanhao-wu-80603723a/)), [Nathan Smash]([url](https://www.linkedin.com/in/nathan-smash-b6b93a24a/))
 
This document describes the methodology used to create maps for Strada’s Spring 2025 exhibition in the DeKalb gallery. We compiled data on gentrification, housing affordability, and other neighborhood demographics in New York. We then created printed maps for the exhibition and interactive 2D and 3D maps as digital companions.


 
## Data Gathering

Boundary files were obtained for NYC Community Districts and 2022 Census TigerLine tracts. Both were projected into UTM Zone 18N. Tracts in the five boroughs were extracted using a query and then water areas were clipped using district boundaries. 

### US Census
We compiled a collection of variables from the Census Bureau and NYC Open Data. See [variable documentation](https://docs.google.com/spreadsheets/d/1ocsovQU9sfGW3KTDgE4AntTEQhZ-ztR_e0dDfXoxsf8/edit?usp=sharing) here. 

Demographic variables were collected from ACS 2023 5yr estimates using the Census API via tidycensus and then joined to spatial data at the tract and community district scales. See R scripts for tract workflow and community district workflow. 


### NYC Open Data

We also pulled several datasets from NYC Open Data for calendar year 2024, including 311 calls related to homelessness, evictions filings, and homeless shelter locations. Due to the large volume of data and the 1000 record limitation that NYC Open Data places on its API, we wrote a loop to query the data via sodapy and transform it to geospatial layers with arcpy. See Python script for workflow.  


## Maps
At exhibition: 
2D Interactive: https://prattsavi.maps.arcgis.com/apps/webappviewer/index.html?id=6deed25ae96b496ca4cbc66723d51abe 
3D Interactive: https://prattsavi.maps.arcgis.com/apps/webappviewer3d/index.html?id=61d3ae908f314ac7ba09283414a42807
