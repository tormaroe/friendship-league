express = require "express"
models = require "./models"

Recaptcha = require("recaptcha").Recaptcha

app = do express

## ---------------------------------- GENERAL CONFIG
port = 3000
app.use express.bodyParser()
RECAPTCHA_PUBLIC_KEY = "6Lcn6NoSAAAAACx49LIh_rj4NAMAgyilezPbtMLe"
RECAPTCHA_PRIVATE_KEY = "6Lcn6NoSAAAAAGulj9_OoR-PH8x22s_1cU1g5pNa"

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

renderCreateForm = (res, msg) ->
  recaptcha = new Recaptcha RECAPTCHA_PUBLIC_KEY, RECAPTCHA_PRIVATE_KEY
  res.render "create", {
    title: "Create League"
    recaptcha: do recaptcha.toHTML
  }

app.get "/create", (req, res) ->
  renderCreateForm res, ""

app.post "/create", (req, res) ->
  console.log "create posted"
  recaptchaData =
    remoteip: req.connection.remoteAddress
    challenge: req.body.recaptcha_challenge_field
    response: req.body.recaptcha_response_field
  recaptcha = new Recaptcha RECAPTCHA_PUBLIC_KEY, RECAPTCHA_PRIVATE_KEY, recaptchaData
  recaptcha.verify (success, errorCode) ->
    if success
      league =
        name: req.body.leagueName
        description: req.body.description
        email: req.body.email
        password: req.body.password
      models.createLeague league, ->
        res.redirect "/create-done"
    else
      console.log "ERROR: " + errorCode
      renderCreateForm res, "CAPTCHA invalid - are you sure you're a human?"


app.get "/create-done", (req, res) ->
  console.log "create done"
  res.render "create_done", {
    title: "League created!"
  }

## ------------------------------- START SERVER

app.listen port
console.log "Listening on port #{port}"
