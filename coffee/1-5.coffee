lib = require './lib'
###
Repeating-key XOR
e.g.
Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal
to
0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272
a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f
###
testFailures = 0
testFn = (input, key, expected) ->
  console.log "*** Testing: lib.repeatingKeyXor(#{input}, #{key})"
  res = lib.repeatingKeyXor input, key
  console.log "EXPECTED: #{expected} (#{expected?.length})"
  console.log "ACTUAL  : #{res} (#{res?.length})"
  if expected isnt res
    console.log "FAILED!"
    testFailures++
  else
    console.log "Passed!"
  console.log ''

test = ->
  # This is failing and I wonder if it's because of the newline??
  res =
    '0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f'
  testFn "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal", "ICE", res
  if testFailures is 0
    console.log "SUCCESS! All tests passed."
  else
    console.log "ERROR! #{testFailures} tests failed."

test()
