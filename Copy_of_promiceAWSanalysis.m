%% promice data processing

opts = detectImportOptions("promice/promiceHourly.csv");
opts.SelectedVariableNames = ["time", "cc", "albedo", "gps_lat", "gps_lon",...
    "gps_alt","aws"];
df = readtable('promice/promiceHourly.csv', opts);
df = df(df.gps_alt < 2000, :);
dfsat = readtable("promice\hsa.csv");
%% AWS time series analysis and plot
delete 'print/promiceDuration.pdf'
writetable(cell2table(cell(0,13), 'VariableNames', ...
    {'aws', 'lat', 'lon', 'alt', 'year', 'duration_bareice', 'duration_darkice',...
    'dbratio', 'albedo', 'albedoJA', 'dark_1stday', 'bare_1stday', 'dark_speed'}),...
    'promice/icestats20092017.xlsx', 'sheet', 'statPROMICE',...
    'WriteVariableNames', true, 'WriteMode', 'overwritesheet');
writetable(cell2table(cell(0,10), 'VariableNames', ...
    {'aws', 'year', 'duration_bareice', 'duration_darkice',...
    'dbratio', 'albedo', 'albedoJA', 'dark_1stday', 'bare_1stday', 'dark_speed'}),...
    'promice/icestats20092017.xlsx', 'sheet', 'statHSA',...
    'WriteVariableNames', true, 'WriteMode', 'overwritesheet');
aws = unique(df.aws);

for i = 1:numel(aws)
    awsid = string(aws(i));
    disp(awsid);
    dfaws = df(df.aws == awsid, :);
    dfhsa = dfsat(dfsat.aws == awsid, :);

    [dfhsa.y, dfhsa.m, dfhsa.d] = ymd(dfhsa.datetime);
    [dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);

    index = dfaws.m>5 & dfaws.m<9 & dfaws.y>2009 &dfaws.y<2017;
    dfaws = dfaws(index, :);
    dfaws = groupsummary(dfaws, ["y", "m", "d"], "mean", ...
        ["albedo", "gps_lat", "gps_lon", "gps_alt"]);
    dfaws.time = datetime(dfaws.y, dfaws.m, dfaws.d);
    if all(dfaws.mean_albedo >= 0.45)
        fprintf("No dark ice in this station\n");
        continue
    end
    
    dfhsa = groupsummary(dfhsa, ["y", "m", "d"], "mean", "visnirAlbedo");
    dfhsa.time = datetime(dfhsa.y, dfhsa.m, dfhsa.d);

    % get time series plot
%     f1 = figure('Visible','off'); %'Visible','off'
%     f1.Position = [480 95 1240 1240];
%     t = tiledlayout(4,4);
    for y = 2007:1:2022
        disp(y);
        index = dfaws.y == y;
        dfannual = dfaws(index, :);
        index = dfhsa.y == y;
        dfhsaannual = dfhsa(index, :);
%         nexttile(t)        
        if all(dfannual.mean_albedo >= 0.45)
            fprintf("No dark ice in this year\n");
            continue
        end
        
        % quick statistics PROMICE
        dfstat = table;
        dfstat.aws = awsid;
        dfstat.lat = mean(dfannual.mean_gps_lat,'omitnan');
        dfstat.lon = mean(dfannual.mean_gps_lon,'omitnan');
        dfstat.alt = mean(dfannual.mean_gps_alt,'omitnan');
        dfstat.year = y;
        dfstat.duration_bareice = numel(find(dfannual.mean_albedo < 0.65));
        dfstat.duration_darkice = numel(find(dfannual.mean_albedo < 0.45));
        dfstat.dbratio = dfstat.duration_darkice / dfstat.duration_bareice;
        dfstat.albedo = mean(dfannual.mean_albedo, 'omitnan');
        dfstat.albedoJA = mean(dfannual.mean_albedo(dfannual.m==7 | dfannual.m==8),...
            'omitnan');
        % find 1st day of dark ice and the closest 1st bare ice day
        index = find(dfannual.mean_albedo < 0.45, 1);
        dfstat.dark_1stday = dfannual.time(index);
        index = find(dfannual.mean_albedo(1:index) >= 0.65, 1, "last");
        if isempty(index)
            index=0;
        end
        dfstat.bare_1stday = dfannual.time(index+1);
        dfstat.dark_speed = days(dfstat.dark_1stday - dfstat.bare_1stday);

        writetable(dfstat, 'promice/icestats20092017.xlsx', 'sheet', 'statPROMICE',...
            'WriteVariableNames', false, 'WriteMode', 'append');
        
        if isempty(dfannual.time)
            continue
        end
        
%         % ploting 
%         plot(dfannual.time, dfannual.mean_albedo, LineWidth=2);
%         hold on
%         index = find(dfannual.mean_albedo<0.65);
%         scatter(dfannual.time(index), dfannual.mean_albedo(index), 'filled');
%         index = find(dfannual.mean_albedo<0.45);
%         scatter(dfannual.time(index), dfannual.mean_albedo(index), 'filled');
%         scatter(dfhsaannual.time, dfhsaannual.mean_visnirAlbedo, 'filled');
%         index = find(dfannual.mean_albedo < 0.45, 1);
%         index = find(dfannual.mean_albedo(1:index) >= 0.65, 1, "last");
%         if isempty(index)
%             index=0;
%         end
%         index = index + 1;
%         plot([dfstat.bare_1stday, dfstat.dark_1stday],...
%             [dfannual.mean_albedo(index),...
%             dfannual.mean_albedo(find(dfannual.mean_albedo < 0.45, 1))],...
%             'Color','k', 'LineWidth', 1.5);
%         hold off
%         grid on
%         legend('daily', 'bare ice', 'dark ice', 'HSA', 'bare-dark ice transition',...
%             'Location', 'southoutside');
%         if y == 2007
%             ylabel('albedo');
%         end
        
%         quick statistics HSA
        if all(dfhsaannual.mean_visnirAlbedo >= 0.45)
            fprintf("No HSA observed dark ice in this year\n");
            continue
        end
        dfstat = table;
        dfstat.aws = awsid;
        dfstat.year = y;
        dfstat.duration_bareice = numel(find(dfhsaannual.mean_visnirAlbedo < 0.65));
        dfstat.duration_darkice = numel(find(dfhsaannual.mean_visnirAlbedo < 0.45));
        dfstat.dbratio = dfstat.duration_darkice / dfstat.duration_bareice;
        dfstat.albedo = mean(dfhsaannual.mean_visnirAlbedo, 'omitnan');
        dfstat.albedoJA = mean(dfhsaannual.mean_visnirAlbedo(dfhsaannual.m==7 | dfhsaannual.m==8),...
            'omitnan');
        % find 1st day of dark ice and the closest 1st bare ice day
        index = find(dfhsaannual.mean_visnirAlbedo < 0.45, 1);
        dfstat.dark_1stday = dfhsaannual.time(index);
        index = find(dfhsaannual.mean_visnirAlbedo(1:index) >= 0.65, 1, "last");
        if isempty(index)
            index=0;
        end
        dfstat.bare_1stday = dfhsaannual.time(index+1);
        dfstat.dark_speed = days(dfstat.dark_1stday - dfstat.bare_1stday);

        writetable(dfstat, 'promice/icestats.xlsx', 'sheet', 'statHSA',...
            'WriteVariableNames', false, 'WriteMode', 'append');
    end
%     title(t,upper(insertBefore(awsid, "_", "\")));
%     t.TileSpacing = 'compact';
%     t.Padding = 'compact';
%     exportgraphics(t, 'print/promiceDuration.pdf', 'Append',true,...
%         'Resolution',300);
end
close all
