function [imcount] = func_iminterp(inputfolder, outputfolder)
% This function interpolates the images in the input folder and writes the
% interpolated images to the output folder. The input folder should contain
% the images in the format "YYYY-MM-DD-0000000000-0000000000.tif", which 
% can be built into daily mosaic images using the func_buildmosaic function.
% Shunan Feng (shunan.feng@envs.au.dk)

tic
% imcroplist = ["/*-0000000000-0000000000.tif";
%               "/*-0000000000-0000046592.tif";
%               "/*-0000046592-0000000000.tif";
%               "/*-0000046592-0000046592.tif";
%               "/*-0000093184-0000000000.tif";
%               "/*-0000093184-0000046592.tif"];
%% 2019-06-01 to 2019-08-31
imfiles = dir(inputfolder + "/*-0000000000-0000000000.tif"); %A
% imfiles = dir(inputfolder + "/*-0000000000-0000046592.tif"); %B
% imfiles = dir(inputfolder + "/*-0000046592-0000000000.tif"); %C
% imfiles = dir(inputfolder + "/*-0000046592-0000046592.tif"); %D
% imfiles = dir(inputfolder + "/*-0000093184-0000000000.tif"); %E
% imfiles = dir(inputfolder + "/*-0000093184-0000046592.tif"); %F

imnames = string(extractfield(imfiles, "name")');
imnames = extractBefore(imnames, "-0000");

A = readgeoraster(fullfile(imfiles(1).folder, imfiles(1).name));

numsteps = 23;
imA = zeros([size(A) numsteps], "single");

% for i = 1:numsteps
for i = 1+numsteps:numsteps+numsteps    
% for i = 1+numsteps+numsteps:numsteps+numsteps+numsteps
% for i = 1+numsteps+numsteps+numsteps:numsteps+numsteps+numsteps+numsteps    
    fprintf("processing %s\n", imnames(i));
    A = readgeoraster(fullfile(imfiles(i).folder, imfiles(i).name), "OutputType", "single")./10000;
    A(A>=1) = nan;
    A(A==0) = nan;
    imA(:,:,i) = A;
end

% Interpolate the images
fprintf("Interpolating images\n");
imA = fillmissing(imA, "linear", 3);

% Write the images to new folder
% for i = 1:numsteps
for i = 1+numsteps:numsteps+numsteps    
% for i = 1+numsteps+numsteps:numsteps+numsteps+numsteps
% for i = 1+numsteps+numsteps+numsteps:numsteps+numsteps+numsteps+numsteps   
    fprintf("writing %s\n", imnames(i));
    [~, R] = readgeoraster(fullfile(imfiles(i).folder, imfiles(i).name));
    geotiffwrite(fullfile(outputfolder, imfiles(i).name), ...
        uint16(imA(:,:,i).*10000), R, "CoordRefSysCode", 3413);
end


imcount = height(dir(outputfolder + "/*.tif"));
toc
elapsedTime = toc;
hours = floor(elapsedTime / 3600);
minutes = floor(mod(elapsedTime, 3600) / 60);
seconds = mod(elapsedTime, 60);
fprintf("Done in %d hours, %d minutes, and %f seconds\n", hours, minutes, seconds);
end

