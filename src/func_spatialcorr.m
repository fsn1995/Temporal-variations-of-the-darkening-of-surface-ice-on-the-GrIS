function [correlationR, correlationP, R] = func_spatialcorr(imfolder, imsource)
    
switch imsource
    case "hsa"  

        imfiles = dir(fullfile(imfolder, '*.mat'));
        % pre-allocate the array
        load(fullfile(imfolder, imfiles(1).name), 'albedo_avg');
        % numClear = zeros([size(gapA) height(imfiles)], "uint16");
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

        for i = 1:length(imindex)

            fprintf("Correlating pixel %d out of %d \n", i, length(imindex));
            [r, p] = corrcoef(numDuration(imindex(i), :)', albedo(imindex(i), :)');
            correlationR(imindex(i)) = r(1, 2);
            correlationP(imindex(i)) = p(1, 2);

        end

        % reshape the correlation matrix
        correlationR = reshape(correlationR, size(albedo_avg, 1), size(albedo_avg, 2));
        correlationP = reshape(correlationP, size(albedo_avg, 1), size(albedo_avg, 2));

    case "s3"        

        imfiles = dir(fullfile(imfolder, '*.mat'));
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

        for i = 1:length(imindex)

            fprintf("Correlating pixel %d out of %d \n", i, length(imindex));
            [r, p] = corrcoef(numDuration(imindex(i), :)', albedo(imindex(i), :)');
            correlationR(imindex(i)) = r(1, 2);
            correlationP(imindex(i)) = p(1, 2);
            % mdl = fitlm(numDuration(imindex(i), :)', albedo(imindex(i), :)', 'linear', 'RobustOpts', 'off');
            % correlationR(imindex(i)) = mdl.Rsquared.Ordinary;
            % correlationP(imindex(i)) = mdl.Coefficients.pValue(2);

        end

        % reshape the correlation matrix
        correlationR = reshape(correlationR, size(albedo_avg, 1), size(albedo_avg, 2));
        correlationP = reshape(correlationP, size(albedo_avg, 1), size(albedo_avg, 2));

    case "mods3"
        imfiles = dir(fullfile(imfolder, '*.mat'));
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

        % xlimit = R.XWorldLimits;
        % ylimit = R.YWorldLimits;

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

        for i = 1:length(imindex)

            fprintf("Correlating pixel %d out of %d \n", i, length(imindex));
            df = [numDuration(imindex(i), :)' albedo(imindex(i), :)'];
            % remove nan values
            df(any(isnan(df), 2), :) = [];
            [r, p] = corrcoef(df(:, 1), df(:, 2));
            correlationR(imindex(i)) = r(1, 2);
            correlationP(imindex(i)) = p(1, 2);

        end
        
        % reshape the correlation matrix
        correlationR = reshape(correlationR, size(albedo_avg, 1), size(albedo_avg, 2));
        correlationP = reshape(correlationP, size(albedo_avg, 1), size(albedo_avg, 2));
        
end
end
