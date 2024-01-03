function [f1, dfstat] = func_threshold_analysis(dfaws, statsoutput)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% check input variable
if isstring(dfaws)
    dfaws = readtable(dfaws);
end
[dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);
dfaws = dfaws(dfaws.m>5 & dfaws.m<9, :); % limit to JJA
awsgroup = ["U", "M", "L", "G"];
awsgroupColor = ["#186294", "#bd3162", "#cdb47b", "#41b4ee"]; % gyarados

%% plot mean albedo over different AWS groups

% all years
df = groupsummary(dfaws, {'m', 'd', 'awsgroup'}, "all", "albedo");
df.y = repmat(2023, height(df), 1);
df.mean_albedoH = df.mean_albedo + df.std_albedo;
df.mean_albedoL = df.mean_albedo - df.std_albedo;
df.time = datetime(2023, df.m, df.d); % assign a random y for plotting

f1 = figure;
f1.Position = [488   245   917   417];
t = tiledlayout(1, 3, "TileSpacing","compact", "Padding","compact");
ax1 = nexttile(t);
A = imread("..\print\aoi.png");
imshow(A);
text(ax1, 80, 1600, "a)", "FontSize", 12, "Color", "w");
ax2 = nexttile([1 2]);
hold on
plotAWSGroup(ax2, df, awsgroup, awsgroupColor);
ax2.XTickLabel = ax2.XTickLabel;
text(ax2, datetime(2023, 6, 3), 0.15, "b)", "FontSize", 12);
fontsize(f1, 12, "points");
exportgraphics(f1, "..\print\fig1_aoi.pdf", "Resolution", 300);

dfstat = df;
writetable(dfstat, statsoutput+"\stat.xlsx","Sheet", "threshold");
% f1 = figure;
% f1.Position = [488   242   560   420];
% figax = gca;
% hold on
% plotAWSGroup(figax, df, awsgroup, awsgroupColor);
% figax.XTickLabel = figax.XTickLabel;
% exportgraphics(f1, "..\print\threshold_analysis.pdf", "Append", false, "Resolution", 300);
% 
% % year by year
% df = groupsummary(dfaws, {'y', 'm', 'd', 'awsgroup'}, "all", "albedo");
% df.mean_albedoH = df.mean_albedo + df.std_albedo;
% df.mean_albedoL = df.mean_albedo - df.std_albedo;
% df.time = datetime(df.y, df.m, df.d); 
% for y = min(df.y):1:max(df.y)
%     f1 = figure;
%     f1.Position = [488   242   560   420];
%     figax = gca;
%     hold on
%     plotAWSGroup(figax, df(df.y==y, :), awsgroup, awsgroupColor);
%     exportgraphics(f1, "..\print\threshold_analysis.pdf", "Append", true, "Resolution", 300);
%     close all
% end


%% functions
function plotAWSGroup(figax, df, awsgroup, awsgroupColor)
    % hold on
    ax = zeros(numel(awsgroup), 1);
    for i = 1:numel(awsgroup)
        index = df.awsgroup == awsgroup(i);
        dfawsplot = df(index, :);
        if isempty(dfawsplot)
            continue
        end
        ax(i) = plot(dfawsplot.time, dfawsplot.mean_albedo, ...
            "LineWidth", 2, "DisplayName", awsgroup(i), "Color", awsgroupColor(i));
        plotci(figax, dfawsplot.time, dfawsplot.mean_albedoH, dfawsplot.mean_albedoL, ...
            awsgroupColor(i));
    end
    yline(figax, 0.565,       '--', '\alpha = 0.565',         ...
        'Color', 'k', 'LineWidth', 1.5); % 
    % yline(figax, 0.565+0.109, '--', '\alpha = 0.565+1\sigma', ...
    %     'Color', 'k', 'LineWidth', 1);
    % yline(figax, 0.565-0.109, '--', '\alpha = 0.565-1\sigma', ...
    %     'Color', 'k', 'LineWidth', 1);
    xlim([datetime(unique(df.y), 6, 1) datetime(unique(df.y), 8, 31)]);
    hold off
    legend(figax, ax(ax>0), "Location", "northoutside", "NumColumns", numel(awsgroup));
    grid on
    % clearvars ax
end

function plotci(ax, x, meanH, meanL, colorcode)

index = isnan(meanH);
p = fill(ax, [x(~index); flipud(x(~index))], [meanH(~index); flipud(meanL(~index))], 'k');
p.FaceColor = colorcode;
p.EdgeColor = "none";
p.FaceAlpha = 0.2;

end
end

