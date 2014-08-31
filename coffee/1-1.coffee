###
Covert hex to base64.
e.g.
49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d
to
SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t
###
hexToInt = (x) -> parseInt x, 16

TOP_HALF_MASK = 12
BOT_HALF_MASK = 3
hexToIntBase64 = (hex) ->
  # Pad to make the hex string length a multiple of threes.
  remove = 0
  if hex.length % 3 is 1
    hex += '00' # Append 1 extra base-64 'A'
    remove = 1
  else if hex.length % 3 is 2
    hex += '0000' # Appends 2 extra base-64 'A's
    remove += 2

  digits = []
  i = 0
  while i < hex.length
    vals = [ a, b, c ] = hex[i..i + 3]
    [ a, b, c ] = (hexToInt(x) for x in vals)

    digits.push (a << 2) + ((b & TOP_HALF_MASK) >> 2)
    digits.push ((b & BOT_HALF_MASK) << 4) + c

    i += 3

  # Remove extra padding if any
  console.log "Before removal " + (base64IntToChar(c) for c in digits).join ''
  digits = digits.slice(0, digits.length - remove)
  return digits

base64IntToChar = (num) ->
  if not (0 <= num < 64)
    throw new Error "Invalid base64 number #{num}."

  if num < 26
    return String.fromCharCode(num + hexToInt '0041')
  else if num < 52
    return String.fromCharCode(num - 26 + hexToInt '0061')
  else if num < 62
    return String.fromCharCode(num - 52 + hexToInt '0030')

  if num is 62
    return '+'
  if num is 63
    return '/'

hexToBase64 = (hex) ->
  if hex.length % 2 isnt 0
    throw new Error "Hex string must be contain an even number of characters."

  result = (base64IntToChar(c) for c in hexToIntBase64(hex))
  return result.join ''


testFailures = 0
testFn = (input, expected) ->
  console.log "*** Testing: hexToBase64(#{input})"
  res = hexToBase64 input
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
