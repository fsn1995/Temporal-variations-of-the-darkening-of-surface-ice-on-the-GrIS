function [exporteddata] = func_albedospatial(imfolder)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

imfiles = dir(fullfile(imfolder,'*.tif'));
imdate = string({imfiles.name}.');
imdate = datetime(extractBetween(imdate, "albedo_", ".tif"), ...
    "InputFormat", "uuuu-MM-dd");
[y, ~, ~] = ymd(imdate);

% iterate over years from 2019 to 2023
for i = 2019:1:2023
    index = y == i;
    fprintf("Year: %d\n", i);
    imfiles_filtered = imfiles(index, :);

    [sumA, R] = readgeoraster("/data/shunan/data/GrISdailyAlbedoMosaic/albedo_2019-06-01.tif");
    sumA = zeros(size(sumA), "uint16");
    gapA = sumA; % to count how many pixels are valid in each year
    % bare_count = zeros([size(sumA) height(imfiles_filtered)], "uint16"); % to count how many days are bare ice in each year
    bare_count_pre = sumA;
    bare_count_aft = sumA;

    % iterate over each day in the year
    for j = 1:height(imfiles_filtered)
        imfile = fullfile(imfiles_filtered(j).folder, imfiles_filtered(j).name);
        fprintf("processing %s\n", string(imfiles_filtered(j).name));
        A = readgeoraster(imfile);
        gapA = gapA + uint16(A>0);
        sumA = A + sumA;
        A = (A > 0) & (A < (0.565*10000));
        A = uint16(A).*j;
        index = bare_count_pre == 0;
        bare_count_pre(index) = A(index);
        index = A > bare_count_pre;
        bare_count_aft(index) = A(index);

    end

    albedo_avg = sumA ./ gapA;
    bare_duration = bare_count_aft - bare_count_pre;
    bare_duration(bare_count_pre > 0) = bare_duration(bare_count_pre > 0) +1;
    % bare_duration = max(bare_count(bare_count>0), [], 3,"omitmissing") - ...
    %     min(bare_count(bare_count>0), [], 3, "omitmissing") + 1;
    
    % save the albedo_avg, gapA, bare_duration to a .mat file for each year
    save(fullfile(imfolder, sprintf("albedo_spatial_%d.mat", i)), ...
        "albedo_avg", "gapA", "bare_duration", "R", "-mat", "-v7.3");

end

% return the location of the .mat files
exporteddata = dir(fullfile(imfolder, "albedo_spatial_*.mat"));

end