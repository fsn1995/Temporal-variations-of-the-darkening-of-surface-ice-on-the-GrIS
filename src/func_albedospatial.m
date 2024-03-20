function [exporteddata] = func_albedospatial(imfolder, imsource)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

switch imsource
    case "hsa"
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
            sumA = zeros(size(sumA), "single");
            gapA = zeros(size(sumA), "uint16"); % to count how many pixels are valid in each year
            % bare_count = zeros([size(sumA) height(imfiles_filtered)], "uint16"); % to count how many days are bare ice in each year
            bare_count_pre = gapA;
            bare_count_aft = gapA;

            % iterate over each day in the year
            for j = 1:height(imfiles_filtered)
                imfile = fullfile(imfiles_filtered(j).folder, imfiles_filtered(j).name);
                fprintf("processing %s\n", string(imfiles_filtered(j).name));
                A = readgeoraster(imfile, "OutputType", "single") ./ 10000;
                gapA = gapA + uint16(A>0);
                sumA = A + sumA;
                A = (A > 0) & (A < 0.565);
                A = uint16(A).*j;
                index = bare_count_pre == 0;
                bare_count_pre(index) = A(index);
                index = A > bare_count_pre;
                bare_count_aft(index) = A(index);

            end

            albedo_avg = uint16((sumA ./ single(gapA)) .* 10000);
            bare_duration = bare_count_aft - bare_count_pre;
            bare_duration(bare_count_pre > 0) = bare_duration(bare_count_pre > 0) +1;
            % bare_duration = max(bare_count(bare_count>0), [], 3,"omitmissing") - ...
            %     min(bare_count(bare_count>0), [], 3, "omitmissing") + 1;
            
            % save the albedo_avg, gapA, bare_duration to a .mat file for each year
            save(fullfile(imfolder, sprintf("albedo_spatial_%d.mat", i)), ...
                "albedo_avg", "gapA", "bare_duration", "R", "-mat", "-v7.3");

        end

    case "s3"
        imfiles = dir(fullfile(imfolder,'*.nc'));
        imdate = string({imfiles.name}.');
        imdate = datetime(extractBetween(imdate, "sice_500_", ".nc"), "Format", "uuuu_MM_dd");
        [y, ~, ~] = ymd(imdate);

        % iterate over years from 2019 to 2023
        for i = 2019:1:2023
            index = y == i;
            fprintf("Year: %d\n", i);
            imfiles_filtered = imfiles(index, :);

            sumA = ncread(fullfile(imfiles_filtered(1).folder, imfiles_filtered(1).name), "albedo_bb_planar_sw");
            mapx = ncread(fullfile(imfiles_filtered(1).folder, imfiles_filtered(1).name), "x");
            mapy = ncread(fullfile(imfiles_filtered(1).folder, imfiles_filtered(1).name), "y");
            maplat = ncread(fullfile(imfiles_filtered(1).folder, imfiles_filtered(1).name), "lat");
            maplon = ncread(fullfile(imfiles_filtered(1).folder, imfiles_filtered(1).name), "lon");
            sumA = zeros(size(sumA), "single");
            gapA = zeros(size(sumA), "uint16"); % to count how many pixels are valid in each year
            bare_duration = zeros(size(sumA), "uint16"); % to count how many days are bare ice in each year

            % iterate over each day in the year
            for j = 1:height(imfiles_filtered)
                imfile = fullfile(imfiles_filtered(j).folder, imfiles_filtered(j).name);
                fprintf("processing %s\n", string(imfiles_filtered(j).name));
                A = ncread(imfile, "albedo_bb_planar_sw");
                A(A<=0 | A>=1) = nan;
                gapA = gapA + uint16(A>0);
                sumA = A + sumA;
                bare_duration = bare_duration + uint16(A > 0 & A < 0.565);
            end

            albedo_avg = uint16((sumA ./ single(gapA)) .* 10000);
            
            % save the albedo_avg, gapA, bare_count, coordinates to a .mat file for each year
            save(fullfile(imfolder, sprintf("albedo_spatial_%d.mat", i)), ...
                "albedo_avg", "gapA", "bare_duration", "mapx", "mapy", "maplat", "maplon","-mat");
        end
end
% return the location of the .mat files
exporteddata = dir(fullfile(imfolder, "albedo_spatial_*.mat"));
end