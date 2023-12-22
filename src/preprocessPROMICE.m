%% extract AWS data with valid albedo, cc, and GPS 

awsfiles = dir("H:\AU\promiceaws\day\*.csv");

df = array2table(zeros(0,7), 'VariableNames',["cc", "albedo", "gps_lat", ...
        "gps_lon", "gps_alt", "z_pt_cor", "aws"]);
writetable(df, "H:\AU\promiceaws\promiceDaily.csv", "WriteVariableNames",...
    true, "WriteMode", 'overwrite');

    %     writetable(df, "promice/promiceHourly.csv", "WriteVariableNames", ...
    %         false, "WriteMode", 'append');
    % end
for i = 1:length(awsfiles)
    awsfile = fullfile(awsfiles(i).folder, awsfiles(i).name);
    awsname = erase(awsfiles(i).name, "_day.csv");
    disp(awsname);
    
    opts = detectImportOptions(awsfile);
    opts = setvartype(opts, ["cc", "albedo", "gps_lat", ...
        "gps_lon", "gps_alt", "z_pt_cor"], 'double');
    opts.SelectedVariableNames = ["time", "cc", "albedo", "gps_lat", ...
        "gps_lon", "gps_alt"];
    
    df = rmmissing(readtable(awsfile, opts));
    if isempty(df)
        fprintf("is empty\n");
        continue
    elseif min(df.albedo)>0.65
        fprintf("has no bare ice\n");
        continue
    elseif max(df.time<datetime("2019-01-01"))
        fprintf("has no data after 2019\n");
        continue
    end
    df.aws = repmat(awsname, length(df.cc), 1);
    writetable(df, "H:\AU\promiceaws\promiceDaily.csv", "WriteVariableNames", ...
        false, "WriteMode", 'append');
end
