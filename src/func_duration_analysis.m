function [f1] = func_duration_analysis(dfduration, outputfolder)
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
f1.Position = [313.8000   77.0000  727.2000  649.6000];
t = tiledlayout(f1, 2, 2, "TileSpacing","tight", "Padding", "tight");
% awsgroupColor = ["#186294", "#bd3162", "#cdb47b", "#41b4ee"]; % gyarados "U", "M", "L", "G"

ax1 = nexttile;
mdl_bare = fitlm(dfawsduration.duration_bareice, dfawsduration.albedo, "linear");
h1 = plot(ax1, mdl_bare);
hold on
text(ax1, 2, 0.17, ...
    sprintf("a) r^2:%.2f, p-value<%.2f, n:%.0f", ...
    mdl_bare.Rsquared.Ordinary, mdl_bare.ModelFitVsNullModel.Pvalue, mdl_bare.NumObservations));
s1 = gscatter(ax1, dfawsduration.duration_bareice, dfawsduration.albedo, ...
    dfawsduration.awsgroup);
s1(1).Color = "#cdb47b";
s1(2).Color = "#bd3162";
s1(3).Color = "#41b4ee";
s1(4).Color = "#186294";
set(h1(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
set(h1(3), "Color", "k");
% set(h1(4), "Color", "k");
delete(h1(1)); %[h1(1), h1(3), h1(4)]
xlim(ax1, [1 92]);
ylim(ax1, [0.1 0.8]);
pbaspect(ax1, [1 1 1]);
xlabel(ax1, "bare ice duration (days)");
ylabel(ax1, "albedo (JJA average)");
title(ax1, "");
grid on
hold off
leg = legend(ax1,[s1(3) s1(1) s1(2) s1(4)],'Orientation','Horizontal');
% leg.Position = [ 0.1595    0.9528    0.1658    0.0655];
leg.Layout.Tile = 'North';

ax2 = nexttile;
mdl = fitlm(dfawsduration.albedo, dfawsduration.ablation, "linear");
h5 = plot(ax2, mdl);
hold on
text(ax2, 0.20, -5.5, ...
    sprintf("b) r^2:%.2f, p-value<%.2f, n:%.0f", ...
    mdl.Rsquared.Ordinary, mdl.ModelFitVsNullModel.Pvalue, mdl.NumObservations));
s3 = gscatter(ax2, dfawsduration.albedo, dfawsduration.ablation, ...
    dfawsduration.awsgroup);
s3(1).Color = "#cdb47b";
s3(2).Color = "#bd3162";
s3(3).Color = "#41b4ee";
s3(4).Color = "#186294";
set(h5(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
set(h5(3), "Color", "k");
% set(h5(4), "Color", "k");
delete(h5(1)); %[h1(1), h1(3), h1(4)]
title(ax2, "");
xlabel(ax2, "albedo (JJA average)");
ylabel(ax2, "ablation (m)");
% legend(ax2,[s3(3) s3(1) s3(2) s3(4)], ...
%     'Location','NorthOutside','Orientation','Horizontal');
legend(ax2, 'hide')
ylim(ax2, [-6.1 0]);
grid on
pbaspect(ax2, [1 1 1]);
% ax3 = nexttile;
% mdl_dark = fitlm(dfawsduration.duration_darkice, dfawsduration.albedo, "linear");
% h2 = plot(ax3, mdl_dark);
% hold on
% text(ax3, 2, 0.15, ...
%     sprintf("c) r^2:%.2f, p-value<%.2f, n:%.0f", ...
%     mdl_dark.Rsquared.Ordinary, mdl_dark.ModelFitVsNullModel.Pvalue, mdl_dark.NumObservations));
% s2 = gscatter(ax3, dfawsduration.duration_darkice, dfawsduration.albedo, ...
%     dfawsduration.awsgroup);
% s2(1).Color = "#186294";
% s2(2).Color = "#bd3162";
% s2(3).Color = "#cdb47b";
% s2(4).Color = "#41b4ee";
% set(h2(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
% set(h2(3), "Color", "k");
% set(h2(4), "Color", "k");
% delete(h2(1));
% xlim(ax3, [1 92]);
% pbaspect(ax3,[1 1 1]);
% xlabel(ax3, "dark ice duration (days)");
% ylabel(ax3, "albedo (JJA average)");
% title(ax3, "");
% grid on
% hold off
% leg = legend(ax3, 'Location','NorthOutside','Orientation','Horizontal');
% leg.Layout.Tile = 'North';
% % leg.Position = [0.2239    0.9528   0.2384    0.0521];
% linkaxes([ax1 ax3], 'xy');

% ax4 = nexttile;
% dfawsduration.darkspeed = daysact(dfawsduration.bare_1stday, dfawsduration.dark_1stday);
% boxchart(ax4, categorical(dfawsduration.awsgroup), dfawsduration.darkspeed, "Notch", "on");
% grid on
% ylabel(ax4, "bare-dark transition (days)");
% xlabel(ax4, "AWS group");
% text(ax4, 0.3, 5, "c)");
% pbaspect(ax4, [1 1 1]);

%% AWS vs HSA
% dfawsduration = dfawsduration(dfawsduration.year>2018,:);

ax5 = nexttile;
A = imread("..\print\HSA_linear.png");
% A = imresize(A, 0.8);
imshow(A);
text(ax5, -0.02, -0.05, 'c) r^2:0.55, p-value<0.00, n:1,889,267,238', 'Units', 'normalized');
% text(ax3,5, 120, 'c)', 'FontSize',20);
% scatter(ax5, dfhsaduration.duration_bareice, dfawsduration.duration_bareice, [], ...
%     dfhsaduration.num, "filled");
% hold on
% % refline(ax5, 1, 0);
% mdl_hsa = fitlm(dfhsaduration.duration_bareice, dfawsduration.duration_bareice, "linear");
% h3 = plot(mdl_hsa);
% set(h3(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
% set(h3(3), "Color", "k");
% set(h3(4), "Color", "k");
% delete(h3(1));
% legend off
% c = colorbar(ax5, 'eastoutside');
% c.Label.String = 'number of clear observations';
% cmocean('algae');
% clim(ax5, [min(dfhsaduration.num) max(dfhsaduration.num)]);
% title(ax5, "");
% xlabel(ax5, "HSA estimated bare ice duration (days)");
% ylabel(ax5, "AWS estimated bare ice duration (days)");
% pbaspect(ax5, [1 1 1]);
% xlim(ax5, [0 100]);
% ylim(ax5, [0,100]);
% text(ax5, 15, 10, ...
%     sprintf("d) r^2:%.2f, p-value<%.2f, n:%.0f", ...
%     mdl_hsa.Rsquared.Ordinary, mdl_hsa.ModelFitVsNullModel.Pvalue, mdl_hsa.NumObservations));
% grid on

% ax6 = nexttile;
% scatter(ax6, dfhsaduration.duration_darkice, dfawsduration.duration_darkice, [], ...
%     dfhsaduration.num, "filled");
% hold on
% % refline(ax5, 1, 0);
% mdl_hsa = fitlm(dfhsaduration.duration_darkice, dfawsduration.duration_darkice, "linear");
% h4 = plot(mdl_hsa);
% set(h4(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
% set(h4(3), "Color", "k");
% set(h4(4), "Color", "k");
% delete(h4(1));
% legend off
% c = colorbar('eastoutside');
% c.Label.String = 'number of clear observations';
% cmocean('algae');
% clim(ax6, [min(dfhsaduration.num) max(dfhsaduration.num)]);
% title(ax6, "");
% xlabel(ax6, "HSA estimated dark ice duration (days)");
% ylabel(ax6, "AWS estimated dark ice duration (days)");
% pbaspect(ax6, [1 1 1]);
% xlim(ax6, [0 100]);
% ylim(ax6, [0,100]);
% text(ax6, 15, 5, ...
%     sprintf("f) r^2:%.2f, p-value<%.2f, n:%.0f", ...
%     mdl_hsa.Rsquared.Ordinary, mdl_hsa.ModelFitVsNullModel.Pvalue, mdl_hsa.NumObservations));
% grid on
% linkaxes([ax5 ax6], 'xy');
fontsize(t, 12, "points");

exportgraphics(f1, outputfolder+'\duration_analysis.pdf', "Resolution",300);
% legend(ax3, "off");



