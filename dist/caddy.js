(function() {
  var EventEmitter, wrap, __nextDomainTick, _addListener, _listeners, _nextTick, _on, _once, _removeListener, _setImmediate, _setInterval, _setTimeout;

  EventEmitter = require('events').EventEmitter;

  module.currScope;

  module.exports.start = function() {
    return module.currScope = {};
  };

  module.exports.connect = function(req, res, next) {
    module.exports.start();
    next();
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

  wrap = function(once, event, callback) {
    var savedScope;
    if (module.currScope) {
      savedScope = module.currScope;
    }
    return function() {
      if (savedScope) {
        module.currScope = savedScope;
      }
      if (once && this !== process) {
        this.removeListener(event, callback);
      }
      return callback.apply(this, arguments);
    };
  };

  _nextTick = process.nextTick;

  if (_nextTick != null) {
    process.nextTick = function(callback) {
      var args;
      args = Array.prototype.slice.call(arguments);
      args[0] = wrap(false, null, callback);
      return _nextTick.apply(this, args);
    };
  }

  __nextDomainTick = process._nextDomainTick;

  if (__nextDomainTick != null) {
    process._nextDomainTick = function(callback) {
      var args;
      args = Array.prototype.slice.call(arguments);
      args[0] = wrap(false, null, callback);
      return __nextDomainTick.apply(this, args);
    };
  }

  _setTimeout = global.setTimeout;

  if (_setTimeout != null) {
    global.setTimeout = function(callback) {
      var args;
      args = Array.prototype.slice.call(arguments);
      args[0] = wrap(false, null, callback);
      return _setTimeout.apply(this, args);
    };
  }

  _setInterval = global.setInterval;

  if (_setInterval != null) {
    global.setInterval = function(callback) {
      var args;
      args = Array.prototype.slice.call(arguments);
      args[0] = wrap(false, null, callback);
      return _setInterval.apply(this, args);
    };
  }

  _setImmediate = global.setImmediate;

  if (_setImmediate != null) {
    global.setImmediate = function(callback) {
      var args;
      args = Array.prototype.slice.call(arguments);
      args[0] = wrap(false, null, callback);
      return _setImmediate.apply(this, args);
    };
  }

  _listeners = EventEmitter.prototype.listeners;

  if (_listeners != null) {
    EventEmitter.prototype.listeners = function(event) {
      var listener, listeners, origListeners, _i, _len;
      listeners = _listeners.call(this, event);
      origListeners = [];
      for (_i = 0, _len = listeners.length; _i < _len; _i++) {
        listener = listeners[_i];
        if (listener != null ? listener._origCallback : void 0) {
          origListeners.push(listener._origCallback);
        } else {
          origListeners.push(listener);
        }
      }
      return origListeners;
    };
  }

  _on = EventEmitter.prototype.on;

  if (_on != null) {
    EventEmitter.prototype.on = function(event, callback) {
      var args, listeners;
      args = Array.prototype.slice.call(arguments);
      args[1] = wrap(false, event, callback);
      _on.apply(this, args);
      listeners = _listeners.call(this, event);
      listeners[listeners.length - 1]._origCallback = callback;
      return this;
    };
  }

  _addListener = EventEmitter.prototype.addListener;

  if (_addListener != null) {
    EventEmitter.prototype.addListener = function(event, callback) {
      var args, listeners;
      args = Array.prototype.slice.call(arguments);
      args[1] = wrap(false, event, callback);
      _addListener.apply(this, args);
      listeners = _listeners.call(this, event);
      listeners[listeners.length - 1]._origCallback = callback;
      return this;
    };
  }

  _once = EventEmitter.prototype.once;

  if (_once != null) {
    EventEmitter.prototype.once = function(event, callback) {
      var args, listeners;
      args = Array.prototype.slice.call(arguments);
      args[1] = wrap(true, event, callback);
      _once.apply(this, args);
      listeners = _listeners.call(this, event);
      listeners[listeners.length - 1]._origCallback = callback;
      return this;
    };
  }

  _removeListener = EventEmitter.prototype.removeListener;

  if (_removeListener != null) {
    EventEmitter.prototype.removeListener = function(event, callback) {
      var args, called, listener, _i, _len, _ref;
      args = Array.prototype.slice.call(arguments);
      called = false;
      _ref = _listeners.call(this, event);
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
        _removeListener.apply(this, args);
      }
      return this;
    };
  }

}).call(this);
