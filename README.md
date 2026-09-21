# Bare ice duration darkens the Greenland Ice Sheet
[![Paper DOI](https://img.shields.io/badge/DOI-10.1029/2026JF009204-blue)](https://doi.org/10.1029/2026JF009204)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.12735481.svg)](https://doi.org/10.5281/zenodo.12735481)
 
This GitHub repository investigates the impact of bare ice duration on the average summer albedo and the influence of albedo on melt rates on the bare ice area of the Greenland Ice Sheet. 
Details of this repository are described in a manuscript that is published in JGR: Earth Surface.

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

## References
Harvard style citations:
```markdown
Feng, S., Cook, J.M., Box, J.E., Langen, P.L., Olesen, M., Anesio, A.M., Benning, L.G., Tranter, M., 2026. Associations Between the Seasonal Darkening of the Greenland Ice Sheet and the Duration of Bare Ice. Journal of Geophysical Research: Earth Surface 131, e2026JF009204. https://doi.org/10.1029/2026JF009204
```

Bibtex:
```bibtex
@article{bareice2026,
   author = {Shunan Feng and Joseph Mitchell Cook and Jason Eric Box and Peter L. Langen and Martin Olesen and Alexandre Magno Anesio and Liane G. Benning and Martyn Tranter},
   doi = {10.1029/2026JF009204},
   issn = {2169-9003},
   issue = {9},
   journal = {Journal of Geophysical Research: Earth Surface},
   keywords = {Greenland ice sheet,albedo,melt},
   month = {9},
   pages = {e2026JF009204},
   publisher = {John Wiley \& Sons, Ltd},
   title = {Associations Between the Seasonal Darkening of the Greenland Ice Sheet and the Duration of Bare Ice},
   volume = {131},
   year = {2026}
}

```