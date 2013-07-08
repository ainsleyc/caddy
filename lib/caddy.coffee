
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

wrap = (callback) ->
  if module.currScope
    savedScope = module.currScope
  ->
    if savedScope
      module.currScope = savedScope
    callback.apply(this, arguments)

_nextTick = process.nextTick
process.nextTick = (callback) ->
  args = Array::slice.call(arguments)
  args[0] = wrap(callback)
  _nextTick.apply(this, args)

_setTimeout = global.setTimeout
global.setTimeout = (callback) ->
  args = Array::slice.call(arguments)
  args[0] = wrap(callback)
  _setTimeout.apply(this, args)

_setInterval = global.setInterval
global.setInterval = (callback) ->
  args = Array::slice.call(arguments)
  args[0] = wrap(callback)
  _setInterval.apply(this, args)

_on = EventEmitter.prototype.on
EventEmitter.prototype.on = (event, callback) ->
  args = Array::slice.call(arguments)
  args[1] = wrap(callback)
  args[1]._origCallback = callback
  _on.apply(this, args)

_addListener = EventEmitter.prototype.addListener
EventEmitter.prototype.addListener = (event, callback) ->
  args = Array::slice.call(arguments)
  args[1] = wrap(callback)
  args[1]._origCallback = callback
  _addListener.apply(this, args)

_once = EventEmitter.prototype.once
EventEmitter.prototype.once = (event, callback) ->
  args = Array::slice.call(arguments)
  args[1] = wrap(callback)
  args[1]._origCallback = callback
  _once.apply(this, args)

_removeListener = EventEmitter.prototype.removeListener
EventEmitter.prototype.removeListener = (event, callback) ->
  args = Array::slice.call(arguments)
  called = false
  for listener in this.listeners(event)
    if listener?._origCallback is callback
      called = true
      args[1] = listener
      _removeListener.apply(this, args)
      break
  if not called
    _removeListener.apply(this, args)

