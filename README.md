# Atmosphere Models (MATLAB)

Overview
--------

This repository provides functions for reading IONEX files, interpolating TEC maps in space and time, converting geodetic coordinates, and computing pierce points / ionospheric mapping parameters. Additionally, the UNB3 atmospheric model is implemented.

Functions
-------------------------

- `UNB3Model.m` : Implementation of the UNB3 tropospheric model. More details on implementation can be found on [Navipedia](https://gssc.esa.int/navipedia/index.php/Tropospheric_Delay#cite_note-4)
- `readionexfile.m` : Read IONEX (TEC map) files. Returns grid metadata and TEC values for available epochs. This function was adapted from Erman Senturk and is available on [ResearchGate](https://www.researchgate.net/publication/341453294_MATLAB_code_to_read_IONEX_files_of_Global_Ionosphere_Maps?channel=doi&linkId=5ec25029299bf1c09ac4d230&showFulltext=true)
- `interpTECMap.m` : Spatial interpolation of a TEC map for a single epoch
- `interpTECMapTime.m` : Temporal interpolation across TEC map epochs
- `calcIPP.m` : Calculate ionospheric pierce points (IPPs) for satellite emitters

Quick start
-----------

To get started, simply clone the repository and add the /src folder to your MATLAB path. Example calculations are provided in a script called modelTest.m

Data
----
Ionosphere maps can be obtained from [NASA's CDDIS data repository](https://www.earthdata.nasa.gov/centers/cddis-daac). You will need to make an account.

TLE data can be found on [Celestrak](https://celestrak.org/)


