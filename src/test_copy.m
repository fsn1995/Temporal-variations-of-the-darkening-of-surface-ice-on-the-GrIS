imfolder = "/data/shunan/data/GrISdailyAlbedoMosaic";
imfiles = dir(fullfile(imfolder, '*.mat'));

% load the data into a multi-dimensional array

% pre-allocate the array
load(fullfile(imfolder, imfiles(1).name));
albedo = zeros([size(albedo_avg) height(imfiles)], "uint16");
numClear = albedo;
numDuration = albedo;

% load the data
for i = 1:height(imfiles)
    load(fullfile(imfolder, imfiles(i).name));
    albedo(:,:,i) = albedo_avg;
    numClear(:,:,i) = gapA;
    numDuration(:,:,i) = bare_duration;
end

% plot the albedo by year
for i = 1:height(imfiles)
    figure;
    imagesc(albedo(:,:,i));
    colorbar;
    title(imfiles(i).name);
end
% plot the bare duration by year
for i = 1:height(imfiles)
    figure;
    imagesc(numDuration(:,:,i));
    colorbar;
    title(imfiles(i).name);
end

