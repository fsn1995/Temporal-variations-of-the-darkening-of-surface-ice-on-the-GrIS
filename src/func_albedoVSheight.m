function [dfawsnew, dfhsajoined]= func_albedoVSheight(dfaws, outputfolder)
%FUNC_PLOTALBEDO Summary of this function goes here
%   Detailed explanation goes here

% check input variable
if isstring(dfaws)
    dfaws = readtable(dfaws);
end
% if isstring(dfhsa)
%     dfhsa = readtable(dfhsa);
% end
% [dfhsa.y, dfhsa.m, dfhsa.d] = ymd(dfhsa.datetime);
% dfhsa.time = datetime(dfhsa.y, dfhsa.m, dfhsa.d);
% dfhsa = innerjoin(dfhsa, dfaws,"Keys",{'aws', 'time'});
[dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);
% writetable(dfhsa, outputfolder + "\AWS_height_station_HSA_joined.csv");

% remove exported figure file if it exits already
imgoutput = outputfolder + "\AWS_vs_height_preview.pdf";
if isfile(imgoutput)
    delete(imgoutput);
end

% prepare output csv file
% varlist = dfaws.Properties.VariableNames;
% df = array2table(zeros(0,length(varlist)+2), 'VariableNames', ...
%     [varlist, "cumalbedo", "cumheight"]);
% writetable(df, outputfolder + "\AWS_height_daily_filtered.csv",...
%     'WriteVariableNames', true, 'WriteMode','overwrite');
% varlist = dfhsa.Properties.VariableNames;
% df = array2table(zeros(0,length(varlist)+2), 'VariableNames', ...
%     [varlist, "cumhsa", "cumheight"]);
% writetable(df, outputfolder + "\AWS_height_station_HSA_joined.csv",...
%     'WriteVariableNames', true, 'WriteMode','overwrite');



awslist = unique(dfaws.aws);

for i = 1:numel(awslist)
    awsid = string(awslist(i));
    disp(awsid);

    % filter data by AWS
    dfawssub = dfaws(dfaws.aws == awsid, :);
    % dfhsasub = dfhsa(dfhsa.aws == awsid, :);
    % keep May-Sep only
    index = dfawssub.m > 4 & dfawssub.m < 10;
    dfawssub = dfawssub(index, :);

    f1 = figure; %'Visible','off'
    f1.Position = [350 310 1450 250];
    t = tiledlayout(1,5, "TileSpacing","compact", "Padding","compact");

    for y = 2019:1:2023
        nexttile(t);

        if ~ismember(y, dfawssub.y)
            fprintf("year %d has no data\n", y);
            continue
        else
            disp(y);
        end

        index = dfawssub.y == y;
        dfawsplot = dfawssub(index,:);
        dfawsplot.cumalbedo = cumsum(dfawsplot.albedo);
        dfawsplot.cumheight = cumsum(dfawsplot.z_pt_cor);
        dfawsplot.cumheight_diff = cumsum(dfawsplot.height_diff);
        dfawsplot.cumalbedo_diff = cumsum(dfawsplot.albedo_diff);
        % index = dfhsasub.y == y;
        % dfhsaplot = dfhsasub(index,:);
        % dfhsaplot.cumhsa    = cumsum(dfhsaplot.visnirAlbedo);
        % dfhsaplot.cumheight = cumsum(dfhsaplot.z_pt_cor);

        % make scatter plot with linear trendline
        mdl = fitlm(dfawsplot.cumalbedo, dfawsplot.cumheight, "linear");
        s1 = scatter(dfawsplot, "cumalbedo", "cumheight", "filled", "DisplayName","AWS");
        hold on
        h1 = plot(mdl);
        delete([h1(1), h1(4)]);
        set(h1(2), "Color", "k", "LineWidth",1.5);
        % plot(dfplot.cumalbedo, mdl.Fitted, "LineWidth",1.5, "Color", "k");     
        grid on
        legend off
        text(0.1 * max(dfawsplot.cumalbedo), 0.9 * max(dfawsplot.cumheight), ...
            sprintf("AWS: r^2: %.3f", mdl.Rsquared.Ordinary));
        % export the filtered data with cumulative albedo and height
        % writetable(dfawsplot, ...
        %     outputfolder + "\AWS_height_daily_filtered.csv", ...
        %     "WriteVariableNames", false, "WriteMode","append");
      
        % mdl = fitlm(dfhsaplot.cumhsa, dfhsaplot.cumheight, "linear");
        % s2 = scatter(dfhsaplot, "cumhsa", "cumheight", "filled", "DisplayName","HSA");
        % if isempty(dfhsaplot)
        %     legend([s1 s2], "Location","southeast");
        %     title(string(y), "FontWeight", "normal");
        %     xlabel("cumulative albedo");
        %     ylabel("cumulative surface ice height");
        %     continue
        % else
        %     h2 = plot(mdl);
        %     delete([h2(1), h2(4)]);
        %     set(h2(2), "Color", "k", "LineWidth",1.5);
        %     % plot(dfplot.cumalbedo, mdl.Fitted, "LineWidth",1.5, "Color", "k");     
        %     legend off
        %     text(0.1 * max(dfawsplot.cumalbedo), 0.7 * max(dfawsplot.cumheight), ...
        %         "HSA: r^2="+mdl.Rsquared.Ordinary);
        %     legend([s1 s2], "Location","southeast");
        %     title(string(y), "FontWeight", "normal");
        %     xlabel("cumulative albedo");
        %     ylabel("cumulative surface ice height");
        %     % export the filtered data with cumulative albedo and height
        %     writetable(dfhsaplot, ...
        %         outputfolder + "\AWS_height_station_HSA_joined.csv", ...
        %         "WriteVariableNames", false, "WriteMode","append");
        % end
    end
    title(t, insertBefore(awsid, "_", "\"));
    exportgraphics(f1, imgoutput, "Resolution", 300, "Append", true);
    close(f1);
end
% dfawsnew = readtable(outputfolder + "\AWS_height_daily_filtered.csv");
% dfhsajoined = readtable(outputfolder + "\AWS_height_station_HSA_joined.csv");
