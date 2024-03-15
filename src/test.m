%% test image mosaic with matlab
[imcount] = func_iminterp("H:\AU\GrISdailyAlbedoChip", ...
    "H:\AU\GrISdailyAlbedoChipInterpolated");
close all
clearvars

% [imcount] = func_buildmosaic("/data/shunan/data/GrISdailyAlbedoChip", ...
%     "/data/shunan/data/GrISdailyAlbedoMosaic");