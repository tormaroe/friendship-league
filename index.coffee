express = require "express"
Db = require("mongodb").Db
Connection = require("mongodb").Connection
Server = require("mongodb").Server

port = 3000
app = do express

## ------------------------------------------- VIEWS
app.engine ".html", require("ejs").__express
app.set "views", __dirname + "/views"
app.set "view engine", "html"

## ------------------------------------ STATIC FILES
app.use "/static", express.static(__dirname + "/public")

app.get "/", (req, res) ->
  Db.connect "mongodb://localhost/fleague", (err, db) ->
    console.log "Connected.."
    db.collection "leagues", (err, collection) ->
      console.log "Inserting document.."
      collection.insert {"a": 1}

  res.render "index", {}

app.listen port
console.log "Listening on port #{port}"
