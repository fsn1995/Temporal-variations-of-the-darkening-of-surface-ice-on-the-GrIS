function imgoutput = func_height_analysis(dfaws, outputfolder)
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
% if isstring(dfhsa)
%     dfhsa = readtable(dfhsa);
% end
imgoutput = outputfolder + "\height_analysis.pdf";
delete(imgoutput);

% filter data to June-July-August
[dfaws.y, dfaws.m, dfaws.d] = ymd(dfaws.time);

dfaws = dfaws(dfaws.m>5 & dfaws.m<9, :);
% dfhsa = dfhsa(dfhsa.m>5 & dfhsa.m<9, :);

awslist = unique(dfaws.aws);

for i = 1:numel(awslist)
    awsid = string(awslist(i));
    disp(awsid);

    % filter data by AWS
    dfawssub = dfaws(dfaws.aws == awsid, :);
    % dfhsasub = dfhsa(dfhsa.aws == awsid, :);

    % f1 = figure; %'Visible','off'
    % f1.Position = [350 310 1450 250];
    % t = tiledlayout(1,5, "TileSpacing","compact", "Padding","compact");

    for y = min(unique(dfawssub.y)):1:max(unique(dfawssub.y))
        % ax1 = nexttile(t);

        if ~ismember(y, dfawssub.y)
            fprintf("year %d has no data\n", y);
            continue
        else
            disp(y);
        end

        index = dfawssub.y == y;
        dfawsplot = dfawssub(index,:);
        dfawsplot.height_diff = dfawsplot.z_pt_cor - dfawsplot.z_pt_cor(1);

        f1 = figure; %'Visible','off'
        f1.Position = [711 818 1019 420];
        t = tiledlayout(1, 2, "TileSpacing","compact", "Padding","compact");
        ax1 = nexttile;
        plot(ax1, dfawsplot.time, dfawsplot.albedo, 'LineWidth',2, 'DisplayName','albedo');
        
        % calculate statistics
        mdl = fitlm(dfawsplot.albedo, dfawsplot.height_diff, "linear");
        text(ax1, datetime(y, 6, 5), 0.1, ...
            sprintf("r^2: %.2f, p-value<%.2f", ...
            mdl.Rsquared.Ordinary, mdl.ModelFitVsNullModel.Pvalue));

        ylim(ax1, [0 1]);
        xlim(ax1, [datetime(y, 6, 1) datetime(y, 8, 31)]);
        xlabel(ax1, "");
        ylabel(ax1,"albedo");
        grid on
        
        yyaxis right 
        plot(ax1, dfawsplot.time, dfawsplot.height_diff, 'LineWidth',2,...
            "DisplayName", "height\_diff");
        ylabel(ax1, "height difference (m)")
        legend(ax1,"Location", "southoutside", "NumColumns",2);
        
        % scatter plot
        ax2 = nexttile;
        h2 = plot(ax2, mdl);
        grid on
        ylabel(ax2, "height difference (m)");
        xlabel(ax2, "albedo");
        title(ax2, "");
        set(h2(2), "Color", "k", "LineStyle","-", "LineWidth",1.5);
        set(h2(1), "Marker", ".", "MarkerSize", 10,"Color", "#80B3FF");
        legend(ax2, "off");
        title(t, insertBefore(awsid, "_", "\"));
        exportgraphics(f1, imgoutput, "Resolution", 300, "Append", true);
        close(f1);
    end
    
end

