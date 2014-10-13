fs = require 'fs'

lib = require './lib'

ciphertexts = lib.readFileByLine('./8.txt', 'hex')
results = lib.whichCiphersAreFromAesWithEcb ciphertexts
pretty = ({score: r.score, ciphertext: r.ciphertext.toString('hex')} for r in results[0..10] when r.score > 0)
console.log pretty
