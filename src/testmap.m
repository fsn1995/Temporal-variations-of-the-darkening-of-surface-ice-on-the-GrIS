
f1 = figure;
f1.Position = [583 602 1400 668];
t = tiledlayout(4,6, 'TileSpacing','tight','Padding','compact'); % 
ax = 1:1:24;

imfolder = "O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\SICEalbedo";
immatfiles = dir(fullfile(imfolder, '*.mat'));
imdate = string({immatfiles.name}.');
imdate = double(extractBetween(imdate, "albedo_spatial_", ".mat"));
imdate = sort(imdate);

axnum = 13:1:18;
for i = 1:numel(axnum)
    fprintf("Plotting s3 data in %d\n", imdate(i));
    load(fullfile(imfolder, sprintf("albedo_spatial_%d.mat", imdate(i))));
    albedo_avg = double(albedo_avg) ./ 10000;
    bare_duration = double(bare_duration);
    bare_duration(bare_duration == 0) = nan;
    albedo_avg(bare_duration < 1) = nan;
    
    ax(axnum(i)) = nexttile(axnum(i));
    mapshow(ax(axnum(i)), mapx, mapy, flipud(rot90(bare_duration)), 'DisplayType','surface');
    colormap(ax(axnum(i)), cmocean('-deep'));

end
