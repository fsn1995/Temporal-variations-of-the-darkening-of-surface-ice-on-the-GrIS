%% test image mosaic with matlab
[imcount] = func_iminterp("/data/shunan/data/GrISdailyAlbedoChip", ...
    "/data/shunan/data/GrISdailyAlbedoChipInterp");
close all
clearvars

% [imcount] = func_buildmosaic("/data/shunan/data/GrISdailyAlbedoChip", ...
%     "/data/shunan/data/GrISdailyAlbedoMosaic");