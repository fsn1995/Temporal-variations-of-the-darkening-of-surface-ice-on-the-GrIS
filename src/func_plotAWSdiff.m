function imgoutput = func_plotAWSdiff(dfaws,dfhsa,outputfolder)
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
if isstring(dfhsa)
    dfhsa = readtable(dfhsa);
end
imgoutput = outputfolder + "\AWS_albedoVSheight.pdf";
delete(imgoutput);

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
        plot(ax1, dfawsplot.time, dfawsplot.albedo_diff, 'LineWidth',2, 'DisplayName','AWS');
        % text(datetime(y, 5, 1), 0.2, sprintf("AWS: %d", sum(index)));
        hold on
        % index = dfhsasub.y == y;
        % dfhsaplot = dfhsasub(index,:);
        % scatter(ax1, dfhsaplot.time, dfhsaplot.hsa, "filled", "DisplayName","HSA");

        % df = innerjoin(dfhsaplot, dfawsplot, "Keys", "time");
        % if ~isempty(df)
        %     mdl = fitlm(df.hsa, df.albedo, "linear");
        %     text(datetime(y, 6, 1), 0.1, ...
        %         sprintf("r^2: %.2f, p-value<%.2f", ...
        %         mdl.Rsquared.Ordinary, mdl.ModelFitVsNullModel.Pvalue));
        % else
        %     fprintf('no paired HSA \n');
        % end
        % ylim([0 1]);
        xlim([datetime(y, 5, 31) datetime(y, 9, 1)]);
        xlabel("");
        ylabel("albedo_diff");
        grid on
        
        yyaxis(ax1, "right");
        plot(ax1, dfawsplot.time, dfawsplot.height_diff, 'LineWidth',2,...
            "DisplayName", "height_diff");
        ylabel(ax1,"height difference (m)")
        mdl = fitlm(dfawsplot.albedo_diff, cumsum(dfawsplot.height_diff), "linear");
        yyaxis(ax1, "left");
        text(ax1,datetime(y, 6, 1), 0.2, ...
            sprintf("r^2: %.2f", mdl.Rsquared.Ordinary));
        legend("Location", "southoutside");
    end
    title(t, insertBefore(awsid, "_", "\"));
    exportgraphics(f1, imgoutput, "Resolution", 300, "Append", true);
    close(f1);
end

