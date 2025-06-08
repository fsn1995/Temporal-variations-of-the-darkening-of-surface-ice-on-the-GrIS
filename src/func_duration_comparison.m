function [f1] = func_duration_comparison(dfduration, outputfolder)
%
% This function performs duration analysis on the temporal variations of the darkening of surface ice on the Greenland Ice Sheet (GrIS).
% It takes in the necessary input data and calculates various statistics related to the duration of darkening events.
% The function returns the figure as output.
%
% Inputs:
%   - dfduration: A table containing the duration of darkening events for each AWS and HSA site.
%   - outputfolder: A string containing the path to the output folder where the figure will be saved.
%
% Outputs:
%   - f1: A figure containing the results of the duration analysis.
%
% Author: Shunan Feng (shunan.feng@envs.au.dk)
% 

% check input variable
if isstring(dfduration)
    dfawsduration = readtable(dfduration, "Sheet", "AWS");
    dfhsaduration = readtable(dfduration, "Sheet", "HSA");
end

%% filter out durations >=92 or <1
dfawsduration.duration_bareice(dfawsduration.duration_bareice < 1) = nan;
dfawsduration.duration_darkice(dfawsduration.duration_darkice < 1) = nan;

%% plotting
f1 = figure;
f1.Position = [750 379 round(1186*2/3) round(744*2/3)];
t = tiledlayout(f1, 1, 2, "TileSpacing","tight", "Padding", "tight");
% awsgroupColor = ["#186294", "#bd3162", "#cdb47b", "#41b4ee"]; % gyarados "U", "M", "L", "G"

%% AWS vs HSA
dfawsduration = dfawsduration(dfawsduration.year>2018,:);

ax1 = nexttile;


% refline(ax1, 1, 0);
mdl_duration = fitlm(dfhsaduration.duration_bareice, dfawsduration.duration_bareice, "linear");
h3 = plot(mdl_duration);
hold on
markers = {'o', 's', 'd', '^'}; % different marker shapes for each group
groups = unique(dfawsduration.awsgroup, 'stable');
hold on;
s1 = gobjects(length(groups), 1); % pre-allocate array
for i = 1:length(groups)
    idx = strcmp(dfawsduration.awsgroup, groups{i});
    s1(i) = scatter(dfhsaduration.duration_bareice(idx), dfawsduration.duration_bareice(idx), ...
        50, dfhsaduration.num(idx), markers{i}, 'filled', "DisplayName", groups{i});
end
colormap(ax1, crameri('roma'));
c = colorbar(ax1, 'eastoutside');
c.Label.String = 'Number of clear HSA observations';
clim(ax1, [1 92]);
c.Layout.Tile = 'south';
% s1(1).Color = "#cdb47b";
% s1(2).Color = "#bd3162";
% s1(3).Color = "#41b4ee";
% s1(4).Color = "#186294";
set(h3(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
set(h3(3), "Color", "k");
% set(h3(4), "Color", "k");
delete(h3(1));
legend off
% c = colorbar(ax1, 'eastoutside');
% c.Label.String = 'number of clear observations';
% cmocean('algae');
% clim(ax1, [min(dfhsaduration.num) max(dfhsaduration.num)]);
title(ax1, "");
xlabel(ax1, "HSA estimated bare ice duration (days)");
ylabel(ax1, "AWS estimated bare ice duration (days)");
pbaspect(ax1, [1 1 1]);
xlim(ax1, [1 92]);
ylim(ax1, [1,92]);
text(ax1, 4, 10, ...
    sprintf("a) r^2:%.2f, p-value<%.3f, n:%.0f", ...
    mdl_duration.Rsquared.Ordinary, 0.001, mdl_duration.NumObservations));% mdl_duration.ModelFitVsNullModel.Pvalue
grid on
leg = legend(ax1,[s1(3) s1(1) s1(2) s1(4)],'Orientation','Horizontal');
% leg.Position = [ 0.1595    0.9528    0.1658    0.0655];
leg.Layout.Tile = 'North';

ax2 = nexttile;
% refline(ax1, 1, 0);
mdl_albedo = fitlm(dfhsaduration.hsa, dfawsduration.albedo, "linear");
h4 = plot(mdl_albedo);
hold on
markers = {'o', 's', 'd', '^'}; % different marker shapes for each group
groups = unique(dfawsduration.awsgroup, 'stable');
hold on;
s2 = gobjects(length(groups), 1); % pre-allocate array
for i = 1:length(groups)
    idx = strcmp(dfawsduration.awsgroup, groups{i});
    s2(i) = scatter(dfhsaduration.hsa(idx), dfawsduration.albedo(idx), ...
        50, dfhsaduration.num(idx), markers{i}, 'filled', "DisplayName", groups{i});
end
colormap(ax2, crameri('roma'));
% c = colorbar(ax2, 'eastoutside');
% c.Label.String = 'Number of clear observations';
clim(ax2, [1 92]);
set(h4(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
set(h4(3), "Color", "k");
% set(h4(4), "Color", "k");
delete(h4(1));
legend off
% c = colorbar('eastoutside');
% c.Label.String = 'number of clear observations';
% cmocean('algae');
% clim(ax2, [min(dfhsaduration.num) max(dfhsaduration.num)]);
title(ax2, "");
xlabel(ax2, "HSA (JJA average)");
ylabel(ax2, "AWS albedo (JJA average)");
pbaspect(ax2, [1 1 1]);
xlim(ax2, [0.1 0.8]);
ylim(ax2, [0.1,0.8]);
text(ax2, 0.15, 0.15, ...
    sprintf("b) r^2:%.2f, p-value<%.3f, n:%.0f", ...
    mdl_albedo.Rsquared.Ordinary, 0.001, mdl_duration.NumObservations));
grid on

% ax3 = nexttile;
% mdl_hsa = fitlm(dfhsaduration.duration_bareice, dfhsaduration.hsa, "linear");
% h5 = plot(mdl_hsa);
% hold on
% markers = {'o', 's', 'd', '^'}; % different marker shapes for each group
% groups = unique(dfawsduration.awsgroup, 'stable');
% hold on;
% s3 = gobjects(length(groups), 1); % pre-allocate array
% for i = 1:length(groups)
%     idx = strcmp(dfawsduration.awsgroup, groups{i});
%     s3(i) = scatter(dfhsaduration.duration_bareice(idx), dfhsaduration.hsa(idx), ...
%         50, dfhsaduration.num(idx), markers{i}, 'filled', "DisplayName", groups{i});
% end
% colormap(ax3, crameri('roma'));
% % c = colorbar(ax3, 'eastoutside');
% % c.Label.String = 'Number of clear observations';
% clim(ax3, [1 92]);
% set(h5(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
% set(h5(3), "Color", "k");
% % set(h5(4), "Color", "k");
% delete(h5(1));
% legend off
% title(ax3, "");
% xlabel(ax3, "HSA estimated bare ice duration (days)");
% ylabel(ax3, "HSA (JJA average)");
% pbaspect(ax3, [1 1 1]);
% xlim(ax3, [1 92]);
% ylim(ax3, [0,0.9]);
% grid on
% text(ax3, 4, 0.1, ...
%     sprintf("c) r^2:%.2f, p-value<%.3f, n:%.0f", ...
%     mdl_hsa.Rsquared.Ordinary, 0.001, mdl_hsa.NumObservations));
fontsize(t, 15, "points");

exportgraphics(f1, outputfolder+'\duration_comparison.pdf', "Resolution",300);
exportgraphics(f1, outputfolder+'\duration_comparison.png', "Resolution",300);
% legend(ax1, "off");