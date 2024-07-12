#%% load packages
import xarray as xr
import numpy as np
import pandas as pd
import glob
# %%
def add_time_dim(xda):
    img_name = xda.encoding["source"]
    img_datetime = img_name.replace("sice_500_", "").replace(".nc", "")
    img_datetime = img_datetime.split("/")[-1]
    # dt = datetime.strptime(img_datetime, "%Y-%m-%d")
    dt = pd.to_datetime(img_datetime, format="%Y_%m_%d")

    xda = xda.expand_dims(time=[dt])
    return xda

images = sorted(glob.glob("/data/shunan/data/SICEdata/*.nc"))
images_year = [image.replace("sice_500_", "").replace(".nc", "") for image in images]
images_year = [image.split("/")[-1] for image in images_year]
images_year = [image.split("_")[0] for image in images_year]
images_year = np.uint16(images_year).T

# %% iterate over years and calculate the average albedo and standard deviation

for y in range(2019, 2024):
    print("Processing year: ", y)
    index = images_year.astype(int) == y
    images_filtered = np.array(images)[index]
    datacube = xr.open_mfdataset(list(images_filtered), preprocess=add_time_dim, parallel=True, chunks="auto", data_vars="minimal")
    datacube = datacube.albedo_bb_planar_sw

    # filter invalid values <=0 or >=1
    datacube = datacube.where((datacube > 0) & (datacube < 1), other=np.nan)

    # calculate the average albedo and standard deviation
    albedo_mean = datacube.mean().values
    albedo_std  = datacube.std().values
    df = pd.DataFrame({"albedo_mean": albedo_mean, "albedo_std": albedo_std, "year": y}, index=[0])  # Add index=[0]
    if y == 2019:
        df.to_csv("/data/shunan/data/SICEdata/SICEalbedo.csv", 
                  index=False, header=True, mode="w")
    else:
        df.to_csv("/data/shunan/data/SICEdata/SICEalbedo.csv", 
                  index=False, header=False, mode="a")
