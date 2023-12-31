function [dfawsnew, dfhsajoined]= func_reprocess(dfaws, dfhsa, outputfolder)
% This function reprocesses the AWS and HSA data to daily average and
% calculate the difference between two consecutive days.
%   Input:
%       dfaws: AWS data
%       dfhsa: HSA data
%       outputfolder: output folder
%   Output:
%       dfawsnew: reprocessed AWS data
%       dfhsajoined: reprocessed HSA data
% Shunan Feng (shunan.feng@envs.au.dk)

% check input variable
if isstring(dfaws)
    dfaws = readtable(dfaws);
end
if isstring(dfhsa)
    dfhsa = readtable(dfhsa);
end

% convert hsa to daily average
[dfhsa.y, dfhsa.m, dfhsa.d] = ymd(dfhsa.datetime);
dfhsa = groupsummary(dfhsa, ["y", "m", "d", "aws"], "mean", "visnirAlbedo");
dfhsa = renamevars(dfhsa, "mean_visnirAlbedo", "hsa");
dfhsa.time = datetime(dfhsa.y, dfhsa.m, dfhsa.d);
dfhsa = removevars(dfhsa, {'y', 'm', 'd', 'GroupCount'});
dfhsa = sortrows(dfhsa, {'aws', 'time'});

% prepare output csv file
varlist = dfaws.Properties.VariableNames;
df = array2table(zeros(0,length(varlist)+2), 'VariableNames', ...
    [varlist, "albedo_diff", "height_diff"]);
writetable(df, outputfolder + "\AWS_reprocessed.csv",...
    'WriteVariableNames', true, 'WriteMode','overwrite');
varlist = dfhsa.Properties.VariableNames;
df = array2table(zeros(0,length(varlist)+1), 'VariableNames', ...
    [varlist, "hsa_diff"]);
writetable(df, outputfolder + "\HSA_reprocessed.csv",...
    'WriteVariableNames', true, 'WriteMode','overwrite');


[dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);
[dfhsa.y, dfhsa.m, dfhsa.d] = ymd(dfhsa.time);
awslist = unique(dfaws.aws);

for i = 1:numel(awslist)
    awsid = string(awslist(i));
    disp(awsid);

    % filter data by AWS
    dfawssub = dfaws(dfaws.aws == awsid, :);
    dfhsasub = dfhsa(dfhsa.aws == awsid, :);

    for y = 2019:1:2023
        % nexttile(t);

        if ~ismember(y, dfawssub.y)
            fprintf("year %d has no data\n", y);
            continue
        else
            disp(y);
        end

        index = dfawssub.y == y;
        dfaws_reprocessed = dfawssub(index,:);
        dfaws_reprocessed.albedo_diff = zeros(height(dfaws_reprocessed), 1);
        dfaws_reprocessed.height_diff = zeros(height(dfaws_reprocessed), 1);
        dfaws_reprocessed.albedo_diff(2:end) = diff(dfaws_reprocessed.albedo);
        dfaws_reprocessed.height_diff(2:end) = diff(dfaws_reprocessed.z_pt_cor);

        index = dfhsasub.y == y;
        dfhsa_reprocessed = dfhsasub(index,:);
        dfhsa_reprocessed.hsa_diff = zeros(height(dfhsa_reprocessed), 1);
        dfhsa_reprocessed.hsa_diff(2:end) = diff(dfhsa_reprocessed.hsa);
    
        writetable(removevars(dfaws_reprocessed, {'y', 'm', 'd'}), ...
            outputfolder + "\AWS_reprocessed.csv", ...
            "WriteVariableNames", false, "WriteMode","append");
      
        writetable(removevars(dfhsa_reprocessed, {'y', 'm', 'd'}), ...
            outputfolder + "\HSA_reprocessed.csv", ...
            "WriteVariableNames", false, "WriteMode","append");
    end

end
dfawsnew = readtable(outputfolder + "\AWS_reprocessed.csv");
dfhsajoined = readtable(outputfolder + "\HSA_reprocessed.csv");
