

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
% preliminary comparison of in situ albedo vs surface height and filter AWS
% data to May-Sep
[dfaws, dfhsajoined] = func_albedoVSheight("H:\AU\promiceaws\output\AWS_height_daily.csv", ...
    "H:\AU\promiceaws\output\AWS_height_station_HSA.csv", ...
    "H:\AU\promiceaws\output");
