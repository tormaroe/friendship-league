express = require "express"
models = require "./models"


app = do express

## ---------------------------------- GENERAL CONFIG
port = 3000

## ------------------------------------------- VIEWS
app.engine ".html", require("ejs").__express
app.set "views", __dirname + "/views"
app.set "view engine", "html"

## ------------------------------------ STATIC FILES
app.use "/static", express.static(__dirname + "/public")

app.use express.bodyParser()

app.get "/", (req, res) ->
  res.render "index", {
    title: "Friendship League"
  }

app.get "/create", (req, res) ->
  res.render "create", {
    title: "Create League"
  }

app.post "/create", (req, res) ->
  console.log "create posted"
  league =
    name: req.body.leagueName
    description: req.body.description
    email: req.body.email
  models.createLeague league, ->
    res.send "ok"

app.listen port
console.log "Listening on port #{port}"
