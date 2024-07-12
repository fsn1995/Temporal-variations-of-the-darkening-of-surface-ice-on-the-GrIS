
f1 = figure;
f1.Position = [583 602 1400 668];
t = tiledlayout(4,6, 'TileSpacing','tight','Padding','compact'); % 
ax = 1:1:24;

%% Duration vs albedo
%% hsa data
% imfolder = "/data/shunan/data/GrISdailyAlbedoMosaic";
% immatfiles = dir(fullfile(imfolder, '*.mat'));
% imdate = string({immatfiles.name}.');
% imdate = double(extractBetween(imdate, "albedo_spatial_", ".mat"));
% imdate = sort(imdate);
% 
% axnum = 1:1:5;
% for i = 1:numel(axnum)
% 
%     fprintf("Plotting hsa data in %d\n", imdate(i));
%     load(fullfile(imfolder, sprintf("albedo_spatial_%d.mat", imdate(i))));
%     albedo_avg = double(albedo_avg) ./ 10000;
%     bare_duration = double(bare_duration);
%     bare_duration(bare_duration == 0) = nan;
%     albedo_avg(isnan(bare_duration)) = nan;
% 
%     ax(axnum(i)) = nexttile(axnum(i));
%     greenland('k');
%     mapshow(ax(axnum(i)), bare_duration, R, 'DisplayType','surface');
%     scalebarpsn('location','se');
%     colormap(ax(axnum(i)), cmocean('solar'));
%     axis off
% 
%     ax(axnum(i)+6) = nexttile(axnum(i)+6);
%     greenland('k');
%     mapshow(ax(axnum(i)+6),albedo_avg, R, 'DisplayType','surface');
%     scalebarpsn('location','se');
%     colormap(ax(axnum(i)+6), func_dpcolor());
%     axis off
% 
% end

%% s3 data
imfolder = "/data/shunan/data/SICEalbedo";
immatfiles = dir(fullfile(imfolder, '*.mat'));
imdate = string({immatfiles.name}.');
imdate = double(extractBetween(imdate, "albedo_spatial_", ".mat"));
imdate = sort(imdate);

axnum = 13:1:17;
for i = 1:numel(axnum)
    fprintf("Plotting s3 data in %d\n", imdate(i));
    load(fullfile(imfolder, sprintf("albedo_spatial_%d.mat", imdate(i))));
    albedo_avg = double(albedo_avg) ./ 10000;
    bare_duration = double(bare_duration);
    bare_duration(bare_duration == 0) = nan;
    albedo_avg(isnan(bare_duration)) = nan;
    
    ax(axnum(i)) = nexttile(axnum(i));
    greenland('k');
    mapshow(ax(axnum(i)), mapx, mapy, flipud(rot90(bare_duration)), 'DisplayType','surface');
    scalebarpsn('location','se');
    colormap(ax(axnum(i)), cmocean('solar'));
    axis off

    ax(axnum(i)+6) = nexttile(axnum(i)+6);
    greenland('k');
    mapshow(ax(axnum(i)+6), mapx, mapy, flipud(rot90(albedo_avg)), 'DisplayType','surface');
    scalebarpsn('location','se');
    colormap(ax(axnum(i)+6), func_dpcolor());
    axis off

end

%% data density plot

f2 = figure;
f2.Position = [583 602 1400 668];
t = tiledlayout(2,5, 'TileSpacing','tight','Padding','compact'); %

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

% s3 data
imfolder = "/data/shunan/data/SICEalbedo";
immatfiles = dir(fullfile(imfolder, '*.mat'));
imdate = string({immatfiles.name}.');
imdate = double(extractBetween(imdate, "albedo_spatial_", ".mat"));
imdate = sort(imdate);

axnum = 6:1:10;
for i = 1:numel(axnum)
    fprintf("Plotting s3 data in %d\n", imdate(i));
    load(fullfile(imfolder, sprintf("albedo_spatial_%d.mat", imdate(i))));
    gapA = double(gapA);
    gapA(gapA == 0) = nan;
    
    ax(axnum(i)) = nexttile(axnum(i));
    greenland('k');
    mapshow(ax(axnum(i)), mapx, mapy, flipud(rot90(gapA)), 'DisplayType','surface');
    scalebarpsn('location','se');
    colormap(ax(axnum(i)), cmocean('haline'));
    axis off

end