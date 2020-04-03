"use strict"

exports.onChanged = browser.sessions.onChanged;

exports.restoreImpl = function(a) {
    return browser.sessions.restore(a)
}

exports.getRecentlyClosedImpl = function(a) {
    return browser.sessions.getRecentlyClosed(a)
}

exports.setWindowValueImpl = function(windowId, key, value) {
    return browser.sessions.setWindowValue(windowId, key, value)
}

exports.getWindowValueImpl = function(windowId, key) {
    return browser.sessions.getWindowValue(windowId, key)
}

