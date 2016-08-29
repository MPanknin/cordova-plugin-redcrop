/* global cordova */
var crop = module.exports = function cropImage (success, fail, image, options) {
  options = options || {}
  options.quality = options.quality || 100
  options.keepingCropAspectRatio = options.keepingCropAspectRatio || true
  return cordova.exec(success, fail, 'CropPlugin', 'cropImage', [image, options])
}