###

https://github.com/xinthink/node-conf-loader

Copyright (c) 2013 xinthink
Licensed under the MIT license.

###

'use strict'


# merge a with b
exports.merge = (a, b) ->
  result = {}
  pushAll result, a
  pushAll result, b


# push all props of values into target
exports.pushAll = pushAll = (target, values) ->
  target[k] = v for k, v of values if values?
  target
