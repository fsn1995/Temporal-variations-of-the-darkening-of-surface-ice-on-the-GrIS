%% Main script for the project
% This script is the main script for the project. It calls all the other
% functions in the project. The project is divided into three parts:
% 1. Data Preprocessing
% 2. Data Analysis and Visualization
% 3. Supplementary Data Analysis and Visualization


%% 1. Data Preprocessing 
% Note: The data preprocessing is done in the following steps. 
% However the postprocessed data are saved in the data folder.
% The following steps are for reference only, but can be run if needed.

% 1.1 - point scale AWS and HSA data
% extract and plot daily AWS data with transducer measurements
[~, ~] = func_preprocessAWS("H:\AU\promiceaws\day", "H:\AU\promiceaws\output");

% Preview AWS vs HSA time series data
[~] = func_plotalbedo("H:\AU\promiceaws\output\AWS_height_daily.csv", ...
    "H:\AU\promiceaws\output\AWS_height_station_HSA.csv", ...
    "H:\AU\promiceaws\output");
% Preview satellite images and time series data
[~] = func_satimgPreview("H:\AU\promiceaws\output\AWS_height_daily.csv", ...
    "H:\AU\promiceaws\HSA"); % this step takes quite long
% Add albedo_diff, height_diff, and hsa_diff to the datasets 
[~, ~] = func_reprocess("H:\AU\promiceaws\output\AWS_height_daily.csv", ...
    "H:\AU\promiceaws\output\AWS_height_station_HSA.csv", ...
    "H:\AU\promiceaws\output");

% 1.2 - Spatial scale MOD10 and SICE albedo data
% Build mosaic of daily HSA albedo
[imcount] = func_buildmosaic("/data/shunan/data/GrISdailyAlbedoChip", ...
    "/data/shunan/data/GrISdailyAlbedoMosaic");

% Extract pixel values from the mosaic
[filelist] = func_albedospatial("/data/shunan/data/GrISdailyAlbedoMosaic", "hsa");
[filelist] = func_albedospatial("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\SICEalbedo", "s3");
[filelist] = func_albedospatial("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\MOD10", "mod10");

% 1.3 - Spatial scale SMB data
filelist = func_preprocessSMB("H:\AU\ENVS_SMB_ALBEDO");


%% 2. Data Analysis and Visualization
% 2.1 Visualize AWS location and time series of albedo (fig. 1)
[~] = func_threshold_analysis("..\data\AWS_reprocessed.csv");

% 2.2 Point and pixel scale bare ice duration, albedo, and ablation/melt analysis
% Impact of bare ice duration on albedo, and the influence of albedo on ablation/melt (fig. 2)

% calculate bare ice duration, albedo, and ablation/melt
[~] = func_duration_calculator("..\data\AWS_reprocessed.csv", ...
    "..\data\HSA_reprocessed.csv", ...
    "..\print", "..\stat");
% plot bare ice duration, albedo, and ablation/melt
[~] = func_duration_analysis("..\stat\icestats.xlsx", "..\print");
[~] = func_duration_comparison("..\stat\icestats.xlsx", "..\print");
% 2.3 Spatial scale bare ice duration, albedo, and melt analysis
% Spatial analysis of the impact of bare ice duration on albedo, and the influence of albedo on melt (fig. 3)

% calculate spatial correlation
[correlationR, correlationP, R, slope, intercept] = func_spatialcorr("..\data\mods3", "mods3");
save("..\data\mod10s3corr.mat", ...
    "correlationP", "correlationR", "R", "slope", "intercept", "-mat");
[correlationR, correlationP, R, slope, intercept] = func_spatialcorr("..\data\mods3", "smb");
save("..\data\mods3smbcorr.mat", ...
    "correlationP", "correlationR", "R", "slope", "intercept", "-mat");
f1 = func_corrmap("..\data");
f1 = func_corrmap_regression("..\data"); 
f1 = func_corrmap_regression_darkzone("..\data");
%% 3. Supplementary Data Analysis and Visualization
f1 = func_supplement("..\data\mods3", ...
    "..\print\timeseriesmap");

