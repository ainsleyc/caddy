(function() {
  var wrap, _nextTick, _setInterval, _setTimeout;

  module.currScope;

  module.exports.caddy = function(req, res, next) {
    module.currScope = {};
    return next();
  };

  module.exports.get = function(tag) {
    if (module.currScope) {
      return module.currScope[tag];
    } else {
      return null;
    }
  };

  module.exports.set = function(tag, data) {
    if (module.currScope) {
      return module.currScope[tag] = data;
    } else {
      return null;
    }
  };

  wrap = function(callback) {
    var savedScope;
    savedScope = module.currScope;
    return function() {
      module.currScope = savedScope;
      return callback(arguments);
    };
  };

  _nextTick = process.nextTick;

  process.nextTick = function(callback) {
    var args;
    args = Array.prototype.slice.call(arguments);
    args[0] = wrap(callback);
    return _nextTick.apply(this, args);
  };

  _setTimeout = global.setTimeout;

  global.setTimeout = function(callback) {
    var args;
    args = Array.prototype.slice.call(arguments);
    args[0] = wrap(callback);
    return _setTimeout.apply(this, args);
  };

  _setInterval = global.setInterval;

  global.setInterval = function(callback) {
    var args;
    args = Array.prototype.slice.call(arguments);
    args[0] = wrap(callback);
    return _setInterval.apply(this, args);
  };

}).call(this);
