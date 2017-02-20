# Is 2016 the Hottest Year on Record?

## Abstract
That our climate is changing seems unequivocal. Data sets such as NOAA’s GHCN [1] comprise up-to-date records of temperatures from stations all over the world. Using a recent version of the GHCN data, I reproduced a target graph from NOAA’s Climate at a Glance webpage showing global land temperature anomalies for the period 1901-2016. To obtain the NOAA graph, I had to use the quality control adjusted (QCA) data and apply two non-trivial transformations. First, stations were grouped into 5x5 grid boxes and an average of these stations was taken to represent each grid box (gridding). Second, station observations were recast with respect to a baseline obtained from the 1961-1990 period (baselining). Both gridding and baselining employed seemingly arbitrary parameterization. In contrast, I modify NOAA’s techniques and employ an adaptive climate-based gridding and a station-relative baselining, approaches I believe to be more defensible as “natural” transformations. In addition, the final result respects the original QCA data while retaining key aspects of the NOAA analysis. A warming trend is clearly indicated, in spite of a late 20th/early 21st century slowdown. 2016 is the warmest year after the transformations, illustrating the effects of the larger climate change.

## Table of Contents
This repository contains all of the data and code needed to reproduce the analyses in [the overview paper](noaa_revisited2.pdf). Brief descriptions follow.

1. [noaa_revisited2.pdf](noaa_revisited2.pdf) -- this is the paper containing the main results and should be read first as all other files are with respect to this writeup.

2. [GHCN_analysis.pdf](GHCN_analysis.pdf) -- this is a sketch of my prior analysis.

3. CSV files:
  * [2x2grid.csv](2x2grid.csv), [5x5grid.csv](5x5grid.csv), [10x10grid.csv](10x10grid.csv) -- these contain the WKT (well-known text) form of the grid polygons at indicated resolution, for ease of import into the database.
  * [climate_zones.csv](climate_zones.csv) -- this contains the polygons corresponding to Koeppen-Geiger climate boundaries.
  * [tavg_qca_final.csv](tavg_qca_final.csv) -- this contains the munged GHCN average temperature data
  * [locations_final.csv](locations.csv) -- this contains the weather stations and their locations and attributes
  * [yrly_grid_avgs.csv](yrly_grid_avgs.csv) -- this contains temperatures averaged over the 5x5 grid
  * [yrly_climate_avgs.csv](yrly_climate_avgs.csv) -- this contains temperatures averaged over the climate polygons
  * [yrly_anoms.csv](yrly_anoms.csv) -- this contains anomalies with baseline 1961-1990
  * [yrly_anom_baselines4.csv](yrly_anom_baselines4.csv) -- this contains anomalies with different baselines
  * [yrly_anom_varying.csv](yrly_anom_varying.csv) -- this contains anomalies with baselines varying by station
  * [yrly_grid_anoms.csv](yrly_grid_anoms.csv) -- this contains 1961-1990 anomalies averaged over the 5x5 grid
  * [yrly_climate_anoms.csv](yrly_climate_anoms.csv) -- this contains varying baseline anomalies averaged over the climate grid
  
4. PNG files:
  * [qcu_analysis.png](qcu_analysis.png) -- the original analysis from the GHCN_analysis.pdf methods
  * [multigraph_NOAAland.png](multigraph_NOAAland.png) -- the NOAA Climate at a Glance plot I set out to reproduce
  * [station_locations_kav7.png](station_locations_kav7.png) -- station locations and 5x5 grid illustrated
  * [climate_grid.png](climate_grid.png) -- climate grid illustrated
  
5. SQL files:
  * [yrly_grid_avgs.sql](yrly_grid_avgs.sql) -- sql to initialize database and create [yrly_grid_avgs.csv](yrly_grid_avgs.csv)
  * [climates.sql](climates.sql) -- sql to create [yrly_climate_avgs.csv](yrly_climate_avgs.csv) and [yrly_climate_anoms.csv](yrly_climate_anoms.csv)
  * [anoms.sql](anoms.sql) -- sql to create [yrly_anoms.csv](yrly_anoms.csv), [yrly_anom_baselines4.csv](yrly_anom_baselines4.csv), [yrly_anom_varying.csv](yrly_anom_varying.csv), and [yrly_grid_anoms.csv](yrly_grid_anoms.csv).
  
6. R (and R markdown) files:
  * [munge.R](munge.R) -- R script to turn original GHCN data obtained from NOAA into [tavg_qca_final.csv](tavg_qca_final.csv)
  * [munge_locations.R](munge_locations.R) -- R script to turn original GHCN station info into [locations_final.csv](locations_final.csv)
  * [noaa_revisited2.Rmd](noaa_revisited2.Rmd) -- source code for the final write up [noaa_revisited2.pdf](noaa_revisited2.pdf)
  
7. Jupyter Notebook (Python) file:
  * [ghcn1.ipynb](ghcn1.ipynb) -- Python for various helper actions: generating map images, exporting polygon WKT, etc.
  
8. Zip file:
  * [ghcn1.zip](ghcnq.zip) -- all the input files the python script [ghcn1.ipynb](ghcn1.ipynb) needs (shapefiles, etc)

[1] Jay H. Lawrimore, Matthew J. Menne, Byron E. Gleason, Claude N. Williams, David B. Wuertz, Russell S. Vose, and Jared Rennie (2011): Global Historical Climatology Network - Monthly (GHCN-M), Version 3. Average Temperatures. NOAA National Centers for Environmental Information. doi:10.7289/V5X34VDR 01/22/2017.
