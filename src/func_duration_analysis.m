function [f1] = func_duration_analysis(dfduration, outputfolder)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
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
f1.Position = [125 47 1158 722];
t = tiledlayout(f1, 2, 3, "TileSpacing","tight", "Padding", "tight");
% awsgroupColor = ["#186294", "#bd3162", "#cdb47b", "#41b4ee"]; % gyarados "U", "M", "L", "G"
ax1 = nexttile;
mdl = fitlm(dfawsduration.albedo, dfawsduration.ablation, "linear");
h5 = plot(ax1, mdl);
hold on
text(ax1, 0.25, -5.5, ...
    sprintf("a) r^2:%.2f, p-value<%.2f, n:%.0f", ...
    mdl.Rsquared.Ordinary, mdl.ModelFitVsNullModel.Pvalue, mdl.NumObservations));
s3 = gscatter(ax1, dfawsduration.albedo, dfawsduration.ablation, ...
    dfawsduration.awsgroup);
s3(1).Color = "#186294";
s3(2).Color = "#bd3162";
s3(3).Color = "#cdb47b";
s3(4).Color = "#41b4ee";
set(h5(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
set(h5(3), "Color", "k");
set(h5(4), "Color", "k");
delete(h5(1)); %[h1(1), h1(3), h1(4)]
title(ax1, "");
xlabel(ax1, "albedo (JJA average)");
ylabel(ax1, "ablation (m)");
legend(ax1, "off");
ylim(ax1, [-6.1 0]);
grid on

ax2 = nexttile;
mdl_bare = fitlm(dfawsduration.duration_bareice, dfawsduration.albedo, "linear");
h1 = plot(ax2, mdl_bare);
hold on
text(ax2, 2, 0.15, ...
    sprintf("b) r^2:%.2f, p-value<%.2f, n:%.0f", ...
    mdl_bare.Rsquared.Ordinary, mdl_bare.ModelFitVsNullModel.Pvalue, mdl_bare.NumObservations));
s1 = gscatter(ax2, dfawsduration.duration_bareice, dfawsduration.albedo, ...
    dfawsduration.awsgroup);
s1(1).Color = "#186294";
s1(2).Color = "#bd3162";
s1(3).Color = "#cdb47b";
s1(4).Color = "#41b4ee";
set(h1(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
set(h1(3), "Color", "k");
set(h1(4), "Color", "k");
delete(h1(1)); %[h1(1), h1(3), h1(4)]
xlim(ax2, [1 92]);
ylim(ax2, [0.1 0.8]);
pbaspect(ax2, [1 1 1]);
xlabel(ax2, "bare ice duration (days)");
ylabel(ax2, "albedo (JJA average)");
title(ax2, "");
grid on
hold off
legend(ax2, "off");

ax3 = nexttile;
mdl_dark = fitlm(dfawsduration.duration_darkice, dfawsduration.albedo, "linear");
h2 = plot(ax3, mdl_dark);
hold on
text(ax3, 2, 0.15, ...
    sprintf("c) r^2:%.2f, p-value<%.2f, n:%.0f", ...
    mdl_dark.Rsquared.Ordinary, mdl_dark.ModelFitVsNullModel.Pvalue, mdl_dark.NumObservations));
s2 = gscatter(ax3, dfawsduration.duration_darkice, dfawsduration.albedo, ...
    dfawsduration.awsgroup);
s2(1).Color = "#186294";
s2(2).Color = "#bd3162";
s2(3).Color = "#cdb47b";
s2(4).Color = "#41b4ee";
set(h2(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
set(h2(3), "Color", "k");
set(h2(4), "Color", "k");
delete(h2(1));
xlim(ax3, [1 92]);
pbaspect(ax3,[1 1 1]);
xlabel(ax3, "dark ice duration (days)");
ylabel(ax3, "albedo (JJA average)");
title(ax3, "");
grid on
hold off
leg = legend(ax3, 'Location','NorthOutside','Orientation','Horizontal');
leg.Layout.Tile = 'North';
% leg.Position = [0.2239    0.9528   0.2384    0.0521];
linkaxes([ax2 ax3], 'xy');

ax4 = nexttile;
dfawsduration.darkspeed = daysact(dfawsduration.bare_1stday, dfawsduration.dark_1stday);
boxchart(ax4, categorical(dfawsduration.awsgroup), dfawsduration.darkspeed, "Notch", "on");
grid on
ylabel(ax4, "bare-dark transition (days)");
xlabel(ax4, "AWS group");
text(ax4, 0.3, 5, "d)")

%% AWS vs HSA
dfawsduration = dfawsduration(dfawsduration.year>2018,:);

ax5 = nexttile;
scatter(ax5, dfhsaduration.duration_bareice, dfawsduration.duration_bareice, [], ...
    dfhsaduration.num, "filled");
hold on
% refline(ax5, 1, 0);
mdl_hsa = fitlm(dfhsaduration.duration_bareice, dfawsduration.duration_bareice, "linear");
h3 = plot(mdl_hsa);
set(h3(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
set(h3(3), "Color", "k");
set(h3(4), "Color", "k");
delete(h3(1));
legend off
cmocean('algae');
clim(ax5, [min(dfhsaduration.num) max(dfhsaduration.num)]);
title(ax5, "");
xlabel(ax5, "HSA estimated bare ice duration (days)");
ylabel(ax5, "AWS estimated bare ice duration (days)");
pbaspect(ax5, [1 1 1]);
xlim(ax5, [0 100]);
ylim(ax5, [0,100]);
text(ax5, 15, 5, ...
    sprintf("e) r^2:%.2f, p-value<%.2f, n:%.0f", ...
    mdl_hsa.Rsquared.Ordinary, mdl_hsa.ModelFitVsNullModel.Pvalue, mdl_hsa.NumObservations));
grid on

ax6 = nexttile;
scatter(ax6, dfhsaduration.duration_darkice, dfawsduration.duration_darkice, [], ...
    dfhsaduration.num, "filled");
hold on
% refline(ax5, 1, 0);
mdl_hsa = fitlm(dfhsaduration.duration_darkice, dfawsduration.duration_darkice, "linear");
h4 = plot(mdl_hsa);
set(h4(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
set(h4(3), "Color", "k");
set(h4(4), "Color", "k");
delete(h4(1));
legend off
c = colorbar('eastoutside');
c.Label.String = 'number of clear observations';
cmocean('algae');
clim(ax6, [min(dfhsaduration.num) max(dfhsaduration.num)]);
title(ax6, "");
xlabel(ax6, "HSA estimated dark ice duration (days)");
ylabel(ax6, "AWS estimated dark ice duration (days)");
pbaspect(ax6, [1 1 1]);
xlim(ax6, [0 100]);
ylim(ax6, [0,100]);
text(ax6, 15, 5, ...
    sprintf("f) r^2:%.2f, p-value<%.2f, n:%.0f", ...
    mdl_hsa.Rsquared.Ordinary, mdl_hsa.ModelFitVsNullModel.Pvalue, mdl_hsa.NumObservations));
grid on
linkaxes([ax5 ax6], 'xy');
fontsize(t, 12, "points");

exportgraphics(f1, outputfolder+'\duration_analysis.pdf', "Resolution",300);
% legend(ax3, "off");



