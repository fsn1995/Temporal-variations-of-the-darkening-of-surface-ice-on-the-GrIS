function [imgoutput] = func_satimgPreview(dfaws,imgfolder)
% func_satimgPreview: Preview satellite images and time series data
%   func_satimgPreview(dfaws, imgfolder) generates a preview of satellite
%   images and time series data. The function reads the daily AWS data
%   (dfaws) and the folder containing the satellite images (imgfolder) to
%   generate a preview of the satellite images and the AWS data. The
%   function returns the path of the generated image output.
%
%   Shunan Feng (shunan.feng@envs.au.dk)


if isstring(dfaws)
    dfaws = readtable(dfaws);
end
dfaws(dfaws.time<datetime(2019,1,1), :) = [];
% remove exported figure file if it exits already
imgoutput = imgfolder + "\*.pdf";
delete(imgoutput);
% imgoutput = imgfolder + "\satimgPreview.pdf";
% if isfile(imgoutput)
%     delete(imgoutput);
% end
imfiles = dir(imgfolder+ "\**\*.tif");

for i = 1:length(imfiles)
    imfile = fullfile(imfiles(i).folder, imfiles(i).name);
    imdate = datetime(erase(imfiles(i).name, ".tif"));
    imaws  = split(imfiles(i).folder, "\");
    imaws  = string(imaws(5));
    df = table(imaws, imdate);
    dfjoined = innerjoin(df, dfaws, ...
        "LeftKeys",{'imaws', 'imdate'}, "RightKeys", {'aws', 'time'});

    [A, R] = readgeoraster(imfile);
    imalbedo = A(:,:,end);
    if sum(imalbedo, "all", "omitmissing")==0
        fprintf('no valid pixels at %s\n', imaws + '-' + string(imdate));
        continue
    end
    immask = ones(size(imalbedo));
    immask(A(:,:,end) == 0) = nan;
    A = A.*immask;
    imrgb = A(:,:,3:-1:1);
    imrgb(isnan(imrgb)) = 255;
    imalbedo = A(:,:,end);

    f1 = figure();
    f1.Position = [488   242   560   420];
    t = tiledlayout(1,2, "TileSpacing","compact", "Padding","compact");
    ax1 = nexttile;
    mapshow(ax1,imrgb,R, "DisplayType","image");
    scalebarpsn('location', 'se', 'color','#EDB120');
    ax2 = nexttile;
    mapshow(ax2,imalbedo,R,"DisplayType", "surface");
    colormap(ax2, func_dpcolor());
    c = colorbar(ax2);
    c.Label.String = 'albedo';
    clim(ax2, [0, 1]);
    linkaxes([ax1 ax2]);
    xlim(ax1, R.XWorldLimits);
    ylim(ax1, R.YWorldLimits);
    title(t, insertBefore(imaws, "_", "\") + '-' + string(imdate));
    
    imgoutput = imgfolder + "\" + imaws +"_Preview.pdf";
    if isempty(dfjoined)
        fprintf('No aws data matched at %s\n', imaws + '-' + string(imdate));
        exportgraphics(f1, imgoutput, "Append", true, "Resolution", 300);
        close(f1);
        continue
    else
        fprintf('Mapping image and AWS site at %s\n', imaws + '-' + string(imdate));
        [dfjoined.mapx, dfjoined.mapy] = projfwd(R.ProjectedCRS, ...
            dfjoined.gps_lat, dfjoined.gps_lon);
        mapshow(ax1, dfjoined.mapx, dfjoined.mapy, "DisplayType","point", ...
            "Marker","o", "MarkerFaceColor", "k", "MarkerEdgeColor","none");
        mapshow(ax2, dfjoined.mapx, dfjoined.mapy, "DisplayType","point", ...
            "Marker","o", "MarkerFaceColor", "k", "MarkerEdgeColor","none");
        exportgraphics(f1, imgoutput, "Append", true, "Resolution", 300);
        close(f1);
    end
    
end

