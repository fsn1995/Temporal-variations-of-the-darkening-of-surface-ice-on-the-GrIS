function imgoutput = func_plotalbedo(dfaws,dfhsa,outputfolder)
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
        dfplotaws = dfawssub(index,:);
        plot(dfplotaws.time, dfplotaws.albedo, 'LineWidth',2, 'DisplayName','AWS');
        text(datetime(y, 5, 1), 0.2, sprintf("AWS: %d", sum(index)));
        hold on
        index = dfhsasub.y == y;
        dfplothsa = dfhsasub(index,:);
        scatter(dfplothsa, "time", "mean_visnirAlbedo", "filled", "DisplayName","HSA");

        df = innerjoin(dfplothsa, dfplotaws, "Keys", "time");
        if ~isempty(df)
            mdl = fitlm(df.mean_visnirAlbedo, df.albedo, "linear");
            text(datetime(y, 5, 1), 0.3, sprintf("r^2: %.3f", mdl.Rsquared.Ordinary));
        else
            fprintf('no paired albedo values \n');
        end

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

