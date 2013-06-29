
expect = require('chai').expect
sinon = require('sinon')

spyNextTick = sinon.spy(process, 'nextTick')
spySetTimeout = sinon.spy(global, 'setTimeout')
spySetInterval = sinon.spy(global, 'setInterval')

caddy = require('../dist/caddy')

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

