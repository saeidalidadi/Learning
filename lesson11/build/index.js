var Hapi, config, jwtoken, server, users;

Hapi = require("hapi");

jwtoken = require("jsonwebtoken");

users = {
  'alidadisaeid@gmail.com': {
    email: 'alidadisaeid@gmail.com',
    password: 'pass',
    fullname: 'Saeid Alidadi',
    dob: '1989-05-12',
    weight: 74,
    height: 172
  }
};

config = {
  tokenKey: 'secret'
};

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
  server.route([
    {
      path: '/',
      method: 'GET',
      handler: function(request, reply) {
        return reply();
      }
    }, {
      path: '/signup',
      method: 'POST',
      config: {
        auth: {
          mode: 'try'
        }
      },
      handler: function(request, reply) {
        var payload;
        if (!request.payload) {
          return reply('No information');
        }
        payload = request.payload;
        if (!payload.email || !payload.password || !payload.fullname || !payload.dob || !payload.weight || !payload.height) {
          return reply('all field must be filled');
        } else if (users[payload.email]) {
          return reply('This email has been registered before');
        } else {
          users[payload.email] = payload;
          return reply("Your registeration was successful login to your account");
        }
      }
    }, {
      path: '/login',
      method: 'POST',
      config: {
        auth: {
          mode: 'try'
        }
      },
      handler: function(request, reply) {
        var cr;
        if (!request.payload) {
          return reply('not a payload');
        }
        if (request.auth.isAuthenticated) {
          return reply('you are loged in as a valid user');
        } else if (!request.payload.email || !request.payload.password) {
          return reply('password or email is not valid');
        } else if (!users[request.payload.email]) {
          return reply('You are not registered');
        } else {
          cr = {
            email: users[request.payload.email].email
          };
          return reply('authorized').header('Autherization', jwtoken.sign(cr, config.tokenKey, {
            expiresIn: "30s"
          }));
        }
      }
    }, {
      path: '/me',
      method: 'GET',
      handler: function(request, reply) {
        var identifier;
        identifier = request.auth.credentials.email;
        return reply(users[identifier]);
      }
    }, {
      path: '/feed',
      method: 'GET',
      config: {
        auth: {
          mode: 'try'
        }
      },
      handler: function(request, reply) {
        var name;
        if (!request.auth.isAuthenticated) {
          return reply([
            {
              card: 'menu'
            }, {
              card: 'login'
            }
          ]);
        } else {
          name = users[request.auth.credentials.email].fullname;
          return reply([
            {
              card: 'menu'
            }, {
              card: 'profile',
              name: name
            }
          ]);
        }
      }
    }, {
      path: '/logout',
      method: 'POST',
      config: {
        auth: {
          mode: 'try'
        }
      },
      handler: function(request, reply) {
        if (request.auth.isAuthenticated) {
          console.log(request.auth.token);
          return reply();
        }
      }
    }
  ]);
  return server.start(function(err) {
    if (err) {
      throw err;
    }
    return console.log("server running at: " + server.info.uri);
  });
});
