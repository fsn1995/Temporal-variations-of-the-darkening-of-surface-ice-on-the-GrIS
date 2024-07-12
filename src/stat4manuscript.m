%% Some statistics for manuscript writing.

%% bare ice extent comparison

load("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\MOD10\albedo_spatial_2002.mat", "bare_duration");
bare_duration = single(bare_duration);
bare_duration(bare_duration == 0) = nan;

bare_duration2002 = bare_duration;
bare_duration2002(isnan(bare_duration2002)) = [];

load("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\MOD10\albedo_spatial_2012.mat", "bare_duration");
bare_duration = single(bare_duration);
bare_duration(bare_duration == 0) = nan;

bare_duration2012 = bare_duration;
bare_duration2012(isnan(bare_duration2012)) = [];

load("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\SICEalbedo\albedo_spatial_2022.mat", "bare_duration");
bare_duration = single(bare_duration);
bare_duration(bare_duration == 0) = nan;

bare_duration2022 = bare_duration;
bare_duration2022(isnan(bare_duration2022)) = [];

% area comparison
fprintf("2002 bare ice extent: %.2f km^2\n", numel(bare_duration2002) * 500 * 500 / 1e6);
fprintf("2012 bare ice extent: %.2f km^2\n", numel(bare_duration2012) * 500 * 500 / 1e6);
fprintf("2022 bare ice extent: %.2f km^2\n", numel(bare_duration2022) * 500 * 500 / 1e6);
fprintf("2012 is %.2f times of 2002\n", numel(bare_duration2012) / numel(bare_duration2002));
fprintf("2012 is %.2f times of 2022\n", numel(bare_duration2012) / numel(bare_duration2022));

% duration comparison using ransum statistics

[p, h] = ranksum(bare_duration2012, bare_duration2002, "tail", "right", "alpha", 0.05);
if h == 1
    fprintf("2012 bare ice duration is significantly longer than 2002 (p = %.4f)\n", p);
else
    fprintf("2012 bare ice duration is not significantly longer than 2002 (p = %.4f)\n", p);
end
[p, h] = ranksum(bare_duration2012, bare_duration2022, "tail", "right", "alpha", 0.05);
if h == 1
    fprintf("2012 bare ice duration is significantly longer than 2022 (p = %.4f)\n", p);
else
    fprintf("2012 bare ice duration is not significantly longer than 2022 (p = %.4f)\n", p);
end

%% spatial correlation analysis
clearvars
load("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\albedospatial\mod10s3corr.mat");
correlationR(correlationP>=0.05) = nan;
correlationR = correlationR(:);
correlationR(isnan(correlationR)) = [];

imr2 = correlationR.*correlationR;
figure; boxchart(imr2);
figure; boxchart(correlationR);

fprintf("mean R: %.4f\n", mean(correlationR));
fprintf("median R: %.4f\n", median(correlationR));

fprintf("mean r2: %.4f\n", mean(imr2));
fprintf("median r2: %.4f\n", median(imr2));