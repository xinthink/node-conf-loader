'use strict'

global.sinon          = require 'sinon'
global.chai           = require 'chai'
global.should         = require('chai').should()
global.expect         = require('chai').expect
global.AssertionError = require('chai').AssertionError

global.spy  = sinon.spy
global.stub = sinon.stub

global.swallow = (thrower) ->
  try
    thrower()
  catch e
    # ignores

chai.use require 'sinon-chai'
