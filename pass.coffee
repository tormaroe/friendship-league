crypto = require "crypto"

len = 128
iterations = 12000

exports.hash = (pwd, salt, fn) ->
  if arguments.length == 3
    crypto.pbkdf2 pwd, salt, iterations, len, fn
  else
    fn = salt
    crypto.randomBytes len, (err, salt) ->
      return fn(err) if err
      salt = salt.toString "base64"
      crypto.pbkdf2 pwd, salt, iterations, len, (err, hash) ->
        return fn(err) if err
        fn null, salt, hash
