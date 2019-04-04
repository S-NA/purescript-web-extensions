"use strict"

exports.update = function(url) {
	return function(){
		browser.tabs.update({"url": url})
	}
}

exports.logger = function(s) {
	return function() {
		console.log(s)
	}
}

exports.executeScriptImpl = function() {
	return function(details) {
		return browser.tabs.executeScript(details);
	};
}

exports.test = "test"
exports.array = [1,2,3]
