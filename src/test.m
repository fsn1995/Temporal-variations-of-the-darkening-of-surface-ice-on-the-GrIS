% close all
dfaws = readtable("H:\AU\promiceaws\output\AWS_reprocessed.csv");
% dfaws = dfaws(dfaws.year>2018,:);
dfhsa = readtable("H:\AU\promiceaws\output\HSA_reprocessed.csv");

dftest = outerjoin(dfaws, dfhsa, "Keys",{'aws', 'time'});