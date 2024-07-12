function imgoutput = func_plotAWSHSA(dfaws,dfhsa,outputfolder)
%  This function plots the AWS and HSA albedo data for each AWS station
%  and save the image to the output folder.
%  dfaws: table of AWS data
%  dfhsa: table of HSA data
%  outputfolder: folder to save the output image
%  Shunan Feng (shunan.feng@envs.au.dk)

% check input variable
if isstring(dfaws)
    dfaws = readtable(dfaws);
end
dfaws(dfaws.time<datetime(2019,1,1), :) = [];
if isstring(dfhsa)
    dfhsa = readtable(dfhsa);
end
imgoutput = outputfolder + "\AWS_HSA_preview.pdf";
% remove exported figure file if it exits already
if isfile(imgoutput)
    delete(imgoutput);
end
% prepare new HSA output
df = array2table(zeros(0,4), 'VariableNames', ...
    ["time", "aws", "hsa" "hsa_interp"]);
writetable(df, outputfolder + "\HSA_interp.csv",...
    'WriteVariableNames', true, 'WriteMode','overwrite');

% dfaws = outerjoin(dfaws, dfhsa, "Keys",{'aws', 'time'}, 'MergeKeys',true);
% filter data to June-July-August
[dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);
[dfhsa.y, dfhsa.m, dfhsa.d] = ymd(dfhsa.time);

dfaws = dfaws(dfaws.m>5 & dfaws.m<9, :);
dfhsa = dfhsa(dfhsa.m>5 & dfhsa.m<9, :);

awslist = unique(dfaws.aws);

for i = 1:numel(awslist)
    awsid = string(awslist(i));
    disp(awsid);

    % filter data by AWS
    dfawssub = dfaws(dfaws.aws == awsid, :);
    dfhsasub = dfhsa(dfhsa.aws == awsid, :);

    f1 = figure; %'Visible','off'
    f1.Position = [350 310 1450 250];
    t = tiledlayout(1,5, "TileSpacing","compact", "Padding","compact");

    for y = 2019:1:2023
        ax1 = nexttile(t);

        if ~ismember(y, dfawssub.y)
            fprintf("year %d has no data\n", y);
            continue
        else
            disp(y);
        end

        index = dfawssub.y == y;
        dfawsplot = dfawssub(index,:);
        plot(ax1, dfawsplot.time, dfawsplot.albedo, 'LineWidth',2, 'DisplayName','AWS');
        % text(datetime(y, 5, 1), 0.2, sprintf("AWS: %d", sum(index)));
        hold on
        index = dfhsasub.y == y;
        dfhsaplot = dfhsasub(index,:);
        dfhsa_new = table;
        dfhsa_new.time = (datetime(y, 6, 1):caldays(1):datetime(y, 8, 31))';
        dfhsa_new.aws = repmat(unique(dfhsaplot.aws), height(dfhsa_new), 1);
        dfhsa_new = outerjoin(dfhsa_new, dfhsaplot, "Keys",{'time', 'aws'}, "MergeKeys",true);
        dfhsa_new.hsa_interp = fillmissing(dfhsa_new.hsa, "linear");
        scatter(ax1, dfhsaplot.time, dfhsaplot.hsa, "filled", "DisplayName","HSA");
        plot(ax1, dfhsa_new.time, dfhsa_new.hsa_interp, 'LineWidth',2, 'DisplayName','HSA interp')

        df = innerjoin(dfhsaplot, dfawsplot, "Keys", "time");
        if ~isempty(df)
            mdl = fitlm(df.hsa, df.albedo, "linear");
            text(datetime(y, 6, 1), 0.07, ...
                sprintf("HSA r^2: %.2f, p-value<%.2f, n:%.0f", ...
                mdl.Rsquared.Ordinary, mdl.ModelFitVsNullModel.Pvalue, mdl.NumObservations));
        else
            fprintf('no paired HSA \n');
        end
        df = innerjoin(dfhsa_new, dfawsplot,  "Keys",{'time', 'aws'});
        mdl = fitlm(df.hsa_interp, df.albedo, "linear");
        text(datetime(y, 6, 1), 0.2, ...
                sprintf("interp r^2: %.2f, p-value<%.2f, n:%.0f", ...
                mdl.Rsquared.Ordinary, mdl.ModelFitVsNullModel.Pvalue, mdl.NumObservations));

        ylim(ax1, [0 1]);
        xlim(ax1, [datetime(y, 6, 1) datetime(y, 8, 31)]);
        xlabel(ax1, "");
        ylabel(ax1, "albedo");
        grid on
        yyaxis right
        dfawsplot.height_diff = dfawsplot.z_pt_cor - dfawsplot.z_pt_cor(1);
        plot(dfawsplot.time, dfawsplot.height_diff, 'LineWidth',2, 'DisplayName','ablation');
        % % perform height quality check
        % if max(abs(dfawsplot.height_rate))>5
        %     legend("Location", "southoutside");
        %     fprintf("outlier found in height, discard in plot\n")
        %     continue
        % end
        % 
        % yyaxis(ax1, "right");
        % plot(ax1, dfawsplot.time, dfawsplot.height_diff, 'LineWidth',2,...
        %     "DisplayName", "height_diff");
        % ylabel(ax1,"height difference (m)")
        % mdl = fitlm(dfawsplot.albedo, dfawsplot.height_diff, "linear");
        % yyaxis(ax1, "left");
        % text(ax1,datetime(y, 6, 1), 0.2, ...
        %     sprintf("AWS albedo vs height r^2: %.2f", mdl.Rsquared.Ordinary));
        legend("Location", "southoutside", "NumColumns", 2);
        writetable(removevars(dfhsa_new, {'hsa_diff' 'hsa_rate' 'y' 'm' 'd' }), ...
            outputfolder + "\HSA_interp.csv",...
            'WriteVariableNames', false, 'WriteMode','append');
    end
    title(t, insertBefore(awsid, "_", "\"));
    exportgraphics(f1, imgoutput, "Resolution", 300, "Append", true);
    close(f1);
end

