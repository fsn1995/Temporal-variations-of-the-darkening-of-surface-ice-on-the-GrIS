function imgoutput = func_duration_calculator(dfaws,dfhsa,outputfolder)

%  Shunan Feng (shunan.feng@envs.au.dk)

% check input variable
if isstring(dfaws)
    dfaws = readtable(dfaws);
end
% dfaws(dfaws.time<datetime(2019,1,1), :) = [];
if isstring(dfhsa)
    dfhsa = readtable(dfhsa);
end
imgoutput = outputfolder + "\duration_calculator.pdf";
% remove exported figure file if it exits already
if isfile(imgoutput)
    delete(imgoutput);
end

writetable(cell2table(cell(0,6), 'VariableNames', ...
    {'aws','awsgroup', 'year', 'albedo', 'duration_bareice', 'duration_darkice'}),...
    outputfolder+'/icestats.xlsx', 'sheet', 'AWS',...
    'WriteVariableNames', true, 'WriteMode', 'overwritesheet');
writetable(cell2table(cell(0,7), 'VariableNames', ...
    {'aws','awsgroup', 'year', 'hsa', 'duration_bareice', 'duration_darkice', 'num'}),...
    outputfolder+'/icestats.xlsx', 'sheet', 'HSA',...
    'WriteVariableNames', true, 'WriteMode', 'overwritesheet');

% filter data to June-July-August
[dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);
[dfhsa.y, dfhsa.m, dfhsa.d] = ymd(dfhsa.time);

dfaws = dfaws(dfaws.m>5 & dfaws.m<9, :);
dfhsa = dfhsa(dfhsa.m>5 & dfhsa.m<9, :);

awslist = unique(dfaws.aws);

%% derive durations and export data
for i = 1:numel(awslist)
    awsid = string(awslist(i));
    disp(awsid);

    % filter data by AWS
    dfawssub = dfaws(dfaws.aws == awsid, :);
    dfhsasub = dfhsa(dfhsa.aws == awsid, :);

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
        dfstat.awsgroup = dfawssub.awsgroup(1);
        dfstat.y = y;
        dfstat.albedo = mean(dfawsplot.albedo);
        dfstat.duration_bareice = numel(find(dfawsplot.albedo<0.565));
        dfstat.duration_darkice = numel(find(dfawsplot.albedo<0.451));
        writetable(dfstat, outputfolder+'/icestats.xlsx', 'sheet', 'AWS',...
            'WriteVariableNames', false, 'WriteMode', 'append');
        % plotting
        plot(ax1, dfawsplot.time, dfawsplot.albedo, 'LineWidth',2, 'DisplayName','AWS');
        % text(datetime(y, 5, 1), 0.2, sprintf("AWS: %d", sum(index)));
        hold on
        index = dfhsasub.y == y;
        dfhsaplot = dfhsasub(index,:);
        scatter(ax1, dfhsaplot.time, dfhsaplot.hsa, "filled", "DisplayName","HSA");
        
        index = find(dfawsplot.albedo<0.565);
        scatter(ax1, dfawsplot.time(index), dfawsplot.albedo(index), "filled", "DisplayName","bare ice");
        index = find(dfawsplot.albedo<0.451);
        scatter(ax1, dfawsplot.time(index), dfawsplot.albedo(index), "filled", "DisplayName","dark ice");

        ylim([0 1]);
        xlim([datetime(y, 6, 1) datetime(y, 8, 31)]);
        xlabel("");
        ylabel("albedo");
        grid on
        legend("Location", "southoutside", "NumColumns", 2);

        % statistics of HSA data
        dfstat = table;
        dfstat.aws = awsid;
        dfstat.awsgroup = dfawssub.awsgroup(1);
        dfstat.y = y;
        dfstat.hsa = mean(dfhsaplot.hsa);
        dfstat.duration_bareice = numel(find(dfhsaplot.hsa<0.565));
        dfstat.duration_darkice = numel(find(dfhsaplot.hsa<0.451));
        dfstat.num = height(dfhsaplot);
        writetable(dfstat, outputfolder+'/icestats.xlsx', 'sheet', 'HSA',...
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
        dfstat.awsgroup = dfawssub.awsgroup(1);
        dfstat.y = y;
        dfstat.albedo = mean(dfawsplot.albedo);
        dfstat.duration_bareice = numel(find(dfawsplot.albedo<0.565));
        dfstat.duration_darkice = numel(find(dfawsplot.albedo<0.451));
        writetable(dfstat, outputfolder+'/icestats.xlsx', 'sheet', 'AWS',...
            'WriteVariableNames', false, 'WriteMode', 'append');
        % plotting
        plot(ax2, dfawsplot.time, dfawsplot.albedo, 'LineWidth',2, 'DisplayName','AWS');
        % text(datetime(y, 5, 1), 0.2, sprintf("AWS: %d", sum(index)));
        hold on
        index = dfhsasub.y == y;
        dfhsaplot = dfhsasub(index,:);
        scatter(ax2, dfhsaplot.time, dfhsaplot.hsa, "filled", "DisplayName","HSA");
        
        index = find(dfawsplot.albedo<0.565);
        scatter(ax2, dfawsplot.time(index), dfawsplot.albedo(index), "filled", "DisplayName","bare ice");
        index = find(dfawsplot.albedo<0.451);
        scatter(ax2, dfawsplot.time(index), dfawsplot.albedo(index), "filled", "DisplayName","dark ice");

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

