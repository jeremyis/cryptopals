lib = require './lib'
###
Write a function that takes two equal-length buffers and produces their XOR
combination.

1c0111001f010100061a024b53535009181c xor 686974207468652062756c6c277320657965
->
746865206b696420646f6e277420706c6179
###
testFailures = 0
testFn = (a, b, expected) ->
  console.log "*** Testing: lib.fixedXor(#{a}, #{b})"
  res = lib.fixedXor a, b
  res = res.toString('hex')
  expected = expected.toString('hex')
  console.log "EXPECTED: #{expected} (#{expected.length})"
  console.log "ACTUAL  : #{res} (#{res.length})"
  if expected isnt res
    console.log "FAILED!"
    testFailures++
  else
    console.log "Passed!"
  console.log ''

test = ->
  testFn '1c0111001f010100061a024b53535009181c',
    '686974207468652062756c6c277320657965',
    '746865206b696420646f6e277420706c6179'
  testFn new Buffer('1c0111001f010100061a024b53535009181c', 'hex'),
    new Buffer('686974207468652062756c6c277320657965', 'hex'),
    new Buffer('746865206b696420646f6e277420706c6179', 'hex')
  if testFailures is 0
    console.log "SUCCESS! All tests passed."
  else
    console.log "ERROR! #{testFailures} tests failed."

test()
