dfaws = readtable("H:\AU\promiceaws\output\AWS_reprocessed.csv");

[dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);
dfaws = dfaws(dfaws.m>5 & dfaws.m<9, :); % limit to JJA
df = dfaws(dfaws.awsgroup == "M", :);
df.doy = day(df.time, 'dayofyear');

%%
scatter(df.doy, df.albedo);
