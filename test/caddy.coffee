
expect = require('chai').expect
sinon = require('sinon')
EventEmitter = require('events').EventEmitter

spyNextTick = sinon.spy(process, 'nextTick')
spySetTimeout = sinon.spy(global, 'setTimeout')
spySetInterval = sinon.spy(global, 'setInterval')

spyEmitterAddListener = sinon.spy(EventEmitter.prototype, 'addListener')
spyEmitterRemoveListener = sinon.spy(EventEmitter.prototype, 'removeListener')
spyEmitterOnce = sinon.spy(EventEmitter.prototype, 'once')
spyEmitterOn = sinon.spy(EventEmitter.prototype, 'on')

caddy = require('../dist/caddy')

describe 'interface', ->

  it 'should export a start function', ->
    expect(caddy.start).to.exist
  it 'should export a get function', ->
    expect(caddy.get).to.exist
  it 'should export a set function', ->
    expect(caddy.set).to.exist

  it 'should create a new data scope when start is called', ->
    expect(caddy.set('key', 'data')).to.not.exist
    expect(caddy.get('key')).to.not.exist
    caddy.start()
    expect(caddy.set('key', 'data')).to.exist
    expect(caddy.get('key')).to.exist
  it 'should allow setting and getting of data by key', ->
    caddy.start()
    caddy.set('key', 'data')
    expect(caddy.get('key')).to.equal('data')

describe 'function wrapping', ->

  it 'should wrap process.nextTick', ->
    expect(process.nextTick).to.not.equal(spyNextTick)
  it 'should call original process.nextTick', (done) ->
    spyNextTick.reset()
    process.nextTick(->
      expect(spyNextTick.calledOnce).to.be.true
      spyNextTick.reset()
      done()
    )

  it 'should wrap global.setTimeout', ->
    expect(global.setTimeout).to.not.equal(spySetTimeout)
  it 'should call original global.setTimeout', (done) ->
    spySetTimeout.reset()
    setTimeout((->
      expect(spySetTimeout.calledOnce).to.be.true
      spySetTimeout.reset()
      done()
    ), 1000)

  it 'should wrap global.setInterval', ->
    expect(global.setInterval).to.not.equal(spySetInterval)
  it 'should call original global.setTimeout', (done) ->
    spySetInterval.reset()
    intervalId = setInterval((->
      expect(spySetInterval.calledOnce).to.be.true
      spySetInterval.reset()
      clearInterval(intervalId)
      done()
    ), 1000)

  it 'should wrap EventEmitter.addListener', ->
    expect(EventEmitter.prototype.addListener).to.not.equal(spyEmitterAddListener)
  it 'should call original EventEmitter.addListener', ->
    spyEmitterAddListener.reset()
    emitter = new EventEmitter()
    emitter.addListener('exit', ->)
    expect(spyEmitterAddListener.calledOnce).to.be.true

  it 'should wrap EventEmitter.once', ->
    expect(EventEmitter.prototype.once).to.not.equal(spyEmitterOnce)
  it 'should call original EventEmitter.once', ->
    spyEmitterOnce.reset()
    emitter = new EventEmitter()
    emitter.once('exit', ->)
    expect(spyEmitterOnce.calledOnce).to.be.true

  it 'should wrap EventEmitter.on', ->
    expect(EventEmitter.prototype.on).to.not.equal(spyEmitterOn)
  it 'should call original EventEmitter.on', ->
    spyEmitterOn.reset()
    emitter = new EventEmitter()
    emitter.on('exit', ->)
    expect(spyEmitterOn.calledOnce).to.be.true

  it 'should wrap EventEmitter.removeListener', ->
    expect(EventEmitter.prototype.removeListener).to.not.equal(spyEmitterRemoveListener)
  it 'should call original EventEmitter.removeListener', ->
    spyEmitterRemoveListener.reset()
    emitter = new EventEmitter()
    emitter.removeListener('exit', ->)
    expect(spyEmitterRemoveListener.calledOnce).to.be.true
  it 'should removed wrapped event handlers when removeListener is called', ->
    emitter = new EventEmitter()
    cb1 = ->
      return 1
    cb2 = ->
      return 2
    emitter.addListener('cb1', cb1)
    emitter.addListener('cb1', cb2)
    emitter.on('cb2', cb2)

    expect(emitter.listeners('cb1').length).to.equal(2)
    expect(emitter.listeners('cb2').length).to.equal(1)

    emitter.removeListener('cb1', cb1)
    expect(emitter.listeners('cb1').length).to.equal(1)

    emitter.removeListener('cb1', cb2)
    expect(emitter.listeners('cb1').length).to.equal(0)

    emitter.removeListener('cb2', cb1)
    expect(emitter.listeners('cb2').length).to.equal(1)

    emitter.removeListener('cb2', cb2)
    expect(emitter.listeners('cb2').length).to.equal(0)

describe 'data persistence', ->
  it 'should save data between process.nextTick calls', (done) ->
    caddy.start()
    caddy.set('tag1', 1)
    process.nextTick(->
      expect(caddy.get('tag1')).to.equal(1)
      expect(caddy.get('tag2')).to.not.exist
      expect(caddy.get('tag3')).to.not.exist
    )
    caddy.start()
    caddy.set('tag2', 'two')
    process.nextTick(->
      expect(caddy.get('tag2')).to.equal('two')
      expect(caddy.get('tag1')).to.not.exist
      expect(caddy.get('tag3')).to.not.exist
    )
    caddy.start()
    caddy.set('tag3', [3])
    process.nextTick(->
      expect(caddy.get('tag3')[0]).to.equal(3)
      expect(caddy.get('tag2')).to.not.exist
      expect(caddy.get('tag1')).to.not.exist
      done()
    )

  it 'should save data between global.setTimeout calls', (done) ->
    caddy.start()
    caddy.set('tag1', 1)
    setTimeout(->
      expect(caddy.get('tag1')).to.equal(1)
      expect(caddy.get('tag2')).to.not.exist
      expect(caddy.get('tag3')).to.not.exist
      done()
    , 500)
    caddy.start()
    caddy.set('tag2', 'two')
    setTimeout(->
      expect(caddy.get('tag2')).to.equal('two')
      expect(caddy.get('tag1')).to.not.exist
      expect(caddy.get('tag3')).to.not.exist
    , 300)
    caddy.start()
    caddy.set('tag3', [3])
    setTimeout(->
      expect(caddy.get('tag3')[0]).to.equal(3)
      expect(caddy.get('tag2')).to.not.exist
      expect(caddy.get('tag1')).to.not.exist
    , 100)

  it 'should save data between global.setInterval calls', (done) ->
    caddy.start()
    caddy.set('tag1', 1)
    interval1 = setInterval(->
      expect(caddy.get('tag1')).to.equal(1)
      expect(caddy.get('tag2')).to.not.exist
      expect(caddy.get('tag3')).to.not.exist
      clearInterval(interval1)
      done()
    , 500)
    caddy.start()
    caddy.set('tag2', 'two')
    interval2 = setInterval(->
      expect(caddy.get('tag2')).to.equal('two')
      expect(caddy.get('tag1')).to.not.exist
      expect(caddy.get('tag3')).to.not.exist
      clearInterval(interval2)
    , 300)
    caddy.start()
    caddy.set('tag3', [3])
    interval3 = setInterval(->
      expect(caddy.get('tag3')[0]).to.equal(3)
      expect(caddy.get('tag2')).to.not.exist
      expect(caddy.get('tag1')).to.not.exist
      clearInterval(interval3)
    , 100)

describe 'node library compatibility', ->
  it 'http.request', (done) ->
    urls = [
      'www.factual.com',
      'www.lifehacker.com',
      'www.stackoverflow.com'
    ]
    http = require('http')
    reqCount = 0
    for url in urls
      do (url) ->
        caddy.start()
        caddy.set(url, url)
        options =
          hostname: url
          port: 80
          path: '/'
          method: 'GET'
        req = http.request(options, (res) ->
          res.on('end', ->
            expect(caddy.get(url)).to.equal(url)
            reqCount++
            if reqCount is urls.length
              done()
          )
        )
        req.end()


