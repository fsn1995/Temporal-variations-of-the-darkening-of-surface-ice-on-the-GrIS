

% extract daily AWS data covering bare ice area
% [~, ~] = func_preprocessPROMICEGC("H:\AU\promiceaws\day", "H:\AU\promiceaws\output");

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
% % analyze albeod threshold
[~] = func_threshold_analysis("H:\AU\promiceaws\output\AWS_reprocessed.csv");

% % duration analysis
% [~] = func_duration_calculator("H:\AU\promiceaws\output\AWS_reprocessed.csv", ...
%     "H:\AU\promiceaws\output\HSA_reprocessed.csv", ...
%     "..\print", "..\stat");

% [~] = func_duration_analysis("..\stat\icestats.xlsx", "..\print");


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


%% albedo maps
[imcount] = func_buildmosaic("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\GrISdailyAlbedoChip", ...
    "O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\GrISdailyAlbedoMosaic");
