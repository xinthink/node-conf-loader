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


###
The loader that use Coffee-script as config files.
The configures will be watched and reloaded automatically, and events will be emitted.
@event ready when configures be loaded or reloaded
@event error
###
class CoffeeConfLoader extends events.EventEmitter

  ###
  Synchronous version of <code>load</code>.
  @param f [String] path of the config file (coffee-script)
  @param locals [Object] additional variables should be seen by the config file
  @return configures
  @see load
  ###
  loadSync: (f, locals={}) ->
    @file = f
    addGlobals f, locals
    watchConfFile f, @, @_loadFile, locals
    @_evalConf fs.readFileSync(f, 'utf-8'), locals


  ###
  Async load and watchs a config file.
  When configures loaded (at the first time) or changed, a 'ready' event will be emitted.
  @param f [String] path of the config file (coffee-script)
  @param locals [Object] additional variables should be seen by the config file
  ###
  load: (f, locals={}) ->
    @file = f
    addGlobals f, locals
    @_loadFile f, locals
    watchConfFile f, @, @_loadFile, locals
    this


  ###
  Stop watching the config file.
  All listeners to this conf-loader instance will also be removed
  ###
  stopWatching: -> @removeAllListeners()


  ###
  Remove all config listeners
  @override
  ###
  removeAllListeners: ->
    super()
    fs.unwatchFile @file


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


###
Prepare global variables the config file has access.
@param f [String] the config file
@param locals [Object] the target container to inject globals
###
addGlobals = (f, locals) ->
  locals.__dirname = path.dirname f
  locals.require   = require
  locals.global    = global
  locals.process   = process
  locals.module    = module
  locals.console   = console


###
Callback when file changes.
@param f [String] file to watch
@param obj [Object] the context of callback function
@param cb [Function] the function to be invoked when file changes
@param args... [Any] callback function arguments
###
watchConfFile = (f, obj, cb, args...) ->
  fs.watch f, (event, filename) ->
    switch event
      when 'change'
        cb.apply obj, [f].concat args
      else
        console.warn "unhandled confile file event: #{event}, #{f} -> #{filename}"


module.exports = new CoffeeConfLoader
