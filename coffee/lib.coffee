crypto = require 'crypto'
fs = require 'fs'
# TODO: it's confusing dealing with ASCII, hex, base64, decimal representation,
# etc. Really, I should just make a "Buffer" class that handles all these
# interpretations and the respective operations.
# Note: this is EXACTLY what the Node.JS Buffer class does. D'oh.
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

  [aIsString, bIsString] = [typeof hexA is 'string', typeof hexB is 'string']

  a = if aIsString then new Buffer(hexA, 'hex') else hexA
  b = if bIsString then new Buffer(hexB, 'hex') else hexB

  if a.length isnt b.length
    throw new Error "fixedXor can only operate on two equal-length strings."

  results = []
  for i in [0...a.length]
    results.push (a[i] ^ b[i])
  results = new Buffer(results)

  if aIsString or bIsString then results.toString('hex') else results


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

exports.hexToAscii = hexToAscii = (hex) ->
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
    throw new Error "Str is supposed to represent text so should be a multiple of 2. Is: #{str.length}"

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
      message: hexToAscii message
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

exports.hammingDistanceAscii = (asciiA, asciiB) ->
  a = asciiToHex asciiA
  b = asciiToHex asciiB
  hammingDistance a, b

hammingDistance = (hexA, hexB) ->
  if hexA.length isnt hexB.length
    throw new Error "Hamming distance between two unequal strings #{hexA.length} and #{hexB.length}"

  dist = 0
  i = 0
  while i < hexA.length
    a = (hexA[i] + hexA[i+1])
    b = (hexB[i] + hexB[i+1])

    diffs = parseInt(a, 16) ^ parseInt(b, 16)
    while diffs > 0
      dist += diffs & 1
      diffs = diffs >>> 1
    #console.log "#{i/2 + 1} char: #{parseInt(a, 16)} (#{parseInt(a, 16).toString(2)}) ^ #{parseInt(b, 16)} (#{parseInt(b, 16).toString(2)}). #{dist}"
    i += 2
  return dist

# TODO: test these guys
padSoDivisble = (dividend, divisor, char=0) ->
  padTo(dividend, dividend.length + (dividend.length % divisor), char)
padTo = (text, to, char) ->
  return text if text.length is to

  #console.log "appending: #{divisor}, #{remainder}, #{Array(divisor - remainder + 1).join char}"

  appendage = (char for x in [0...(text.length - to)])
  if text instanceof Buffer
    Buffer.concat([ text, new Buffer(appendage) ]) 
  else
    "#{text}#{appendage.join ''}"

class BreakRepeatingKeyXor
  # For each KEYSIZE, take the first KEYSIZE worth of bytes, and the second
  # KEYSIZE worth of bytes, and find the edit distance between them.
  # Normalize this result by dividing by KEYSIZE.
  #
  # The KEYSIZE with the smallest normalized edit distance is probably the key.
  # You could proceed perhaps with the smallest 2-3 KEYSIZE values.
  getPossibleKeyLengths = (hexCiphertext) ->
    lenScores = {}
    console.log "ciphertext: #{hexCiphertext.length}"
    # KEYSIZE is in NIBBLES (half bytes)
    for KEYSIZE in [4..80] when KEYSIZE % 2 is 0
      [ a, b ] = [ hexCiphertext[0...KEYSIZE], hexCiphertext[KEYSIZE...2*KEYSIZE] ]
      lenScores[ hammingDistance(a, b) / 2*KEYSIZE ] = KEYSIZE / 2
    console.log lenScores
    (lenScores[i] for i in Object.keys(lenScores).sort())

  # Or take 4 KEYSIZE blocks instead of 2 and average the distances.
  # Returns length in bytes.
  getKeyLength = (hexCiphertext) ->
    lenScores = {}
    console.log "ciphertext: #{hexCiphertext.length}"
    # KEYSIZE is in NIBBLES (half bytes)
    for KEYSIZE in [4..80] when KEYSIZE % 2 is 0

      # Take the a bunch of KEYSIZE blocks.
      blocks = []
      for i in [1..12]
        blocks.push hexCiphertext[i*KEYSIZE...(i+1)*KEYSIZE]

      # Average their hamming distance.
      total = 0
      count = 0
      for outer, i in blocks
        for j in [i + 1...blocks.length]
          total += hammingDistance(outer, blocks[j])
          count++
      average = total / count

      lenScores[ average / KEYSIZE / 2 ] = KEYSIZE / 2
    console.log lenScores
    (lenScores[i] for i in Object.keys(lenScores).sort())[0]

  # Now that you probably know the KEYSIZE: break the ciphertext into blocks
  # of KEYSIZE length.
  # Now transpose the blocks: make a block that is the first byte of every block,
  # and a block that is the second byte of every block, and so on.
  #
  # e.g.:
  # 1d421f4d0b0f021f4f134e3c1a69651f491c0e4e for KEYSIZE = 5
  # or
  # 1d 42 1f 4d 0b
  # 0f 02 1f 4f 13
  # 4e 3c 1a 69 65
  # 1f 49 1c 0e 4e
  # yields =>
  # [ [ '1d', '0f', '4e', '1f' ],
  #   [ '42', '02', '3c', '49' ],
  #   [ '1f', '1f', '1a', '1c' ],
  #   [ '4d', '4f', '69', '0e' ],
  #   [ '0b', '13', '65', '4e' ] ]
  ##
  getTransposedBlocks = (hexCiphertext, size) ->
    blocks = []
    #hexCiphertext = padSoDivisble hexCiphertext, size*2
    i = 0
    while i < hexCiphertext.length
      group = (i / 2) % size
      if blocks.length - 1 < group
        blocks.push []
      blocks[ group ].push( hexCiphertext[i] + hexCiphertext[i+1] )
      i += 2
    return blocks

  @run: (hexCiphertext) ->
    #possibleKeyLengths = getPossibleKeyLengths(hexCiphertext)
    possibleKeyLengths = [ getKeyLength(hexCiphertext) ]
    console.log "Possible Key Lengths: #{possibleKeyLengths}"
    keys = ('' for k in possibleKeyLengths)
    scores = (0 for k in possibleKeyLengths)
    for keyLength, keyId in possibleKeyLengths
      for block, i in getTransposedBlocks hexCiphertext, keyLength
        console.log "############################################"
        # For a given keyLength, what character yields the best histogram?
        blockString = block.join ''
        #console.log "block: #{block} | #{block.length}"
        console.log "KeyLength: #{keyLength}. Block #{i}"
        [ {char, score}, ...] = exports.singleByteXorCipher(blockString, false)
        console.log "KeyLength: #{keyLength}. Block #{i}. Char: #{char}. Score: #{score}"
        keys[ keyId ] = keys[keyId] + String.fromCharCode(char)
        scores[ keyId ] += score

    console.log scores
    console.log keys
    for key in keys
      console.log "################### For #{key}"
      console.log hexToAscii exports.repeatingKeyXor hexCiphertext, key
    return keys

exports.breakRepeatingKeyXor = BreakRepeatingKeyXor.run

exports.readFile = (file, format='base64') ->
  new Buffer(fs.readFileSync(file, 'utf8').split("\n").join(''), format)

exports.readFileByLine = (file, format='base64', splitOn="\n") ->
  (new Buffer(x, format) for x in fs.readFileSync(file, 'utf8').split(splitOn))

exports.decryptAes128Ecb = (ciphertext, key) ->
  ecbDecrypt('aes128', 128, ciphertext, key)

ecbDecrypt = (cipher, blockSize, buf, key) ->
  if buf.length * 8 % blockSize isnt 0
    throw new Error("Buffer (#{buf.length*8}) bits) must be divisible by block size (#{blockSize} bits)")

  i = 0
  decrypted = []
  blockSizeBytes = blockSize / 8
  while i*blockSizeBytes < buf.length
    data = buf.slice(i * blockSizeBytes, (i+1) * blockSizeBytes)

    iv = new Buffer( (0 for x in [0...16]) )
    decipher = crypto.createDecipheriv(cipher, key, iv)
    decipher.setAutoPadding(false) # D'oh this was needed
    decrypted.push Buffer.concat([ decipher.update(data), decipher.final() ])
    i++
  Buffer.concat decrypted

# Return [ {block, freq} ]
histogramOfRepeatedBlocks = (text, blockSize) ->
  padded = padSoDivisble(text, blockSize)
  blocks = {}
  #console.log "text.length = #{text.length}"
  #console.log "padded.length = #{padded.length}"
  for i in [0...padded.length/blockSize]
    block = padded.slice(i*blockSize, (i+1)*blockSize).toString('hex')
    #console.log "#{i*blockSize} -> #{(i+1)*blockSize}. = #{block}"
    blocks[block] ?= 0
    blocks[block]++

  blocks = ({ block: block.toString('hex'), freq, text: text.toString('hex') } for block, freq of blocks)
  return blocks

scoreForAesWithEcb = (text, blockSize) ->
  padded = padSoDivisble(text, blockSize)
  blocks = {}
  #console.log "text.length = #{text.length}"
  #console.log "padded.length = #{padded.length}"
  for i in [0...padded.length/blockSize]
    block = padded.slice(i*blockSize, (i+1)*blockSize).toString('hex')
    #console.log "#{i*blockSize} -> #{(i+1)*blockSize}. = #{block}"
    blocks[block] ?= 0
    blocks[block]++
  score = 0
  for block, freq of blocks when freq > 1 then score += freq

  return score

###
  Accepts an array of buffers.
  Returns an array of {score: Number, ciphertext: String} sorted in descended
    by score. Score indicates likelihood of the text being encrypted by AES with
    ECB.
###
exports.whichCiphersAreFromAesWithEcb = (ciphertexts) ->
  results = []
  for c,i in ciphertexts
    for blockSize in [4...c.length/2]
      #console.log "#{i} for size #{blockSize}"
      results = results.concat {score: scoreForAesWithEcb(c, blockSize), ciphertext: c}
  results.sort (a, b) -> return b.score - a.score
  return results
  # The (key, ciphertext) with the most repeated blocks is AES in ECB.

exports.pkcs7Pad = (message, to) ->
  padTo(message, to, String.fromCharCode(4))
