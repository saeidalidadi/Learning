var Hapi, config, jwtoken, server, users;

Hapi = require("hapi");

jwtoken = require("jsonwebtoken");

config = require("./config");

users = require("./users");

server = new Hapi.Server();

server.connection({
  port: 8011,
  host: 'localhost'
});

server.register(require('hapi-auth-jwt2'), function(err) {
  var validate;
  validate = function(decoded, request, cb) {
    if (!users[decoded.email]) {
      return cb(null, false);
    } else {
      return cb(null, true);
    }
  };
  server.auth.strategy('jwt', 'jwt', true, {
    key: config.tokenKey,
    verifyOptions: {
      ignoreExpiration: false,
      algorithms: ['HS256']
    },
    validateFunc: validate
  });
  server.route(require('./routes'));
  return server.start(function(err) {
    if (err) {
      throw err;
    }
    return console.log("server running at: " + server.info.uri);
  });
});
