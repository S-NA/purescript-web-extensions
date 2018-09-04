'use strict'

exports.onClicked = function(listener) {
	return function() {
		browser.browserAction.onClicked.addListener(listener)
	}
}

