function [correlationR, correlationP] = func_spatialcorr(imfolder, imsource)
    
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

end
end
