lib = require './lib'

ciphertext = lib.readFile '10.txt'

key = 'YELLOW SUBMARINE'
iv = new Buffer( (0 for x in [0...key.length]) )
results = lib.decryptAes128Cbc ciphertext, iv, key
console.log results.toString('ascii')
