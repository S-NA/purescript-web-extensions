"use strict";

exports.onBeforeRequestBlocking = browser.webRequest.onBeforeRequest;
exports.onBeforeRequest = browser.webRequest.onBeforeRequest;
exports.onBeforeSendHeadersBlocking = browser.webRequest.onBeforeSendHeaders;

exports.addListener_ = function(event, filter, callback, extra) {
	event.addListener(callback, filter, extra);
}
