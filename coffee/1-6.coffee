fs = require 'fs'

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

#test()

# Read in file and base-64 decode it.
code = fs.readFileSync './6.txt', 'utf-8'
hexCiphertext = new Buffer(code, 'base64').toString('hex')
console.log "CipherText length: #{hexCiphertext.length}"
console.log lib.breakRepeatingKeyXor hexCiphertext

# Solve each block as if it was single-character XOR. You already have code to
# do this.

# For each block, the single-byte XOR key that produces the best looking
# histogram is the repeating-key XOR key byte for that block. Put them
# together and you have the key.
