exports._get = function(keys) {
	return browser.storage.local.get(keys)
}

exports._set = function(keys) {
	return browser.storage.local.set(keys)
}

exports._remove = function(keys) {
	return browser.storage.local.remove(keys)
}

exports._clear = function() {
	return browser.storage.local.clear()
}

