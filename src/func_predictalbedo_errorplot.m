function stats = func_predictalbedo_errorplot(imfolder, outputfolder)
% func_predictalbedo_errorplot Plot mean bias and RMSE for predicted albedo.
%   stats = func_predictalbedo_errorplot(imfolder, outputfolder)
%   reads albedo_predict_*.mat files created by func_predictalbedo,
%   computes:
%   - mean bias = mean(predicted_jja_albedo - actual_jja_albedo)
%   - RMSE = sqrt(mean((predicted_jja_albedo - actual_jja_albedo).^2))
%   and makes one figure with two panels (bias and RMSE).
%
% Inputs:
%   imfolder: folder containing albedo_predict_*.mat
%   outputfolder (optional): folder to save figure and csv summary
%
% Output:
%   stats: struct with meanBias, rmse, and domain-mean scalars

if nargin < 2 || strlength(string(outputfolder)) == 0
    outputfolder = "..\\print";
end
if ~isfolder(outputfolder)
    mkdir(outputfolder);
end

imfiles = dir(fullfile(imfolder, "albedo_predict_*.mat"));
if isempty(imfiles)
    error("No albedo_predict_*.mat files found in %s", imfolder);
end

imfiles = sortrows(struct2table(imfiles), "name");
imfiles = table2struct(imfiles);

% Reference crop window used in func_spatialcorr for mods3 workflow.
hasCropRef = false;
refFile = fullfile(imfolder, "albedo_predict_2023.mat");
if isfile(refFile)
    Sref = load(refFile, "mapx", "mapy");
    if isfield(Sref, "mapx") && isfield(Sref, "mapy")
        xlimit = [min(Sref.mapx) max(Sref.mapx)];
        ylimit = [min(Sref.mapy) max(Sref.mapy)];
        hasCropRef = true;
    end
end
Rplot = [];

% Initialize using the first valid file.
initialized = false;
for i = 1:numel(imfiles)
    S0 = load(fullfile(imfolder, imfiles(i).name), "actual_jja_albedo", "predicted_jja_albedo", "R");
    if isfield(S0, "actual_jja_albedo") && isfield(S0, "predicted_jja_albedo")
        actual0 = single(S0.actual_jja_albedo);
        predicted0 = single(S0.predicted_jja_albedo);
        yearStr = regexp(imfiles(i).name, "\d{4}", "match", "once");
        yy = str2double(yearStr);

        if ~isnan(yy) && yy <= 2019 && hasCropRef && isfield(S0, "R")
            [actual0, Rplot] = mapcrop(actual0, S0.R, xlimit, ylimit);
            [predicted0, ~] = mapcrop(predicted0, S0.R, xlimit, ylimit);
        elseif ~isnan(yy) && yy >= 2020
            actual0 = flipud(rot90(actual0));
            predicted0 = flipud(rot90(predicted0));
            actual0(1:10, :) = [];
            actual0(end, :) = [];
            predicted0(1:10, :) = [];
            predicted0(end, :) = [];
        end

        if ~isequal(size(actual0), size(predicted0))
            continue;
        end

        sz = size(actual0);
        diffCube = NaN(sz(1), sz(2), numel(imfiles), "single");
        actualCube = NaN(sz(1), sz(2), numel(imfiles), "single");
        predictedCube = NaN(sz(1), sz(2), numel(imfiles), "single");
        initialized = true;
        break;
    end
end

if ~initialized
    error("No file contains both actual_jja_albedo and predicted_jja_albedo.");
end

for i = 1:numel(imfiles)
    f = fullfile(imfolder, imfiles(i).name);
    S = load(f, "actual_jja_albedo", "predicted_jja_albedo", "R");

    if ~isfield(S, "actual_jja_albedo") || ~isfield(S, "predicted_jja_albedo")
        warning("Skip %s (missing actual/predicted fields)", imfiles(i).name);
        continue;
    end

    actual = single(S.actual_jja_albedo);
    predicted = single(S.predicted_jja_albedo);

    yearStr = regexp(imfiles(i).name, "\d{4}", "match", "once");
    yy = str2double(yearStr);

    if ~isnan(yy) && yy <= 2019 && hasCropRef && isfield(S, "R")
        % Apply the same MOD10 crop-domain workflow as func_spatialcorr.
        [actual, ~] = mapcrop(actual, S.R, xlimit, ylimit);
        [predicted, ~] = mapcrop(predicted, S.R, xlimit, ylimit);
    elseif ~isnan(yy) && yy >= 2020
        % Match the MODIS/S3 geometry harmonization used in func_spatialcorr.
        actual = flipud(rot90(actual));
        predicted = flipud(rot90(predicted));
        actual(1:10, :) = [];
        actual(end, :) = [];
        predicted(1:10, :) = [];
        predicted(end, :) = [];
    end

    if ~isequal(size(actual), sz) || ~isequal(size(predicted), sz)
        warning("Skip %s (size mismatch after harmonization)", imfiles(i).name);
        continue;
    end

    d = predicted - actual;
    d(isnan(actual) | isnan(predicted)) = nan;
    diffCube(:, :, i) = d;
    actualCube(:, :, i) = actual;
    predictedCube(:, :, i) = predicted;
end

% Match spatialcorr workflow: keep pixels with BID exposure in >= 10 years.
minExposedYears = 10;
bidMask = sum(~isnan(diffCube), 3) >= minExposedYears;

meanBias = mean(diffCube, 3, "omitnan");
rmse = sqrt(mean(diffCube .^ 2, 3, "omitnan"));
corrMap = NaN(sz(1), sz(2), "single");

validPix = find(bidMask);
for k = 1:numel(validPix)
    [rr, cc] = ind2sub([sz(1), sz(2)], validPix(k));
    df = [double(squeeze(predictedCube(rr, cc, :))), ...
          double(squeeze(actualCube(rr, cc, :)))];
    % Match func_spatialcorr approach: remove rows with NaNs before corrcoef.
    df(any(isnan(df), 2), :) = [];
    if size(df, 1) >= 2
        r = corrcoef(df(:, 1), df(:, 2));
        if numel(r) > 1
            corrMap(rr, cc) = single(r(1, 2));
        end
    end
end

r2Map = corrMap .^ 2;

meanBias(~bidMask) = nan;
rmse(~bidMask) = nan;
r2Map(~bidMask) = nan;

domainMeanBias = mean(meanBias(:), "omitnan");
domainRMSE = mean(rmse(:), "omitnan");
domainMeanR2 = mean(r2Map(:), "omitnan");
domainStdBias = std(meanBias(:), 0, "omitnan");
domainStdRMSE = std(rmse(:), 0, "omitnan");
domainStdR2 = std(r2Map(:), 0, "omitnan");

% One figure with three panels.
f = figure("Position", [120 120 1400 500]);
t= tiledlayout(1, 3, 'TileSpacing','none','Padding','compact');

ax1 = nexttile;
greenland('k');
mapshow(ax1, meanBias, Rplot, 'DisplayType', 'surface');
axis(ax1, "off");
c1 = colorbar(ax1);
colormap(ax1, cmocean('balance'));
c1.Label.String = "Mean Bias";
clim(ax1, [-0.1, 0.1]);
text(ax1, 0.15, 0.1, 'a)', 'Units', 'normalized');

ax2 = nexttile;
greenland('k');
mapshow(ax2, rmse, Rplot, 'DisplayType', 'surface');
axis(ax2, "off");
c2 = colorbar(ax2);
colormap(ax2, cmocean('matter'));
c2.Label.String = "RMSE";
clim(ax2, [0, 0.1]);
text(ax2, 0.15, 0.1, 'b)', 'Units', 'normalized');

ax3 = nexttile;
greenland('k');
mapshow(ax3, r2Map, Rplot, 'DisplayType', 'surface');
axis(ax3, "off");
c3 = colorbar(ax3);
colormap(ax3, cmocean('haline'));
c3.Label.String = "r^2";
clim(ax3, [0, 1]);
scalebarpsn('location', 'se');
text(ax3, 0.15, 0.1, 'c)', 'Units', 'normalized');
fontsize(t, 16, "points");
outPng = fullfile(outputfolder, "predictalbedo_bias_rmse.png");
exportgraphics(f, outPng, "Resolution", 300, "BackgroundColor", "none");
outPDF = fullfile(outputfolder, "predictalbedo_bias_rmse.pdf");
exportgraphics(f, outPDF, "Resolution", 300);

T = table(domainMeanBias, domainStdBias, domainRMSE, domainStdRMSE, domainMeanR2, domainStdR2, ...
    "VariableNames", {"mean_bias", "std_bias", "mean_rmse", "std_rmse", "mean_r2", "std_r2"});
outCsv = fullfile(outputfolder, "predictalbedo_bias_rmse_summary.csv");
writetable(T, outCsv);

stats = struct;
stats.meanBias = meanBias;
stats.rmse = rmse;
stats.r2 = r2Map;
stats.bidMask = bidMask;
stats.minExposedYears = minExposedYears;
stats.domainMeanBias = domainMeanBias;
stats.domainStdBias = domainStdBias;
stats.domainRMSE = domainRMSE;
stats.domainStdRMSE = domainStdRMSE;
stats.domainMeanR2 = domainMeanR2;
stats.domainStdR2 = domainStdR2;
stats.outputFigure = outPng;
stats.outputSummary = outCsv;

end
