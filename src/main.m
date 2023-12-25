

% extract daily AWS data covering bare ice area
% [~, ~] = func_preprocessPROMICEGC("H:\AU\promiceaws\day", "H:\AU\promiceaws\output");

%% Preprocessing
% extract daily AWS data with ice surface height data
[dfaws, awsloc] = func_preprocessAWS("H:\AU\promiceaws\day", "H:\AU\promiceaws\output");

% preview AWS vs HSA
[~] = func_plotalbedo("H:\AU\promiceaws\output\AWS_height_daily.csv", ...
    "H:\AU\promiceaws\output\AWS_height_station_HSA.csv", ...
    "H:\AU\promiceaws\output");

% preliminary comparison of in situ albedo vs surface height and filter AWS
% data to May-Sep
dfaws = func_albedoVSheight(dfaws, "H:\AU\promiceaws\output");
