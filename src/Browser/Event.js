"use strict"

exports.addListener_ = function(cb, ev) {
    ev.addListener(cb);
}
