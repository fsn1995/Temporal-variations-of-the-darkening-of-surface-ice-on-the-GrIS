function [exporteddata] = func_predictalbedo(imfolder, imsource)
% func_predictalbedo Predict and export JJA albedo from BID
%   func_predictalbedo(imfolder, imsource) loads yearly albedo_spatial
%   products, applies the same valid-data mask workflow as
%   func_spatialcorr (source-specific),
%   predicts JJA albedo using alpha = -0.0032 * BID + 0.7161, and exports
%   both predicted and actual JJA albedo as yearly .mat files.
%   
%   imfolder: the folder containing the daily albedo images
%   imsource: the source of the albedo images (e.g., "hsa", "s3", "mod10", "mods3")
%
%   Note: The function expects yearly files named albedo_spatial_YYYY.mat
%   produced by func_albedospatial.
%   Shunan Feng (shunan.feng@envs.au.dk)

switch imsource
    case "hsa"
        years = 2019:1:2023;
    case "s3"
        years = 2020:1:2023;
    case "mod10"
        years = 2002:1:2019;
    case "mods3"
        years = 2002:1:2023;
    otherwise
        error("Unsupported imsource: %s", string(imsource));
end

% For combined MODIS+S3 products, use the same MODIS-domain crop as
% func_spatialcorr to keep geometry/masking consistent.
if imsource == "mods3"
    refFile = fullfile(imfolder, "albedo_spatial_2023.mat");
    if ~isfile(refFile)
        error("Required reference file not found for mods3: %s", refFile);
    end
    ref = load(refFile, "mapx", "mapy");
    if ~isfield(ref, "mapx") || ~isfield(ref, "mapy")
        error("mapx/mapy missing in %s", refFile);
    end
    xlimit = [min(ref.mapx) max(ref.mapx)];
    ylimit = [min(ref.mapy) max(ref.mapy)];
end

for i = years
    infile = fullfile(imfolder, sprintf("albedo_spatial_%d.mat", i));
    if ~isfile(infile)
        warning("File not found, skip year %d: %s", i, infile);
        continue;
    end

    fprintf("Year: %d\n", i);
    S = load(infile);

    if ~isfield(S, "albedo_avg") || ~isfield(S, "bare_duration")
        warning("Missing required fields in %s, skip year %d", infile, i);
        continue;
    end

    albedo_avg = S.albedo_avg;
    bare_duration = S.bare_duration;

    % Match source-specific masking/transform steps in func_spatialcorr.
    switch imsource
        case {"hsa", "s3"}
            bare_duration = single(bare_duration);
            bare_duration(bare_duration < 1) = nan;

            actual_jja_albedo = single(albedo_avg) ./ 10000;
            actual_jja_albedo(actual_jja_albedo == 0) = nan;
            actual_jja_albedo(isnan(bare_duration)) = nan;

        case "mod10"
            bare_duration = single(bare_duration);
            bare_duration(bare_duration < 1) = nan;

            actual_jja_albedo = single(albedo_avg);
            actual_jja_albedo(actual_jja_albedo == 0) = nan;
            actual_jja_albedo(isnan(bare_duration)) = nan;

        case "mods3"
            if i <= 2019
                if ~isfield(S, "R")
                    warning("Missing R in %s, skip year %d", infile, i);
                    continue;
                end
                [actual_jja_albedo, ~] = mapcrop(albedo_avg, S.R, xlimit, ylimit);
                [bare_duration, ~] = mapcrop(bare_duration, S.R, xlimit, ylimit);

                bare_duration = single(bare_duration);
                bare_duration(bare_duration < 1) = nan;

                actual_jja_albedo = single(actual_jja_albedo);
                actual_jja_albedo(actual_jja_albedo == 0) = nan;
                actual_jja_albedo(isnan(bare_duration)) = nan;
            else
                % Same reshape steps used in func_spatialcorr for S3 years.
                actual_jja_albedo = flipud(rot90(albedo_avg));
                bare_duration = flipud(rot90(bare_duration));
                actual_jja_albedo(1:10, :) = [];
                actual_jja_albedo(end, :) = [];
                bare_duration(1:10, :) = [];
                bare_duration(end, :) = [];

                bare_duration = single(bare_duration);
                bare_duration(bare_duration < 1) = nan;

                actual_jja_albedo = single(actual_jja_albedo) ./ 10000;
                actual_jja_albedo(actual_jja_albedo == 0) = nan;
                actual_jja_albedo(isnan(bare_duration)) = nan;
            end
    end

    predicted_jja_albedo = single((-0.0032) .* double(bare_duration) + 0.7161);
    predicted_jja_albedo(isnan(bare_duration)) = nan;

    S.actual_jja_albedo = actual_jja_albedo;
    S.predicted_jja_albedo = predicted_jja_albedo;

    outfile = fullfile(imfolder, sprintf("albedo_predict_%d.mat", i));
    save(outfile, "-struct", "S", "-mat", "-v7.3");
end

% return the location of the exported .mat files
exporteddata = dir(fullfile(imfolder, "albedo_predict_*.mat"));
end