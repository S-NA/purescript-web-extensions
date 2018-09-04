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

exports.test = "test"
exports.array = [1,2,3]

