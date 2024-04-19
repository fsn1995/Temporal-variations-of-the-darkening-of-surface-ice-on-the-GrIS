function f1 = func_corrmap(imfolder)

% imfolder = "O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\albedospatial";

f1 = figure;
f1.Position = [2184 -91 1144 756];
t = tiledlayout(2, 4, 'TileSpacing','none','Padding','compact'); % 

% 2002
load(fullfile(imfolder, "mods3\albedo_spatial_2002.mat"));
bare_duration = single(bare_duration);
bare_duration(bare_duration < 1) = nan;
albedo_avg(isnan(bare_duration)) = nan;

ax1 = nexttile(1);
greenland('k');
mapshow(ax1, bare_duration, R, 'DisplayType', 'surface');
colormap(ax1, cmocean('solar'));
clim(ax1, [1, 92]);
axis off;

ax5 = nexttile(5);
greenland('k');
mapshow(ax5, albedo_avg, R, 'DisplayType', 'surface');
colormap(ax5, func_dpcolor());
clim(ax5, [0, 1]);
axis off;

% 2012
load(fullfile(imfolder, "mods3\albedo_spatial_2012.mat"));
bare_duration = single(bare_duration);
bare_duration(bare_duration < 1) = nan;
albedo_avg(isnan(bare_duration)) = nan;

ax2 = nexttile(2);
greenland('k');
mapshow(ax2, bare_duration, R, 'DisplayType', 'surface');
colormap(ax2, cmocean('solar'));
clim(ax2, [1, 92]);
axis off;

ax6 = nexttile(6);
greenland('k');
mapshow(ax6, albedo_avg, R, 'DisplayType', 'surface');
colormap(ax6, func_dpcolor());
clim(ax6, [0, 1]);
axis off;

% 2022
% read the Greenland ice mask
[mask, R] = readgeoraster("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\greenland_ice_mask.tif");
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

ax3 = nexttile(3);
greenland('k');
mapshow(ax3, bare_duration, Rmask, 'DisplayType', 'surface');
colormap(ax3, cmocean('solar'));
clim(ax3, [1, 92]);
axis off;

ax7 = nexttile(7);
greenland('k');
mapshow(ax7, albedo_avg, Rmask, 'DisplayType', 'surface');
colormap(ax7, func_dpcolor());
clim(ax7, [0, 1]);
axis off;

% Correlation map
load(fullfile(imfolder, "mod10s3corr.mat"));
correlationR(correlationP>=0.05) = nan;

ax4 = nexttile(4);
greenland('k');
mapshow(ax4, correlationR.*correlationR, R, 'DisplayType', 'surface');
% colormap(ax4, cmocean('balance'));
colormap(ax4, cmocean('haline'));
clim(ax4, [0, 1]);
axis off;

load(fullfile(imfolder, "barefruequncy.mat"));
ax8 = nexttile(8);
greenland('k');
mapshow(ax8, bare_frequency, Rmask, 'DisplayType', 'surface');
colormap(ax8, cmocean('-curl', 'pivot', 10));
% colormap(ax8, crameri('-vik', 'pivot', 10));
clim(ax8, [1, 22]);
scalebarpsn('location','se');
axis off;

%% label and annotation
title(ax1, "2002", "FontWeight","normal");
title(ax2, "2012", "FontWeight","normal");
title(ax3, "2022", "FontWeight","normal");
title(ax4, "2002-2023", "FontWeight","normal")

text(ax1, 0.15, 0.1, 'a)', 'Units', 'normalized');
text(ax2, 0.15, 0.1, 'c)', 'Units', 'normalized');
text(ax3, 0.15, 0.1, 'e)', 'Units', 'normalized');
text(ax4, 0.15, 0.1, 'g)', 'Units', 'normalized');
text(ax5, 0.15, 0.1, 'b)', 'Units', 'normalized');
text(ax6, 0.15, 0.1, 'd)', 'Units', 'normalized');
text(ax7, 0.15, 0.1, 'f)', 'Units', 'normalized');
text(ax8, 0.15, 0.1, 'h)', 'Units', 'normalized');

c1 = colorbar(ax1, "westoutside");
c1.Label.String = "bare ice duration (days)";
c5 = colorbar(ax5, "westoutside");
c5.Label.String = "albedo (JJA)";
c4 = colorbar(ax4, "eastoutside");
c4.Label.String = "r^2 (p < 0.05)"; 
c8 = colorbar(ax8, "eastoutside");
c8.Label.String = "bare ice frequency (years)";

fontsize(t, 16, "points");

exportgraphics(f1, "..\print\corrmap.pdf", "Resolution", 300);

end    