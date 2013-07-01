'use strict'

path = require 'path'

confs = require '../lib/conf-loader'

describe 'Coffee config loader', ->

  afterEach ->
    confs.removeAllListeners()

  it 'loads simple coffee config', ->
    conf = confs.loadSync path.join __dirname, 'conf/simple.conf'
    should.exist conf?.foo
    conf.foo.should.eq 'Foo'
    conf.bar.should.be.true


  it 'async load simple coffee config', (done) ->
    confs.load(path.join __dirname, 'conf/simple.conf').on 'updated', (conf) ->
      should.exist conf?.foo
      conf.foo.should.eq 'Foo'
      conf.bar.should.be.true
      done()

    confs.on 'error', done


  it 'async load invalid coffee config, error event emitted', (done) ->
    confs.load(path.join __dirname, 'conf/error.conf').on 'error', (err) -> done null
    confs.on 'updated', -> done 'updated event is not expected to emit'

