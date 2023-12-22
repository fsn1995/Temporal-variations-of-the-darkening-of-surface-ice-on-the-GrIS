function [dfaws, awsloc] = func_preprocessPROMICEGC(awsfolder, outputfolder)
%FUNC_PREPROCESSPROMICE Summary of this function goes here
%   Detailed explanation goes here

awsfiles = dir(awsfolder + "\*.csv");

df = array2table(zeros(0,7), 'VariableNames',["time", "cc", "albedo",...
    "gps_lat", "gps_lon", "gps_alt", "aws"]);
writetable(df, outputfolder+"\promiceDaily.csv", "WriteVariableNames",...
    true, "WriteMode", 'overwrite');

for i = 1:length(awsfiles)
    awsfile = fullfile(awsfiles(i).folder, awsfiles(i).name);
    awsname = erase(awsfiles(i).name, "_day.csv");
    disp(awsname);

    switch awsname
        case "KAN_B"
            fprintf("not on ice\n");
            continue
        case "NUK_B"
            fprintf("not on ice\n");
            continue
        case "WEG_B"
            fprintf("not on ice\n");
            continue
    end
    
    opts = detectImportOptions(awsfile);
    opts = setvartype(opts, ["cc", "albedo", "gps_lat", ...
        "gps_lon", "gps_alt"], 'double');
    opts.SelectedVariableNames = ["time", "cc", "albedo", "gps_lat", ...
        "gps_lon", "gps_alt"];
    
    df = rmmissing(readtable(awsfile, opts));
    if isempty(df)
        fprintf("is empty\n");
        continue
    elseif mean(df.gps_alt)>2000
        fprintf("is above snowline\n")
        continue
    elseif min(df.albedo)>0.65
        fprintf("has no bare ice\n");
        continue
    elseif max(df.time)<datetime("2019-01-01")
        fprintf("has no data after 2019\n");
        continue
    end
    df(df.time<datetime("2019-01-01"), :) = [];
    df.aws = repmat(awsname, length(df.cc), 1);
    writetable(df, outputfolder+"\promiceDaily.csv", "WriteVariableNames", ...
        false, "WriteMode", 'append');
end

% opts = detectImportOptions(outputfolder+"\promiceDaily.csv");
% opts = setvartype(opts, "aws", "string");
% opts.SelectedVariableNames = ["time", "cc", "albedo", "gps_lat", ...
%     "gps_lon", "gps_alt", "aws"];
dfaws = readtable(outputfolder+"\promiceDaily.csv");
% disp(df.Properties.VariableNames)
awslat = groupsummary(dfaws.gps_lat, dfaws.aws, 'mean');
awslon = groupsummary(dfaws.gps_lon, dfaws.aws, 'mean');
awsalt = groupsummary(dfaws.gps_alt, dfaws.aws, 'mean');
aws = upper(unique(dfaws.aws));
awsloc = table(aws, awslat, awslon, awsalt);
writetable(awsloc, outputfolder+"/AWS_station_locations.csv", ...
    "WriteVariableNames", true, "WriteMode", 'overwrite');
end

