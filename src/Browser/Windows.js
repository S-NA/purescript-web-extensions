exports.onRemoved = function(listener) {
	return function() {
		browser.windows.onRemoved.addListener(listener)
	}
}

exports.getAllImpl = function() {
	return browser.windows.getAll
}

exports.getAllImpl1 = function(getInfo) {
	return browser.windows.getAll(getInfo)
}

exports.createImpl = function(createData) {
	return browser.windows.create(createData)
}

exports.removeImpl = function(windowId) {
	return browser.windows.remove(windowId)
}

