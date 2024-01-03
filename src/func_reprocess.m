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
dfaws(dfaws.time<datetime(2008,1,1),:) = [];
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
df = array2table(zeros(0,length(varlist)+5), 'VariableNames', ...
    [varlist, "awsgroup", "albedo_diff", "albedo_rate", "height_diff", "height_rate"]);
writetable(df, outputfolder + "\AWS_reprocessed.csv",...
    'WriteVariableNames', true, 'WriteMode','overwrite');
varlist = dfhsa.Properties.VariableNames;
df = array2table(zeros(0,length(varlist)+2), 'VariableNames', ...
    [varlist, "hsa_diff", "hsa_rate"]);
writetable(df, outputfolder + "\HSA_reprocessed.csv",...
    'WriteVariableNames', true, 'WriteMode','overwrite');


[dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);

fprintf("start reprocessing AWS data\n");
awslist = unique(dfaws.aws);
for i = 1:numel(awslist)
    awsid = string(awslist(i));
    disp(awsid);

    % filter data by AWS
    dfawssub = dfaws(dfaws.aws == awsid, :);
    % group AWS by locations
    awsgroup = extractAfter(awsid, '_');
    if ismissing(awsgroup)
        dfawssub.awsgroup = dfawssub.aws;
    else
        dfawssub.awsgroup = repmat(extract(awsgroup, 1), height(dfawssub), 1);
    end
    switch awsid
        case "JAR"
            dfawssub.awsgroup = repmat("M", height(dfawssub), 1);
        case "JAR_O"
            dfawssub.awsgroup = repmat("M", height(dfawssub), 1);
        case "MIT"
            dfawssub.awsgroup = repmat("G", height(dfawssub), 1);
        case "NUK_K"
            dfawssub.awsgroup = repmat("G", height(dfawssub), 1);
        case "NUK_N"
            dfawssub.awsgroup = repmat("L", height(dfawssub), 1);
        case "SWC"
            dfawssub.awsgroup = repmat("U", height(dfawssub), 1);
        case "SWC_O"
            dfawssub.awsgroup = repmat("U", height(dfawssub), 1);
        case "TAS_A"
            dfawssub.awsgroup = repmat("U", height(dfawssub), 1);
    end

    for y = min(unique(dfawssub.y)):1:max(unique(dfawssub.y))
        % nexttile(t);

        if ~ismember(y, dfawssub.y)
            fprintf("year %d has no data\n", y);
            continue
        elseif min(dfawssub.albedo)>=(0.565+0.109)
                fprintf("year %d has no bare ice\n", y)
                continue
        else
            disp(y);
        end

        index = dfawssub.y == y;
        dfaws_reprocessed = dfawssub(index,:);

        dfaws_reprocessed.albedo_diff = zeros(height(dfaws_reprocessed), 1);
        dfaws_reprocessed.albedo_rate = zeros(height(dfaws_reprocessed), 1);
        dfaws_reprocessed.height_diff = zeros(height(dfaws_reprocessed), 1);
        dfaws_reprocessed.height_rate = zeros(height(dfaws_reprocessed), 1);
        dfaws_reprocessed.albedo_diff = dfaws_reprocessed.albedo - dfaws_reprocessed.albedo(1);
        dfaws_reprocessed.albedo_rate(2:end) = diff(dfaws_reprocessed.albedo)./days(diff(dfaws_reprocessed.time));
        dfaws_reprocessed.height_diff = dfaws_reprocessed.z_pt_cor - dfaws_reprocessed.z_pt_cor(1);
        dfaws_reprocessed.height_rate(2:end) = diff(dfaws_reprocessed.z_pt_cor)./days(diff(dfaws_reprocessed.time));
    
        writetable(removevars(dfaws_reprocessed, {'y', 'm', 'd'}), ...
            outputfolder + "\AWS_reprocessed.csv", ...
            "WriteVariableNames", false, "WriteMode","append");

    end

end

[dfhsa.y, dfhsa.m, dfhsa.d] = ymd(dfhsa.time);

fprintf("start reprocessing HSA data\n");
awslist = unique(dfhsa.aws);
for i = 1:numel(awslist)
    awsid = string(awslist(i));
    disp(awsid);

    % filter data by AWS
    dfhsasub = dfhsa(dfhsa.aws == awsid, :);

    for y = min(unique(dfhsasub.y)):1:max(unique(dfhsasub.y))
        % nexttile(t);

        if ~ismember(y, dfhsasub.y)
            fprintf("year %d has no data\n", y);
            continue
        else
            disp(y);
        end

        index = dfhsasub.y == y;
        dfhsa_reprocessed = dfhsasub(index,:);
        dfhsa_reprocessed.hsa_diff = zeros(height(dfhsa_reprocessed), 1);
        dfhsa_reprocessed.hsa_rate = zeros(height(dfhsa_reprocessed), 1);
        if height(dfhsa_reprocessed)>1
            dfhsa_reprocessed.hsa_diff = dfhsa_reprocessed.hsa - dfhsa_reprocessed.hsa(1);
            dfhsa_reprocessed.hsa_rate(2:end) = diff(dfhsa_reprocessed.hsa)./days(diff(dfhsa_reprocessed.time));
        else 
            fprintf('Number of HSA is less than 2\n');
        end

        writetable(removevars(dfhsa_reprocessed, {'y', 'm', 'd'}), ...
            outputfolder + "\HSA_reprocessed.csv", ...
            "WriteVariableNames", false, "WriteMode","append");
    end

end
dfawsnew = readtable(outputfolder + "\AWS_reprocessed.csv");
dfhsajoined = readtable(outputfolder + "\HSA_reprocessed.csv");
