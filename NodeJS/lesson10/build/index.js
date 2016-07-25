var Hapi, cache, server, users, uuid, view;

Hapi = require("hapi");

uuid = 1;

users = {
  admin: {
    name: 'Arash',
    password: 'admin'
  }
};

view = function(reply, state, message) {
  if ((state != null) && state === 'authenticated') {
    return reply('<html><head><title>Login page</title></head><body><h3>Welcome ' + (message != null ? message : '') + '!</h3><br/><form method="post" action="/logout">' + '<input type="submit" value="Logout">' + '</form></body></html> ');
  } else {
    return reply('<html><head><title>Login page</title></head><body>' + (message != null ? message : 'wellcome') + '<form method="post" action="/login">' + 'Username: <input type="text" name="username"><br>' + 'Password: <input type="password" name="password"><br/>' + '<input type="submit" value="Login"></form></body></html>');
  }
};

server = new Hapi.Server();

cache = server.cache({
  segment: 'sessions',
  expiresIn: 1000 * 60
});

server.app.cache = cache;

server.connection({
  port: 8010,
  host: 'localhost'
});

server.register(require("hapi-auth-cookie"), function(error) {
  server.auth.strategy('session', 'cookie', true, {
    password: 'password-should-be-32-characters',
    cookie: 'sid-example',
    redirectTo: '/',
    isSecure: false,
    validateFunc: function(request, session, cb) {
      return cache.get(session.sid, function(err, cached) {
        if (err) {
          cb(err, false);
        }
        if (!cached) {
          return cb(null, false);
        }
        return cb(null, true, cached.account);
      });
    }
  });
  server.route([
    {
      path: '/',
      method: 'GET',
      config: {
        auth: {
          mode: 'try'
        },
        plugins: {
          'hapi-auth-cookie': {
            redirectTo: false
          }
        },
        handler: function(request, reply) {
          if (request.auth.isAuthenticated) {
            return view(reply, 'authenticated', 'You are authenticated');
          } else {
            return view(reply);
          }
        }
      }
    }, {
      path: '/login',
      method: 'POST',
      config: {
        plugins: {
          'hapi-auth-cookie': {
            redirectTo: false
          }
        },
        handler: function(request, reply) {
          var account, message, sid, state;
          if (request.auth.isAuthenticated) {
            state = 'authenticated';
            message = 'You are loged in';
            return view(reply, state, message);
          } else if (!request.payload.username || !request.payload.password) {
            state = 'invalid';
            message = 'username or password is not valid';
            return view(reply, state, message);
          } else {
            account = users[request.payload.username];
            if (!account || account.password !== request.payload.password) {
              state = 'invalid';
              message = 'Username or password is not valid';
            }
            sid = String(++uuid);
            return request.server.app.cache.set(sid, {
              account: account
            }, 0, function(error) {
              if (error) {
                console.log(error);
              }
              request.cookieAuth.set({
                sid: sid
              });
              message = "You are authenticated " + account.name + " and is valid just " + (cache.rule.expiresIn / 1000) + " seconds";
              state = 'authenticated';
              return view(reply, state, message);
            });
          }
        },
        auth: {
          mode: 'try'
        }
      }
    }, {
      path: '/hello/{name}',
      method: 'GET',
      handler: function(request, reply) {
        console.log(request.params.name.toLowerCase());
        if (request.auth.isAuthenticated && request.params.name.toLowerCase() === request.auth.credentials.name.toLowerCase()) {
          return reply(request.auth.credentials.name + " you have access to this API");
        } else {
          return reply('<h3>You have not access by this name<h3>');
        }
      }
    }, {
      path: '/ping',
      method: 'GET',
      config: {
        auth: {
          mode: 'try'
        },
        plugins: {
          'hapi-auth-cookie': {
            redirectTo: false
          }
        },
        handler: function(request, reply) {
          if (request.auth.isAuthenticated) {
            return reply('pong');
          } else {
            return reply('I will say pong if login');
          }
        }
      }
    }, {
      path: '/logout',
      method: 'POST',
      handler: function(request, reply) {
        request.cookieAuth.clear();
        return reply.redirect('/');
      }
    }
  ]);
  return server.start(function(error) {
    if (error) {
      throw 'Error';
    }
    return console.log("Server running at: " + server.info.uri);
  });
});
