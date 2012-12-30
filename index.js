// Generated by CoffeeScript 1.3.3
(function() {
  var RECAPTCHA_PRIVATE_KEY, RECAPTCHA_PUBLIC_KEY, Recaptcha, app, express, models, port, renderCreateForm, restrict;

  express = require("express");

  models = require("./models");

  Recaptcha = require("recaptcha").Recaptcha;

  app = express();

  app.use(express.bodyParser());

  app.use(express.cookieParser("überzecret!"));

  app.use(express.session());

  port = 3000;

  RECAPTCHA_PUBLIC_KEY = "6Lcn6NoSAAAAACx49LIh_rj4NAMAgyilezPbtMLe";

  RECAPTCHA_PRIVATE_KEY = "6Lcn6NoSAAAAAGulj9_OoR-PH8x22s_1cU1g5pNa";

  app.engine(".html", require("ejs").__express);

  app.set("views", __dirname + "/views");

  app.set("view engine", "html");

  app.use("/static", express["static"](__dirname + "/public"));

  app.get("/", function(req, res) {
    return res.render("index", {
      title: "Friendship League"
    });
  });

  renderCreateForm = function(res, msg, values) {
    var recaptcha;
    recaptcha = new Recaptcha(RECAPTCHA_PUBLIC_KEY, RECAPTCHA_PRIVATE_KEY);
    return res.render("create", {
      title: "Create League",
      recaptcha: recaptcha.toHTML(),
      message: msg,
      values: values
    });
  };

  app.get("/create", function(req, res) {
    return renderCreateForm(res);
  });

  app.post("/create", function(req, res) {
    var league, recaptcha, recaptchaData;
    console.log("create posted");
    league = {
      name: req.body.leagueName,
      description: req.body.description,
      email: req.body.email,
      password: req.body.password
    };
    recaptchaData = {
      remoteip: req.connection.remoteAddress,
      challenge: req.body.recaptcha_challenge_field,
      response: req.body.recaptcha_response_field
    };
    recaptcha = new Recaptcha(RECAPTCHA_PUBLIC_KEY, RECAPTCHA_PRIVATE_KEY, recaptchaData);
    return recaptcha.verify(function(success, errorCode) {
      if (success) {
        return models.createLeague(league, function(err) {
          if (!err) {
            return res.redirect("/create-done");
          } else {
            return renderCreateForm(res, err, league);
          }
        });
      } else {
        console.log("ERROR: " + errorCode);
        return renderCreateForm(res, "CAPTCHA invalid - are you sure you're a human?", league);
      }
    });
  });

  app.get("/create-done", function(req, res) {
    console.log("create done");
    return res.render("create_done", {
      title: "League created!"
    });
  });

  app.get("/login", function(req, res) {
    return res.render("login", {
      title: "Sign in to Friendship League",
      message: void 0
    });
  });

  app.post("/login", function(req, res) {
    return models.authenticate(req.body.email, req.body.password, function(err, league) {
      if (err) {
        return res.render("login", {
          title: "Sign in to Friendship League",
          message: err
        });
      } else {
        return req.session.regenerate(function() {
          req.session.leagueId = league._id;
          return res.redirect("/league/" + league._id);
        });
      }
    });
  });

  restrict = function(req, res, next) {
    if (req.session.leagueId) {
      return next();
    } else {
      return res.redirect("/login");
    }
  };

  app.get("/league/:id", restrict, function(req, res) {
    return res.send("restricted page");
  });

  app.listen(port);

  console.log("Listening on port " + port);

}).call(this);
