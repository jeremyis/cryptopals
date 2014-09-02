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

###
  Takes a hex string (no spaces) of even length and converts it to
  base-64 (no padding).
###
exports.hexToBase64 = (hex) ->
  if hex.length % 2 isnt 0
    throw new Error "Hex string must be contain an even number of characters."

  result = (base64IntToChar(c) for c in hexToIntBase64(hex))
  return result.join ''

###
  Takes two equal-length hex buffers and produces their XOR.
###
exports.fixedXor = (hexA, hexB) ->
  if hexA.length isnt hexB.length
    throw new Error "fixedXor can only operate on two equal-length strings."

  results = []
  for i in [0...hexA.length]
    results.push (parseInt(hexA[i], 16) ^ parseInt(hexB[i], 16)).toString(16)
  return results.join('')


SIG_CHARS = "ETAOIN SHRDLU"
SIG_CHARS += SIG_CHARS.toLowerCase().split(' ').join('')
temp = {}
for char in SIG_CHARS
  temp[ char.charCodeAt(0) ] = char
# Map of ASCII char codes (int) we're scoring for to value
SIG_CHARS = temp
scoreChar = (num) ->
  if SIG_CHARS[num] then return 1
  return 0

###
  Gives text a score between [0, 100]. A higher score means the message is
  more likely English text.
###
scoreText = (text) ->
  score = 0
  i = 0
  while i < text.length
    char = text[i] + text[i+1]
    score += scoreChar parseInt(char, 16)
    i += 2
  #console.log "score: #{score} / #{text.length}"
  score = Math.floor(100 * score / text.length / 2.0)
  #console.log "score now: #{score}"
  return score

exports.hexToAscii = (hex) ->
  result = []
  i = 0
  while i < hex.length
    char = hex[i] + hex[i+1]
    result.push String.fromCharCode parseInt(char, 16)
    i += 2
  return result.join ''

padHex = (c)-> if c.length is 1 then "0#{c}" else c
asciiToHex = (ascii) ->
  result = []
  for c in ascii
    result.push padHex c.charCodeAt(0).toString(16)
  return result.join ''

###
  Xor str by every character and determine which is the correct cipher by
  using a letter frequency count.
###
exports.singleByteXorCipher = (str, verbose=true)->
  if not str?
    str = '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'
  if str.length % 2 isnt 0
    throw new Error "Str is supposed to represent text so should be a multiple of 2."

  # Go through 1 -> 2^8 - 1, and xor str
  # Count number of alphanumeric chars (in ascii). Sort by that. Print out
  # top 3.
  # Maybe there are a lot of letters, if so, try something smarter with letter freq.
  # http://en.wikipedia.org/wiki/Letter_frequency

  # Is it xored against literally a single character or a single character repeated?
  scored = []
  for i in [0..2**8-1]
    hex = padHex i.toString(16)
    cipher = Array(str.length/2 + 1).join hex
    #console.log cipher
    #console.log "#{cipher.length} #{str.length}"

    message = exports.fixedXor(str, cipher)
    score = scoreText(message)
    scored.push {
      char: i
      score
      message: exports.hexToAscii message
    }

  scored = scored.sort (a, b) ->
    if a.score > b.score then return -1
    if b.score > a.score then return 1
    return 0

  if verbose
    for val in scored[0..5]
      { char, score, message } = val
      console.log "Score #{score}. Char #{char} (#{String.fromCharCode char}). Message: #{message}"

  return scored

###
  Accepts an array of same-length strings and returns the top rank for a
  single-cipher xor brute-force.
###
exports.whichStringIsEncrypted = (candidates, verbose = true) ->
  if not candidates?
    throw new Error "No input supplied!"

  len = candidates[0].length
  for candidate in candidates
    if candidate.length isnt len
      throw new Error "Candidates must have the same length. First is #{len}. Entry has #{candidate.length}. #{candidate}"

  results = []
  for candidate in candidates
    results = results.concat exports.singleByteXorCipher(candidate, false)

  results = results.sort (a, b) ->
    if a.score > b.score then return -1
    if b.score > a.score then return 1
    return 0

  if verbose
    for val in results[0..10]
      { char, score, message } = val
      console.log "Score #{score}. Char #{char} (#{String.fromCharCode char}). Message: #{message}"
  return results

exports.repeatingKeyXorAscii = (plaintext, key) ->
  hex = asciiToHex plaintext
  exports.repeatingKeyXor hex, key

exports.repeatingKeyXor = (hex, key) ->
  keyHexNums = (c.charCodeAt(0) for c in key)

  code = []
  keyIndex = 0
  i = 0
  while i < hex.length
    c = hex[i] + hex[i+1]
    k = keyHexNums[ keyIndex % key.length ]
    #console.log "#{k} ^ #{parseInt c, 16} (#{c})"
    val = padHex (parseInt(c, 16) ^ k).toString(16)
    #console.log "#{i}) #{String.fromCharCode parseInt(c, 16)} ^ #{String.fromCharCode k} = #{val}"
    code.push val
    keyIndex++
    i += 2
  return code.join ''
