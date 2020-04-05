"use strict"

exports.onMessage = browser.runtime.onMessage;
exports.onStartup = browser.runtime.onStartup;
exports.onSuspend = browser.runtime.onSuspend;

exports.addMessageListener_ = function(ev, cb) {
	var wrappedCb = function(message, sender, sendResponse) {
		var args =
			{ "message": message
			, "sender": sender
			, "sendResponse": sendResponse
			};
		return cb(args);
	}
	ev.addListener(wrappedCb);
}

exports.getUrl = browser.runtime.getURL;
