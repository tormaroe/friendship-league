hash = require("./pass").hash

Db = require("mongodb").Db
Connection = require("mongodb").Connection
Server = require("mongodb").Server
ObjectID = require("mongodb").ObjectID

dbName = "fleague"

withCollection = (colName, fn) ->
  Db.connect "mongodb://localhost/" + dbName, (err, db) ->
    db.collection colName, (err, collection) ->
      fn collection

exports.createLeague = (league, callback) ->
  withCollection "leagues", (coll) ->
    coll.findOne { email: league.email }, (err, doc) ->
      if err
        callback err
      else if doc
        callback "Sorry, a league is already registered for the given email address!"
      else
        console.log "CREATE LEAGUE " + league.name
        hash league.password, (err, salt, hash) ->
          throw err if err
          league.hash = hash
          league.salt = salt
          league.created = new Date()
          league.last_login = null
          league.login_count = 0
          delete league.password

          coll.insert league, (err, doc) ->
            callback err

exports.authenticate = (email, pass, fn) ->
  withCollection "leagues", (coll) ->
    coll.findOne { email: email }, (err, league) ->
      return fn(err) if err
      return fn("No league found for that email address") unless league
      hash pass, league.salt, (err, hash) ->
        return fn(err) if err
        return fn(null, league) if hash == league.hash
        fn "Invalid password"

exports.loadLeague = (id, fn) ->
  withCollection "leagues", (coll) ->
    coll.findOne { _id: new ObjectID(id) }, (err, league) ->
      return fn(err) if err
      return fn("404") unless league
      return fn(null, league)
      
