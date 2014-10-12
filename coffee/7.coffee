fs = require 'fs'

lib = require './lib'

###
  AES in ECB mode
###

# Contents in 7.txt is encrypted via AES-128 in ECB mode. Key: YELLOW SUBMARINE
ciphertext = lib.readFile('./7.txt')
console.log ciphertext.toString('hex')
key =  new Buffer('YELLOW SUBMARINE', 'ascii')
console.log key.toString('hex')
console.log lib.decryptAes128Ecb(ciphertext, key).toString('ascii')
#console.log require('crypto').getCiphers()

###
crypto = require('crypto')
decipher = crypto.createDecipheriv('aes-128-ecb', key, new Buffer(0))
decoded = Buffer.concat([decipher.update(ciphertext), decipher.final()])
console.log decoded.toString('ascii')
###
#console.log(.toString('utf8'))
