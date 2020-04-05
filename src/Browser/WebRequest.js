"use strict";

exports.onBeforeRequestBlocking = browser.webRequest.onBeforeRequest;
exports.onBeforeRequest = browser.webRequest.onBeforeRequest;
exports.addBeforeRequestListener_ = function(filter, callback, extra) {
	browser.webRequest.onBeforeRequest.addListener(callback, filter, extra);
}
