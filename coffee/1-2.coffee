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
  console.log "EXPECTED: #{expected}"
  console.log "ACTUAL  : #{res}"
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
  if testFailures is 0
    console.log "SUCCESS! All tests passed."
  else
    console.log "ERROR! #{testFailures} tests failed."

test()
