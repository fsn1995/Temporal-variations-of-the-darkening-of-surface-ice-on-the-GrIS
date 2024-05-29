function [exporteddata] = func_preprocessSMB(imfolder)

imfiles = dir(fullfile(imfolder,'*.nc'));
imyrange = string({imfiles.name}.');
imyrange = extractBetween(imyrange, "Daily2D_Merged_", "_ShunanVars.nc");

% iterate over years in imyrange
for i = 1:length(imyrange)
    imfile = fullfile(imfiles(i).folder, imfiles(i).name);
    fprintf("processing %s\n", string(imfiles(i).name));
    % read the SMB variable from the .nc file
    % lon, lat, time, snmel
    imlat = ncread(imfile, "lat");
    imlon = ncread(imfile, "lon");
    imtime = ncread(imfile, "time");
    immelt = ncread(imfile, "snmel");
    
    imtime = datetime(floor(imtime), "ConvertFrom", "yyyymmdd");
    imdateindex = imtime < datetime(double(imyrange(i)), 6, 1) ...
    | imtime > datetime(double(imyrange(i)), 8, 31);
    immelt(:,:,imdateindex) = [];
    % calculate the melt during the JJA period
    immelt = sum(immelt * -1, 3)/1000;

    % read the Greenland ice mask
    [mask, R] = readgeoraster("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\greenland_ice_mask.tif", ...
        'OutputType', 'double');
    mask(mask==0) = nan;
    [mapx, mapy] = projfwd(R.ProjectedCRS, imlat, imlon);
    x = R.XWorldLimits(1)+R.XIntrinsicLimits(1):R.CellExtentInWorldX:R.XWorldLimits(2);
    y = R.YWorldLimits(1)+R.YIntrinsicLimits(1):R.CellExtentInWorldY:R.YWorldLimits(2);
    [X,Y] = meshgrid(x, y);
    immelt = griddata(double(mapx(:)), double(mapy(:)), immelt(:), X, Y);
    immelt = flipud(immelt).*mask;
    Rmelt = R;
    % save the melt to a .mat file for each year
    save(fullfile(imfolder, sprintf("snmelt_%s.mat", imyrange(i))), ...
        "immelt", "Rmelt", "-mat");
end

exporteddata = dir(fullfile(imfolder, "snmelt_*.mat"));

end
