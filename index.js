// Generated by CoffeeScript 1.3.3
(function() {
  var Connection, Db, Server, app, express, port;

  express = require("express");

  Db = require("mongodb").Db;

  Connection = require("mongodb").Connection;

  Server = require("mongodb").Server;

  port = 3000;

  app = express();

  app.engine(".html", require("ejs").__express);

  app.set("views", __dirname + "/views");

  app.set("view engine", "html");

  app.use("/static", express["static"](__dirname + "/public"));

  app.get("/", function(req, res) {
    Db.connect("mongodb://localhost/fleague", function(err, db) {
      console.log("Connected..");
      return db.collection("leagues", function(err, collection) {
        console.log("Inserting document..");
        return collection.insert({
          "a": 1
        });
      });
    });
    return res.render("index", {});
  });

  app.listen(port);

  console.log("Listening on port " + port);

}).call(this);