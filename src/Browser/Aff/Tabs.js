"use strict"

exports.logger = function(s) {
	return function() {
		console.log(s)
	}
}
