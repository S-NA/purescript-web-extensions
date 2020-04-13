"use strict"

exports.updateCurrentImpl = browser.tabs.update;

exports.updateImpl = browser.tabs.update;
exports.queryImpl = browser.tabs.query;

exports.executeScriptCurrentImpl = browser.tabs.executeScript;
exports.executeScriptImpl = browser.tabs.executeScript;
exports.insertCssCurrentImpl = browser.tabs.insertCSS;
exports.insertCssImpl = browser.tabs.insertCSS;
exports.removeCssCurrentImpl = browser.tabs.removeCSS;
exports.removeCssImpl = browser.tabs.removeCSS;

exports.sendMessage_ = browser.tabs.sendMessage;
exports.sendMessageToFrame_ = function(tabId, message, frameId) {
    return browser.tabs.sendMessage(tabId, message, {"frameId": frameId});
}
