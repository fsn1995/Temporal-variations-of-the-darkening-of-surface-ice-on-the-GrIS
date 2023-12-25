function dfawsnew = func_albedoVSheight(dfaws, dfhsa, outputfolder)
%FUNC_PLOTALBEDO Summary of this function goes here
%   Detailed explanation goes here

% check input variable
if isstring(dfaws)
    dfaws = readtable(dfaws);
end
if isstring(dfhsa)
    dfhsa = readtable(dfhsa);
end
imgoutput = outputfolder + "\AWS_vs_height_preview.pdf";
delete(imgoutput);

varlist = dfaws.Properties.VariableNames;
df = array2table(zeros(0,length(varlist)+2), 'VariableNames', ...
    [varlist, "cumalbedo", "cumheight"]);
writetable(df, outputfolder + "\AWS_height_daily_filtered.csv",...
    'WriteVariableNames', true, 'WriteMode','overwrite');

awslist = unique(dfaws.aws);

for i = 1:numel(awslist)
    awsid = string(awslist(i));
    disp(awsid);

    % filter data by AWS
    dfawssub = dfaws(dfaws.aws == awsid, :);
    [dfawssub.y, dfawssub.m, dfawssub.d] = ymd(dfawssub.time);
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
        dfplot = dfawssub(index,:);
        dfplot.cumalbedo = cumsum(dfplot.albedo);
        dfplot.cumheight = cumsum(dfplot.z_pt_cor);
        
        % make scatter plot with linear trendline
        mdl = fitlm(dfplot.cumalbedo, dfplot.cumheight, "linear");
        scatter(dfplot, "cumalbedo", "cumheight", "filled");
        hold on
        h1 = plot(mdl);
        delete([h1(1), h1(4)]);
        set(h1(2), "Color", "k", "LineWidth",1.5);
        % plot(dfplot.cumalbedo, mdl.Fitted, "LineWidth",1.5, "Color", "k");     
        grid on
        legend off
        title(string(y), "FontWeight", "normal");
        xlabel("cumulative albedo");
        ylabel("cumulative surface ice height");
        text(0.1 * max(dfplot.cumalbedo), 0.8 * max(dfplot.cumheight), ...
            "r^2="+mdl.Rsquared.Ordinary);
        
        % export the filtered AWS data with cumulative albedo and height
        writetable(removevars(dfplot, ["y", "m", "d"]), ...
            outputfolder + "\AWS_height_daily_filtered.csv", ...
            "WriteVariableNames", false, "WriteMode","append");
    end
    title(t, insertBefore(awsid, "_", "\"));
    exportgraphics(f1, imgoutput, "Resolution", 300, "Append", true);
    close(f1);
end
dfawsnew = readtable(outputfolder + "\AWS_height_daily_filtered.csv");

