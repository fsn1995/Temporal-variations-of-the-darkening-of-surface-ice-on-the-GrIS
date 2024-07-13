# Bare ice duration darkens the Greenland Ice Sheet
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.12735482.svg)](https://doi.org/10.5281/zenodo.12735482)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Ffsn1995%2FTemporal-variations-of-the-darkening-of-surface-ice-on-the-GrIS&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)
 
This GitHub repository investigates the impact of bare ice duration on the average summer albedo and the influence of albedo on melt rates on the bare ice area of the Greenland Ice Sheet. 
Details of this repository are described in a manuscript that is currently under review.

## Data preparation
The albedo data used in this study includes daily MOD10A1, SICE, harmonized Landsat, and Sentinel 2 (harmonized satellite albedo, HSA), as well as PROMICE weather station data. 
MODIS and HSA albedo products are open access on GEE and were exported for local processing.
The SICE and PROMICE data were obtained from GEUS Dataverse. 

The following scripts are used for data processing and export:
- [src/temporalAnalysis.js](src/temporalAnalysis.js): Calculates and exports the HSA.
- [src/temporalAnalysisMODIS.js](src/temporalAnalysisMODIS.js): Exports the daily MOD10A1 albedo.

Please note that the surface melt data used in this study was provided by coauthors and is not included in this repository.

## Data preprocessing, analysis, and visualization
The main script, [src/main.m](src/main.m), calls all the necessary functions to preprocess the data, calculate the bare ice duration, and analyze the impact of bare ice duration on the average summer albedo and the influence of albedo on melt rates on the Greenland Ice Sheet. Details of the functions are described in the script.
The preprocessed data are stored in the [data](data) folder.
