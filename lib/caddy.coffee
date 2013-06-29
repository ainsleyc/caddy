
module.currScope

module.exports.caddy = (req, res, next) ->
  module.currScope = {}
  next()

module.exports.get = (tag) ->
  if module.currScope then module.currScope[tag]
  else null

module.exports.set = (tag, data) ->
  if module.currScope then module.currScope[tag] = data
  else null

wrap = (callback) ->
  savedScope = module.currScope
  ->
    module.currScope = savedScope
    callback(arguments)

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
