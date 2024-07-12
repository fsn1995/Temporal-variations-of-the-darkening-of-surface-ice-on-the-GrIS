
f1 = figure;
f1.Position = [583 602 1400 668];
t = tiledlayout(3,6, 'TileSpacing','tight','Padding','compact'); % 
ax = 1:1:18;

%% Duration vs albedo vs number of clear observations
% hsa data
imfolder = "/data/shunan/data/GrISdailyAlbedoMosaic";
immatfiles = dir(fullfile(imfolder, '*.mat'));
imdate = string({immatfiles.name}.');
imdate = double(extractBetween(imdate, "albedo_spatial_", ".mat"));
imdate = sort(imdate);

axnum = 1:1:5;
for i = 1:numel(axnum)

    fprintf("Plotting hsa data in %d\n", imdate(i));
    load(fullfile(imfolder, sprintf("albedo_spatial_%d.mat", imdate(i))));
 
    albedo_avg = double(albedo_avg) ./ 10000;
    bare_duration = double(bare_duration);
    gapA = double(gapA);
    bare_duration(bare_duration == 0) = nan;
    albedo_avg(isnan(bare_duration)) = nan;
    gapA(gapA == 0) = nan;
    gapA(isnan(bare_duration)) = nan;

    % export to csv files
    df = table;
    df.bare_duration = bare_duration(:);
    df.albedo_avg = albedo_avg(:);
    df = rmmissing(df, 1);
    if i == 1
        writetable(df, "/data/shunan/data/albedospatial/HSA_data.csv", ...
        "WriteMode","overwrite", "WriteRowNames",true);
    else
        writetable(df, "/data/shunan/data/albedospatial/HSA_data.csv", ...
        "WriteMode","append", "WriteRowNames", false);
    end
    % remove df after writing
    clearvars df

    % % crop and resample the data
    % [albedo_avg, R_crop]= mapcrop(albedo_avg, R, ...
    %     [R.XWorldLimits(1)+10000, R.XWorldLimits(2)-200000], ...
    %     [R.YWorldLimits(1)+100000, R.YWorldLimits(2)]);
    % [albedo_avg, R_resample] = mapresize(albedo_avg, R_crop, 1/2);
    % 
    % [bare_duration, R_crop]= mapcrop(bare_duration, R, ...
    %     [R.XWorldLimits(1)+10000, R.XWorldLimits(2)-200000], ...
    %     [R.YWorldLimits(1)+100000, R.YWorldLimits(2)]);
    % [bare_duration, ~] = mapresize(bare_duration, R_crop, 1/2);
    % 
    % [gapA, R_crop]= mapcrop(gapA, R, ...
    %     [R.XWorldLimits(1)+10000, R.XWorldLimits(2)-200000], ...
    %     [R.YWorldLimits(1)+100000, R.YWorldLimits(2)]);
    % [gapA, ~] = mapresize(gapA, R_crop, 1/2);
    % 
    % % get the range of data
    % fprintf("Range of bare duration: %d - %d\n", min(bare_duration(:), [],"omitmissing"), max(bare_duration(:),[], "omitmissing"));
    % fprintf("Range of albedo: %f - %f\n", min(albedo_avg(:), [],"omitmissing"), max(albedo_avg(:),[], "omitmissing"));
    % fprintf("Range of gapA: %d - %d\n", min(gapA(:),[], "omitmissing"), max(gapA(:),[], "omitmissing"));
    % 
    % ax(axnum(i)) = nexttile(axnum(i));
    % greenland('k');
    % mapshow(ax(axnum(i)), bare_duration, R_resample, 'DisplayType','surface');
    % % scalebarpsn('location','se');
    % colormap(ax(axnum(i)), cmocean('solar'));
    % clim(ax(axnum(i)), [1, 92]);
    % axis off
    % 
    % ax(axnum(i)+6) = nexttile(axnum(i)+6);
    % greenland('k');
    % mapshow(ax(axnum(i)+6),albedo_avg, R_resample, 'DisplayType','surface');
    % % scalebarpsn('location','se');
    % colormap(ax(axnum(i)+6), func_dpcolor());
    % clim(ax(axnum(i)+6), [0, 1]);
    % axis off
    % 
    % ax(axnum(i)+12) = nexttile(axnum(i)+12);
    % greenland('k');
    % mapshow(ax(axnum(i)+12), gapA, R_resample, 'DisplayType','surface');
    % % scalebarpsn('location','se');
    % colormap(ax(axnum(i)+12), cmocean('haline'));
    % clim(ax(axnum(i)+12), [1, 79]);
    % axis off

end

%% correlation map across tile 6, 12, and 18
ax(12) = nexttile(12);
load("/data/shunan/data/albedospatial/hsacorr.mat");
correlationR(correlationP >= 0.05) = nan;

[correlationR, R_crop] = mapcrop(correlationR, R, ...
    [R.XWorldLimits(1)+10000, R.XWorldLimits(2)-200000], ...
    [R.YWorldLimits(1)+100000, R.YWorldLimits(2)]);
[correlationR, ~] = mapresize(correlationR, R_crop, 1/2);

greenland('k');
mapshow(ax(12), correlationR, R_resample, 'DisplayType','surface');
scalebarpsn('location','se');
colormap(ax(12), cmocean('balance'));
clim(ax(12), [-1, 1]);
axis off

%% label and annotation
title(ax(1), "2019", "FontWeight","normal");
title(ax(2), "2020", "FontWeight","normal");
title(ax(3), "2021", "FontWeight","normal");
title(ax(4), "2022", "FontWeight","normal");
title(ax(5), "2023", "FontWeight","normal");

c1 = colorbar(ax(1), "westoutside");
c.Label.String = "Bare ground duration (days)";
c7 = colorbar(ax(7), "westoutside");
c7.Label.String = "Albedo (JJA)";
c13 = colorbar(ax(13), "westoutside");
c13.Label.String = "Data density";

c12 = colorbar(ax(12), "eastoutside");
c12.Label.String = "R value (p < 0.05)"; 
%% data density plot

% f2 = figure;
% f2.Position = [583 602 1400 668];
% t = tiledlayout(1,5, 'TileSpacing','tight','Padding','compact'); %

% hsa data
% imfolder = "/data/shunan/data/GrISdailyAlbedoMosaic";
% immatfiles = dir(fullfile(imfolder, '*.mat'));
% imdate = string({immatfiles.name}.');
% imdate = double(extractBetween(imdate, "albedo_spatial_", ".mat"));
% imdate = sort(imdate);
% 
% axnum = 1:1:5;
% for i = 1:numel(axnum)
%     fprintf("Plotting hsa data in %d\n", imdate(i));
%     load(fullfile(imfolder, sprintf("albedo_spatial_%d.mat", imdate(i))));
%     gapA = double(gapA);
%     gapA(gapA == 0) = nan;
% 
%     ax(axnum(i)) = nexttile(axnum(i));
%     greenland('k');
%     mapshow(ax(axnum(i)), gapA, R, 'DisplayType','surface');
%     scalebarpsn('location','se');
%     colormap(ax(axnum(i)), cmocean('haline'));
%     axis off
% 
% end


%% s3 data
imfolder = "/data/shunan/data/SICEalbedo";
immatfiles = dir(fullfile(imfolder, '*.mat'));
imdate = string({immatfiles.name}.');
imdate = double(extractBetween(imdate, "albedo_spatial_", ".mat"));
imdate = sort(imdate);

for i = 1:numel(imdate)
    fprintf("Plotting s3 data in %d\n", imdate(i));
    load(fullfile(imfolder, sprintf("albedo_spatial_%d.mat", imdate(i))));
    albedo_avg = double(albedo_avg) ./ 10000;
    bare_duration = double(bare_duration);
    gapA = double(gapA);

    bare_duration(bare_duration == 0) = nan;
    albedo_avg(isnan(bare_duration)) = nan;
    gapA(gapA == 0) = nan;
    gapA(isnan(bare_duration)) = nan;

    % export to csv files
    df = table;
    df.bare_duration = bare_duration(:);
    df.albedo_avg = albedo_avg(:);
    df = rmmissing(df, 1);
    if i == 1
        writetable(df, "/data/shunan/data/albedospatial/S3_data.csv", ...
        "WriteMode","overwrite", "WriteRowNames",true);
    else
        writetable(df, "/data/shunan/data/albedospatial/S3_data.csv", ...
        "WriteMode","append", "WriteRowNames", false);
    end
    % remove df after writing
    clearvars df
    % ax(axnum(i)) = nexttile(axnum(i));
    % greenland('k');
    % mapshow(ax(axnum(i)), mapx, mapy, flipud(rot90(gapA)), 'DisplayType','surface');
    % scalebarpsn('location','se');
    % colormap(ax(axnum(i)), cmocean('haline'));
    % axis off

end