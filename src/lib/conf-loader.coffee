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

  loadSync: (f) ->
    watchConfFile f, @_loadFile
    @_evalConf fs.readFileSync f, 'utf-8'


  load: (f) ->
    @_loadFile f
    watchConfFile f, @, @_loadFile
    this


  _loadFile: (f) ->
    self = this

    fs.readFile f, 'utf-8', (err, data) ->
      return self.emit 'error', err if err

      try
        self.emit 'updated', self._evalConf data
      catch e
        self.emit 'error', e


  _evalConf: (content) ->
    content = """#{content}
    return conf
    """

    code = """'use strict';
    return #{coffee.compile content}
    """

    fn = new Function code
    fn.require = require
    fn.global  = global
    fn.process = process
    fn.module  = module
    fn.console = console
    fn()


watchConfFile = (f, obj, cb) ->
  fs.watch f, (event, filename) ->
    switch event
      when 'change'
        cb.call obj, f
      else
        console.warn "unhandled confile file event: #{event}, #{f} -> #{filename}"


module.exports = new CoffeeConfLoader
