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
