fs = require 'fs'

lib = require './lib'
fs.readFile './4.txt', 'utf-8', (error, buf) ->
  candidates = buf.split("\n")
  candidates = candidates[0...candidates.length-1]
  lib.whichStringIsEncrypted candidates
