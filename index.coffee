express = require "express"
models = require "./models"

Recaptcha = require("recaptcha").Recaptcha

app = do express

## ---------------------------------- GENERAL CONFIG
app.use express.bodyParser()
app.use express.cookieParser("überzecret!")
app.use express.session()

port = 3000
RECAPTCHA_PUBLIC_KEY = "6Lcn6NoSAAAAACx49LIh_rj4NAMAgyilezPbtMLe"
RECAPTCHA_PRIVATE_KEY = "6Lcn6NoSAAAAAGulj9_OoR-PH8x22s_1cU1g5pNa"

## ------------------------------------------- VIEWS
app.engine ".html", require("ejs").__express
app.set "views", __dirname + "/views"
app.set "view engine", "html"

app.locals.formatDate = (d) ->
  date = d.getDate()
  month = d.getMonth() + 1
  year = d.getFullYear()
  "#{year}-#{month}-#{date}"


## ------------------------------------ STATIC FILES
app.use "/static", express.static(__dirname + "/public")


## ==================================== REQUEST HANDLERS

app.get "/", (req, res) ->
  res.render "index",
    title: "Friendship League"

renderCreateForm = (res, msg, values) ->
  recaptcha = new Recaptcha RECAPTCHA_PUBLIC_KEY, RECAPTCHA_PRIVATE_KEY
  res.render "create",
    title: "Create League"
    recaptcha: do recaptcha.toHTML
    message: msg
    values: values

app.get "/create", (req, res) ->
  renderCreateForm res

app.post "/create", (req, res) ->
  console.log "create posted"
  league =
    name: req.body.leagueName
    description: req.body.description
    email: req.body.email
    password: req.body.password
  recaptchaData =
    remoteip: req.connection.remoteAddress
    challenge: req.body.recaptcha_challenge_field
    response: req.body.recaptcha_response_field
  recaptcha = new Recaptcha RECAPTCHA_PUBLIC_KEY, RECAPTCHA_PRIVATE_KEY, recaptchaData
  recaptcha.verify (success, errorCode) ->
    if success
      models.createLeague league, (err) ->
        unless err
          res.redirect "/create-done"
        else
          renderCreateForm res, err, league
    else
      console.log "ERROR: " + errorCode
      renderCreateForm res, "CAPTCHA invalid - are you sure you're a human?", league


app.get "/create-done", (req, res) ->
  console.log "create done"
  res.render "create_done",
    title: "League created!"

app.get "/login", (req, res) ->
  res.render "login",
    title: "Sign in to Friendship League"
    message: undefined

app.post "/login", (req, res) ->
  models.authenticate req.body.email, req.body.password, (err, league) ->
    if err
      res.render "login",
        title: "Sign in to Friendship League"
        message: err
    else
      req.session.regenerate ->
        req.session.leagueId = league._id
        res.redirect "/admin"

app.get "/public/:id", (req, res) ->
  models.loadLeague req.params.id, (err, league) ->
    if err
      res.send err
    else
      res.send league.name

## ------------------------------------------- RESTRICTED HANDLERS

restrict = (req, res, next) ->
  if req.session.leagueId
    do next
  else
    res.redirect "/login"

app.get "/admin", restrict, (req, res) ->
  models.loadLeague req.session.leagueId, (err, league) ->
    if err
      res.send err
    else
      res.render "league_admin",
        title: league.name,
        league: league

app.get "/add-friend", restrict, (req, res) ->
  res.send "ADD FRIEND PAGE"

app.get "/add-event", restrict, (req, res) ->
  res.send "ADD EVENT PAGE"

app.post "/add-friend", restrict, (req, res) ->
  res.redirect "/admin"

app.post "/add-event", restrict, (req, res) ->
  res.redirect "/admin"

## ------------------------------- START SERVER

app.listen port
console.log "Listening on port #{port}"
