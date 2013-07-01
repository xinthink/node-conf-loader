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

fns = require './common'


class CoffeeConfLoader extends events.EventEmitter

  loadSync: (f) -> @evalConf fs.readFileSync f, 'utf-8'


  load: (f) ->
    self = this
    fs.readFile f, 'utf-8', (err, data) ->
      return self.emit 'error', err if err

      try
        self.emit 'updated', self.evalConf data
      catch e
        self.emit 'error', e

    this


  evalConf: (content) ->
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


module.exports = new CoffeeConfLoader
