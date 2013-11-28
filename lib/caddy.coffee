
EventEmitter = require('events').EventEmitter

module.currScope

module.exports.start = () ->
  module.currScope = {}

module.exports.connect = (req, res, next) ->
  module.exports.start()
  next()
  return

module.exports.get = (key) ->
  if module.currScope then module.currScope[key]
  else null

module.exports.set = (key, data) ->
  if module.currScope then module.currScope[key] = data
  else null

wrap = (once, event, callback) ->
  if module.currScope
    savedScope = module.currScope
  ->
    if savedScope
      module.currScope = savedScope
    if once and this isnt process
      this.removeListener(event, callback)
    callback.apply(this, arguments)

_nextTick = process.nextTick
if _nextTick?
  process.nextTick = (callback) ->
    args = Array::slice.call(arguments)
    args[0] = wrap(false, null, callback)
    _nextTick.apply(this, args)

__nextDomainTick = process._nextDomainTick
if __nextDomainTick?
  process._nextDomainTick = (callback) ->
    args = Array::slice.call(arguments)
    args[0] = wrap(false, null, callback)
    __nextDomainTick.apply(this, args)

_setTimeout = global.setTimeout
if _setTimeout?
  global.setTimeout = (callback) ->
    args = Array::slice.call(arguments)
    args[0] = wrap(false, null, callback)
    _setTimeout.apply(this, args)

_setInterval = global.setInterval
if _setInterval?
  global.setInterval = (callback) ->
    args = Array::slice.call(arguments)
    args[0] = wrap(false, null, callback)
    _setInterval.apply(this, args)

_setImmediate = global.setImmediate
if _setImmediate?
  global.setImmediate = (callback) ->
    args = Array::slice.call(arguments)
    args[0] = wrap(false, null, callback)
    _setImmediate.apply(this, args)

_listeners = EventEmitter.prototype.listeners
if _listeners?
  EventEmitter.prototype.listeners = (event) ->
    listeners = _listeners.call(this, event)
    origListeners = []
    for listener in listeners
      if listener?._origCallback
        origListeners.push(listener._origCallback)
      else
        origListeners.push(listener)
    return origListeners

_on = EventEmitter.prototype.on
if _on?
  EventEmitter.prototype.on = (event, callback) ->
    args = Array::slice.call(arguments)
    args[1] = wrap(false, event, callback)
    _on.apply(this, args)
    listeners = _listeners.call(this, event)
    listeners[listeners.length-1]._origCallback = callback
    return this

_addListener = EventEmitter.prototype.addListener
if _addListener?
  EventEmitter.prototype.addListener = (event, callback) ->
    args = Array::slice.call(arguments)
    args[1] = wrap(false, event, callback)
    _addListener.apply(this, args)
    listeners = _listeners.call(this, event)
    listeners[listeners.length-1]._origCallback = callback
    return this

_once = EventEmitter.prototype.once
if _once?
  EventEmitter.prototype.once = (event, callback) ->
    args = Array::slice.call(arguments)
    args[1] = wrap(true, event, callback)
    _once.apply(this, args)
    listeners = _listeners.call(this, event)
    listeners[listeners.length-1]._origCallback = callback
    return this

_removeListener = EventEmitter.prototype.removeListener
if _removeListener?
  EventEmitter.prototype.removeListener = (event, callback) ->
    args = Array::slice.call(arguments)
    called = false
    for listener in _listeners.call(this, event)
      if listener?._origCallback is callback
        called = true
        args[1] = listener
        _removeListener.apply(this, args)
        break
    if not called
      _removeListener.apply(this, args)
    return this

