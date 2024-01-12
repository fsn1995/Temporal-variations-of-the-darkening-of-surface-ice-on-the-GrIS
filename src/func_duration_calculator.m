function imgoutput = func_duration_calculator(dfaws,dfhsa,imgoutput,statoutput)

%  Shunan Feng (shunan.feng@envs.au.dk)

% check input variable
if isstring(dfaws)
    dfaws = readtable(dfaws);
end
% dfaws(dfaws.time<datetime(2019,1,1), :) = [];
if isstring(dfhsa)
    dfhsa = readtable(dfhsa);
end
% join dfaws and dfhsa
dfaws = outerjoin(dfaws, dfhsa, "Keys",{'aws', 'time'}, 'MergeKeys',true);
imgoutput = imgoutput + "\duration_calculator.pdf";
% remove exported figure file if it exits already
if isfile(imgoutput)
    delete(imgoutput);
end

writetable(cell2table(cell(0,11), 'VariableNames', ...
    {'aws','awsgroup', 'year', 'albedo', 'duration_bareice', 'duration_darkice', ...
    'bare_1stday', 'bare_lastday', 'dark_1stday', 'dark_lastday', 'ablation'}),...
    statoutput+'/icestats.xlsx', 'sheet', 'AWS',...
    'WriteVariableNames', true, 'WriteMode', 'overwritesheet');
writetable(cell2table(cell(0,11), 'VariableNames', ...
    {'aws','awsgroup', 'year', 'num','hsa', 'duration_bareice', 'duration_darkice', ...
    'bare_1stday', 'bare_lastday', 'dark_1stday', 'dark_lastday'}),...
    statoutput+'/icestats.xlsx', 'sheet', 'HSA',...
    'WriteVariableNames', true, 'WriteMode', 'overwritesheet');

% filter data to June-July-August
[dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);
% [dfhsa.y, dfhsa.m, dfhsa.d] = ymd(dfhsa.time);

dfaws = dfaws(dfaws.m>5 & dfaws.m<9, :);
% dfhsa = dfhsa(dfhsa.m>5 & dfhsa.m<9, :);

awslist = unique(dfaws.aws);

%% derive durations and export data
for i = 1:numel(awslist)
    awsid = string(awslist(i));
    disp(awsid);

    % filter data by AWS
    dfawssub = dfaws(dfaws.aws == awsid, :);
    % dfhsasub = dfhsa(dfhsa.aws == awsid, :);

    f1 = figure; %'Visible','off'
    f1.Position = [350 310 1450 250];
    t = tiledlayout(1,5, "TileSpacing","compact", "Padding","compact");

    %% 2019-2023 both AWS and HSA
    for y = 2019:1:2023
        ax1 = nexttile;

        if ~ismember(y, dfawssub.y)
            fprintf("year %d has no data\n", y);
            continue
        else
            disp(y);
        end

        index = dfawssub.y == y;
        dfawsplot = dfawssub(index,:);

        % remove incomplete observations in JJA
        if height(dfawsplot) < 92
            fprintf("incomplete observations \n");
            continue
        elseif min(dfawsplot.albedo) >=0.565
            fprintf("no bare ice \n");
            continue
        end

        % statistics of AWS data
        dfstat = table;
        dfstat.aws = awsid;
        dfstat.awsgroup = unique(dfawssub.awsgroup(~isnan(dfawssub.albedo)));
        dfstat.y = y;
        dfstat.albedo = mean(dfawsplot.albedo);
        dfstat.duration_bareice = numel(find(dfawsplot.albedo<0.565));
        dfstat.duration_darkice = numel(find(dfawsplot.albedo<0.451));
        index = find(dfawsplot.albedo<0.565, 1, "first");
        dfstat.bare_1stday = dfawsplot.time(index);
        index = find(dfawsplot.albedo<0.565, 1, "last");
        dfstat.bare_lastday = dfawsplot.time(index);
        index = find(dfawsplot.albedo<0.451, 1, "first");
        if isempty(index)
            dfstat.dark_1stday = nan;
            dfstat.dark_lastday = nan;
        else
            dfstat.dark_1stday = dfawsplot.time(index);
            index = find(dfawsplot.albedo<0.451, 1, "last");
            dfstat.dark_lastday = dfawsplot.time(index);
        end
        % ablation filter
        if max(abs(dfawsplot.height_rate))>1
            dfstat.ablation = nan;
        else
            ablation = dfawsplot.z_pt_cor(~isnan(dfawsplot.z_pt_cor));
            dfstat.ablation = ablation(end) - ablation(1);
        end
        writetable(dfstat, statoutput+'/icestats.xlsx', 'sheet', 'AWS',...
            'WriteVariableNames', false, 'WriteMode', 'append');

        % plotting
        plot(ax1, dfawsplot.time, dfawsplot.albedo, 'LineWidth',2, 'DisplayName','AWS');
        % text(datetime(y, 5, 1), 0.2, sprintf("AWS: %d", sum(index)));
        hold on
        scatter(ax1, dfawsplot.time, fillmissing(dfawsplot.hsa, "linear"), "filled", "DisplayName","HSA");
        
        index = find(dfawsplot.albedo<0.565);
        scatter(ax1, dfawsplot.time(index), dfawsplot.albedo(index), "filled", "DisplayName","bare ice");
        index = find(dfawsplot.albedo<0.451);
        scatter(ax1, dfawsplot.time(index), dfawsplot.albedo(index), "filled", "DisplayName","dark ice");
        if ~ismissing(dfstat.dark_1stday)
            plot(ax1, [dfstat.bare_1stday, dfstat.dark_1stday],...
                [dfawsplot.albedo(find(dfawsplot.albedo<0.565, 1, "first")),...
                dfawsplot.albedo(find(dfawsplot.albedo<0.451, 1, "first"))],...
                'Color','k', 'LineWidth', 1.5, 'DisplayName', 'bare-dark transtion');
        end

        ylim([0 1]);
        xlim([datetime(y, 6, 1) datetime(y, 8, 31)]);
        xlabel("");
        ylabel("albedo");
        grid on
        legend("Location", "southoutside", "NumColumns", 2);
        
        % statistics of HSA data
        dfstat = table;
        dfstat.aws = awsid;
        dfstat.awsgroup = unique(dfawssub.awsgroup(~isnan(dfawssub.albedo)));
        dfstat.y = y;
        dfstat.num = sum(~isnan(dfawsplot.hsa));
        dfawsplot.hsa = fillmissing(dfawsplot.hsa, "linear");
        dfstat.hsa = mean(dfawsplot.hsa,"all", "omitmissing");
        dfstat.duration_bareice = numel(find(dfawsplot.hsa<0.565));
        dfstat.duration_darkice = numel(find(dfawsplot.hsa<0.451));
        index = find(dfawsplot.hsa<0.565, 1, "first");
        dfstat.bare_1stday = dfawsplot.time(index);
        index = find(dfawsplot.hsa<0.565, 1, "last");
        dfstat.bard_lastday = dfawsplot.time(index);
        index = find(dfawsplot.hsa<0.451, 1, "first");
        if isempty(index)
            dfstat.dark_1stday = nan;
            dfstat.dark_lastday = nan;
        else
            dfstat.dark_1stday = dfawsplot.time(index);
            index = find(dfawsplot.hsa<0.451, 1, "last");
            dfstat.dark_lastday = dfawsplot.time(index);
        end
        writetable(dfstat, statoutput+'/icestats.xlsx', 'sheet', 'HSA',...
            'WriteVariableNames', false, 'WriteMode', 'append');
        
    end
    title(t, insertBefore(awsid, "_", "\"));
    exportgraphics(f1, imgoutput, "Resolution", 300, "Append", true);
    close(f1);

    %% before 2019
    for y = min(unique(dfawssub.y)):1:2018
        if ~ismember(y, dfawssub.y)
            fprintf("year %d has no data\n", y);
            continue
        else
            disp(y);
        end
        
        index = dfawssub.y == y;
        dfawsplot = dfawssub(index,:);
        
        % remove incomplete observations in JJA
        if height(dfawsplot) < 92
            fprintf("incomplete observations \n");
            continue
        elseif min(dfawsplot.albedo) >=0.565
            fprintf("no bare ice \n");
            continue
        end
        f2 = figure;
        ax2 = gca;
        % statistics
        dfstat = table;
        dfstat.aws = awsid;
        dfstat.awsgroup = unique(dfawssub.awsgroup(~isnan(dfawssub.albedo)));
        dfstat.y = y;
        dfstat.albedo = mean(dfawsplot.albedo);
        dfstat.duration_bareice = numel(find(dfawsplot.albedo<0.565));
        dfstat.duration_darkice = numel(find(dfawsplot.albedo<0.451));
        index = find(dfawsplot.albedo<0.565, 1, "first");
        dfstat.bare_1stday = dfawsplot.time(index);
        index = find(dfawsplot.albedo<0.565, 1, "last");
        dfstat.bard_lastday = dfawsplot.time(index);
        index = find(dfawsplot.albedo<0.451, 1, "first");
        if isempty(index)
            dfstat.dark_1stday = nan;
            dfstat.dark_lastday = nan;
        else
            dfstat.dark_1stday = dfawsplot.time(index);
            index = find(dfawsplot.albedo<0.451, 1, "last");
            dfstat.dark_lastday = dfawsplot.time(index);
        end
        % ablation filter
        if max(abs(dfawsplot.height_rate))>1
            dfstat.ablation = nan;
        else
            ablation = dfawsplot.z_pt_cor(~isnan(dfawsplot.z_pt_cor));
            dfstat.ablation = ablation(end) - ablation(1);
        end
        writetable(dfstat, statoutput+'/icestats.xlsx', 'sheet', 'AWS',...
            'WriteVariableNames', false, 'WriteMode', 'append');
        % plotting
        plot(ax2, dfawsplot.time, dfawsplot.albedo, 'LineWidth',2, 'DisplayName','AWS');
        % text(datetime(y, 5, 1), 0.2, sprintf("AWS: %d", sum(index)));
        hold on
        scatter(ax2, dfawsplot.time, dfawsplot.hsa, "filled", "DisplayName","HSA");
        
        index = find(dfawsplot.albedo<0.565);
        scatter(ax2, dfawsplot.time(index), dfawsplot.albedo(index), "filled", "DisplayName","bare ice");
        index = find(dfawsplot.albedo<0.451);
        scatter(ax2, dfawsplot.time(index), dfawsplot.albedo(index), "filled", "DisplayName","dark ice");
        if ~ismissing(dfstat.dark_1stday)
            plot(ax2, [dfstat.bare_1stday, dfstat.dark_1stday],...
                [dfawsplot.albedo(find(dfawsplot.albedo<0.565, 1, "first")),...
                dfawsplot.albedo(find(dfawsplot.albedo<0.451, 1, "first"))],...
                'Color','k', 'LineWidth', 1.5, 'DisplayName', 'bare-dark transtion');
        end

        ylim([0 1]);
        xlim([datetime(y, 6, 1) datetime(y, 8, 31)]);
        xlabel("");
        ylabel("albedo");
        grid on
        legend("Location", "southoutside", "NumColumns", 2);
        
        title(ax2, insertBefore(awsid, "_", "\"));
        exportgraphics(f2, imgoutput, "Resolution", 300, "Append", true);
        close(f2);
    end
end

