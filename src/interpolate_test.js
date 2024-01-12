/*
This tutorial is made to demonstrate the workflow of harmonizing Landsat 4-7 and Sentinel 2 to Landsat 8 
time series of datasets.
It will display the charts of the harmonized satellite albedo (All Observations) and original albedo 
(All Observations Original).
The linear trendline will be plotted on a separate chart. 

ref:
This script is adapted from the excellent tutorial made by Justin Braaten.
https://github.com/jdbcode
https://developers.google.com/earth-engine/tutorials/community/landsat-etm-to-oli-harmonization

Shunan Feng
shunan.feng@envs.au.dk
*/

/**
 * Intial parameters
 */

var date_start = ee.Date.fromYMD(2019, 1, 1);
var date_end = ee.Date(Date.now());

// var aoi = ee.Geometry.Point([-49.3476433532785, 67.0775206116519]);
var aoi = ee.Geometry.Point([-48.8355, 67.0670]); // change your coordinate here

// Display AOI on the map.
Map.centerObject(aoi, 4);
Map.addLayer(aoi, {color: 'f8766d'}, 'AOI');
Map.setOptions('HYBRID');


/*
prepare harmonized satellite data
*/

// Function to get and rename bands of interest from OLI.
function renameOli(img) {
  return img.select(
    ['SR_B2', 'SR_B3', 'SR_B4', 'SR_B5', 'SR_B6', 'SR_B7', 'QA_PIXEL', 'QA_RADSAT'], // 'QA_PIXEL', 'QA_RADSAT'
    ['Blue',  'Green', 'Red',   'NIR',   'SWIR1', 'SWIR2', 'QA_PIXEL', 'QA_RADSAT']);//'QA_PIXEL', 'QA_RADSAT';
}
// Function to get and rename bands of interest from ETM+, TM.
function renameEtm(img) {
  return img.select(
    ['SR_B1', 'SR_B2', 'SR_B3', 'SR_B4', 'SR_B5', 'SR_B7', 'QA_PIXEL', 'QA_RADSAT'], //#,   'QA_PIXEL', 'QA_RADSAT'
    ['Blue',  'Green', 'Red',   'NIR',   'SWIR1', 'SWIR2', 'QA_PIXEL', 'QA_RADSAT']); // #, 'QA_PIXEL', 'QA_RADSAT'
}
// Function to get and rename bands of interest from Sentinel 2.
function renameS2(img) {
  return img.select(
    ['B2',   'B3',    'B4',  'B8',  'B11',   'B12',   'QA60', 'SCL', QA_BAND],
    ['Blue', 'Green', 'Red', 'NIR', 'SWIR1', 'SWIR2', 'QA60', 'SCL', QA_BAND]
  );
}

/* RMA transformation */
var rmaCoefficients = {
  itcpsL7: ee.Image.constant([-0.0084, -0.0065, 0.0022, -0.0768, -0.0314, -0.0022]),
  slopesL7: ee.Image.constant([1.1017, 1.0840, 1.0610, 1.2100, 1.2039, 1.2402]),
  itcpsS2: ee.Image.constant([0.0210, 0.0167, 0.0155, -0.0693, -0.0039, -0.0112]),
  slopesS2: ee.Image.constant([1.0849, 1.0590, 1.0759, 1.1583, 1.0479, 1.0148])
}; // #rma

function oli2oli(img) {
  return img.select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1', 'SWIR2'])
            .toFloat();
}

function etm2oli(img) {
  return img.select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1', 'SWIR2'])
    .multiply(rmaCoefficients.slopesL7)
    .add(rmaCoefficients.itcpsL7)
    .toFloat();
}
function s22oli(img) {
  return img.select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1', 'SWIR2'])
    .multiply(rmaCoefficients.slopesS2)
    .add(rmaCoefficients.itcpsS2)
    .toFloat();
}

function imRangeFilter(image) {
  var maskMax = image.lte(1);
  var maskMin = image.gt(0);
  return image.updateMask(maskMax).updateMask(maskMin);
}


/* 
Cloud mask for Landsat data based on fmask (QA_PIXEL) and saturation mask 
based on QA_RADSAT.
Cloud mask and saturation mask by sen2cor.
Codes provided by GEE official.
*/

// This example demonstrates the use of the Landsat 8 Collection 2, Level 2
// QA_PIXEL band (CFMask) to mask unwanted pixels.

function maskL8sr(image) {
  // Bit 0 - Fill
  // Bit 1 - Dilated Cloud
  // Bit 2 - Cirrus
  // Bit 3 - Cloud
  // Bit 4 - Cloud Shadow
  var qaMask = image.select('QA_PIXEL').bitwiseAnd(parseInt('11111', 2)).eq(0);
  var saturationMask = image.select('QA_RADSAT').eq(0);

  // Apply the scaling factors to the appropriate bands.
  // var opticalBands = image.select(['Blue', 'Green', 'Red', 'NIR']).multiply(0.0000275).add(-0.2);
  // var thermalBands = image.select('ST_B.*').multiply(0.00341802).add(149.0);

  // Replace the original bands with the scaled ones and apply the masks.
  return image.select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1','SWIR2']).multiply(0.0000275).add(-0.2)
      // .addBands(thermalBands, null, true)
      .updateMask(qaMask)
      .updateMask(saturationMask);
}

// This example demonstrates the use of the Landsat 4, 5, 7 Collection 2,
// Level 2 QA_PIXEL band (CFMask) to mask unwanted pixels.

function maskL457sr(image) {
  // Bit 0 - Fill
  // Bit 1 - Dilated Cloud
  // Bit 2 - Unused
  // Bit 3 - Cloud
  // Bit 4 - Cloud Shadow
  var qaMask = image.select('QA_PIXEL').bitwiseAnd(parseInt('11111', 2)).eq(0);
  var saturationMask = image.select('QA_RADSAT').eq(0);

  // Apply the scaling factors to the appropriate bands.
  // var opticalBands = image.select('SR_B.').multiply(0.0000275).add(-0.2);
  // var thermalBand = image.select('ST_B6').multiply(0.00341802).add(149.0);

  // Replace the original bands with the scaled ones and apply the masks.
  return image.select(['Blue', 'Green', 'Red', 'NIR', 'SWIR1','SWIR2']).multiply(0.0000275).add(-0.2)
      // .addBands(thermalBand, null, true)
      .updateMask(qaMask)
      .updateMask(saturationMask);
}


/**
 * Function to mask clouds using the Sentinel-2 QA band
 * @param {ee.Image} image Sentinel-2 image
 * @return {ee.Image} cloud masked Sentinel-2 image
 * archived after updating to Cloud Score+
 */
// function maskS2sr(image) {
//   var qa = image.select('QA60');

//   // Bits 10 and 11 are clouds and cirrus, respectively.
//   var cloudBitMask = 1 << 10;
//   var cirrusBitMask = 1 << 11;
//   // 1 is saturated or defective pixel
//   var not_saturated = image.select('SCL').neq(1);
//   // Both flags should be set to zero, indicating clear conditions.
//   var mask = qa.bitwiseAnd(cloudBitMask).eq(0)
//       .and(qa.bitwiseAnd(cirrusBitMask).eq(0));

//   // return image.updateMask(mask).updateMask(not_saturated);
//   return image.updateMask(mask).updateMask(not_saturated).divide(10000);
// }

/**
 * Function to mask clouds using the Cloud Score+
 */
// Cloud Score+ image collection. Note Cloud Score+ is produced from Sentinel-2
// Level 1C data and can be applied to either L1C or L2A collections.
var csPlus = ee.ImageCollection('GOOGLE/CLOUD_SCORE_PLUS/V1/S2_HARMONIZED');

// Use 'cs' or 'cs_cdf', depending on your use case; see docs for guidance.
var QA_BAND = 'cs'; // I find'cs' is better than 'cs_cdf' because it is more robust but may mask out more clear pixels though

// The threshold for masking; values between 0.50 and 0.65 generally work well.
// Higher values will remove thin clouds, haze & cirrus shadows.
var CLEAR_THRESHOLD = 0.65;

function maskS2sr(image) {
  // 1 is saturated or defective pixel
  var not_saturated = image.select('SCL').neq(1);
  return image.updateMask(image.select(QA_BAND).gte(CLEAR_THRESHOLD))
              .updateMask(not_saturated)
              .divide(10000);
}

// // narrow to broadband conversion
function addVisnirAlbedo(image) {
  var albedo = image.expression(
    '0.7963 * Blue + 2.2724 * Green - 3.8252 * Red + 1.4143 * NIR + 0.2053',
    {
      'Blue': image.select('Blue'),
      'Green': image.select('Green'),
      'Red': image.select('Red'),
      'NIR': image.select('NIR')
    }
  ).rename('visnirAlbedo');
  return image.addBands(albedo).copyProperties(image, ['system:time_start']);
}
// function addNDSI(image) {
//   // var indice = image.normalizedDifference(['Green', 'SWIR1']).rename('NDSI');
//     return image.normalizedDifference(['Green', 'SWIR1']).rename('NDSI');
//   }

/* get harmonized image collection */

// Define function to prepare OLI2 images.
function prepOli2(img) {
  var orig = img;
  img = renameOli(img);
  img = maskL8sr(img);
  img = oli2oli(img);
  img = imRangeFilter(img);
  img = addVisnirAlbedo(img);
  return ee.Image(img.copyProperties(orig, orig.propertyNames()).set('SATELLITE', 'LANDSAT_9'));
}
// Define function to prepare OLI images.
function prepOli(img) {
  var orig = img;
  img = renameOli(img);
  img = maskL8sr(img);
  img = oli2oli(img);
  img = imRangeFilter(img);
  img = addVisnirAlbedo(img);
  return ee.Image(img.copyProperties(orig, orig.propertyNames()).set('SATELLITE', 'LANDSAT_8'));
}
// Define function to prepare ETM+ images.
function prepEtm(img) {
  var orig = img;
  img = renameEtm(img);
  img = maskL457sr(img);
  img = etm2oli(img);
  img = imRangeFilter(img);
  img = addVisnirAlbedo(img);
  return ee.Image(img.copyProperties(orig, orig.propertyNames()).set('SATELLITE', 'LANDSAT_7'));
}
// Define function to prepare TM images.
function prepTm(img) {
  var orig = img;
  img = renameEtm(img);
  img = maskL457sr(img);
  img = etm2oli(img);
  img = imRangeFilter(img);
  img = addVisnirAlbedo(img);
  return ee.Image(img.copyProperties(orig, orig.propertyNames()).set('SATELLITE', 'LANDSAT_4/5'));
}
// Define function to prepare S2 images.
function prepS2(img) {
  var orig = img;
  img = renameS2(img);
  img = maskS2sr(img);
  img = s22oli(img);
  img = imRangeFilter(img);
  img = addVisnirAlbedo(img);
  return ee.Image(img.copyProperties(orig, orig.propertyNames()).set('SATELLITE', 'SENTINEL_2'));
}


var colFilter = ee.Filter.and(
  ee.Filter.bounds(aoi),
  ee.Filter.date(date_start, date_end),
  ee.Filter.calendarRange(6, 8, 'month')
);

var s2colFilter =  ee.Filter.and(
  ee.Filter.bounds(aoi),
  ee.Filter.date(date_start, date_end),
  ee.Filter.calendarRange(6, 8, 'month')
  // ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 50)
);

var oli2Col = ee.ImageCollection('LANDSAT/LC09/C02/T1_L2') 
              .filter(colFilter) 
              .map(prepOli2)
              .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo'])
var oliCol = ee.ImageCollection('LANDSAT/LC08/C02/T1_L2') 
              .filter(colFilter) 
              .map(prepOli)
              .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo'])
var etmCol = ee.ImageCollection('LANDSAT/LE07/C02/T1_L2') 
            .filter(colFilter) 
            .filter(ee.Filter.calendarRange(1999, 2020, 'year')) // filter out L7 imagaes acquired after 2020 due to orbit drift
            .map(prepEtm)
            .select(['visnirAlbedo']); // # .select(['totalAlbedo']) or  .select(['visnirAlbedo'])
var tmCol = ee.ImageCollection('LANDSAT/LT05/C02/T1_L2') 
            .filter(colFilter) 
            .map(prepTm)
            .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo'])
var tm4Col = ee.ImageCollection('LANDSAT/LT04/C02/T1_L2') 
            .filter(colFilter) 
            .map(prepTm)
            .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo'])
var s2Col = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') 
            .linkCollection(csPlus, [QA_BAND])
            .filter(s2colFilter) 
            .map(prepS2)
            .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo'])

var landsatCol = oliCol.merge(etmCol).merge(tmCol).merge(tm4Col).merge(oli2Col);
var multiSat = landsatCol.merge(s2Col).sort('system:time_start', true); // Sort chronologically in descending order.
  
// prepare the chart of harmonized satellite albedo
var allObs = multiSat.map(function(img) {
  var obs = img.reduceRegion(
      {geometry: aoi, 
      reducer: ee.Reducer.mean(), 
      scale: 30});
  return img.set('visnirAlbedo', obs.get('visnirAlbedo'));
});

var allObsValid = allObs.filter(ee.Filter.lt('visnirAlbedo', 1));
var chartAllObs =
  ui.Chart.feature.groups(allObsValid, 'system:time_start', 'visnirAlbedo', 'SATELLITE')
      .setChartType('ScatterChart')
      // .setSeriesNames(['TM', 'ETM+', 'OLI', 'S2'])
      .setOptions({
        title: 'All Harmonized Observations',
        colors: ['f8766d', '00ba38', '619cff', '8934eb', 'cf513e'],
        hAxis: {title: 'Date'},
        vAxis: {title: 'visnirAlbedo', viewWindow: {min: 0, max: 1}},
        pointSize: 6,
        dataOpacity: 0.5
      });
print(chartAllObs);


// Prepare a regularly-spaced Time-Series

// Generate an empty multi-band image matching the bands
// in the original collection
var bandNames = ee.Image(multiSat.first()).bandNames();
var numBands = bandNames.size();
var initBands = ee.List.repeat(ee.Image(), numBands);
var initImage = ee.ImageCollection(initBands).toBands().rename(bandNames)

// Select the interval. We will have 1 image every n days
var n = 1;
var firstImage = ee.Image(multiSat.sort('system:time_start').first())
var lastImage = ee.Image(multiSat.sort('system:time_start', false).first())
var timeStart = ee.Date(firstImage.get('system:time_start'))
var timeEnd = ee.Date(lastImage.get('system:time_start'))

var totalDays = timeEnd.difference(timeStart, 'day');
var daysToInterpolate = ee.List.sequence(0, totalDays, n)

var initImages = daysToInterpolate.map(function(day) {
  var image = initImage.set({
    'system:index': ee.Number(day).format('%d'),
    'system:time_start': timeStart.advance(day, 'day').millis(),
    // Set a property so we can identify interpolated images
    'type': 'interpolated'
  })
  return image
})

var initCol = ee.ImageCollection.fromImages(initImages)
print('Empty Collection', initCol)

// Merge original and empty collections
var multiSat = multiSat.merge(initCol)

// Interpolation

// Add a band containing timestamp to each image
// This will be used to do pixel-wise interpolation later
var multiSat = multiSat.map(function(image) {
  var timeImage = image.metadata('system:time_start').rename('timestamp')
  // The time image doesn't have a mask. 
  // We set the mask of the time band to be the same as the first band of the image
  var timeImageMasked = timeImage.updateMask(image.mask().select(0))
  return image.addBands(timeImageMasked).toFloat();
})

// For each image in the collection, we need to find all images
// before and after the specified time-window

// This is accomplished using Joins
// We need to do 2 joins
// Join 1: Join the collection with itself to find all images before each image
// Join 2: Join the collection with itself to find all images after each image

// We first define the filters needed for the join

// Define a maxDifference filter to find all images within the specified days
// The filter needs the time difference in milliseconds
// Convert days to milliseconds

// Specify the time-window to look for unmasked pixel
var days = 45;
var millis = ee.Number(days).multiply(1000*60*60*24)

var maxDiffFilter = ee.Filter.maxDifference({
  difference: millis,
  leftField: 'system:time_start',
  rightField: 'system:time_start'
})

// We need a lessThanOrEquals filter to find all images after a given image
// This will compare the given image's timestamp against other images' timestamps
var lessEqFilter = ee.Filter.lessThanOrEquals({
  leftField: 'system:time_start',
  rightField: 'system:time_start'
})

// We need a greaterThanOrEquals filter to find all images before a given image
// This will compare the given image's timestamp against other images' timestamps
var greaterEqFilter = ee.Filter.greaterThanOrEquals({
  leftField: 'system:time_start',
  rightField: 'system:time_start'
})


// Apply the joins

// For the first join, we need to match all images that are after the given image.
// To do this we need to match 2 conditions
// 1. The resulting images must be within the specified time-window of target image
// 2. The target image's timestamp must be lesser than the timestamp of resulting images
// Combine two filters to match both these conditions
var filter1 = ee.Filter.and(maxDiffFilter, lessEqFilter)
// This join will find all images after, sorted in descending order
// This will gives us images so that closest is last
var join1 = ee.Join.saveAll({
  matchesKey: 'after',
  ordering: 'system:time_start',
  ascending: false})
  
var join1Result = join1.apply({
  primary: multiSat,
  secondary: multiSat,
  condition: filter1
})
// Each image now as a property called 'after' containing
// all images that come after it within the time-window
print(join1Result.first())

// Do the second join now to match all images within the time-window
// that come before each image
var filter2 = ee.Filter.and(maxDiffFilter, greaterEqFilter)
// This join will find all images before, sorted in ascending order
// This will gives us images so that closest is last
var join2 = ee.Join.saveAll({
  matchesKey: 'before',
  ordering: 'system:time_start',
  ascending: true})
  
var join2Result = join2.apply({
  primary: join1Result,
  secondary: join1Result,
  condition: filter2
})

// Each image now as a property called 'before' containing
// all images that come after it within the time-window
print(join2Result.first())

var joinedCol = join2Result;

// Do the interpolation

// We now write a function that will be used to interpolate all images
// This function takes an image and replaces the masked pixels
// with the interpolated value from before and after images.

var interpolateImages = function(image) {
  var image = ee.Image(image);
  // We get the list of before and after images from the image property
  // Mosaic the images so we a before and after image with the closest unmasked pixel
  var beforeImages = ee.List(image.get('before'))
  var beforeMosaic = ee.ImageCollection.fromImages(beforeImages).mosaic()
  var afterImages = ee.List(image.get('after'))
  var afterMosaic = ee.ImageCollection.fromImages(afterImages).mosaic()

  // Interpolation formula
  // y = y1 + (y2-y1)*((t – t1) / (t2 – t1))
  // y = interpolated image
  // y1 = before image
  // y2 = after image
  // t = interpolation timestamp
  // t1 = before image timestamp
  // t2 = after image timestamp
  
  // We first compute the ratio (t – t1) / (t2 – t1)

  // Get image with before and after times
  var t1 = beforeMosaic.select('timestamp').rename('t1')
  var t2 = afterMosaic.select('timestamp').rename('t2')

  var t = image.metadata('system:time_start').rename('t')

  var timeImage = ee.Image.cat([t1, t2, t])

  var timeRatio = timeImage.expression('(t - t1) / (t2 - t1)', {
    't': timeImage.select('t'),
    't1': timeImage.select('t1'),
    't2': timeImage.select('t2'),
  })
  // You can replace timeRatio with a constant value 0.5
  // if you wanted a simple average
  
  // Compute an image with the interpolated image y
  var interpolated = beforeMosaic
    .add((afterMosaic.subtract(beforeMosaic).multiply(timeRatio)))
  // Replace the masked pixels in the current image with the average value
  var result = image.unmask(interpolated)
  return result.copyProperties(image, ['system:time_start'])
}

// map() the function to interpolate all images in the collection
var interpolatedCol = ee.ImageCollection(joinedCol.map(interpolateImages))

// Once the interpolation are done, remove original images
// We keep only the generated interpolated images
var regularCol = interpolatedCol.filter(ee.Filter.eq('type', 'interpolated'))


// Display a time-series chart
var chart = ui.Chart.image.series({
  imageCollection: regularCol.select('visnirAlbedo'),
  region: aoi,
  reducer: ee.Reducer.mean(),
  scale: 30
}).setOptions({
      title: 'Regular NDVI Time Series',
      interpolateNulls: false,
      vAxis: {title: 'HSA', viewWindow: {min: 0, max: 1}},
      hAxis: {title: '', format: 'YYYY-MM'},
      lineWidth: 1,
      pointSize: 4,
      series: {
        0: {color: '#238b45'},
      },
    })
print(chart);