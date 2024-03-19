function averageAlbedo = func_albedomap(imfolder)

% s3 data
immatfolder = fullfile(imfolder, 's3');
immatfiles = dir(fullfile(immatfolder, '*.mat'));
imdate = string({immatfiles.name}.');
imdate = double(extractBetween(imdate, "albedo_spatial_", ".mat"));

for i = imdate
    
    fprintf("ploting albedo map for %d\n", i);
    load(fullfile(immatfolder, sprintf('albedo_spatial_%d.mat', i)));
    
    

end