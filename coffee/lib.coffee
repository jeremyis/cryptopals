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

exports.hexToBase64 = (hex) ->
  if hex.length % 2 isnt 0
    throw new Error "Hex string must be contain an even number of characters."

  result = (base64IntToChar(c) for c in hexToIntBase64(hex))
  return result.join ''

