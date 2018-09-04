exports.eventListener = function (fn) {
  return function () {
    return function (event) {
      return fn(event)();
    };
  };
};

