function [correlationR, correlationP, R, slope, intercept] = func_spatialcorr(imfolder, imsource)
%  func_spatialcorr Calculate spatial correlation between variables and linear fit
%   func_spatialcorr(imfolder, imsource) calculates the spatial correlation
%   between bare ice duration and albedo, as well as albedo and melt. 
%   The function reads the bare ice duration, albedo and melt data from the input
%   folder (imfolder) and calculates:
%     - correlation matrix (correlationR)
%     - p-value matrix (correlationP)
%     - spatial reference (R) where applicable
%     - linear regression slope and intercept (pixel-wise)
%
%   imfolder: the folder containing the annual albedo and bare ice duration data in .mat files
%   imsource: the source of the albedo images (e.g., "hsa", "s3", "mods3", "smb")
%
%   Shunan Feng (shunan.feng@envs.au.dk)
    
switch imsource
    case "hsa"  

        imfiles = dir(fullfile(imfolder, 'albedo_spatial*.mat'));
        % pre-allocate the array
        load(fullfile(imfolder, imfiles(1).name), 'albedo_avg');
        albedo = NaN([size(albedo_avg, 1) * size(albedo_avg, 2) height(imfiles)], "single");
        numDuration = albedo;
        imindex = zeros([size(albedo_avg, 1) * size(albedo_avg, 2) height(imfiles)], "uint16");

        % load the data
        for i = 1:height(imfiles)
            fprintf("Loading data %s\n", string(imfiles(i).name));
            load(fullfile(imfolder, imfiles(i).name), 'albedo_avg', 'bare_duration');

            imindex(:, i) = bare_duration(:) > 0;

            bare_duration = single(bare_duration);
            bare_duration(bare_duration < 1) = nan;
            numDuration(:, i) = bare_duration(:);

            albedo_avg = single(albedo_avg)/10000;
            albedo_avg(albedo_avg == 0) = nan;  
            albedo_avg(isnan(bare_duration)) = nan;
            albedo(:, i) = albedo_avg(:);

        end

        % index by finding the pixels with bare ice in all years
        imindex = find(all(imindex, 2));
        % correlate albedo with bare ice duration pixel by pixel
        correlationR = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");
        correlationP = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");
        slope = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");
        intercept = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");

        for i = 1:length(imindex)

            fprintf("Correlating pixel %d out of %d \n", i, length(imindex));
            % Correlation (unchanged behavior)
            [r, p] = corrcoef(numDuration(imindex(i), :)', albedo(imindex(i), :)');
            correlationR(imindex(i)) = r(1, 2);
            correlationP(imindex(i)) = p(1, 2);

            % Linear regression: albedo (y) vs bare ice duration (x)
            x = numDuration(imindex(i), :)';
            y = albedo(imindex(i), :)';
            idx = ~(isnan(x) | isnan(y));
            if nnz(idx) >= 2
                pf = polyfit(x(idx), y(idx), 1);
                slope(imindex(i)) = pf(1);
                intercept(imindex(i)) = pf(2);
            end
        end

        % reshape the outputs
        correlationR = reshape(correlationR, size(albedo_avg, 1), size(albedo_avg, 2));
        correlationP = reshape(correlationP, size(albedo_avg, 1), size(albedo_avg, 2));
        slope = reshape(slope, size(albedo_avg, 1), size(albedo_avg, 2));
        intercept = reshape(intercept, size(albedo_avg, 1), size(albedo_avg, 2));

    case "s3"        

        imfiles = dir(fullfile(imfolder, 'albedo_spatial*.mat'));
        % pre-allocate the array
        load(fullfile(imfolder, imfiles(1).name), 'albedo_avg');
        albedo = NaN([size(albedo_avg, 1) * size(albedo_avg, 2) height(imfiles)], "single");
        numDuration = albedo;
        imindex = zeros([size(albedo_avg, 1) * size(albedo_avg, 2) height(imfiles)], "uint16");

        % load the data
        for i = 1:height(imfiles)
            fprintf("Loading data %s\n", string(imfiles(i).name));
            load(fullfile(imfolder, imfiles(i).name), 'albedo_avg', 'bare_duration');

            imindex(:, i) = bare_duration(:) > 0;

            bare_duration = single(bare_duration);
            bare_duration(bare_duration < 1) = nan;
            numDuration(:, i) = bare_duration(:);

            albedo_avg = single(albedo_avg)/10000;
            albedo_avg(albedo_avg == 0) = nan;  
            albedo_avg(isnan(bare_duration)) = nan;
            albedo(:, i) = albedo_avg(:);

        end

        % index by finding the pixels with bare ice in all years
        imindex = find(all(imindex, 2));
        % correlate albedo with bare ice duration pixel by pixel
        correlationR = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");
        correlationP = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");
        slope = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");
        intercept = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");

        for i = 1:length(imindex)

            fprintf("Correlating pixel %d out of %d \n", i, length(imindex));
            % Correlation (unchanged behavior)
            [r, p] = corrcoef(numDuration(imindex(i), :)', albedo(imindex(i), :)');
            correlationR(imindex(i)) = r(1, 2);
            correlationP(imindex(i)) = p(1, 2);

            % Linear regression: albedo (y) vs bare ice duration (x)
            x = numDuration(imindex(i), :)';
            y = albedo(imindex(i), :)';
            idx = ~(isnan(x) | isnan(y));
            if nnz(idx) >= 2
                pf = polyfit(x(idx), y(idx), 1);
                slope(imindex(i)) = pf(1);
                intercept(imindex(i)) = pf(2);
            end
            % mdl = fitlm(numDuration(imindex(i), :)', albedo(imindex(i), :)', 'linear', 'RobustOpts', 'off');
            % correlationR(imindex(i)) = mdl.Rsquared.Ordinary;
            % correlationP(imindex(i)) = mdl.Coefficients.pValue(2);

        end

        % reshape the outputs
        correlationR = reshape(correlationR, size(albedo_avg, 1), size(albedo_avg, 2));
        correlationP = reshape(correlationP, size(albedo_avg, 1), size(albedo_avg, 2));
        slope = reshape(slope, size(albedo_avg, 1), size(albedo_avg, 2));
        intercept = reshape(intercept, size(albedo_avg, 1), size(albedo_avg, 2));

    case "mods3"
        imfiles = dir(fullfile(imfolder, 'albedo_spatial*.mat'));
        % load s3 data mapx and mapy to determine the image boundary
        load(fullfile(imfolder, 'albedo_spatial_2023.mat'), 'mapx', 'mapy');
        xlimit = [min(mapx) max(mapx)];
        ylimit = [min(mapy) max(mapy)];
        % pre-allocate the array
        load(fullfile(imfolder, imfiles(1).name), 'albedo_avg', 'R');
        [albedo_avg, ~] = mapcrop(albedo_avg, R, xlimit, ylimit);

        albedo = NaN([size(albedo_avg, 1) * size(albedo_avg, 2) height(imfiles)], "single");
        numDuration = albedo;
        imindex = zeros([size(albedo_avg, 1) * size(albedo_avg, 2) height(imfiles)], "uint16");

        % load the mod data 2002 - 2019
        years = 2002:1:2019;
        for i = 1:length(years)
            fprintf("Loading mod data %d\n", years(i));
            load(fullfile(imfolder, sprintf('albedo_spatial_%d.mat', years(i))), 'albedo_avg', 'bare_duration', 'R');
            [albedo_avg, ~] = mapcrop(albedo_avg, R, xlimit, ylimit);
            [bare_duration, R] = mapcrop(bare_duration, R, xlimit, ylimit);

            imindex(:, i) = bare_duration(:) > 0;

            bare_duration = single(bare_duration);
            bare_duration(bare_duration < 1) = nan;
            numDuration(:, i) = bare_duration(:);

            albedo_avg(albedo_avg == 0) = nan;  
            albedo_avg(isnan(bare_duration)) = nan;
            albedo(:, i) = albedo_avg(:);

        end
        % load the s3 data 2020 - 2023
        years = 2020:1:2023;
        for i = 1:length(years)
            fprintf("Loading s3 data %d\n", years(i));
            load(fullfile(imfolder, sprintf('albedo_spatial_%d.mat', years(i))), 'albedo_avg', 'bare_duration');
            
            % reshape the data to match the mod data
            albedo_avg = flipud(rot90(albedo_avg));
            bare_duration = flipud(rot90(bare_duration));
            albedo_avg(1:10, :) = [];
            albedo_avg(end, :) = [];
            bare_duration(1:10, :) = [];
            bare_duration(end, :) = [];

            imindex(:, i + 18) = bare_duration(:) > 0;

            bare_duration = single(bare_duration);
            bare_duration(bare_duration < 1) = nan;
            numDuration(:, i + 18) = bare_duration(:);

            albedo_avg = single(albedo_avg)/10000;
            albedo_avg(albedo_avg == 0) = nan;  
            albedo_avg(isnan(bare_duration)) = nan;
            albedo(:, i + 18) = albedo_avg(:);     

        end

        % index by finding the pixels with bare ice in all years
        imindex = find(sum(imindex, 2) >= 10);
        % correlate albedo with bare ice duration pixel by pixel
        correlationR = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");
        correlationP = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");
        slope = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");
        intercept = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");

        for i = 1:length(imindex)

            fprintf("Correlating pixel %d out of %d \n", i, length(imindex));
            df = [numDuration(imindex(i), :)' albedo(imindex(i), :)'];
            % remove nan values
            df(any(isnan(df), 2), :) = [];
            [r, p] = corrcoef(df(:, 1), df(:, 2));
            correlationR(imindex(i)) = r(1, 2);
            correlationP(imindex(i)) = p(1, 2);

            if size(df,1) >= 2
                pf = polyfit(df(:, 1), df(:, 2), 1);
                slope(imindex(i)) = pf(1);
                intercept(imindex(i)) = pf(2);
            end
        end
        
        % reshape the outputs
        correlationR = reshape(correlationR, size(albedo_avg, 1), size(albedo_avg, 2));
        correlationP = reshape(correlationP, size(albedo_avg, 1), size(albedo_avg, 2));
        slope = reshape(slope, size(albedo_avg, 1), size(albedo_avg, 2));
        intercept = reshape(intercept, size(albedo_avg, 1), size(albedo_avg, 2));
        
    case "smb"
        imfiles = dir(fullfile(imfolder, 'albedo_spatial*.mat'));
        smbfiles = dir(fullfile(imfolder, 'snmelt*.mat'));

        writetable(cell2table(cell(0,3), 'VariableNames', ...
            {'albedo_avg', 'bare_duration', 'immelt'}),...
            fullfile(imfolder, 'smbcorr.csv'), ...
            'WriteVariableNames', true, 'WriteMode', 'overwrite');

        % load s3 data mapx and mapy to determine the image boundary
        load(fullfile(imfolder, 'albedo_spatial_2023.mat'), 'mapx', 'mapy');
        xlimit = [min(mapx) max(mapx)];
        ylimit = [min(mapy) max(mapy)];
        % pre-allocate the array
        load(fullfile(imfolder, imfiles(1).name), 'albedo_avg', 'R');
        [albedo_avg, ~] = mapcrop(albedo_avg, R, xlimit, ylimit);

        albedo = NaN([size(albedo_avg, 1) * size(albedo_avg, 2) height(imfiles)], "single");
        snmelt = albedo;
        imindex = zeros([size(albedo_avg, 1) * size(albedo_avg, 2) height(imfiles)], "uint16");


        % load the mod data 2002 - 2019
        years = 2002:1:2019;
        for i = 1:length(years)
            fprintf("Loading mod data %d\n", years(i));
            load(fullfile(imfolder, sprintf('albedo_spatial_%d.mat', years(i))), 'albedo_avg', 'bare_duration', 'R');
            load(fullfile(imfolder, sprintf('snmelt_%d.mat', years(i))), 'immelt', 'Rmelt');
            [albedo_avg, ~] = mapcrop(albedo_avg, R, xlimit, ylimit);
            [immelt, ~] = mapcrop(immelt, Rmelt, xlimit, ylimit);
            [bare_duration, R] = mapcrop(bare_duration, R, xlimit, ylimit);

            imindex(:, i) = bare_duration(:) > 0;

            bare_duration = single(bare_duration);
            bare_duration(bare_duration < 1) = nan;
            snmelt(:, i) = immelt(:);

            albedo_avg(albedo_avg == 0) = nan;  
            albedo_avg(isnan(bare_duration)) = nan;
            albedo(:, i) = albedo_avg(:);
            
            df = table;
            df.albedo_avg = albedo_avg(:);
            df.bare_duration = bare_duration(:);
            df.immelt = immelt(:);
            df = rmmissing(df);
            writetable(df, fullfile(imfolder, 'smbcorr.csv'), 'WriteMode', 'append', 'WriteVariableNames', false);

        end
        % load the s3 data 2020 - 2023
        years = 2020:1:2023;
        for i = 1:length(years)
            fprintf("Loading s3 data %d\n", years(i));
            load(fullfile(imfolder, sprintf('albedo_spatial_%d.mat', years(i))), 'albedo_avg', 'bare_duration');
            load(fullfile(imfolder, sprintf('snmelt_%d.mat', years(i))), 'immelt', 'Rmelt');

            % reshape the data to match the mod data
            albedo_avg = flipud(rot90(albedo_avg));
            bare_duration = flipud(rot90(bare_duration));
            albedo_avg(1:10, :) = [];
            albedo_avg(end, :) = [];
            bare_duration(1:10, :) = [];
            bare_duration(end, :) = [];
            [immelt, ~] = mapcrop(immelt, Rmelt, xlimit, ylimit);

            imindex(:, i + 18) = bare_duration(:) > 0;

            bare_duration = single(bare_duration);
            bare_duration(bare_duration < 1) = nan;
            snmelt(:, i + 18) = immelt(:);

            albedo_avg = single(albedo_avg)/10000;
            albedo_avg(albedo_avg == 0) = nan;  
            albedo_avg(isnan(bare_duration)) = nan;
            albedo(:, i + 18) = albedo_avg(:);     

            df = table;
            df.albedo_avg = albedo_avg(:);
            df.bare_duration = bare_duration(:);
            df.immelt = immelt(:);
            df = rmmissing(df);
            writetable(df, fullfile(imfolder, 'smbcorr.csv'), 'WriteMode', 'append', 'WriteVariableNames', false);

        end

        % index by finding the pixels with bare ice in all years
        imindex = find(sum(imindex, 2) >= 10);
        % correlate albedo with bare ice duration pixel by pixel
        correlationR = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");
        correlationP = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");
        slope = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");
        intercept = NaN(size(albedo_avg, 1) * size(albedo_avg, 2), 1, "single");

        for i = 1:length(imindex)

            fprintf("Correlating pixel %d out of %d \n", i, length(imindex));
            df = [albedo(imindex(i), :)' snmelt(imindex(i), :)'];
            % remove nan values
            df(any(isnan(df), 2), :) = [];
            [r, p] = corrcoef(df(:, 1), df(:, 2));
            if numel(r)>1
                correlationR(imindex(i)) = r(1, 2);
                correlationP(imindex(i)) = p(1, 2);
            else
                correlationR(imindex(i)) = nan;
                correlationP(imindex(i)) = nan;
            end

            if size(df,1) >= 2
                pf = polyfit(df(:, 1), df(:, 2), 1); % x=albedo, y=immelt
                slope(imindex(i)) = pf(1);
                intercept(imindex(i)) = pf(2);
            end
        end

        % reshape the outputs
        correlationR = reshape(correlationR, size(albedo_avg, 1), size(albedo_avg, 2));
        correlationP = reshape(correlationP, size(albedo_avg, 1), size(albedo_avg, 2));
        slope = reshape(slope, size(albedo_avg, 1), size(albedo_avg, 2));
        intercept = reshape(intercept, size(albedo_avg, 1), size(albedo_avg, 2));
        
end
end
