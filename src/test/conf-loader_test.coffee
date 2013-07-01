'use strict'

fs   = require 'fs'
path = require 'path'

confs = require '../lib/conf-loader'

describe 'Coffee config loader', ->

  afterEach ->
    confs.removeAllListeners()

    tmp = path.join __dirname, 'conf/tmp'
    # fs.unlinkSync tmp if fs.existsSync(tmp)


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


  it 'emit updated event when config file updated', (done) ->
    this.timeout 0
    tmp = path.join __dirname, 'conf/tmp'
    content = """
    conf =
      a: 1
      b: 2
    """
    fs.writeFileSync tmp, content

    updated = 0

    confs.load(tmp).on 'updated', (conf) ->
      console.log 'updated:', updated, conf
      conf.a.should.eq 1
      conf.b.should.eq 2
      switch updated
        when 1
          conf.c.should.eq 3
        when 2
          conf.d.should.eq 4
          done()

    update = (ln) ->
      fs.appendFileSync tmp, ln
      updated++

    setTimeout update, 50, "\n  c: 3\n"
    setTimeout update, 100, "\n  d: 4\n"
