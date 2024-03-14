geusurl = webread("https://dataverse.geus.dk/api/datasets/39088/dirindex/?version=4.0");
url_subfolder = regexp(geusurl, '"/.*?"','match');
parfor i=401:numel(url_subfolder)
    imurl = strip(url_subfolder(i), "both", '"');
    imurl = "https://dataverse.geus.dk" + imurl;
    imurl_subfolder = webread(imurl);

    imname = regexp(imurl_subfolder, 'sice_.*?.nc', 'match');
    if numel(imname) > 1
        imname = imname(1);
        imdate = erase(imname, "sice_500_");
        imdate = extractBetween(imdate, 1,10);
        fprintf("%s has multiple files\n", string(imdate));
    else
        imdate = extractBetween(imname, "sice_500_", ".nc");
    end
    % 
    % imdate = erase(imname, "sice_500_");
    % imdate = erase(imdate, ".nc");
    imdate = datetime(imdate, "Format", "uuuu_MM_dd");
    [y, m, d] = ymd(imdate);
    if imdate < datetime(2019,6,1)
        fprintf("%s beyond time of interest, skip \n", imdate);
        continue
    elseif m<6 || m>8
        fprintf("%s beyond time of interest, skip \n", imdate);
        continue
    end
    
    imurl = regexp(imurl_subfolder, '"/.*?"','match');
    imurl = "https://dataverse.geus.dk" + strip(imurl, "both", '"');
    
    websave( "O:\Tech_ENVS-EMBI-Afdelingsdrev\Shunan\paper6temporal\SICEalbedo\" + imname, imurl);
    fprintf("%s downloaded \n", string(imname));
end