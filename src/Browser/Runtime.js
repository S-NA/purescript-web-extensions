'use strict'

exports.onStartup = function(listener) {
	return function() {
		browser.runtime.onStartup.addListener(listener)
	}
}

exports.onSuspend = function(listener) {
	return function() {
		browser.runtime.onSuspend.addListener(listener)
	}
}

