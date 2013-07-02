###

https://github.com/xinthink/node-conf-loader

Copyright (c) 2013 xinthink
Licensed under the MIT license.

###

'use strict'

fs     = require 'fs'
path   = require 'path'
assert = require 'assert'
events = require 'events'

coffee = require 'coffee-script'


class CoffeeConfLoader extends events.EventEmitter

  loadSync: (f, locals={}) ->
    addGlobals f, locals
    watchConfFile f, @, @_loadFile, locals
    @_evalConf fs.readFileSync(f, 'utf-8'), locals


  load: (f, locals={}) ->
    addGlobals f, locals
    @_loadFile f, locals
    watchConfFile f, @, @_loadFile, locals
    this


  _loadFile: (f, locals) ->
    self = this

    fs.readFile f, 'utf-8', (err, data) ->
      return self.emit 'error', err if err

      try
        self.emit 'ready', self._evalConf data, locals
      catch e
        self.emit 'error', e


  _evalConf: (content, locals) ->
    content = """#{content}
    return conf
    """

    code = """var conf = {};
    with (locals) {
      return #{coffee.compile content}
    }
    """

    fn = new Function 'locals', code
    fn locals


addGlobals = (f, locals) ->
  locals.__dirname = path.dirname f
  locals.require   = require
  locals.global    = global
  locals.process   = process
  locals.module    = module
  locals.console   = console


watchConfFile = (f, obj, cb, args...) ->
  fs.watch f, (event, filename) ->
    switch event
      when 'change'
        cb.apply obj, [f].concat args
      else
        console.warn "unhandled confile file event: #{event}, #{f} -> #{filename}"


module.exports = new CoffeeConfLoader
