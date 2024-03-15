imfiles = dir("O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\SICEalbedo\*.nc");
% prepare new data
df = array2table(zeros(0,3), 'VariableNames', ...
    {'year', 'albedo_avg', 'albedo_std'});
writetable(df, "O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\SICEalbedo\SICEalbedo.csv", ...
    "WriteRowNames", true, "WriteMode","overwrite");

imdate = string({imfiles.name}.');
imdate = datetime(extractBetween(imdate, "sice_500_", ".nc"), "Format", "uuuu_MM_dd");
[y, m, d] = ymd(imdate);


for i = 2019:1:2023
    index = y == i;
    fprintf("year %d\n", i);
    imfiles_filtered = imfiles(index,:);

    sumA = ncread('O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\SICEalbedo\sice_500_2019_06_01.nc', ...
    "albedo_bb_planar_sw");
    sumA = zeros(size(sumA), "single");
    gapA = sumA; % to count how many pixels are valid in each year
    
    for j = 1:height(imfiles_filtered)
        imfile = fullfile(imfiles_filtered(j).folder, imfiles_filtered(j).name);
        fprintf("processing %s\n", string(imfiles_filtered(j).name));
        A = ncread(imfile, "albedo_bb_planar_sw");
        A(A<=0 | A>=1) = nan;
        gapA = gapA + ~isnan(A);
        A(isnan(A)) = 0;
        sumA = A + sumA;
    end
    
    sumA = sumA ./ gapA;
    sumA(sumA == 0) = nan;

    albedo_avg = mean(sumA, "all", "omitmissing");
    albedo_std = std(sumA(:), "omitmissing");

    df = table;
    df.year = i;
    df.albedo_avg = albedo_avg;
    df.albedo_std = albedo_std;
    writetable(df, "O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\SICEalbedo\SICEalbedo.csv", ...
        "WriteRowNames", false, "WriteMode", "append");
end