function figfile = func_supplement(imfolder, outputfolder)
% This function generates the supplementary figures for the manuscript.
% It takes in the necessary input data and saves the figures to the output folder.
% The function returns the path to the saved figure.
%
% Inputs:
%   - imfolder: A string containing the path to the folder where the input data is stored.
%   - outputfolder: A string containing the path to the output folder where the figures will be saved.
%
% Outputs:
%   - figfile: A matlab figure object containing the generated figure for the bare ice frequency.
%
% Author: Shunan Feng (shunan.feng@envs.au.dk)

imfiles = dir(fullfile(imfolder, "*.mat"));
imdate = string({imfiles.name}.');
imdate =extractBetween(imdate, "albedo_spatial_", ".mat");
% if figfile exist, delete it
if isfile(fullfile(outputfolder, "supplement_duration_albedo.pdf"))
    delete(fullfile(outputfolder, "supplement_duration_albedo.pdf"));
end

% read the Greenland ice mask
[mask, R] = readgeoraster("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\greenland_ice_mask.tif");
% preallocate a matrix for the bare ice frequency
bare_frequency = zeros(size(mask), 'single');

for i = 1:length(imfiles)-4

    load(fullfile(imfolder, imfiles(i).name));
    bare_duration = single(bare_duration);
    bare_duration(bare_duration < 1) = nan;
    albedo_avg(isnan(bare_duration)) = nan;

    bare_frequency = bare_frequency + ~isnan(bare_duration);

    figfile = figure;
    figfile.Position = [876 673 1066 565];

    t = tiledlayout(1, 2, 'TileSpacing','compact','Padding','compact');

    ax1 = nexttile;
    greenland('k');
    mapshow(ax1, bare_duration, R, 'DisplayType', 'surface');
    colormap(ax1, cmocean('solar'));
    clim(ax1, [1, 92]);
    axis off;
    scalebarpsn('location','se');

    ax2 = nexttile;
    greenland('k');
    mapshow(ax2, albedo_avg, R, 'DisplayType', 'surface');
    colormap(ax2, func_dpcolor());
    clim(ax2, [0, 1]);
    axis off;
    scalebarpsn('location','se');

    c1 = colorbar(ax1, "westoutside");
    c1.Label.String = "bare ice duration (days)";
    c2 = colorbar(ax2, "westoutside");
    c2.Label.String = "albedo (JJA)";

    title(t, imdate(i));
    fontsize(t, 16, "points");
    exportgraphics(figfile, fullfile(outputfolder, sprintf("supplement_duration_albedo_%s.png", imdate(i))), ...
    'Resolution', 300);
    exportgraphics(figfile, fullfile(outputfolder, "supplement_duration_albedo.pdf"), ...
    'Resolution', 300, 'Append', true);
    close all
end

load(fullfile(imfolder, imfiles(end-3).name), 'mapx', 'mapy');
xlimit = [min(mapx) max(mapx)];
ylimit = [min(mapy) max(mapy)];
[bare_frequency, ~] = mapcrop(bare_frequency, R, xlimit, ylimit);

for i = length(imfiles)-3:length(imfiles)

    load(fullfile(imfolder, imfiles(i).name));
    albedo_avg = flipud(rot90(albedo_avg));
    bare_duration = flipud(rot90(bare_duration));
    albedo_avg(1:10, :) = [];
    albedo_avg(end, :) = [];
    bare_duration(1:10, :) = [];
    bare_duration(end, :) = [];
    xlimit = [min(mapx) max(mapx)];
    ylimit = [min(mapy) max(mapy)];
    [s3mask, Rmask] = mapcrop(mask, R, xlimit, ylimit);
    s3mask = uint16(s3mask);
    bare_duration = bare_duration .* s3mask;
    albedo_avg = albedo_avg .* s3mask;

    bare_duration = single(bare_duration);
    bare_duration(bare_duration < 1) = nan;
    albedo_avg = single(albedo_avg)/10000;
    albedo_avg(isnan(bare_duration)) = nan;
    bare_frequency = bare_frequency + ~isnan(bare_duration);

    figfile = figure;
    figfile.Position = [876 673 1066 565];
    
    t = tiledlayout(1, 2, 'TileSpacing','compact','Padding','compact');
    
    ax1 = nexttile;
    greenland('k');
    mapshow(ax1, bare_duration, Rmask, 'DisplayType', 'surface');
    colormap(ax1, cmocean('solar'));
    clim(ax1, [1, 92]);
    axis off;
    scalebarpsn('location','se');
    
    ax2 = nexttile;
    greenland('k');
    mapshow(ax2, albedo_avg, Rmask, 'DisplayType', 'surface');
    colormap(ax2, func_dpcolor());
    clim(ax2, [0, 1]);
    axis off;
    scalebarpsn('location','se');
    
    c1 = colorbar(ax1, "westoutside");
    c1.Label.String = "bare ice duration (days)";
    c2 = colorbar(ax2, "westoutside");
    c2.Label.String = "albedo (JJA)";
    
    title(t, imdate(i));
    fontsize(t, 16, "points");
    exportgraphics(figfile, fullfile(outputfolder, sprintf("supplement_duration_albedo_%s.png", imdate(i))), ...
    'Resolution', 300);
    exportgraphics(figfile, fullfile(outputfolder, "supplement_duration_albedo.pdf"), ...
    'Resolution', 300, 'Append', true);
    close all
end

bare_frequency(bare_frequency == 0) = nan;
save("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\albedospatial\barefruequncy.mat", ...
    "bare_frequency", "Rmask");
% f1 = figure;
% mapshow(bare_frequency, Rmask, 'DisplayType', 'surface');
% greenland('k');
% colormap(cmocean('-ice'));
% clim([1, 22]);
% axis off;
% scalebarpsn('location','se');
% c = colorbar("westoutside");
% c.Label.String = "bare ice frequency (years)"; 
% exportgraphics(f1, fullfile(outputfolder, "supplement_bare_frequency.pdf"), ...
%     'Resolution', 300);

end