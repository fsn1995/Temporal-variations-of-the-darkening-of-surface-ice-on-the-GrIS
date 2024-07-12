function dfstat = func_height_calculator(dfaws,dfhsa,outputfolder,statfolder)
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
imgoutput = outputfolder + "\height_calculator.pdf";
% remove exported figure file if it exits already
if isfile(imgoutput)
    delete(imgoutput);
end
% prepare new HSA output
df = array2table(zeros(0,17), 'VariableNames', ...
    {'aws', 'awsgroup', 'y', 'bare_1stday', 'bare_lastday', 'dark_1stday', ...
    'dark_lastday', 'bare_r2', 'bare_p', 'bare_n', 'bare_albedo', 'slope', ...
    'dark_r2', 'dark_p' 'dark_n' 'dark_albedo', 'ablation'});
writetable(df, statfolder + "\icestats.xlsx",'Sheet', 'ablation', ...
    'WriteVariableNames', true, 'WriteMode','overwritesheet');

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
        % ablation filter
        if max(abs(dfawsplot.height_rate))>1
            fprintf("invalid ablation record detected, skipping \n");
            continue
        elseif min(dfawsplot.albedo, [], "all", "omitmissing") >=0.451
            fprintf("no dark ice, skipping \n");
            continue
        elseif height(dfawsplot)<42
            fprintf("low data density, skipping \n"); % this is an empirical value
            continue
        else
            dfawsplot.height_diff = dfawsplot.z_pt_cor - dfawsplot.z_pt_cor(1);
        end
        
        % statistics of AWS data
        dfstat = table;
        dfstat.aws = awsid;
        dfstat.awsgroup = unique(dfawssub.awsgroup(~isnan(dfawssub.albedo)));
        dfstat.y = y;
        % dfstat.albedo = mean(dfawsplot.albedo);
        % dfstat.duration_bareice = numel(find(dfawsplot.albedo<0.565));
        % dfstat.duration_darkice = numel(find(dfawsplot.albedo<0.451));
        index = find(dfawsplot.albedo<0.565, 1, "first");
        dfstat.bare_1stday = dfawsplot.time(index);
        index = find(dfawsplot.albedo<0.565, 1, "last");
        dfstat.bare_lastday = dfawsplot.time(index);
        index = find(dfawsplot.albedo<0.451, 1, "first");
        dfstat.dark_1stday = dfawsplot.time(index);
        index = find(dfawsplot.albedo<0.451, 1, "last");
        dfstat.dark_lastday = dfawsplot.time(index);
        
        % correlate daily bare ice albedo with ablation
        % index = dfawsplot.time >= dfstat.bare_1stday & dfawsplot.time<=dfstat.dark_1stday;
        % dfbare = dfawsplot(index, :);
        % mdl_bare = fitlm(dfbare.albedo, dfbare.height_diff, "linear");
        index = dfawsplot.albedo<0.565;
        dfbare = dfawsplot(index, :);
        dfbare.bare_days = (1:1:height(dfbare))';
        mdl_bare = fitlm(dfbare.bare_days, dfbare.height_diff, "linear");        
        dfstat.bare_r2 = mdl_bare.Rsquared.Ordinary;
        dfstat.bare_p  = mdl_bare.ModelFitVsNullModel.Pvalue;
        dfstat.bare_n  = mdl_bare.NumObservations;
        dfstat.bare_albedo = mean(dfbare.albedo);

        dfstat.bare_slope = mdl_bare.Coefficients.Estimate(2);
        % correlate dark ice duration with ablation
        index = dfawsplot.albedo < 0.451;
        dfdark = dfawsplot(index, :);
        dfdark.dark_days = (1:1:height(dfdark))';
        mdl_dark = fitlm(dfdark.dark_days, dfdark.height_diff, "linear");
        dfstat.dark_r2 = mdl_dark.Rsquared.Ordinary;
        dfstat.dark_p  = mdl_dark.ModelFitVsNullModel.Pvalue;
        dfstat.dark_n  = mdl_dark.NumObservations;
        dfstat.dark_albedo = mean(dfdark.albedo);
        dfstat.ablation = dfawsplot.height_diff(end);
        
        plot(ax1, dfawsplot.time, dfawsplot.albedo, 'LineWidth',2, 'DisplayName','AWS');
        hold on
        index = dfhsasub.y == y;
        dfhsaplot = dfhsasub(index,:);
        scatter(ax1, dfhsaplot.time, dfhsaplot.hsa, "filled", "DisplayName","HSA");
        plot(ax1, dfhsaplot.time, dfhsaplot.hsa_interp, 'LineWidth',2, 'DisplayName','HSA interp')
        text(datetime(y, 6, 1), 0.2, ...
                sprintf("bare r^2: %.2f, p-value<%.2f, n:%.0f", ...
                mdl_bare.Rsquared.Ordinary, mdl_bare.ModelFitVsNullModel.Pvalue, mdl_bare.NumObservations));

        ylim(ax1, [0 1]);
        xlim(ax1, [datetime(y, 6, 1) datetime(y, 8, 31)]);
        xlabel(ax1, "");
        ylabel(ax1, "albedo");
        grid on
        yyaxis right
        plot(dfawsplot.time, dfawsplot.height_diff, 'LineWidth',2, 'DisplayName','ablation');
        ylabel("ablation (m)");
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
        yyaxis(ax1, "left");
        text(ax1,datetime(y, 6, 1), 0.1, ...
            sprintf("dark r^2: %.1f, p-value<%.2f, n:%.0f", ...
                mdl_dark.Rsquared.Ordinary, mdl_dark.ModelFitVsNullModel.Pvalue, mdl_dark.NumObservations));
        legend("Location", "southoutside", "NumColumns", 2);
        writetable(dfstat, statfolder + "\icestats.xlsx",'Sheet', ...
            'ablation', 'WriteVariableNames', false, 'WriteMode','append');
    end
    title(t, insertBefore(awsid, "_", "\"));
    exportgraphics(f1, imgoutput, "Resolution", 300, "Append", true);
    close(f1);
end

