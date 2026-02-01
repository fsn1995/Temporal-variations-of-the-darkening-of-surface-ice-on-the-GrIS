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
f1.Position = [750 379 1152 744];
t = tiledlayout(f1, 1, 3, "TileSpacing","tight", "Padding", "tight");
% awsgroupColor = ["#186294", "#bd3162", "#cdb47b", "#41b4ee"]; % gyarados "U", "M", "L", "G"

ax1 = nexttile;
mdl_bare = fitlm(dfawsduration.duration_bareice, dfawsduration.albedo, "linear");
h1 = plot(ax1, mdl_bare);
hold on
% text(ax1, 2, 0.17, ...
%     sprintf("a) r^2:%.2f, p-value<%.2f, n:%.0f", ...
%     mdl_bare.Rsquared.Ordinary, mdl_bare.ModelFitVsNullModel.Pvalue, mdl_bare.NumObservations));
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
ylim(ax1, [0 0.9]);
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
% text(ax2, 0.23, -5.5, ...
%     sprintf("b) r^2:%.2f, p-value<%.2f, n:%.0f", ...
%     mdl.Rsquared.Ordinary, mdl.ModelFitVsNullModel.Pvalue, mdl.NumObservations));
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

ax3 = nexttile;
mdl_snowfree = fitlm(dfawsduration.duration_bareice, dfawsduration.albedo_ice, "linear");
h3 = plot(ax3, mdl_snowfree);
hold on
% text(ax3, 2, 0.15, ...
%     sprintf("e) r^2:%.2f, p-value<%.2f, n:%.0f", ...
%     mdl_snowfree.Rsquared.Ordinary, mdl_snowfree.ModelFitVsNullModel.Pvalue, mdl_bare.NumObservations));
s2 = gscatter(ax3, dfawsduration.duration_bareice, dfawsduration.albedo_ice, ...
    dfawsduration.awsgroup);
s2(1).Color = "#cdb47b";
s2(2).Color = "#bd3162";
s2(3).Color = "#41b4ee";
s2(4).Color = "#186294";
set(h3(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
set(h3(3), "Color", "k");
% set(h3(4), "Color", "k");
delete(h3(1)); %[h1(1), h1(3), h1(4)]
xlim(ax3, [1 92]);
pbaspect(ax3,[1 1 1]);
xlabel(ax3, "bare ice duration (days)");
ylabel(ax3, "bare ice albedo (JJA average)");
title(ax3, "");
grid on
pbaspect(ax3, [1 1 1]);
hold off
linkaxes([ax1 ax3], 'xy');
legend(ax3, 'hide');

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

% ax5 = nexttile;
% A = imread("..\print\HSA_linear.png");
% % A = imresize(A, 0.8);
% imshow(A);
% text(ax5, -0.05, -0.05, 'c) r^2:0.55, p-value<0.00, n:1,889,267,238', 'Units', 'normalized');
% 
% ax6 = nexttile;
% A = imread("..\print\smb_linear.png");
% % A = imresize(A, 0.8);
% imshow(A);
% text(ax6, 0.0, -0.05, 'd) r^2:0.46, p-value<0.00, n:31,283,401', 'Units', 'normalized');


fontsize(t, 14, "points");

exportgraphics(f1, outputfolder+'\duration_analysis.png', "Resolution",300);
% legend(ax3, "off");



