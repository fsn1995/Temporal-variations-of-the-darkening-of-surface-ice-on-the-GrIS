#%% load the required libraries
import glob
import xarray as xr
import numpy as np
import pandas as pd
import time

# Start the timer
start_time = time.time()
#%% Load the geotiff data as a time series xarray dataset
def add_time_dim(xda):
    img_name = xda.encoding["source"]
    img_datetime = img_name[:len(img_name)-26]
    img_datetime = img_datetime.split("/")[-1]
    img_datetime = img_datetime.split("_")[1]
    # dt = datetime.strptime(img_datetime, "%Y-%m-%d")
    dt = pd.to_datetime(img_datetime, format="%Y-%m-%d")

    xda = xda.expand_dims(time = [dt])
    return xda

# images = sorted(glob.glob("/data/shunan/data/GrISdailyAlbedoChipYear/2019/*-0000000000-0000000000.tif"))
# datacube = xr.open_mfdataset(images, preprocess=add_time_dim, parallel=True, chunks="auto")
# # convert the datacube from uint16 to float32 and divide by 10000, and set invalid values to nan
# datacube = datacube.astype(np.float32) / 10000
# datacube = datacube.where(datacube != 0, other=np.nan)
# datacube = datacube.where(datacube  < 1, other=np.nan)

# # %% counting
# # count the number of nan values in the datacube along the time dimension
# datacube_nan_count = datacube.isnull().sum(dim="time").astype(np.uint16)
# datacube_nan_count.to_netcdf("/data/shunan/data/GrISdailyAlbedoGap/GrISdailyAlbedoGap_2019-0000000000-0000000000.nc")


# # Define the batch size
# batch_size = 47  # Adjust this value based on your memory capacity

# # Interpolate in smaller batches
# for i in range(0, len(datacube.time), batch_size):
#     datacube_chunk = datacube.isel(time=slice(i, i + batch_size))
#     datacube_chunk = datacube_chunk.chunk(dict(time=-1))  # Rechunk the smaller datacube
#     datacube_chunk = datacube_chunk.interpolate_na(dim="time", method="linear")
#     if i == 0:
#         datacube_interpolated = datacube_chunk
#     else:
#         datacube_interpolated = xr.concat([datacube_interpolated, datacube_chunk], dim="time")

# # Replace the original datacube with the interpolated one
# datacube = datacube_interpolated
# # Delete datacube_interpolated
# del datacube_interpolated

# # interpolate to fill nan in the datacube 
# # datacube = datacube.interpolate_na(dim="time", method="linear")

# # rechunk the datacube back to its original chunking
# # datacube = datacube.chunk(dict(time="auto"))

# # count the number of pixels with values >0 but <0.565
# datacube_nan_count = datacube.where((datacube > 0) & (datacube < 0.565)).count(dim="time")
# datacube_nan_count = datacube_nan_count.astype(np.uint16)
# datacube_nan_count.to_netcdf("/data/shunan/data/GrISdailyBareIceDuration/GrISdailyDuration_2019-0000000000-0000000000.nc")
# # calculate the mean of the datacube
# data_mean = datacube.mean(dim="time")*10000
# data_mean = data_mean.astype(np.uint16)
# # data_mean.band_data.plot()
# data_mean.to_netcdf("/data/shunan/data/GrISdailyAlbedoMean/GrISdailyAlbedoMean_2019-0000000000-0000000000.nc.nc")

#%% for loop for all years from 2019 to 2023
years = range(2019, 2024)
for year in years:
    images = sorted(glob.glob(f"/data/shunan/data/GrISdailyAlbedoChipYear/{year}/*-0000000000-0000000000.tif"))
    datacube = xr.open_mfdataset(images, preprocess=add_time_dim, parallel=True, chunks="auto")
    # convert the datacube from uint16 to float32 and divide by 10000, and set invalid values to nan
    datacube = datacube.astype(np.float32) / 10000
    datacube = datacube.where(datacube != 0, other=np.nan)
    datacube = datacube.where(datacube  < 1, other=np.nan)

    # count the number of nan values in the datacube along the time dimension
    datacube_nan_count = datacube.isnull().sum(dim="time").astype(np.uint16)
    datacube_nan_count.to_netcdf(f"/data/shunan/data/GrISdailyAlbedoGap/GrISdailyAlbedoGap_{year}-0000000000-0000000000.nc")

    # Define the batch size
    batch_size = 46  # Adjust this value based on your memory capacity

    # Interpolate in smaller batches
    for i in range(0, len(datacube.time), batch_size):
        datacube_chunk = datacube.isel(time=slice(i, i + batch_size))
        datacube_chunk = datacube_chunk.chunk(dict(time=-1))  # Rechunk the smaller datacube
        datacube_chunk = datacube_chunk.interpolate_na(dim="time", method="linear")
        if i == 0:
            datacube_interpolated = datacube_chunk
        else:
            datacube_interpolated = xr.concat([datacube_interpolated, datacube_chunk], dim="time")

    # Replace the original datacube with the interpolated one
    datacube = datacube_interpolated
    # Delete datacube_interpolated
    del datacube_interpolated

    # interpolate to fill nan in the datacube 
    # datacube = datacube.interpolate_na(dim="time", method="linear")

    # rechunk the datacube back to its original chunking
    # datacube = datacube.chunk(dict(time="auto"))

    # count the number of pixels with values >0 but <0.565
    datacube_nan_count = datacube.where((datacube > 0) & (datacube < 0.565)).count(dim="time")
    datacube_nan_count = datacube_nan_count.astype(np.uint16)
    datacube_nan_count.to_netcdf(f"/data/shunan/data/GrISdailyBareIceDuration/GrISdailyDuration_{year}-0000000000-0000000000.nc")
    # calculate the mean
    data_mean = datacube.mean(dim="time")*10000
    data_mean = data_mean.astype(np.uint16)
    # data_mean.band_data.plot()
    data_mean.to_netcdf(f"/data/shunan/data/GrISdailyAlbedoMean/GrISdailyAlbedoMean_{year}-0000000000-0000000000.nc")
    print(f"year {year} is done")


# Stop the timer
end_time = time.time()
# Calculate the elapsed time
elapsed_time = end_time - start_time
# Convert the elapsed time into hours, minutes, and seconds
hours, remainder = divmod(elapsed_time, 3600)
minutes, seconds = divmod(remainder, 60)

print(f"The script took {int(hours)} hours, {int(minutes)} minutes, and {seconds:.2f} seconds to run.")