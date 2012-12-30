hash = require("./pass").hash

Db = require("mongodb").Db
Connection = require("mongodb").Connection
Server = require("mongodb").Server

dbName = "fleague"

withCollection = (colName, fn) ->
  Db.connect "mongodb://localhost/" + dbName, (err, db) ->
    db.collection colName, (err, collection) ->
      fn collection

exports.createLeague = (league, callback) ->
  withCollection "leagues", (coll) ->
    console.log "CREATE LEAGUE " + league.name
    # TODO: validate that email is unique
    hash league.password, (err, salt, hash) ->
      throw err if err
      league.hash = hash
      league.salt = salt
      league.created = new Date()
      league.last_login = null
      league.login_count = 0
      delete league.password

      coll.insert league, (err, doc) ->
        do callback

exports.authenticate = (email, pass, fn) ->
  withCollection "leagues", (coll) ->
    coll.findOne { email: email }, (err, league) ->
      console.log err
      return fn(err) if err
      console.log "FOO"
      return fn("No league found") unless league
      console.log "BAR"
      hash pass, league.salt, (err, hash) ->
        return fn(err) if err
        return fn(null, league) if hash == league.hash
        fn "Invalid password"


