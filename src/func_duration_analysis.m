function [f1] = func_duration_analysis(dfduration, outputfolder)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% check input variable
if isstring(awsduration)
    dfawsduration = readtable(dfduration, "Sheet", "AWS");
    dfhsaduration = readtable(dfduration, "Sheet", "HSA");
end

%% filter out durations >=92 or <1
dfawsduration.duration_bareice(dfawsduration.duration_bareice >=92 | dfawsduration.duration_bareice < 1) = nan;
dfawsduration.duration_darkice(dfawsduration.duration_darkice >=92 | dfawsduration.duration_darkice < 1) = nan;

%% plotting
f1 = figure;
f1.Position = [466   226   715   369];
t = tiledlayout(f1, 1, 2, "TileSpacing","compact", "Padding", "compact");
% awsgroupColor = ["#186294", "#bd3162", "#cdb47b", "#41b4ee"]; % gyarados "U", "M", "L", "G"

ax1 = nexttile;
mdl_bare = fitlm(dfawsduration.duration_bareice, dfawsduration.albedo, "linear");
h1 = plot(ax1, mdl_bare);
hold on
text(ax1, 2, 0.15, ...
    sprintf("a) r^2: %.2f, p-value<%.2f", ...
    mdl_bare.Rsquared.Ordinary, mdl_bare.ModelFitVsNullModel.Pvalue));
s1 = gscatter(ax1, dfawsduration.duration_bareice, dfawsduration.albedo, ...
    dfawsduration.awsgroup);
s1(1).Color = "#186294";
s1(2).Color = "#bd3162";
s1(3).Color = "#cdb47b";
s1(4).Color = "#41b4ee";
set(h1(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
delete([h1(1), h1(3), h1(4)]);
xlim(ax1, [1 91]);
xlabel(ax1, "bare ice duration (days)");
ylabel(ax1, "albedo (JJA average)");
title(ax1, "");
grid on
hold off
legend(ax1, 'off');

ax2 = nexttile;
mdl_dark = fitlm(dfawsduration.duration_darkice, dfawsduration.albedo, "linear");
h2 = plot(ax2, mdl_dark);
hold on
text(ax2, 2, 0.15, ...
    sprintf("b) r^2: %.2f, p-value<%.2f", ...
    mdl_dark.Rsquared.Ordinary, mdl_dark.ModelFitVsNullModel.Pvalue));
s2 = gscatter(ax2, dfawsduration.duration_darkice, dfawsduration.albedo, ...
    dfawsduration.awsgroup);
s2(1).Color = "#186294";
s2(2).Color = "#bd3162";
s2(3).Color = "#cdb47b";
s2(4).Color = "#41b4ee";
set(h2(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
delete([h2(1), h2(3), h2(4)]);
xlim(ax2, [1 91]);
xlabel(ax2, "dark ice duration (days)");
ylabel(ax2, "");
title(ax2, "");
grid on
hold off

leg = legend(ax2, 'Location','NorthOutside','Orientation','Horizontal');
leg.Layout.Tile = 'North';
linkaxes([ax1 ax2], 'xy');

fontsize(t, 12, "points");

exportgraphics(f1, outputfolder+'\duration_analysis.pdf', "Resolution",300);
% legend(ax2, "off");


