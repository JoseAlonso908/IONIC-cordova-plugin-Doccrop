var exec = require("cordova/exec");

var DocCrop = function () {};

DocCrop.prototype.cropresult = function (onSuccess, onFail) {
  exec(onSuccess, onFail, "DocCrop", "result");
};

module.exports = new DocCrop();