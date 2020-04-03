"use strict"

exports.updateCurrentImpl = function(details) {
	browser.tabs.update(details);
}
exports.updateImpl = browser.tabs.update;

exports.executeScriptCurrentImpl = function(details) {
	return browser.tabs.executeScript(details);
}
exports.executeScriptImpl = browser.tabs.executeScript;
exports.insertCssCurrentImpl = function(details) {
	return browser.tabs.insertCss(details);
}
exports.insertCssImpl = browser.tabs.insertCss;
