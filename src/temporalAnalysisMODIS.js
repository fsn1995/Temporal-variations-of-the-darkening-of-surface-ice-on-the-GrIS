/*
This script is used to generate the mean, min, bare ice duration and dark ice duration of the albedo time 
series for the whole Greenland in the summer (June, July, August) of a specific year.
The albedo time series is generated from the harmonized satellite data including Landsat 4/5/7/8, Sentinel 2.
The albedo is calculated from the visible and near-infrared bands of the satellite data.
The bare ice duration is defined as the number of days with albedo < 0.565.
The dark ice duration is defined as the number of days with albedo < 0.451.
The mean albedo is the mean value of the albedo time series.
The min albedo is the minimum value of the albedo time series.
The albedo time series is interpolated to daily composite.
The output is exported to Google Drive and Earth Engine asset.
The output is used to analyze the temporal variation of the albedo in the summer of Greenland.

However, timeout error forced me to change the workflow to export the intermediate results to Google Drive
for further processing and analysis.

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
// Map.setOptions('HYBRID');

var greenlandmask = ee.Image('OSU/GIMP/2000_ICE_OCEAN_MASK')
                      .select('ice_mask').eq(1); //'ice_mask', 'ocean_mask'
var elevation = ee.Image('OSU/GIMP/DEM').select('elevation').updateMask(greenlandmask);
var iceMask = elevation.lt(2000); // ice mask is defined as elevation < 2000 m and ice mask = 1
/*
prepare modis albedo data
*/
var mod10 = ee.ImageCollection('MODIS/061/MOD10A1')
                .select('Snow_Albedo_Daily_Tile')
                .filterDate(date_start, date_end)
                .filterBounds(aoi)
                .map(function(img) {
                  return img.updateMask(iceMask).divide(100);
                });

// export the mean albedo (visnirAlbedo) of the interpolated time series to EE asset and google drive
var meanAlbedo = mod10.mean();
// Export.image.toAsset({
//   image: meanAlbedo,
//   description: 'meanAlbedo' + yearOfInterest + roi,
//   assetId: 'projects/ee-deeppurple/assets/TemporalAnalysis/meanAlbedo_JJA' + yearOfInterest,
//   region: aoi,
//   scale: 500,
//   maxPixels: 1e13
// });
Export.image.toDrive({
  image: meanAlbedo,
  description: 'meanAlbedo' + yearOfInterest + roi,
  folder: 'export',
  crs: 'EPSG:3413',
  region: aoi,
  scale: 500,
  maxPixels: 1e13
});

// export the number of valid pixels in the time series to EE asset and google drive
var countAlbedo = mod10.count();
// Export.image.toAsset({
//   image: countAlbedo,
//   description: 'countAlbedo' + yearOfInterest + roi,
//   assetId: 'projects/ee-deeppurple/assets/TemporalAnalysis/countAlbedo_JJA' + yearOfInterest,
//   region: aoi,
//   scale: 500,
//   maxPixels: 1e13
// });
Export.image.toDrive({
  image: countAlbedo,
  description: 'countAlbedo' + yearOfInterest + roi,
  folder: 'export',
  crs: 'EPSG:3413',
  region: aoi,
  scale: 500,
  maxPixels: 1e13
});
  
// // export the min albedo (visnirAlbedo) of the interpolated time series to EE asset and google drive
// var minAlbedo = mod10.min();
// // Export.image.toAsset({
// //   image: minAlbedo,
// //   description: 'minAlbedo' + yearOfInterest + roi,
// //   assetId: 'projects/ee-deeppurple/assets/TemporalAnalysis/minAlbedo_JJA' + yearOfInterest,
// //   region: aoi,
// //   scale: 500,
// //   maxPixels: 1e13
// // });
// Export.image.toDrive({
//   image: minAlbedo,
//   description: 'minAlbedo' + yearOfInterest + roi,
//   folder: 'export',
//   crs: 'EPSG:3413',
//   region: aoi,
//   scale: 500,
//   maxPixels: 1e13
// });

// bare ice duaration is defined as the number of days with albedo < 0.565
// export the bare ice duration of the interpolated time series to EE asset and google drive
var bareIceDuration = mod10.map(function(img) {
  return img.updateMask(img.lt(0.565));
}).count();

// Export.image.toAsset({
//   image: bareIceDuration,
//   description: 'bareIceDuration' + yearOfInterest + roi,
//   assetId: 'projects/ee-deeppurple/assets/TemporalAnalysis/bareIceDuration_JJA' + yearOfInterest,
//   region: aoi,
//   scale: 500,
//   maxPixels: 1e13
// });
Export.image.toDrive({
  image: bareIceDuration,
  description: 'bareIceDuration' + yearOfInterest + roi,
  folder: 'export',
  crs: 'EPSG:3413',
  region: aoi,
  scale: 500,
  maxPixels: 1e13
});

// // dark ice duaration is defined as the number of days with albedo < 0.451
// // export the dark ice duration of the interpolated time series to EE asset and google drive
// var darkIceDuration = mod10.map(function(img) {
//   return img.updateMask(img.lt(0.451));
// }).count();

// // Export.image.toAsset({
// //   image: darkIceDuration,
// //   description: 'darkIceDuration'+ yearOfInterest + roi,
// //   assetId: 'projects/ee-deeppurple/assets/TemporalAnalysis/darkIceDuration_JJA' + yearOfInterest,
// //   region: aoi,
// //   scale: 500,
// //   maxPixels: 1e13
// // });
// Export.image.toDrive({
//   image: darkIceDuration,
//   description: 'darkIceDuration'+ yearOfInterest + roi,
//   folder: 'export',
//   crs: 'EPSG:3413',
//   region: aoi,
//   scale: 500,
//   maxPixels: 1e13
// });