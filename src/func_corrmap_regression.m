function f_slope = func_corrmap_regression(imfolder)
% func_corrmap_regression Plot regression maps for slope, intercept, and R²
%   Creates three separate figures showing spatial distributions and inset
%   boxplots for:
%   - Linear regression slope (bare ice duration vs albedo)
%   - Linear regression intercept
%   - R² values (correlation coefficient squared)
%   Shunan Feng (shunan.feng@envs.au.dk)

%% Slope map (duration vs albedo)
load(fullfile(imfolder, "mod10s3corr.mat"));
% if isvector(slope) && numel(slope) == numel(correlationR)
%     slope = reshape(slope, size(correlationR)); % fallback if saved as 1-D
% end
slope(correlationP >= 0.05) = nan;
slope(slope>1 | slope<-1) = nan;

f_slope = figure;
f_slope.Position = [100 100 900 700];
ax_slope_map = axes(f_slope);
greenland('k');
mapshow(ax_slope_map, slope, R, 'DisplayType', 'surface');
colormap(ax_slope_map, cmocean('ice'));
clim(ax_slope_map, [-0.05, 0]);
axis off;
% title(ax_slope_map, "Slope: Albedo vs Bare Ice Duration", "FontWeight", "normal");
c_slope = colorbar(ax_slope_map, "eastoutside");
c_slope.Label.String = "Slope: BID vs $\overline{\alpha}$";
c_slope.Label.Interpreter = 'latex';
scalebarpsn('location', 'se');

% axpos = ax_slope_map.Position;
% inset_slope = axes(f_slope, 'Position', [axpos(1)+axpos(3)*0.55, axpos(2)+axpos(4)*0.2, axpos(3)*0.25, axpos(4)*0.2]);
% boxchart(inset_slope, slope(:), 'BoxFaceColor', '#083962', 'MarkerColor', '#94ace6');
% set(inset_slope, 'XTickLabel', [], 'Color', 'None',);
fontsize(f_slope, 16, "points");
exportgraphics(f_slope, "..\print\corrmap_bid_slope.png", "Resolution", 300);

%% Intercept map (duration vs albedo)
% load(fullfile(imfolder, "mod10s3corr.mat"));
% if isvector(intercept) && numel(intercept) == numel(correlationR)
%     intercept = reshape(intercept, size(correlationR)); % fallback if saved as 1-D
% end
intercept(correlationP >= 0.05) = nan;
intercept(isnan(slope)) = nan;

f_intercept = figure;
f_intercept.Position = [100 100 900 700];
ax_intercept_map = axes(f_intercept);
greenland('k');
mapshow(ax_intercept_map, intercept, R, 'DisplayType', 'surface');
colormap(ax_intercept_map, cmocean('tempo'));
clim(ax_intercept_map, [0.35, 0.85]);
axis off;
% title(ax_intercept_map, "Intercept: Albedo vs Bare Ice Duration", "FontWeight", "normal");
c_intercept = colorbar(ax_intercept_map, "eastoutside");
c_intercept.Label.String = "Intercept (BID vs $\overline{\alpha}$)";
c_intercept.Label.Interpreter = 'latex';
scalebarpsn('location', 'se');

% axpos = ax_intercept_map.Position;
% inset_intercept = axes(f_intercept, 'Position', [axpos(1)+axpos(3)*0.55, axpos(2)+axpos(4)*0.2, axpos(3)*0.25, axpos(4)*0.2]);
% boxchart(inset_intercept, intercept(:), 'BoxFaceColor', '#083962', 'MarkerColor', '#94ace6');
% set(inset_intercept, 'XTickLabel', [], 'Color', 'None', 'FontSize', 8);
fontsize(f_intercept, 16, "points");
exportgraphics(f_intercept, "..\print\corrmap_bid_intercept.png", "Resolution", 300);

%% R² map (duration vs albedo)
load(fullfile(imfolder, "mod10s3corr.mat"));
correlationR_sq = correlationR .* correlationR;
correlationR_sq(correlationP >= 0.05) = nan;

f_r2 = figure;
f_r2.Position = [100 100 900 700];
ax_r2_map = axes(f_r2);
greenland('k');
mapshow(ax_r2_map, correlationR_sq, R, 'DisplayType', 'surface');
colormap(ax_r2_map, cmocean('solar'));
clim(ax_r2_map, [0, 1]);
axis off;
% title(ax_r2_map, "R²: Bare Ice Duration vs Albedo", "FontWeight", "normal");
c_r2 = colorbar(ax_r2_map, "eastoutside");
c_r2.Label.String = "r² (p < 0.05)";
scalebarpsn('location', 'se');

axpos = ax_r2_map.Position;
inset_r2 = axes(f_r2, 'Position', [axpos(1)+axpos(3)/1.95 ...
    axpos(2)+axpos(4)/3 ...
    axpos(3)/10 axpos(4)/2]);
boxchart(inset_r2, correlationR_sq(:), 'BoxFaceColor', '#083962', 'MarkerColor', '#94ace6');
set(inset_r2, 'XTickLabel', [], 'Color', 'None', 'FontSize', 8);
fontsize(f_r2, 16, "points");
exportgraphics(f_r2, "..\print\corrmap_bid_r2.png", "Resolution", 300);

end