function imgoutput = func_plotalbedo(dfaws,dfhsa,outputfolder)
%FUNC_PLOTALBEDO Summary of this function goes here
%   Detailed explanation goes here

% check input variable
if isstring(dfaws)
    dfaws = readtable(dfaws);
end
if isstring(dfhsa)
    dfhsa = readtable(dfhsa);
end
imgoutput = outputfolder + "\AWS_HSA_preview.pdf";
delete(imgoutput);

awslist = unique(dfaws.aws);

for i = 1:numel(awslist)
    awsid = string(awslist(i));
    disp(awsid);

    % filter data by AWS
    dfawssub = dfaws(dfaws.aws == awsid, :);
    dfhsasub = dfhsa(dfhsa.aws == awsid, :);

    [dfhsasub.y, dfhsasub.m, dfhsasub.d] = ymd(dfhsasub.datetime);
    [dfawssub.y, dfawssub.m, dfawssub.d] = ymd(dfawssub.time);

    dfhsasub = groupsummary(dfhsasub, ["y", "m", "d"], "mean", "visnirAlbedo");
    dfhsasub.time = datetime(dfhsasub.y, dfhsasub.m, dfhsasub.d);

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
        plot(dfplot.time, dfplot.albedo, 'LineWidth',2, 'DisplayName','AWS');
        text(datetime(y, 5, 1), 0.2, sprintf("AWS: %d", sum(index)));
        hold on
        index = dfhsasub.y == y;
        dfplot = dfhsasub(index,:);
        scatter(dfplot, "time", "mean_visnirAlbedo", "filled", "DisplayName","HSA");
        text(datetime(y, 5, 1), 0.1, sprintf("HSA: %d", sum(index)));
        grid on
        ylim([0 1]);
        legend("Location", "southoutside");
        xlim([datetime(y, 5, 1) datetime(y, 9, 30)]);
        xlabel("");
        ylabel("albedo");
    end
    title(t, insertBefore(awsid, "_", "\"));
    exportgraphics(f1, imgoutput, "Resolution", 300, "Append", true);
    close(f1);
end

