
dfaws = readtable("H:\AU\promiceaws\output\AWS_reprocessed.csv");
index = isnan(dfaws.dod);
dfaws(index, :) = [];
awsgroup = ["U", "M", "L", "G"];
awsgroupColor = ["#186294", "#bd3162", "#cdb47b", "#41b4ee"]; % gyarados

%% plot mean albedo over different AWS groups

% average over all years
df = groupsummary(dfaws, {'dod', 'awsgroup'}, "all", "albedo");
% df.y = repmat(2023, height(df), 1);
df.mean_albedoH = df.mean_albedo + df.std_albedo;
df.mean_albedoL = df.mean_albedo - df.std_albedo;
% df.time = datetime(2023, df.m, df.d); % assign a random y for plotting

% assign day of year to data
% dfaws.doy = day(dfaws.time, "dayofyear");
% df.doy = day(df.time, "dayofyear");
% dfstat = df(df.awsgroup == "M", :);
% 
% % find abrupt change in mean
% [TF,S1,S2] = ischange(dfstat.mean_albedo, "mean", "MaxNumChanges", 3);
% time_change = dfstat.time(TF);
% albedo_change = dfstat.mean_albedo(TF);
% albedo_threshold = mean(albedo_change(2:3));

figure;
ax = gca;
hold on
plotAWSGroup(ax, df, awsgroup, awsgroupColor);

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
        ax(i) = plot(dfawsplot.dod, dfawsplot.mean_albedo, ...
            "LineWidth", 2, "DisplayName", awsgroup(i), "Color", awsgroupColor(i));
        plotci(figax, dfawsplot.dod, dfawsplot.mean_albedoH, dfawsplot.mean_albedoL, ...
            awsgroupColor(i));
    end
    yline(figax, 0.565,       '--', '\alpha = 0.565',         ...
        'Color', 'k', 'LineWidth', 1.5, 'LabelHorizontalAlignment','right'); 
    % yline(figax, 0.565+0.109, '--', '\alpha = 0.565+1\sigma', ...
    %     'Color', 'k', 'LineWidth', 1);
    % yline(figax, 0.565-0.109, '--', '\alpha = 0.565-1\sigma', ...
    %     'Color', 'k', 'LineWidth', 1);
    % xlim([datetime(unique(df.y), 6, 1) datetime(unique(df.y), 8, 31)]);
    % hold off
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
% % close all
% % dfaws = readtable("..\stat\icestats.xlsx", "Sheet", "AWS");
% % % dfaws = dfaws(dfaws.year>2018,:);
% % dfhsa = readtable("..\stat\icestats.xlsx", "Sheet", "HSA");
% % scatter(dfhsa.hsa, dfaws.albedo, [], dfhsa.num, "filled");
% % % plot(mdl);
% % xlim([0.15 0.7])
% % ylim([0.15 0.7])
% % pbaspect([1 1 1])
% % r1 = refline(1, 0);
% df = readtable("..\stat\icestats.xlsx", "Sheet", "ablation");
% df(df.slope>0, :) = [];
% df.darkspeed = daysact(df.bare_1stday, df.dark_1stday);
% df(df.slope<-0.3, :) = [];
% %% ablation
% figure;
% gscatter(df.bare_n, df.slope, df.awsgroup);
% % figure;
% % gscatter(dfaws.duration_bareice, dfaws.ablation, dfaws.awsgroup);
% % hold on
% % mdl = fitlm(dfaws.duration_bareice, dfaws.ablation);
% % disp(mdl)
% % 
% % figure;
% % gscatter(dfaws.duration_darkice, dfaws.ablation, dfaws.awsgroup);
% % hold on
% % mdl = fitlm(dfaws.duration_darkice, dfaws.ablation);
% % disp(mdl)
% % % refline
% %% how fast ice became dark
% % figure;
% % dfaws.darkspeed = daysact(dfaws.bare_1stday, dfaws.dark_1stday);
% % % figure;
% % % h = heatmap(dfaws, "aws", "year", "ColorVariable", "darkspeed");
% % figure;
% % boxchart(categorical(dfaws.awsgroup), dfaws.darkspeed, "Notch", "on");
% % hold on
% % swarmchart(categorical(dfaws.awsgroup), dfaws.darkspeed);
% % figure;
% % boxchart(categorical(dfaws.awsgroup), dfaws.duration_darkice, "Notch", "on");
% % figure;
% % boxchart(categorical(dfaws.awsgroup), dfaws.darkspeed)
% % sortx(h, )
% % dfhsa.duration_bareice = daysact(dfhsa.bare_1stday, dfhsa.bare_lastday);
% % dfhsa.duration_darkice = daysact(dfhsa.dark_1stday, dfhsa.dark_lastday);
% % dfhsa.duration_bareice_corrected = dfhsa.duration_bareice./(dfhsa.num/92);
% % dfhsa.duration_darkice_corrected = dfhsa.duration_darkice./(dfhsa.num/92);
% % figure
% % mdl = fitlm(dfhsa.duration_bareice, dfaws.duration_bareice)
% % % mdl = fitlm(dfhsa.duration_bareice_corrected, dfaws.duration_bareice)
% % plot(mdl);
% % % 
% % figure
% % mdl = fitlm(dfhsa.duration_darkice, dfaws.duration_darkice)
% % % mdl = fitlm(dfhsa.duration_darkice_corrected, dfaws.duration_darkice)
% % plot(mdl);
% % % scatter(dfaws.duration_darkice, dfhsa.duration_darkice_corrected);
% % % refline
% % figure
% % % mdl = fitlm(dfhsa.hsa, dfaws.albedo)
