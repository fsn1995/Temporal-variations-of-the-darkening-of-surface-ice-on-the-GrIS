function f1 = func_corrmap(imfolder)
% func_corrmap Plot the correlation map of bare ice duration, albedo, and melt
% Shunan Feng (shunan.feng@envs.au.dk)

f1 = figure;
f1.Position = [2170 -227 1054 1008];
t = tiledlayout(3, 4, 'TileSpacing','none','Padding','compact'); % 

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

load(fullfile(imfolder, "mods3\snmelt_2002.mat"));
immelt(isnan(bare_duration)) = nan;
ax9 = nexttile(9);
greenland('k');
mapshow(ax9, immelt, R, 'DisplayType', 'surface');
colormap(ax9, cmocean('-amp'));
clim(ax9, [-5, 0]);
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

load(fullfile(imfolder, "mods3\snmelt_2012.mat"));
immelt(isnan(bare_duration)) = nan;
ax10 = nexttile(10);
greenland('k');
mapshow(ax10, immelt, R, 'DisplayType', 'surface');
colormap(ax10, cmocean('-amp'));
clim(ax10, [-5, 0]);
axis off;

% 2022
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

load(fullfile(imfolder, "mods3\snmelt_2022.mat"));
[immelt, Rmask] = mapcrop(immelt, Rmelt, xlimit, ylimit);
immelt(isnan(bare_duration)) = nan;
ax11 = nexttile(11);
greenland('k');
mapshow(ax11, immelt, Rmask, 'DisplayType', 'surface');
colormap(ax11, cmocean('-amp'));
clim(ax11, [-5, 0]);
axis off;

% Correlation map
% duration vs albedo
load(fullfile(imfolder, "mod10s3corr.mat"));
correlationR(correlationP>=0.05) = nan;
correlationR = correlationR .* correlationR;

ax4 = nexttile(4);
greenland('k');
mapshow(ax4, correlationR, R, 'DisplayType', 'surface');
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
axis off;

% albedo vs melt
load(fullfile(imfolder, "mods3smbcorr.mat"));
correlationR(correlationP>=0.05) = nan;
correlationR = correlationR .* correlationR;

ax12 = nexttile(12);
greenland('k');
mapshow(ax12, correlationR, R, 'DisplayType', 'surface');
colormap(ax12, cmocean('haline'));
clim(ax12, [0, 1]);
scalebarpsn('location','se');
axis off;

%% label and annotation
title(ax1, "2002", "FontWeight","normal");
title(ax2, "2012", "FontWeight","normal");
title(ax3, "2022", "FontWeight","normal");
title(ax4, "2002-2023", "FontWeight","normal")

text(ax1, 0.15, 0.1, 'a)', 'Units', 'normalized');
text(ax2, 0.15, 0.1, 'b)', 'Units', 'normalized');
text(ax3, 0.15, 0.1, 'c)', 'Units', 'normalized');
text(ax4, 0.15, 0.1, 'j)', 'Units', 'normalized');
text(ax5, 0.15, 0.1, 'd)', 'Units', 'normalized');
text(ax6, 0.15, 0.1, 'e)', 'Units', 'normalized');
text(ax7, 0.15, 0.1, 'f)', 'Units', 'normalized');
text(ax8, 0.15, 0.1, 'k)', 'Units', 'normalized');
text(ax9, 0.15, 0.1, 'g)', 'Units', 'normalized');
text(ax10, 0.15, 0.1, 'h)', 'Units', 'normalized');
text(ax11, 0.15, 0.1, 'i)', 'Units', 'normalized');
text(ax12, 0.15, 0.1, 'l)', 'Units', 'normalized');

c1 = colorbar(ax1, "westoutside");
c1.Label.String = "bare ice duration (days)";
c5 = colorbar(ax5, "westoutside");
c5.Label.String = "albedo (JJA)";
c4 = colorbar(ax4, "eastoutside");
c4.Label.String = "duration vs albedo: r^2 (p < 0.05)"; 
c8 = colorbar(ax8, "eastoutside");
c8.Label.String = "bare ice frequency (years)";
c9 = colorbar(ax9, "westoutside");
c9.Label.String = "melt (m w.e.)";
c12 = colorbar(ax12, "eastoutside");
c12.Label.String = "albedo vs melt: r^2 (p < 0.05)";

fontsize(t, 16, "points");

load(fullfile(imfolder, "mod10s3corr.mat"));
correlationR(correlationP>=0.05) = nan;
correlationR = correlationR .* correlationR;
ax4_1 = axes(f1, 'Position', [ax4.Position(1)+ax4.Position(3)/1.9 ...
    ax4.Position(2)+ax4.Position(4)/3 ...
    ax4.Position(3)/6 ax4.Position(4)/3]);
boxchart(ax4_1, correlationR(:), ... Blastoise
    'BoxFaceColor', '#083962', 'MarkerColor', '#94ace6');
set(ax4_1, 'XTickLabel', [], 'Color', 'None', 'FontSize', 8);

ax8_1 = axes(f1, 'Position', [ax8.Position(1)+ax8.Position(3)/1.9 ...
    ax8.Position(2)+ax8.Position(4)/3 ...
    ax8.Position(3)/6 ax8.Position(4)/3]);
boxchart(ax8_1, bare_frequency(:), ...
    'BoxFaceColor', '#083962', 'MarkerColor', '#94ace6');
set(ax8_1, 'XTickLabel', [], 'Color', 'None', 'FontSize', 8);

load(fullfile(imfolder, "mods3smbcorr.mat"));
correlationR(correlationP>=0.05) = nan;
correlationR = correlationR .* correlationR;

ax12_1 = axes(f1, 'Position', [ax12.Position(1)+ax12.Position(3)/1.9 ...
    ax12.Position(2)+ax12.Position(4)/3 ...
    ax12.Position(3)/6 ax12.Position(4)/3]);
boxchart(ax12_1, correlationR(:), ...
    'BoxFaceColor', '#083962', 'MarkerColor', '#94ace6');
set(ax12_1, 'XTickLabel', [], 'Color', 'None', 'FontSize', 8);

exportgraphics(f1, "..\print\corrmap.png", "Resolution", 300);

end    