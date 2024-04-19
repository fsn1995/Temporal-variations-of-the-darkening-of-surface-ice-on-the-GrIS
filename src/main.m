%% Main script for the project
% This script is the main script for the project. It calls all the other
% functions in the project. The project is divided into three parts:
% 1. Preprocessing
% 2. Data analysis
% 3. Albedo spatial correlation


%% Preprocessing
% extract and plot daily AWS data with ice surface height data
[~, ~] = func_preprocessAWS("H:\AU\promiceaws\day", "H:\AU\promiceaws\output");

% preview AWS vs HSA
[~] = func_plotalbedo("H:\AU\promiceaws\output\AWS_height_daily.csv", ...
    "H:\AU\promiceaws\output\AWS_height_station_HSA.csv", ...
    "H:\AU\promiceaws\output");
[~] = func_satimgPreview("H:\AU\promiceaws\output\AWS_height_daily.csv", ...
    "H:\AU\promiceaws\HSA"); % this step takes quite long

% add albedo_diff, height_diff, and hsa_diff to the datasets 
[~, ~] = func_reprocess("H:\AU\promiceaws\output\AWS_height_daily.csv", ...
    "H:\AU\promiceaws\output\AWS_height_station_HSA.csv", ...
    "H:\AU\promiceaws\output");

% [~] = func_plotheight("H:\AU\promiceaws\output\AWS_reprocessed.csv", ...
%     "H:\AU\promiceaws\output");
% % preliminary comparison of in situ albedo vs surface height and filter AWS
% % data to May-Sep
% [dfaws, dfhsajoined] = func_albedoVSheight("H:\AU\promiceaws\output\AWS_height_daily.csv", ...
%     "H:\AU\promiceaws\output\AWS_height_station_HSA.csv", ...
%     "H:\AU\promiceaws\output");

%% Data analysis
% analyze albeod threshold
[~] = func_threshold_analysis("H:\AU\promiceaws\output\AWS_reprocessed.csv");

% duration analysis
[~] = func_duration_calculator("H:\AU\promiceaws\output\AWS_reprocessed.csv", ...
    "H:\AU\promiceaws\output\HSA_reprocessed.csv", ...
    "..\print", "..\stat");

[~] = func_duration_analysis("..\stat\icestats.xlsx", "..\print");



% plot albedo vs HSA, and interpolated HSA
% [~] = func_plotAWSHSA("H:\AU\promiceaws\output\AWS_reprocessed.csv", ...
%     "H:\AU\promiceaws\output\HSA_reprocessed.csv", ...
%     "..\print");

% height analysis
% plot albedo vs height
% [~] = func_plotheight("H:\AU\promiceaws\output\AWS_reprocessed.csv", "..\print");

% [dfstat] = func_height_calculator("H:\AU\promiceaws\output\AWS_reprocessed.csv", ...
%     "H:\AU\promiceaws\output\HSA_interp.csv", ...
%     "..\print", "..\stat");


%% albedo spatial correlation

% build mosaic of daily HSA albedo
[imcount] = func_buildmosaic("/data/shunan/data/GrISdailyAlbedoChip", ...
    "/data/shunan/data/GrISdailyAlbedoMosaic");

% extract pixel values from the mosaic
% [filelist] = func_albedospatial("/data/shunan/data/GrISdailyAlbedoMosaic", "hsa");
[filelist] = func_albedospatial("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\SICEalbedo", "s3");
[filelist] = func_albedospatial("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\MOD10", "mod10");

% calculate spatial correlation
[correlationR, correlationP, R] = func_spatialcorr("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\albedospatial\mods3", "mods3");
save("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\albedospatial\mod10s3corr.mat", ...
    "correlationP", "correlationR", "R", "-mat");
[correlationR, correlationP] = func_spatialcorr("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\SICEalbedo", "s3");

% plotting
% f1 = func_supplement("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\albedospatial\mods3", ...
%     "..\print\timeseriesmap");

f1 = func_corrmap("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\albedospatial");

