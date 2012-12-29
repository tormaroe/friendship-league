express = require "express"

port = 3000
app = do express

app.engine ".html", require("ejs").__express
app.set "views", __dirname + "/views"
app.set "view engine", "html"

app.get "/", (req, res) ->
  res.render "index", {}

app.listen port
console.log "Listening on port #{port}"
