
expect = require('chai').expect
sinon = require('sinon')
EventEmitter = require('events').EventEmitter

spyNextTick = sinon.spy(process, 'nextTick')
spyNextDomainTick = sinon.spy(process, '_nextDomainTick')
spySetTimeout = sinon.spy(global, 'setTimeout')
spySetInterval = sinon.spy(global, 'setInterval')
spySetImmediate = sinon.spy(global, 'setImmediate')

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
  it 'should export a connect function', ->
    expect(caddy.connect).to.exist

  it 'should create a new data scope when start is called', ->
    expect(caddy.set('key', 'data')).to.not.exist
    expect(caddy.get('key')).to.not.exist
    caddy.start()
    expect(caddy.set('key', 'data')).to.exist
    expect(caddy.get('key')).to.exist
    caddy.set('key', undefined)
  it 'should create a new data scope when connect is called', ->
    stub = new sinon.stub()
    expect(caddy.get('key')).to.not.exist
    caddy.connect(null, null, stub)
    expect(caddy.set('key', 'data')).to.exist
    expect(caddy.get('key')).to.exist
    expect(stub.calledOnce).to.be.true
    caddy.set('key', undefined)
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

  it 'should wrap process._nextDomainTick', ->
    expect(process._nextDomainTick).to.not.equal(spyNextDomainTick)
  it 'should call original process._nextDomainTick', (done) ->
    spyNextDomainTick.reset()
    process._nextDomainTick(->
      expect(spyNextDomainTick.calledOnce).to.be.true
      spyNextDomainTick.reset()
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

  it 'should wrap global.setImmediate', ->
    expect(global.setImmediate).to.not.equal(spySetImmediate)
  it 'should call original global.setImmediate', (done) ->
    spySetImmediate.reset()
    immediateId = setImmediate((->
      expect(spySetImmediate.calledOnce).to.be.true
      spySetImmediate.reset()
      clearImmediate(immediateId)
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
  it 'should remove event handlers correctly', ->
    emitter = new EventEmitter()

    addListener1 = ->
    addListener2 = ->
    expect(emitter.listeners('addListener').length).to.equal(0)
    emitter.addListener('addListener', addListener1)
    emitter.addListener('addListener', addListener2)
    expect(emitter.listeners('addListener').length).to.equal(2)

    once1 = ->
    once2 = ->
    expect(emitter.listeners('once').length).to.equal(0)
    emitter.once('once', once1)
    emitter.once('once', once2)
    expect(emitter.listeners('once').length).to.equal(2)

    on1 = ->
    on2 = ->
    expect(emitter.listeners('on').length).to.equal(0)
    emitter.on('on', on1)
    emitter.on('on', on2)
    expect(emitter.listeners('on').length).to.equal(2)

    emitter.removeListener('addListener', addListener2)
    expect(emitter.listeners('addListener').length).to.equal(1)
    emitter.removeListener('addListener', addListener1)
    expect(emitter.listeners('addListener').length).to.equal(0)

    emitter.removeListener('on', on1)
    expect(emitter.listeners('on').length).to.equal(1)
    emitter.removeListener('on', on2)
    expect(emitter.listeners('on').length).to.equal(0)

    emitter.removeListener('once', once2)
    expect(emitter.listeners('once').length).to.equal(1)
    emitter.removeListener('once', once1)
    expect(emitter.listeners('once').length).to.equal(0)
  it 'should once event handlers should be removed correctly after being emmited', (done) ->
    emitter = new EventEmitter()

    once1 = ->
    once2 = ->
    expect(emitter.listeners('once').length).to.equal(0)
    emitter.once('once', once1)
    emitter.once('once', once1)
    emitter.once('once', once2)
    emitter.once('once2', once1)
    emitter.once('once2', once2)
    expect(emitter.listeners('once').length).to.equal(3)
    expect(emitter.listeners('once2').length).to.equal(2)

    emitter.emit('once')
    process.nextTick(->
      expect(emitter.listeners('once').length).to.equal(0)
      expect(emitter.listeners('once2').length).to.equal(2)
      emitter.emit('once2')
      process.nextTick(->
        expect(emitter.listeners('once').length).to.equal(0)
        expect(emitter.listeners('once2').length).to.equal(0)
        done()
      )
    )
  it 'should return the original callbacks when EventEmitter.listeners() is called', () ->
    emitter = new EventEmitter()
    event1 = ->
      console.log('event1')
    event2 = ->
      console.log('event2')
    event3 = ->
      console.log('event3')
    emitter.on('eventA', event1)
    emitter.on('eventA', event2)
    emitter.on('eventB', event3)
    expect(emitter.listeners('eventA').length).to.equal(2)
    expect(emitter.listeners('eventB').length).to.equal(1)
    expect(emitter.listeners('eventA')[0]).to.equal(event1)
    expect(emitter.listeners('eventA')[1]).to.equal(event2)
    expect(emitter.listeners('eventB')[0]).to.equal(event3)

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

  it 'should save data between process._nextDomainTick calls', (done) ->
    caddy.start()
    caddy.set('tag1', 1)
    process._nextDomainTick(->
      expect(caddy.get('tag1')).to.equal(1)
      expect(caddy.get('tag2')).to.not.exist
      expect(caddy.get('tag3')).to.not.exist
    )
    caddy.start()
    caddy.set('tag2', 'two')
    process._nextDomainTick(->
      expect(caddy.get('tag2')).to.equal('two')
      expect(caddy.get('tag1')).to.not.exist
      expect(caddy.get('tag3')).to.not.exist
    )
    caddy.start()
    caddy.set('tag3', [3])
    process._nextDomainTick(->
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

  it 'should save data between global.setImmediate calls', (done) ->
    caddy.start()
    caddy.set('tag1', 1)
    counter = 0
    setImmediate(->
      counter = counter + 1
      expect(caddy.get('tag1')).to.equal(1)
      expect(caddy.get('tag2')).to.not.exist
      expect(caddy.get('tag3')).to.not.exist
      if counter is 3 then done()
    )
    caddy.start()
    caddy.set('tag2', 'two')
    setImmediate(->
      counter = counter + 1
      expect(caddy.get('tag2')).to.equal('two')
      expect(caddy.get('tag1')).to.not.exist
      expect(caddy.get('tag3')).to.not.exist
      if counter is 3 then done()
    )
    caddy.start()
    caddy.set('tag3', [3])
    setInterval(->
      counter = counter + 1
      expect(caddy.get('tag3')[0]).to.equal(3)
      expect(caddy.get('tag2')).to.not.exist
      expect(caddy.get('tag1')).to.not.exist
      if counter is 3 then done()
    )

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
        req = http.get(options, (res) ->
          res.on('data', (chunk) ->
            expect(caddy.get(url)).to.equal(url)
            reqCount++
            if reqCount is urls.length
              done()
          )
        )
        req.end()
