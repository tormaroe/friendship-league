express = require "express"
Db = require("mongodb").Db
Connection = require("mongodb").Connection
Server = require("mongodb").Server

app = do express

## ---------------------------------- GENERAL CONFIG
port = 3000
dbName = "fleague"

## ------------------------------------------- VIEWS
app.engine ".html", require("ejs").__express
app.set "views", __dirname + "/views"
app.set "view engine", "html"

## ------------------------------------ STATIC FILES
app.use "/static", express.static(__dirname + "/public")

app.get "/", (req, res) ->
  Db.connect "mongodb://localhost/" + dbName, (err, db) ->
    console.log "Connected.."
    db.collection "leagues", (err, collection) ->
      console.log "Inserting document.."
      collection.insert {"a": 1}

  res.render "index", {
    title: "Friendship League"
  }

app.get "/create", (req, res) ->
  res.render "create", {
    title: "Create League"
  }

app.post "/create", (req, res) ->
  console.log "create posted"
  res.send "ok"

app.listen port
console.log "Listening on port #{port}"
