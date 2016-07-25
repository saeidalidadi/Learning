var config, id, jwtoken, messages, users;

config = require("./config");

users = require("./users");

jwtoken = require("jsonwebtoken");

messages = require("./messages");

id = 0;

module.exports = [
  {
    path: '/',
    method: 'GET',
    config: {
      auth: false
    },
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
        return reply(messages.signup.isn_payload);
      }
      payload = request.payload;
      if (!payload.email || !payload.password || !payload.fullname || !payload.dob || !payload.weight || !payload.height) {
        return reply(messages.signup.isn_payload);
      } else if (users[payload.email]) {
        return reply(messages.signup.before_registered);
      } else {
        users[payload.email] = payload;
        return reply(messages.signup.success);
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
        return reply(messages.login.invalid);
      }
      if (request.auth.isAuthenticated) {
        return reply(messages.login.loggedin);
      } else if (!request.payload.email || !request.payload.password) {
        return reply(messages.login.invalid);
      } else if (!users[request.payload.email]) {
        return reply(messages.login.unregistered);
      } else {
        id = String(++request.server.app.uid);
        request.server.app.logins[id] = request.payload.email;
        cr = {
          email: users[request.payload.email].email,
          id: id
        };
        return reply(messages.login.success).header('Autherization', jwtoken.sign(cr, config.tokenKey, {
          expiresIn: "3m"
        }));
      }
    }
  }, {
    path: '/me',
    method: 'GET',
    handler: function(request, reply) {
      var identity;
      identity = request.auth.credentials.email;
      return reply(users[identity]);
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
        id = request.auth.credentials.id;
        delete request.server.app.logins[id];
        return reply(messages.logout.success);
      } else {
        return reply(messages.logout.isn_loggedin);
      }
    }
  }
];
