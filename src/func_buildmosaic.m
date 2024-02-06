function [imcount] = func_buildmosaic(inputfolder,outputfolder)
%FUNC_BUILDMOSAIC Summary of this function goes here
%   Detailed explanation goes here
imfiles = dir(inputfolder + "\*.tif");
imnames = string(extractfield(imfiles, "name")');
imnames = extractBefore(imnames, "-0000");
index = findgroups(imnames);
indexUnique = unique(index);
imnamesUnique = unique(imnames);

for i = 1:max(indexUnique)
    fprintf("processing %s\n", imnamesUnique(i));
    imselect = index == i;
    mosaicfiles = imfiles(imselect, :);
    [im11, R11] = readgeoraster(fullfile(mosaicfiles(1).folder, mosaicfiles(1).name));
    [im12, R12] = readgeoraster(fullfile(mosaicfiles(2).folder, mosaicfiles(2).name));
    [im21, R21] = readgeoraster(fullfile(mosaicfiles(3).folder, mosaicfiles(3).name));
    [im22, R22] = readgeoraster(fullfile(mosaicfiles(4).folder, mosaicfiles(4).name));
    immosaic = [im11 im12;
                im21 im22];
    immosaic(immosaic>=10000) = 0; 
    xlimits = [R11.XWorldLimits(1) R12.XWorldLimits(2)];
    ylimits = [R21.YWorldLimits(1) R11.YWorldLimits(2)];
    mosaicR = maprefcells(xlimits,ylimits,size(immosaic));
    mosaicR.ColumnsStartFrom = 'north';
    mosaicR.ProjectedCRS = R11.ProjectedCRS;
    geotiffwrite(fullfile(outputfolder, imnamesUnique(i) + ".tif"), ...
        immosaic, mosaicR, "CoordRefSysCode", 3413);
    
end
imcount = height(dir(outputfolder + "\*.tif"));
end

