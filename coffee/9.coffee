
lib = require './lib'

testPassIf = (pass) ->
  if not pass
    console.log "FAILED!"
  else
    console.log "Passed!"
  console.log ''

testPkcs7Pad = (a, to, expected) ->
  console.log "*** Testing: lib.pkcs7Pad('#{a}', #{to})"
  res = lib.pkcs7Pad a, to
  console.log "EXPECTED (hex): #{new Buffer(expected, 'utf8').toString('hex')}"
  console.log "ACTUAL  (hex): #{new Buffer(res, 'utf8').toString('hex')}"
  testPassIf expected is res

testPkcs7Pad "YELLOW SUBMARINE", 20, "YELLOW SUBMARINE\x04\x04\x04\x04"
testPkcs7Pad new Buffer("YELLOW SUBMARINE", 'ascii'), 
  20,
  new Buffer("YELLOW SUBMARINE\x04\x04\x04\x04", 'ascii')
