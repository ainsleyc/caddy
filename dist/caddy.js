(function() {
  var EventEmitter, http, https, wrap, _addListener, _nextTick, _on, _once, _removeListener, _setInterval, _setTimeout;

  EventEmitter = require('events').EventEmitter;

  http = require('http');

  https = require('https');

  module.currScope;

  module.exports.start = function() {
    return module.currScope = {};
  };

  module.exports.get = function(key) {
    if (module.currScope) {
      return module.currScope[key];
    } else {
      return null;
    }
  };

  module.exports.set = function(key, data) {
    if (module.currScope) {
      return module.currScope[key] = data;
    } else {
      return null;
    }
  };

  wrap = function(callback) {
    var savedScope;
    if (module.currScope) {
      savedScope = module.currScope;
    }
    return function() {
      if (savedScope) {
        module.currScope = savedScope;
      }
      return callback.apply(this, arguments);
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

  _on = EventEmitter.prototype.on;

  EventEmitter.prototype.on = function(event, callback) {
    var args;
    args = Array.prototype.slice.call(arguments);
    args[1] = wrap(callback);
    args[1]._origCallback = callback;
    return _on.apply(this, args);
  };

  _addListener = EventEmitter.prototype.addListener;

  EventEmitter.prototype.addListener = function(event, callback) {
    var args;
    args = Array.prototype.slice.call(arguments);
    args[1] = wrap(callback);
    args[1]._origCallback = callback;
    return _addListener.apply(this, args);
  };

  _once = EventEmitter.prototype.once;

  EventEmitter.prototype.once = function(event, callback) {
    var args;
    args = Array.prototype.slice.call(arguments);
    args[1] = wrap(callback);
    args[1]._origCallback = callback;
    return _once.apply(this, args);
  };

  _removeListener = EventEmitter.prototype.removeListener;

  EventEmitter.prototype.removeListener = function(event, callback) {
    var args, called, listener, _i, _len, _ref;
    args = Array.prototype.slice.call(arguments);
    called = false;
    _ref = this.listeners(event);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      listener = _ref[_i];
      if ((listener != null ? listener._origCallback : void 0) === callback) {
        called = true;
        args[1] = listener;
        _removeListener.apply(this, args);
        break;
      }
    }
    if (!called) {
      return _removeListener.apply(this, args);
    }
  };

}).call(this);
