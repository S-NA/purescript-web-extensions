exports._get = function(keys) {
	return browser.storage.local.get(keys)
}


exports._set = function(keys) {
	return browser.storage.local.set(keys)
}
