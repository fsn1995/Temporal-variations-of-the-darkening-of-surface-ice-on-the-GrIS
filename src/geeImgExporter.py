# %% [markdown]
'''
This script is used to export images from GEE to local folder or Google Drive.
Exporting to Google Drive is recommended because it is faster and more stable,
but there's a hard limit on the number of tasks you can run per day.
Hence, if you have a large number of images to export, you may want to export the images
to a local folder first. This is the default option. You can change the export option 
by uncommenting the corresponding line in the code below.
Note that export images from GEE to local folder may have a bug that removes land mask. 

Author: Shunan Feng
Email : shunan.feng@envs.au.dk
'''

# %%
import geemap
import ee
import pandas as pd
# import os
import datetime

# %% [markdown]
# # Initialization
print(datetime.datetime.now())
print('Start!\n')
# %% load AWS data and define output folder
df = pd.read_csv("H:\AU\promiceaws\output\AWS_height_station_locations_4gee.csv")
output_folder = "H:\AU\promiceaws\HSA1"
# %% [markdown]
# # GEE

# %%
Map = geemap.Map()
Map

# %% [markdown]
# ## Landsat and Sentinel 

# %%
def addVisnirAlbedo(image):
    albedo = image.expression(
        '0.7963 * Blue + 2.2724 * Green - 3.8252 * Red + 1.4143 * NIR + 0.2053',
        {
            'Blue': image.select('Blue'),
            'Green': image.select('Green'),
            'Red': image.select('Red'),
            'NIR': image.select('NIR')
        }
    ).rename('visnirAlbedo')
    return image.addBands(albedo).copyProperties(image, ['system:time_start'])

rmaCoefficients = {
  'itcpsL7': ee.Image.constant([-0.0084, -0.0065, 0.0022, -0.0768, -0.0314, -0.0022]),
  'slopesL7': ee.Image.constant([1.1017, 1.0840, 1.0610, 1.2100, 1.2039, 1.2402]),
  'itcpsS2': ee.Image.constant([0.0210, 0.0167, 0.0155, -0.0693, -0.0039, -0.0112]),
  'slopesS2': ee.Image.constant([1.0849, 1.0590, 1.0759, 1.1583, 1.0479, 1.0148])
}; #rma

# %%
# Function to get and rename bands of interest from OLI.
def renameOli(img):
  return img.select(
    ['SR_B2', 'SR_B3', 'SR_B4', 'SR_B5', 'SR_B6', 'SR_B7', 'QA_PIXEL', 'QA_RADSAT'],
    ['Blue',  'Green', 'Red',   'NIR',   'SWIR1', 'SWIR2', 'QA_PIXEL', 'QA_RADSAT'])

# Function to get and rename bands of interest from ETM+, TM.
def renameEtm(img):
  return img.select(
    ['SR_B1', 'SR_B2', 'SR_B3', 'SR_B4', 'SR_B5', 'SR_B7', 'QA_PIXEL', 'QA_RADSAT'],
    ['Blue',  'Green', 'Red',   'NIR',   'SWIR1', 'SWIR2', 'QA_PIXEL', 'QA_RADSAT'])

# Function to get and rename bands of interest from Sentinel 2.
def renameS2(img):
  return img.select(
    ['B2',   'B3',    'B4',  'B8',  'B11',   'B12',   'QA60', 'SCL', QA_BAND],
    ['Blue', 'Green', 'Red', 'NIR', 'SWIR1', 'SWIR2', 'QA60', 'SCL', QA_BAND]
  )

def oli2oli(img):
  return img.select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1', 'SWIR2']) \
    .toDouble()

def etm2oli(img):
  return img.select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1', 'SWIR2']) \
    .multiply(rmaCoefficients["slopesL7"]) \
    .add(rmaCoefficients["itcpsL7"]) \
    .toDouble()
    # .round() \
    # .toShort() 
    # .addBands(img.select('pixel_qa'))

def s22oli(img):
  return img.select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1', 'SWIR2']) \
    .multiply(rmaCoefficients["slopesS2"]) \
    .add(rmaCoefficients["itcpsS2"]) \
    .toDouble()
    # .round() \
    # .toShort() # convert to Int16
    # .addBands(img.select('pixel_qa'))

def imRangeFilter(image):
  maskMax = image.lt(1)
  maskMin = image.gt(0)
  return image.updateMask(maskMax).updateMask(maskMin)

'''
Cloud mask for Landsat data based on fmask (QA_PIXEL) and saturation mask 
based on QA_RADSAT.
Cloud mask and saturation mask by sen2cor.
Codes provided by GEE official. '''

# the Landsat 8 Collection 2
def maskL8sr(image):
  # Bit 0 - Fill
  # Bit 1 - Dilated Cloud
  # Bit 2 - Cirrus
  # Bit 3 - Cloud
  # Bit 4 - Cloud Shadow
  qaMask = image.select('QA_PIXEL').bitwiseAnd(int('11111', 2)).eq(0)
  saturationMask = image.select('QA_RADSAT').eq(0)

  # Apply the scaling factors to the appropriate bands.
  # opticalBands = image.select('SR_B.').multiply(0.0000275).add(-0.2)
  # thermalBands = image.select('ST_B.*').multiply(0.00341802).add(149.0)

  # Replace the original bands with the scaled ones and apply the masks.
  #image.addBands(opticalBands, {}, True) \ maybe not available in python api
  return image.select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1', 'SWIR2']).multiply(0.0000275).add(-0.2) \
    .updateMask(qaMask) \
    .updateMask(saturationMask)

  
# the Landsat 4, 5, 7 Collection 2
def maskL457sr(image):
  # Bit 0 - Fill
  # Bit 1 - Dilated Cloud
  # Bit 2 - Unused
  # Bit 3 - Cloud
  # Bit 4 - Cloud Shadow
  qaMask = image.select('QA_PIXEL').bitwiseAnd(int('11111', 2)).eq(0)
  saturationMask = image.select('QA_RADSAT').eq(0)

  # Apply the scaling factors to the appropriate bands.
  # opticalBands = image.select('SR_B.')
  # opticalBands = image.select('SR_B.').multiply(0.0000275).add(-0.2)
  # thermalBand = image.select('ST_B6').multiply(0.00341802).add(149.0)

  # Replace the original bands with the scaled ones and apply the masks.
  return image.select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1', 'SWIR2']).multiply(0.0000275).add(-0.2) \
      .updateMask(qaMask) \
      .updateMask(saturationMask)
 #
 # Function to mask clouds using the Sentinel-2 QA band
 # @param {ee.Image} image Sentinel-2 image
 # @return {ee.Image} cloud masked Sentinel-2 image
 # archived after updating to Cloud Score+
 #
# def maskS2sr(image):
#   qa = image.select('QA60')

#   # Bits 10 and 11 are clouds and cirrus, respectively.
#   cloudBitMask = 1 << 10
#   cirrusBitMask = 1 << 11
#   # Bits 1 is saturated or defective pixel
#   not_saturated = image.select('SCL').neq(1)
#   # Both flags should be set to zero, indicating clear conditions.
#   mask = qa.bitwiseAnd(cloudBitMask).eq(0) \
#       .And(qa.bitwiseAnd(cirrusBitMask).eq(0)) 

#   return image.updateMask(mask).updateMask(not_saturated).divide(10000)

#
# Function to mask clouds using the Cloud Score+
#
# Cloud Score+ image collection. Note Cloud Score+ is produced from Sentinel-2
# Level 1C data and can be applied to either L1C or L2A collections.
csPlus = ee.ImageCollection('GOOGLE/CLOUD_SCORE_PLUS/V1/S2_HARMONIZED')

# Use 'cs' or 'cs_cdf', depending on your use case; see docs for guidance.
QA_BAND = 'cs' # I find'cs' is better than 'cs_cdf' because it is more robust but may mask out more clear pixels though

# The threshold for masking; values between 0.50 and 0.65 generally work well.
# Higher values will remove thin clouds, haze & cirrus shadows.
CLEAR_THRESHOLD = 0.65

def maskS2sr(image):
  # qa = image.select('QA60')

  # # Bits 10 and 11 are clouds and cirrus, respectively.
  # cloudBitMask = 1 << 10
  # cirrusBitMask = 1 << 11
  # Bits 1 is saturated or defective pixel
  not_saturated = image.select('SCL').neq(1)
  # Both flags should be set to zero, indicating clear conditions.
  # mask = qa.bitwiseAnd(cloudBitMask).eq(0) \
  #     .And(qa.bitwiseAnd(cirrusBitMask).eq(0)) 

  return image.updateMask(image.select(QA_BAND).gte(CLEAR_THRESHOLD)).updateMask(not_saturated).divide(10000)
# %%
# Define function to prepare OLI images.
def prepOli(img):
  orig = img
  img = renameOli(img)
  img = maskL8sr(img)
  img = oli2oli(img)
  img = imRangeFilter(img)
  # img = addTotalAlbedo(img)
  img = addVisnirAlbedo(img)
  return ee.Image(img.copyProperties(orig, orig.propertyNames()))

# Define function to prepare ETM+/TM images.
def prepEtm(img):
  orig = img
  img = renameEtm(img)
  img = maskL457sr(img)
  img = etm2oli(img)
  img = imRangeFilter(img)
  # img = addTotalAlbedo(img)
  img = addVisnirAlbedo(img)
  return ee.Image(img.copyProperties(orig, orig.propertyNames()))

# Define function to prepare S2 images.
def prepS2(img):
  orig = img
  img = renameS2(img)
  img = maskS2sr(img)
  img = s22oli(img)
  img = imRangeFilter(img)
  # img = addTotalAlbedo(img)
  img = addVisnirAlbedo(img)
  return ee.Image(img.copyProperties(orig, orig.propertyNames()).set('SATELLITE', 'SENTINEL_2'))


# %%
# https://developers.google.com/earth-engine/tutorials/community/intro-to-python-api-guiattard by https://github.com/guiattard
def ee_array_to_df(arr, list_of_bands):
    """Transforms client-side ee.Image.getRegion array to pandas.DataFrame."""
    df = pd.DataFrame(arr)

    # Rearrange the header.
    headers = df.iloc[0]
    df = pd.DataFrame(df.values[1:], columns=headers)

    # Remove rows without data inside.
    df = df[['longitude', 'latitude', 'time', *list_of_bands]].dropna()

    # Convert the data to numeric values.
    for band in list_of_bands:
        df[band] = pd.to_numeric(df[band], errors='coerce')

    # Convert the time field into a datetime.
    df['datetime'] = pd.to_datetime(df['time'], unit='ms')

    # Keep the columns of interest.
    df = df[['time','datetime',  *list_of_bands]]

    return df

# %%
for i in range(len(df.aws)):
    
    print('The station is: %s \n' %df.aws[i])
    print('date is %d-%d \n' % (df.y[i], df.m[i]))
    # subfolder = os.path.join(output_folder, df.aws[i], str(df.y[i]) + '-' + str(df.m[i]))
    subfolder = df.aws[i] +'-' + str(df.y[i]) + '-' + str(df.m[i])

    poi = ee.Geometry.Point([df.mean_gps_lon[i], df.mean_gps_lat[i]])
    aoi = poi.buffer(2500).bounds() # 5000 is the buffer size in meters
    Map.addLayer(aoi, {}, str(df.y[i]) + '-' + str(df.m[i]))
    date_start = ee.Date.fromYMD(df.y[i].item(), df.m[i].item(), 1)
    date_end =  ee.Date.fromYMD(df.y[i].item(), df.m[i].item() + 1, 1)
    # print(date_start)

    # create filter for image collection
    colFilter = ee.Filter.And(
        ee.Filter.geometry(aoi), # filterbounds not available on python api https://github.com/google/earthengine-api/issues/83
        ee.Filter.date(date_start, date_end)
        # ee.Filter.calendarRange(5, 9, 'month')
        # ee.Filter.lt('CLOUD_COVER', 50)
    )

    s2colFilter =  ee.Filter.And(
        ee.Filter.geometry(aoi), # filterbounds not available on python api https://github.com/google/earthengine-api/issues/83
        ee.Filter.date(date_start, date_end),
        # ee.Filter.calendarRange(5, 9, 'month'),
        ee.Filter.lt('MEAN_SOLAR_ZENITH_ANGLE', 76)
    )

    oliCol = ee.ImageCollection('LANDSAT/LC08/C02/T1_L2') \
                .filter(colFilter) \
                .map(prepOli) \
                .select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1','SWIR2','visnirAlbedo'])
    oli2Col = ee.ImageCollection('LANDSAT/LC09/C02/T1_L2') \
                .filter(colFilter) \
                .map(prepOli) \
                .select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1','SWIR2','visnirAlbedo'])                    
    etmCol = ee.ImageCollection('LANDSAT/LE07/C02/T1_L2') \
                .filter(ee.Filter.calendarRange(1999, 2020, 'year')) \
                .filter(colFilter) \
                .map(prepEtm) \
                .select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1','SWIR2','visnirAlbedo'])
    tmCol = ee.ImageCollection('LANDSAT/LT05/C02/T1_L2') \
                .filter(colFilter) \
                .map(prepEtm) \
                .select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1','SWIR2','visnirAlbedo'])
    tm4Col = ee.ImageCollection('LANDSAT/LT04/C02/T1_L2') \
                .filter(colFilter) \
                .map(prepEtm) \
                .select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1','SWIR2','visnirAlbedo'])
    s2Col = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') \
                .linkCollection(csPlus, [QA_BAND]) \
                .filter(s2colFilter) \
                .map(prepS2) \
                .select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1','SWIR2','visnirAlbedo'])
    # landsatCol = etmCol.merge(tmCol)
    landsatCol = oliCol.merge(etmCol).merge(tmCol).merge(tm4Col).merge(oli2Col)
    multiSat = landsatCol.merge(s2Col).sort('system:time_start', True) # // Sort chronologically in descending order.

    # Difference in days between start and finish
    diff = date_end.difference(date_start, 'day')
    # Make a list of all dates
    dayNum = 1
    range = ee.List.sequence(0, diff.subtract(1), dayNum).map(lambda day: date_start.advance(day, 'day'))

    def day_mosaics(date, newlist):
        # Cast
        date = ee.Date(date)
        newlist = ee.List(newlist)

        # Filter collection between date and the next timestep (here is one day)
        filtered = multiSat.filterDate(date, date.advance(1, 'day'))
        
        # Make the mosaic
        image = ee.Image(
          filtered.mean().copyProperties(filtered.first())) \
          .set({'date': date.format('yyyy-MM-dd')}) \
          .set('system:index', date.format('yyyy-MM-dd')) \
          .set('system:time_start', filtered.first().get('system:time_start'))
        return ee.List(ee.Algorithms.If(filtered.size(), newlist.add(image), newlist))
    # mask the image collection of albedo by the ice mask
    greenlandmask = ee.Image('OSU/GIMP/2000_ICE_OCEAN_MASK') \
                   .select('ice_mask').eq(1) #'ice_mask', 'ocean_mask'
    # greenlandmask = ee.Image('OSU/GIMP/2000_ICE_OCEAN_MASK') \
    #                .select('ice_mask') #'ice_mask', 'ocean_mask'
    # glimsmask = ee.Image().paint(ee.FeatureCollection('GLIMS/current'), 1)
    # iceMask = ee.ImageCollection([
    #    greenlandmask,
    #    glimsmask.rename('ice_mask')
    # ]).mosaic().eq(1)

    def applyIceMask(image):
        return image.updateMask(greenlandmask)
    hsaDayCol = ee.ImageCollection(ee.List(range.iterate(day_mosaics, ee.List([])))).map(applyIceMask)
    # if multiSat.size().getInfo()==0:
    #     continue
    
    geemap.ee_export_image_collection(
        hsaDayCol, 
        out_dir = subfolder, 
        scale = 30, 
        crs = 'EPSG:3411', 
        region = aoi, 
        file_per_band = False
    )
    # geemap.ee_export_image_collection_to_drive(
    #     hsaDayCol, 
    #     folder=subfolder,
    #     scale = 30, 
    #     crs = 'EPSG:3411', 
    #     region = aoi
    # )
print(datetime.datetime.now())
print('Done!\n')
# %%