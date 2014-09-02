lib = require './lib'
###
  Break repeating-key XOR
###
testPassIf = (pass) ->
  if not pass
    console.log "FAILED!"
    testFailures++
  else
    console.log "Passed!"
  console.log ''

testFailures = 0
testHammingFn = (a, b, expected) ->
  console.log "*** Testing: lib.hammingDistanceAscii('#{a}', '#{b}')"
  res = lib.hammingDistanceAscii a, b
  console.log "EXPECTED: #{expected}"
  console.log "ACTUAL  : #{res}"
  testPassIf expected is res

hammingTests = ->
  # CryptoPals Example
  testHammingFn 'this is a test', 'wokka wokka!!!', 37
  testHammingFn 'karolin', 'kathrin', 9

test = ->
  hammingTests()
  if testFailures is 0
    console.log "SUCCESS! All tests passed."
  else
    console.log "ERROR! #{testFailures} tests failed."

test()
