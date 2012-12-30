// Generated by CoffeeScript 1.3.3
(function() {
  var Connection, Db, Server, dbName, hash, withCollection;

  hash = require("./pass").hash;

  Db = require("mongodb").Db;

  Connection = require("mongodb").Connection;

  Server = require("mongodb").Server;

  dbName = "fleague";

  withCollection = function(colName, fn) {
    return Db.connect("mongodb://localhost/" + dbName, function(err, db) {
      return db.collection(colName, function(err, collection) {
        return fn(collection);
      });
    });
  };

  exports.createLeague = function(league, callback) {
    return withCollection("leagues", function(coll) {
      console.log("CREATE LEAGUE " + league.name);
      return hash(league.password, function(err, salt, hash) {
        if (err) {
          throw err;
        }
        league.hash = hash;
        league.salt = salt;
        league.created = new Date();
        league.last_login = null;
        league.login_count = 0;
        delete league.password;
        return coll.insert(league, function(err, doc) {
          console.log("_id: " + doc._id);
          return callback();
        });
      });
    });
  };

}).call(this);
