# Data updates (after the original exhibition)

This documents subsequent updates to data related to Collective Mobilities, as we update the maps and share data in related projects. [`compile_data_Census.R`](compile_data_Census.R) pulls housing data from the Census API, cleaning them and aggregating into relevant spatial units (block groups, tracts, and NYC community districts). [`compile_data_NYCOpenData.R`](compile_data_NYCOpenData.R) similarly pulls data related to housing insecurity from the NYC Open Data API, cleaning them and aggregating into the same spatial units. 

To replicate this workflow, simply download the `.R` scripts, save them in a relevant working directory, and run them with your preferred code editor. Both work from open data APIs, so you'll also need to obtain and enter API keys from the [Census API](https://api.census.gov/data/key_signup.html) and [NYC Open Data/Socrata API](https://www.nyc.gov/opendata/get-started/user-guides/open-data-apis). 
