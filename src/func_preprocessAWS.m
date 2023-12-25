function [dfaws, awsloc] = func_preprocessAWS(awsfolder, outputfolder)
% This function preprocesses the PROMICE AWS data for further analysis.
% It extracts the time series of interest and plots the time series for
% visual inspection. It also exports the AWS location for mapping.
% [awsfolder] is the folder containing the PROMICE AWS data.
% [outputfolder] is the folder to save the output files.
% [dfaws] is the table containing the time series of interest.
% [awsloc] is the table containing the AWS location for mapping.
% Three csv files are exported to [outputfolder]:
%   1. AWS_height_daily.csv contains the time series of interest (no
%   filter).
%   2. AWS_height_station_locations.csv contains the AWS location for
%      mapping. Filtered to May-Sep.
%   3. AWS_height_station_locations_4gee.csv contains the monthly AWS
%      location for GEE. Filtered to May-Sep.
% 
% Shunan Feng (shunan.feng@envs.au.dk)
%   

%% extract time series of interest
awsfiles = dir(awsfolder + "\*.csv");
delete(outputfolder+"\AWS_height_daily.pdf");

df = array2table(zeros(0,8), 'VariableNames',["time", "cc", "albedo", "z_pt_cor"...
    "gps_lat", "gps_lon", "gps_alt", "aws"]);
writetable(df, outputfolder+"\AWS_height_daily.csv", "WriteVariableNames",...
    true, "WriteMode", 'overwrite');

for i = 1:length(awsfiles)
    awsfile = fullfile(awsfiles(i).folder, awsfiles(i).name);
    awsname = erase(awsfiles(i).name, "_day.csv");
    disp(awsname);
    
    % filter out irrelevant AWS
    switch awsname
        case "KAN_B"
            fprintf("not on ice sheet\n");
            continue
        case "NUK_B"
            fprintf("not on ice sheet\n");
            continue
        case "WEG_B"
            fprintf("not on ice sheet\n");
            continue
        % case "LYN_L"
        %     fprintf("local glacier\n");
        %     continue   
        % case "LYN_T"
        %     fprintf("local glacier\n");
        %     continue 
        % case "MIT"
        %     fprintf("local glacier\n");
        %     continue    
        % case "NUK_K"
        %     fprintf("local glacier\n");
        %     continue 
        case "Roof_GEUS"
            fprintf("not on ice sheet\n");
            continue 
        case "Roof_PROMICE"
            fprintf("not on ice sheet\n");
            continue 
        case "UWN"
            fprintf("not on ice sheet\n");
            continue 
        % case "ZAK_L"
        %     fprintf("local glacier\n");
        %     continue 
        % case "ZAK_U"
        %     fprintf("local glacier\n");
        %     continue 
        % case "ZAK_Uv3"
        %     fprintf("local glacier\n");
        %     continue 
    end
    
    opts = detectImportOptions(awsfile);
    if ~ismember('z_pt_cor', opts.VariableNames)
        fprintf("no transducer data\n")
        continue
    end
    opts = setvartype(opts, ["cc", "albedo", "gps_lat", "z_pt_cor",...
        "gps_lon", "gps_alt"], 'double');
    opts.SelectedVariableNames = ["time", "cc", "albedo", "z_pt_cor",...
        "gps_lat", "gps_lon", "gps_alt"];
    
    df = rmmissing(readtable(awsfile, opts));
    df(df.time<datetime("2019-01-01"), :) = [];

    if isempty(df)
        fprintf("is empty\n");
        continue
    elseif mean(df.gps_alt)>2000
        fprintf("is above snowline\n")
        continue
    elseif min(df.albedo)>0.65
        fprintf("has no bare ice\n");
        continue
    end
    
    df.aws = repmat(awsname, length(df.cc), 1);
    writetable(df, outputfolder+"\AWS_height_daily.csv", "WriteVariableNames", ...
        false, "WriteMode", 'append');

    % plot time series data
    [df.y, df.m, df.d] = ymd(df.time);
    index = df.m>4 & df.m<10;
    df = df(index,:);
    f1 = figure; %'Visible','off'
    f1.Position = [219 130 1400 400]; %[2200 120 950 280];
    t = tiledlayout(2,5, "TileSpacing","compact", "Padding","compact");
    for y = 2019:1:2023
        nexttile(t);
        if ~ismember(y, df.y)
            fprintf("year %d has no data\n", y);
            continue
        else
            disp(y);
        end
        index = df.y == y;
        dfplot = df(index,:);
        plot(dfplot.time, dfplot.albedo, 'LineWidth',2, 'DisplayName','albedo');
        ylim([0 1]);
        hold on
        yyaxis right
        plot(dfplot.time, dfplot.z_pt_cor, 'LineWidth',2, 'DisplayName','height');
        grid on
        legend("Location", "southoutside");
        xlim([datetime(y, 5, 1) datetime(y, 9, 30)]);
    end

    for y=2019:1:2023
        if ~ismember(y, df.y)
            % fprintf("year %d has no data\n", y);
            continue
        end

        index = df.y == y;
        dfplot = df(index,:);

        gax = geoaxes(t);
        gax.Layout.Tile = y-2019+6;
        geoscatter(dfplot.gps_lat, dfplot.gps_lon, 'filled');
        geobasemap("colorterrain");
    end
    title(t, insertBefore(awsname, "_", "\"));
    exportgraphics(f1, outputfolder+"\AWS_height_daily.pdf", ...
        "Resolution",300, "Append", true)
    close(f1);
end

%% export AWS location for mapping 
% opts = detectImportOptions(outputfolder+"\promiceDaily.csv");
% opts = setvartype(opts, "aws", "string");
% opts.SelectedVariableNames = ["time", "cc", "albedo", "gps_lat", ...
%     "gps_lon", "gps_alt", "aws"];
dfaws = readtable(outputfolder+"\AWS_height_daily.csv");
% disp(df.Properties.VariableNames)
awslat = groupsummary(dfaws.gps_lat, dfaws.aws, 'mean');
awslon = groupsummary(dfaws.gps_lon, dfaws.aws, 'mean');
awsalt = groupsummary(dfaws.gps_alt, dfaws.aws, 'mean');
aws = upper(unique(dfaws.aws));
awsloc = table(aws, awslat, awslon, awsalt);
writetable(awsloc, outputfolder+"/AWS_height_station_locations.csv", ...
    "WriteVariableNames", true, "WriteMode", 'overwrite');
fprintf("AWS location exported at %s\n", outputfolder+"/AWS_height_station_locations.csv");
%% export monthly AWS location for GEE
df = readtable("H:\AU\promiceaws\output\AWS_height_daily.csv");
[df.y, df.m, ~] = ymd(df.time);
df = removevars(df, ["time", "albedo", "cc", "z_pt_cor"]);
index = df.m>4 & df.m<10;
dfgee = groupsummary(df(index, :), ["aws", "y", "m"], "mean", ["gps_lat", "gps_lon"]);
writetable(dfgee, outputfolder+"/AWS_height_station_locations_4gee.csv");
fprintf("monthly AWS location for GEE exported at %s\n", outputfolder+"/AWS_height_station_locations_4gee.csv");
end

