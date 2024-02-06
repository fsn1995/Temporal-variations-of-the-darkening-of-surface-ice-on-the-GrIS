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

var yearOfInterest = 2019; // year of interest

var date_start = ee.Date.fromYMD(yearOfInterest, 6, 1);
var date_end = ee.Date.fromYMD(yearOfInterest, 9, 1);

var roi = 'GrIS'; // region of interest
// var GrISRegion = ee.FeatureCollection("projects/ee-deeppurple/assets/GrISRegion");
// var aoi = GrISRegion.filter(ee.Filter.eq('SUBREGION1', roi)); // Greenland
var aoi = /* color: #ffc82d */ee.Geometry.Polygon(
  [[[-36.29516924635421, 83.70737243835941],
    [-51.85180987135421, 82.75597137647488],
    [-61.43188799635421, 81.99879137488564],
    [-74.08813799635422, 78.10103528196419],
    [-70.13305987135422, 75.65372336709613],
    [-61.08032549635421, 75.71891096312955],
    [-52.20337237135421, 60.9795530382023],
    [-43.41430987135421, 58.59235996703347],
    [-38.49243487135421, 64.70478286561182],
    [-19.771731746354217, 69.72271161037442],
    [-15.728762996354217, 76.0828635948066],
    [-15.904544246354217, 79.45091003031243],
    [-10.015872371354217, 81.62328742628017],
    [-26.627200496354217, 83.43179828852398],
    [-31.636966121354217, 83.7553561747887]]]); // whole greenland

// Display AOI on the map.
Map.centerObject(aoi, 4);
Map.addLayer(aoi, {color: 'f8766d'}, 'AOI');
Map.setOptions('HYBRID');

var greenlandmask = ee.Image('OSU/GIMP/2000_ICE_OCEAN_MASK')
                      .select('ice_mask').eq(1); //'ice_mask', 'ocean_mask'
var elevation = ee.Image('OSU/GIMP/DEM').select('elevation').updateMask(greenlandmask);
var iceMask = elevation.lt(2000); // ice mask is defined as elevation < 2000 m and ice mask = 1
/*
prepare harmonized satellite data
*/

// Function to get and rename bands of interest from OLI.
function renameOli(img) {
  return img.select(
    ['SR_B2', 'SR_B3', 'SR_B4', 'SR_B5', 'QA_PIXEL', 'QA_RADSAT'], // 'QA_PIXEL', 'QA_RADSAT'
    ['Blue',  'Green', 'Red',   'NIR',   'QA_PIXEL', 'QA_RADSAT']);//'QA_PIXEL', 'QA_RADSAT';
}
// Function to get and rename bands of interest from ETM+, TM.
function renameEtm(img) {
  return img.select(
    ['SR_B1', 'SR_B2', 'SR_B3', 'SR_B4', 'QA_PIXEL', 'QA_RADSAT'], //#,   'QA_PIXEL', 'QA_RADSAT'
    ['Blue',  'Green', 'Red',   'NIR',   'QA_PIXEL', 'QA_RADSAT']); // #, 'QA_PIXEL', 'QA_RADSAT'
}
// Function to get and rename bands of interest from Sentinel 2.
function renameS2(img) {
  return img.select(
    ['B2',   'B3',    'B4',  'B8',  'QA60', 'SCL', QA_BAND],
    ['Blue', 'Green', 'Red', 'NIR', 'QA60', 'SCL', QA_BAND]
  );
}

/* RMA transformation */
var rmaCoefficients = {
  itcpsL7: ee.Image.constant([-0.0084, -0.0065, 0.0022, -0.0768]),
  slopesL7: ee.Image.constant([1.1017, 1.0840, 1.0610, 1.2100]),
  itcpsS2: ee.Image.constant([0.0210, 0.0167, 0.0155, -0.0693]),
  slopesS2: ee.Image.constant([1.0849, 1.0590, 1.0759, 1.1583])
}; // #rma

function oli2oli(img) {
  return img.select(['Blue', 'Green', 'Red', 'NIR'])
            .toFloat();
}

function etm2oli(img) {
  return img.select(['Blue', 'Green', 'Red', 'NIR'])
    .multiply(rmaCoefficients.slopesL7)
    .add(rmaCoefficients.itcpsL7)
    .toFloat();
}
function s22oli(img) {
  return img.select(['Blue', 'Green', 'Red', 'NIR'])
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
  return image.select(['Blue', 'Green', 'Red', 'NIR']).multiply(0.0000275).add(-0.2)
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
  return image.select(['Blue', 'Green', 'Red', 'NIR']).multiply(0.0000275).add(-0.2)
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
            .select(['visnirAlbedo']); // # .select(['totalAlbedo']) or  .select(['visnirAlbedo']);
var tmCol = ee.ImageCollection('LANDSAT/LT05/C02/T1_L2') 
            .filter(colFilter) 
            .map(prepTm)
            .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo']);
var tm4Col = ee.ImageCollection('LANDSAT/LT04/C02/T1_L2') 
            .filter(colFilter) 
            .map(prepTm)
            .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo']);
var s2Col = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED') 
            .linkCollection(csPlus, [QA_BAND])
            .filter(s2colFilter) 
            .map(prepS2)
            .select(['visnirAlbedo']); //# .select(['totalAlbedo']) or  .select(['visnirAlbedo']);

var landsatCol = oliCol.merge(etmCol).merge(tmCol).merge(tm4Col).merge(oli2Col);
var multiSat = landsatCol.merge(s2Col).sort('system:time_start', true); // Sort chronologically in descending order.
 
// var hsaimg = multiSat.mean().updateMask(iceMask).multiply(10000).toUint16();

// Export.image.toDrive({
//   image: hsaimg,
//   description: 'albedo_' + imdate,
//   folder: 'export',
//   crs: 'EPSG:3411',
//   region: aoi,
//   scale: 30,
//   maxPixels: 1e13,
//   fileFormat: 'GeoTIFF'
// });
// convert multiSat to daily composite
// Difference in days between start and finish
var diff = date_end.difference(date_start, 'day');

// Make a list of all dates
var dayNum = 1; // steps of day number
var range = ee.List.sequence(0, diff.subtract(1), dayNum).map(function(day){return date_start.advance(day,'day')});

var day_mosaics = function(date, newlist) {
    // Cast
    date = ee.Date(date)
    newlist = ee.List(newlist)
  
    // Filter collection between date and the next day
    var filtered = multiSat.filterDate(date, date.advance(dayNum,'day'));
  
    // Make the mosaic
    var image = ee.Image(
        filtered.mean().copyProperties(filtered.first()))
        .set({date: date.format('yyyy-MM-dd')})
        .set('system:time_start', filtered.first().get('system:time_start'));
    // Add the mosaic to a list only if the collection has images
    return ee.List(ee.Algorithms.If(filtered.size(), newlist.add(image), newlist));
  };
var hsaDayCol = ee.ImageCollection(ee.List(range.iterate(day_mosaics, ee.List([])))).map(function(img){
  return img.updateMask(iceMask);
});
// // print(multiSat);
// // var imgHSA = multiSat.mean().clip(aoi).updateMask(greenlandmask);
// // var visParam = {min:0, max:1, bands:['Red', 'Green', 'Blue']};
// // Map.addLayer(imgHSA, visParam, 'img');

// var batch = require('users/fitoprincipe/geetools:batch');

// // batch export
// batch.Download.ImageCollection.toDrive(hsaDayCol.select(['visnirAlbedo']), 'export', 
//                 {scale: 30, 
//                  region: aoi, 
//                  crs: 'EPSG:3411',
//                  type: 'uint16',
//                  name: 'albedo_{system_date}'
//                 });
// batch.Download.ImageCollection.toAsset(hsaDayCol.select(['visnirAlbedo']), 'projects/ee-deeppurple/assets/TemporalAnalysis/albedo_JJA' + yearOfInterest,
//                 {scale: 30,
//                   region: aoi,
//                   crs: 'EPSG:3411',
//                   type: 'uint16',
//                   name: 'albedo_{system_date}'
//                 });
// Prepare a regularly-spaced Time-Series

// Generate an empty multi-band image matching the bands
// in the original collection
var bandNames = ee.Image(hsaDayCol.first()).bandNames();
var numBands = bandNames.size();
var initBands = ee.List.repeat(ee.Image(), numBands);
var initImage = ee.ImageCollection(initBands).toBands().rename(bandNames);

// Select the interval. We will have 1 image every n days
var n = 1;
var firstImage = ee.Image(hsaDayCol.sort('system:time_start').first());
var lastImage = ee.Image(hsaDayCol.sort('system:time_start', false).first());
var timeStart = ee.Date(firstImage.get('system:time_start'));
var timeEnd = ee.Date(lastImage.get('system:time_start'));

var totalDays = timeEnd.difference(timeStart, 'day');
var daysToInterpolate = ee.List.sequence(0, totalDays, n);

var initImages = daysToInterpolate.map(function(day) {
  var image = initImage.set({
    'system:index': ee.Number(day).format('%d'),
    'system:time_start': timeStart.advance(day, 'day').millis(),
    // Set a property so we can identify interpolated images
    'type': 'interpolated'
  });
  return image;
});

var initCol = ee.ImageCollection.fromImages(initImages);
// print('Empty Collection', initCol);

// Merge original and empty collections
var multiSat = multiSat.merge(initCol);

// Interpolation

// Add a band containing timestamp to each image
// This will be used to do pixel-wise interpolation later
var multiSat = multiSat.map(function(image) {
  var timeImage = image.metadata('system:time_start').rename('timestamp');
  // The time image doesn't have a mask. 
  // We set the mask of the time band to be the same as the first band of the image
  var timeImageMasked = timeImage.updateMask(image.mask().select(0));
  return image.addBands(timeImageMasked).toFloat();
});

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
var days = 4;
var millis = ee.Number(days).multiply(1000*60*60*24);

var maxDiffFilter = ee.Filter.maxDifference({
  difference: millis,
  leftField: 'system:time_start',
  rightField: 'system:time_start'
});

// We need a lessThanOrEquals filter to find all images after a given image
// This will compare the given image's timestamp against other images' timestamps
var lessEqFilter = ee.Filter.lessThanOrEquals({
  leftField: 'system:time_start',
  rightField: 'system:time_start'
});

// We need a greaterThanOrEquals filter to find all images before a given image
// This will compare the given image's timestamp against other images' timestamps
var greaterEqFilter = ee.Filter.greaterThanOrEquals({
  leftField: 'system:time_start',
  rightField: 'system:time_start'
});


// Apply the joins

// For the first join, we need to match all images that are after the given image.
// To do this we need to match 2 conditions
// 1. The resulting images must be within the specified time-window of target image
// 2. The target image's timestamp must be lesser than the timestamp of resulting images
// Combine two filters to match both these conditions
var filter1 = ee.Filter.and(maxDiffFilter, lessEqFilter);
// This join will find all images after, sorted in descending order
// This will gives us images so that closest is last
var join1 = ee.Join.saveAll({
  matchesKey: 'after',
  ordering: 'system:time_start',
  ascending: false});
  
var join1Result = join1.apply({
  primary: multiSat,
  secondary: multiSat,
  condition: filter1
});
// Each image now as a property called 'after' containing
// all images that come after it within the time-window
// print(join1Result.first());

// Do the second join now to match all images within the time-window
// that come before each image
var filter2 = ee.Filter.and(maxDiffFilter, greaterEqFilter);
// This join will find all images before, sorted in ascending order
// This will gives us images so that closest is last
var join2 = ee.Join.saveAll({
  matchesKey: 'before',
  ordering: 'system:time_start',
  ascending: true});
  
var join2Result = join2.apply({
  primary: join1Result,
  secondary: join1Result,
  condition: filter2
});

// Each image now as a property called 'before' containing
// all images that come after it within the time-window
// print(join2Result.first());

var joinedCol = join2Result;

// Do the interpolation

// We now write a function that will be used to interpolate all images
// This function takes an image and replaces the masked pixels
// with the interpolated value from before and after images.

var interpolateImages = function(image) {
  var image = ee.Image(image);
  // We get the list of before and after images from the image property
  // Mosaic the images so we a before and after image with the closest unmasked pixel
  var beforeImages = ee.List(image.get('before'));
  var beforeMosaic = ee.ImageCollection.fromImages(beforeImages).mosaic();
  var afterImages = ee.List(image.get('after'));
  var afterMosaic = ee.ImageCollection.fromImages(afterImages).mosaic();

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
  var t1 = beforeMosaic.select('timestamp').rename('t1');
  var t2 = afterMosaic.select('timestamp').rename('t2');

  var t = image.metadata('system:time_start').rename('t');

  var timeImage = ee.Image.cat([t1, t2, t]);

  var timeRatio = timeImage.expression('(t - t1) / (t2 - t1)', {
    't': timeImage.select('t'),
    't1': timeImage.select('t1'),
    't2': timeImage.select('t2'),
  });
  // You can replace timeRatio with a constant value 0.5
  // if you wanted a simple average
  
  // Compute an image with the interpolated image y
  var interpolated = beforeMosaic
    .add((afterMosaic.subtract(beforeMosaic).multiply(timeRatio)));
  // Replace the masked pixels in the current image with the average value
  var result = image.unmask(interpolated);
  return result.copyProperties(image, ['system:time_start']);
};

// map() the function to interpolate all images in the collection
var interpolatedCol = ee.ImageCollection(joinedCol.map(interpolateImages));

// Once the interpolation are done, remove original images
// We keep only the generated interpolated images
var regularCol = interpolatedCol.filter(ee.Filter.eq('type', 'interpolated'));



// export the mean albedo (visnirAlbedo) of the interpolated time series to EE asset and google drive
var meanAlbedo = regularCol.select(['visnirAlbedo']).mean();
Export.image.toAsset({
  image: meanAlbedo,
  description: 'meanAlbedo' + yearOfInterest + roi,
  assetId: 'projects/ee-deeppurple/assets/TemporalAnalysis/meanAlbedo_JJA' + yearOfInterest,
  region: aoi,
  scale: 30,
  maxPixels: 1e13
});
// Export.image.toDrive({
//   image: meanAlbedo,
//   description: 'meanAlbedo' + yearOfInterest + roi,
//   folder: 'export',
//   crs: 'EPSG:3411',
//   region: aoi,
//   scale: 30,
//   maxPixels: 1e13
// });

// export the min albedo (visnirAlbedo) of the interpolated time series to EE asset and google drive
var minAlbedo = regularCol.select(['visnirAlbedo']).min();
Export.image.toAsset({
  image: minAlbedo,
  description: 'minAlbedo' + yearOfInterest + roi,
  assetId: 'projects/ee-deeppurple/assets/TemporalAnalysis/minAlbedo_JJA' + yearOfInterest,
  region: aoi,
  scale: 30,
  maxPixels: 1e13
});
// Export.image.toDrive({
//   image: minAlbedo,
//   description: 'minAlbedo' + yearOfInterest + roi,
//   folder: 'export',
//   crs: 'EPSG:3411',
//   region: aoi,
//   scale: 30,
//   maxPixels: 1e13
// });

// bare ice duaration is defined as the number of days with albedo < 0.565
// export the bare ice duration of the interpolated time series to EE asset and google drive
var bareIceDuration = regularCol.select(['visnirAlbedo']).map(function(img) {
  return img.updateMask(img.lt(0.565));
}).count();

Export.image.toAsset({
  image: bareIceDuration,
  description: 'bareIceDuration' + yearOfInterest + roi,
  assetId: 'projects/ee-deeppurple/assets/TemporalAnalysis/bareIceDuration_JJA' + yearOfInterest,
  region: aoi,
  scale: 30,
  maxPixels: 1e13
});
// Export.image.toDrive({
//   image: bareIceDuration,
//   description: 'bareIceDuration' + yearOfInterest + roi,
//   folder: 'export',
//   crs: 'EPSG:3411',
//   region: aoi,
//   scale: 30,
//   maxPixels: 1e13
// });

// dark ice duaration is defined as the number of days with albedo < 0.451
// export the dark ice duration of the interpolated time series to EE asset and google drive
var darkIceDuration = regularCol.select(['visnirAlbedo']).map(function(img) {
  return img.updateMask(img.lt(0.451));
}).count();

Export.image.toAsset({
  image: darkIceDuration,
  description: 'darkIceDuration'+ yearOfInterest + roi,
  assetId: 'projects/ee-deeppurple/assets/TemporalAnalysis/darkIceDuration_JJA' + yearOfInterest,
  region: aoi,
  scale: 30,
  maxPixels: 1e13
});
// Export.image.toDrive({
//   image: darkIceDuration,
//   description: 'darkIceDuration'+ yearOfInterest + roi,
//   folder: 'export',
//   crs: 'EPSG:3411',
//   region: aoi,
//   scale: 30,
//   maxPixels: 1e13
// });