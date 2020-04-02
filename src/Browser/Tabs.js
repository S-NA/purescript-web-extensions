"use strict"

exports.updateCurrentImpl = function(details) {
	browser.tabs.update(details);
}
exports.updateImpl = browser.tabs.update;

exports.executeScriptCurrentImpl = function(details) {
	return browser.tabs.executeScript(details);
}
exports.executeScriptImpl = browser.tabs.executeScript;
