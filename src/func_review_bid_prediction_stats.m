function stats = func_review_bid_prediction_stats(imfolder, outputfolder, minBIDYears)
% func_review_bid_prediction_stats Reviewer diagnostics for Eq4 albedo estimates.
%   stats = func_review_bid_prediction_stats(imfolder, outputfolder, minBIDYears)
%   computes 2002-2023 pixel-wise metrics between observed JJA albedo and
%   Eq4-predicted JJA albedo over the BID area, using the same mods3
%   workflow as func_spatialcorr.
%
%   Metrics:
%   - Mean observed and predicted JJA albedo (2002-2023)
%   - Mean bias: mean(pred - obs)
%   - RMSE across years
%   - Temporal correlation across years (per pixel)
%   - Interannual variability of observed JJA albedo (std dev)
%   - Areas where |bias| > std(obs) and RMSE > std(obs)
%
%   BID area is limited to pixels where BID > 0 in at least minBIDYears
%   summers (default: 10), matching the screening approach in func_spatialcorr.
%
%   Inputs:
%   - imfolder: folder containing albedo_spatial_YYYY.mat files
%   - outputfolder: folder to save outputs (default: ..\print)
%   - minBIDYears: minimum BID occurrences (default: 10)
%
%   Output:
%   - stats: struct with maps and summary numbers for manuscript text.
%
%   Shunan Feng (shunan.feng@envs.au.dk)

if nargin < 2 || strlength(string(outputfolder)) == 0
    outputfolder = "..\\print";
end
if nargin < 3 || isempty(minBIDYears)
    minBIDYears = 10;
end
if ~isfolder(outputfolder)
    mkdir(outputfolder);
end

years = 2002:2023;
nYears = numel(years);

% Match spatial domain used in func_spatialcorr (mods3 branch).
refS3 = load(fullfile(imfolder, "albedo_spatial_2023.mat"), "mapx", "mapy");
xlimit = [min(refS3.mapx) max(refS3.mapx)];
ylimit = [min(refS3.mapy) max(refS3.mapy)];

% Use the MODIS grid after crop as target geometry.
S0 = load(fullfile(imfolder, "albedo_spatial_2002.mat"), "albedo_avg", "R");
[tmpl, R] = mapcrop(S0.albedo_avg, S0.R, xlimit, ylimit);

nRows = size(tmpl, 1);
nCols = size(tmpl, 2);
obsCube = NaN(nRows, nCols, nYears, "single");
predCube = NaN(nRows, nCols, nYears, "single");
bidCount = zeros(nRows, nCols, "uint8");

for k = 1:nYears
    yy = years(k);
    f = fullfile(imfolder, sprintf("albedo_spatial_%d.mat", yy));
    if ~isfile(f)
        warning("Missing file, skipping year %d: %s", yy, f);
        continue;
    end

    S = load(f, "albedo_avg", "bare_duration", "R");
    if ~isfield(S, "albedo_avg") || ~isfield(S, "bare_duration")
        warning("Missing albedo_avg/bare_duration in year %d", yy);
        continue;
    end

    if yy <= 2019
        if ~isfield(S, "R")
            warning("Missing R in year %d; skipping", yy);
            continue;
        end
        [albedo_avg, ~] = mapcrop(S.albedo_avg, S.R, xlimit, ylimit);
        [bare_duration, ~] = mapcrop(S.bare_duration, S.R, xlimit, ylimit);
        albedo_avg = single(albedo_avg);
    else
        % Same S3 reshaping as func_spatialcorr (mods3 branch).
        albedo_avg = flipud(rot90(S.albedo_avg));
        bare_duration = flipud(rot90(S.bare_duration));
        albedo_avg(1:10, :) = [];
        albedo_avg(end, :) = [];
        bare_duration(1:10, :) = [];
        bare_duration(end, :) = [];
        albedo_avg = single(albedo_avg) ./ 10000;
    end

    bare_duration = single(bare_duration);
    bare_duration(bare_duration < 1) = nan;

    albedo_avg(albedo_avg == 0) = nan;
    albedo_avg(isnan(bare_duration)) = nan;

    predicted = single((-0.0032) .* double(bare_duration) + 0.7161);
    predicted(isnan(bare_duration)) = nan;

    obsCube(:, :, k) = albedo_avg;
    predCube(:, :, k) = predicted;
    bidCount = bidCount + uint8(~isnan(bare_duration));
end

% BID-area filter requested by reviewer response.
bidMask = bidCount >= uint8(minBIDYears);

diffCube = predCube - obsCube;
meanObs = mean(obsCube, 3, "omitnan");
meanPred = mean(predCube, 3, "omitnan");
meanBias = mean(diffCube, 3, "omitnan");
rmseMap = sqrt(mean(diffCube .^ 2, 3, "omitnan"));
stdObs = std(obsCube, 0, 3, "omitnan");

corrMap = NaN(nRows, nCols, "single");
pMap = NaN(nRows, nCols, "single");
validPix = find(bidMask);

for ii = 1:numel(validPix)
    idx = validPix(ii);
    x = double(squeeze(obsCube(idx)));
    y = double(squeeze(predCube(idx)));
    keep = ~(isnan(x) | isnan(y));
    if nnz(keep) >= 3
        [r, p] = corrcoef(x(keep), y(keep));
        if numel(r) > 1
            corrMap(idx) = single(r(1, 2));
            pMap(idx) = single(p(1, 2));
        end
    end
end

% Apply BID-area mask to final maps.
meanObs(~bidMask) = nan;
meanPred(~bidMask) = nan;
meanBias(~bidMask) = nan;
rmseMap(~bidMask) = nan;
stdObs(~bidMask) = nan;
corrMap(~bidMask) = nan;
pMap(~bidMask) = nan;

absBiasGtStd = abs(meanBias) > stdObs;
rmseGtStd = rmseMap > stdObs;
absBiasGtStd(~bidMask) = false;
rmseGtStd(~bidMask) = false;

% Domain-level 3D summary over all valid BID-area voxels.
bidMask3 = repmat(bidMask, 1, 1, nYears);
paired = bidMask3 & ~isnan(obsCube) & ~isnan(predCube);
obsVec = double(obsCube(paired));
predVec = double(predCube(paired));
diffVec = predVec - obsVec;

summary = table;
summary.n_pixels_bid = nnz(bidMask);
summary.n_voxels_paired = numel(diffVec);
summary.mean_bias_3d = mean(diffVec, "omitnan");
summary.rmse_3d = sqrt(mean(diffVec .^ 2, "omitnan"));
summary.corr_3d = corr(obsVec, predVec, "rows", "complete");

% Same metrics but from mean maps (Fig. 5d style comparison).
dMean = double(meanPred(bidMask)) - double(meanObs(bidMask));
summary.mean_bias_meanmap = mean(dMean, "omitnan");
summary.rmse_meanmap = sqrt(mean(dMean .^ 2, "omitnan"));
summary.corr_meanmap = corr(double(meanObs(bidMask)), double(meanPred(bidMask)), "rows", "complete");

v = bidMask & ~isnan(stdObs);
summary.frac_absbias_gt_std = nnz(absBiasGtStd(v)) / nnz(v);
summary.frac_rmse_gt_std = nnz(rmseGtStd(v)) / nnz(v);

writetable(summary, fullfile(outputfolder, "review_bid_prediction_summary.csv"));

save(fullfile(outputfolder, "review_bid_prediction_maps.mat"), ...
    "years", "R", "bidMask", "bidCount", ...
    "meanObs", "meanPred", "meanBias", "rmseMap", "corrMap", "pMap", ...
    "stdObs", "absBiasGtStd", "rmseGtStd", "summary", "-v7.3");

% Quick-look figure for reviewer-response text and supplements.
f = figure("Position", [100 80 1500 850]);
t = tiledlayout(2, 4, "TileSpacing", "compact", "Padding", "compact");

ax1 = nexttile; mapshow(ax1, meanObs, R, "DisplayType", "surface"); axis(ax1, "off"); colorbar(ax1); title(ax1, "Mean observed JJA albedo");
ax2 = nexttile; mapshow(ax2, meanPred, R, "DisplayType", "surface"); axis(ax2, "off"); colorbar(ax2); title(ax2, "Mean Eq4 estimated JJA albedo");
ax3 = nexttile; mapshow(ax3, meanBias, R, "DisplayType", "surface"); axis(ax3, "off"); colorbar(ax3); title(ax3, "Mean bias (pred - obs)");
ax4 = nexttile; mapshow(ax4, rmseMap, R, "DisplayType", "surface"); axis(ax4, "off"); colorbar(ax4); title(ax4, "RMSE across 2002-2023");
ax5 = nexttile; mapshow(ax5, corrMap, R, "DisplayType", "surface"); axis(ax5, "off"); colorbar(ax5); title(ax5, "Temporal corr (per pixel)");
ax6 = nexttile; mapshow(ax6, stdObs, R, "DisplayType", "surface"); axis(ax6, "off"); colorbar(ax6); title(ax6, "Interannual std of observed JJA");
ax7 = nexttile; mapshow(ax7, single(absBiasGtStd), R, "DisplayType", "surface"); axis(ax7, "off"); colorbar(ax7); title(ax7, "|Mean bias| > std(obs)");
ax8 = nexttile; mapshow(ax8, single(rmseGtStd), R, "DisplayType", "surface"); axis(ax8, "off"); colorbar(ax8); title(ax8, "RMSE > std(obs)");

title(t, sprintf("Eq4 vs satellite JJA albedo over BID area (BID >= %d years)", minBIDYears));
exportgraphics(f, fullfile(outputfolder, "review_bid_prediction_maps.png"), "Resolution", 300);
close(f);

stats = struct;
stats.years = years;
stats.R = R;
stats.bidMask = bidMask;
stats.bidCount = bidCount;
stats.meanObs = meanObs;
stats.meanPred = meanPred;
stats.meanBias = meanBias;
stats.rmseMap = rmseMap;
stats.corrMap = corrMap;
stats.pMap = pMap;
stats.stdObs = stdObs;
stats.absBiasGtStd = absBiasGtStd;
stats.rmseGtStd = rmseGtStd;
stats.summary = summary;

end
