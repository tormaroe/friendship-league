express = require "express"
models = require "./models"

app = do express

## ---------------------------------- GENERAL CONFIG
port = 3000
app.use express.bodyParser()

## ------------------------------------------- VIEWS
app.engine ".html", require("ejs").__express
app.set "views", __dirname + "/views"
app.set "view engine", "html"

## ------------------------------------ STATIC FILES
app.use "/static", express.static(__dirname + "/public")


## ==================================== REQUEST HANDLERS

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
    password: req.body.password
  models.createLeague league, ->
    res.redirect "/create-done"

app.get "/create-done", (req, res) ->
  console.log "create done"
  res.render "create_done", {
    title: "League created!"
  }

## ------------------------------- START SERVER

app.listen port
console.log "Listening on port #{port}"
