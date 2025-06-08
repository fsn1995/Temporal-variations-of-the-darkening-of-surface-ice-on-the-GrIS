imfolder = "..\data";

years = [2002, 2012];
for i = 1:length(years)
    year = years(i);

    % Load data
    load(fullfile(imfolder, sprintf("mods3/albedo_spatial_%d.mat", year)));
    bare_duration = single(bare_duration);  
    bare_duration(bare_duration < 1) = nan;
    albedo_avg(isnan(bare_duration)) = nan;

    % bare ice duration map
    figfile = figure("Visible", "off");
    greenland('k');
    hold on
    mapshow(bare_duration, R, 'DisplayType', 'surface');
    colormap(cmocean('solar'));
    clim([1, 92]);
    axis off;
    c1 = colorbar('eastoutside');
    c1.Label.String = 'bare ice duration (days)';
    mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
    scalebarpsn('location', 'se');
    fontsize(15, "points");
    exportgraphics(figfile, sprintf("../print/darkzone/duration%d.png", year), "Resolution", 300);
    close(figfile)

    % albedo map
    figfile = figure("Visible", "off");
    greenland('k');
    hold on
    mapshow(albedo_avg, R, 'DisplayType', 'surface');
    colormap(func_dpcolor());
    clim([0, 1]);
    axis off;
    c2 = colorbar('eastoutside');
    c2.Label.String = 'albedo (JJA)';
    mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
    scalebarpsn('location', 'se');
    fontsize(15, "points");
    exportgraphics(figfile, sprintf("../print/darkzone/albedo%d.png", year), "Resolution", 300);
    close(figfile)

    % melt map
    load(fullfile(imfolder, sprintf("mods3/snmelt_%d.mat", year)));
    immelt(isnan(bare_duration)) = nan;
    figfile = figure("Visible", "off");
    greenland('k');
    hold on
    mapshow(immelt, R, 'DisplayType', 'surface');
    colormap(cmocean('-amp'));
    clim([-5, 0]);
    axis off;
    c3 = colorbar('eastoutside');
    c3.Label.String = 'melt (m w.e.)';
    mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
    scalebarpsn('location', 'se');
    fontsize(15, "points");
    exportgraphics(figfile, sprintf("../print/darkzone/melt%d.png", year), "Resolution", 300);
    close(figfile)
end

% 2022 data
% read the Greenland ice mask
[mask, R] = readgeoraster("..\data\greenland_ice_mask.tif");
load(fullfile(imfolder, "mods3\albedo_spatial_2022.mat"));
xlimit = [min(mapx) max(mapx)];
ylimit = [min(mapy) max(mapy)];
[s3mask, Rmask] = mapcrop(mask, R, xlimit, ylimit);

albedo_avg = flipud(rot90(albedo_avg));
bare_duration = flipud(rot90(bare_duration));
albedo_avg(1:10, :) = [];
albedo_avg(end, :) = [];
bare_duration(1:10, :) = [];
bare_duration(end, :) = [];
s3mask = uint16(s3mask);
bare_duration = bare_duration .* s3mask;
albedo_avg = albedo_avg .* s3mask;

bare_duration = single(bare_duration);
bare_duration(bare_duration < 1) = nan;
albedo_avg = single(albedo_avg)/10000;
albedo_avg(isnan(bare_duration)) = nan;

% bare ice duration map for 2022
figfile = figure("Visible", "off");
greenland('k');
hold on
mapshow(bare_duration, Rmask, 'DisplayType', 'surface');
colormap(cmocean('solar'));
clim([1, 92]);
axis off;
c1 = colorbar('eastoutside');
c1.Label.String = 'bare ice duration (days)';
mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
scalebarpsn('location', 'se');
fontsize(15, "points");
exportgraphics(figfile, "../print/darkzone/duration2022.png", "Resolution", 300);
close(figfile)

% albedo map for 2022
figfile = figure("Visible", "off");
greenland('k');
hold on
mapshow(albedo_avg, Rmask, 'DisplayType', 'surface');
colormap(func_dpcolor());
clim([0, 1]);
axis off;
c2 = colorbar('eastoutside');
c2.Label.String = 'albedo (JJA)';
mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
scalebarpsn('location', 'se');
fontsize(15, "points");
exportgraphics(figfile, "../print/darkzone/albedo2022.png", "Resolution", 300);
close(figfile)

% melt map for 2022
load(fullfile(imfolder, "mods3\snmelt_2022.mat"));
[immelt, Rmask] = mapcrop(immelt, Rmelt, xlimit, ylimit);
immelt(isnan(bare_duration)) = nan;
figfile = figure("Visible", "off");
greenland('k');
hold on
mapshow(immelt, Rmask, 'DisplayType', 'surface');
colormap(cmocean('-amp'));
clim([-5, 0]);
axis off;
c3 = colorbar('eastoutside');
c3.Label.String = 'melt (m w.e.)';
mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
scalebarpsn('location', 'se');
fontsize(15, "points");
exportgraphics(figfile, "../print/darkzone/melt2022.png", "Resolution", 300);
close(figfile)

% duration vs albedo
load(fullfile(imfolder, "mod10s3corr.mat"));
correlationR(correlationP>=0.05) = nan;
correlationR = correlationR .* correlationR;

figfile = figure("Visible", "off");
greenland('k');
hold on
mapshow(correlationR, R, 'DisplayType', 'surface');
colormap(cmocean('haline'));
clim([0, 1]);
axis off;
c4 = colorbar('eastoutside');
c4.Label.String = 'duration vs albedo: r^2 (p < 0.05)';
mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
scalebarpsn('location', 'se');
fontsize(15, "points");
exportgraphics(figfile, "../print/darkzone/duration_albedo_correlation.png", "Resolution", 300);
close(figfile)

% albedo vs melt
load(fullfile(imfolder, "mods3smbcorr.mat"));
correlationR(correlationP>=0.05) = nan;
correlationR = correlationR .* correlationR;

figfile = figure("Visible", "off");
greenland('k');
hold on
mapshow(correlationR, R, 'DisplayType', 'surface');
colormap(cmocean('haline'));
clim([0, 1]);
axis off;
c5 = colorbar('eastoutside');
c5.Label.String = 'albedo vs melt: r^2 (p < 0.05)';
mapzoompsn(67.167,-49.833,'mapwidth',[500 800],'ne');
scalebarpsn('location', 'se');
fontsize(15, "points");
exportgraphics(figfile, "../print/darkzone/albedo_melt_correlation.png", "Resolution", 300);
close(figfile)