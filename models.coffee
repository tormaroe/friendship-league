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
    uniqueCode = "XY1234"
    callback uniqueCode
