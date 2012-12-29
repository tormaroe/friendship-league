express = require "express"

port = 3000
app = do express

## ------------------------------------------- VIEWS
app.engine ".html", require("ejs").__express
app.set "views", __dirname + "/views"
app.set "view engine", "html"

## ------------------------------------ STATIC FILES
app.use "/static", express.static(__dirname + "/public")

app.get "/", (req, res) ->
  res.render "index", {}

app.listen port
console.log "Listening on port #{port}"
