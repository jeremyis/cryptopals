lib = require './lib'
###
Covert hex to base64.
e.g.
49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d
to
SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t
###
testFailures = 0
testFn = (input, expected) ->
  console.log "*** Testing: lib.hexToBase64(#{input})"
  res = lib.hexToBase64 input
  console.log "EXPECTED: #{expected}"
  console.log "ACTUAL  : #{res}"
  if expected isnt res
    console.log "FAILED!"
    testFailures++
  else
    console.log "Passed!"
  console.log ''

test = ->
  testFn 'a4b021', 'pLAh'
  testFn '0e4f', 'Dk8'
  testFn '12345678', 'EjRWeA'
  testFn '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d',
    'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t'
  testFn '5468697320636f756e74727920746973206f6620746865652c207377656574206c616e64206f66206c69626572747921',
    'VGhpcyBjb3VudHJ5IHRpcyBvZiB0aGVlLCBzd2VldCBsYW5kIG9mIGxpYmVydHkh'
  testFn '5468697320636f756e74727920746973206f6620746865652c207377656574206c616e64206f66206c696265727479',
    'VGhpcyBjb3VudHJ5IHRpcyBvZiB0aGVlLCBzd2VldCBsYW5kIG9mIGxpYmVydHk'
  if testFailures is 0
    console.log "SUCCESS! All tests passed."
  else
    console.log "ERROR! #{testFailures} tests failed."

test()
