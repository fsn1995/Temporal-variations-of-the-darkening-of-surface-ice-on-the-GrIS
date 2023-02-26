%% load promice aws data

urllist = readtable("promice/hourly_data_urls_edition4.csv","Delimiter",',');

for i = 1:length(urllist.data_name)
    opts = detectImportOptions(string(urllist.data_url(i)));
    opts = setvartype(opts, {'gps_lat', 'gps_lon'}, 'double');
    opts.SelectedVariableNames = ["time", "cc", "albedo", "gps_lat", ...
        "gps_lon", "gps_alt"];
    
    df = rmmissing(readtable(string(urllist.data_url(i)), opts));
    
    awsname = erase(string(urllist.data_name(i)), "_hour");
    disp(awsname);
    df.aws = repmat(awsname, length(df.cc), 1);
    
    if i == 37
        df.gps_lon = df.gps_lon * -1;
    end
%     [zd,zltr,zone] = timezone(df.gps_lon);
%     df.time = datetime(df.time, 'TimeZone','UTC') - hours(zd);
    if i == 1
        writetable(df, "promice/promiceHourly.csv", "WriteVariableNames",...
            true, "WriteMode", 'overwrite');
    else
        writetable(df, "promice/promiceHourly.csv", "WriteVariableNames", ...
            false, "WriteMode", 'append');
    end
end


opts = detectImportOptions("promice/promiceHourly.csv");
opts.SelectedVariableNames = ["time", "cc", "albedo", "gps_lat", ...
    "gps_lon", "gps_alt", "aws"];
df = readtable("promice/promiceHourly.csv", opts);
% disp(df.Properties.VariableNames)
df(df.aws=="weg_b", :) = [];
awslat = groupsummary(df.gps_lat, df.aws, 'mean');
awslon = groupsummary(df.gps_lon, df.aws, 'mean');
awsalt = groupsummary(df.gps_alt, df.aws, 'mean');
aws = upper(unique(df.aws));
dfaws = table(aws, awslat, awslon, awsalt);
figure;
geoscatter(dfaws, "awslat", "awslon");
writetable(dfaws, "promice/AWS_station_locations.csv", ...
    "WriteVariableNames", true, "WriteMode", 'overwrite');
