
module.exports = (server, options) ->
  [{

    path: '/register'
    method: ['GET', 'POST']
    config:
      auth: { mode: 'try' }
    handler: (request, reply) ->
      require('./handlers/register') request, reply, options
  }
  ,
  {
    path: '/login'
    method: ['GET', 'POST']
    config:
      auth: { mode: 'try' }
    handler: (request, reply) ->
      require('./handlers/login') request, reply, options
  }
  ,
  {
    path: '/me'
    method: 'GET'
    handler: (request, reply) ->
      require("./handlers/profile") request, reply, options
  }
  ,
  {
    path: '/logout'
    method: ['GET', 'POST']
    config:
      auth: { mode: 'try' }
    handler: require "./handlers/logout"
  }]
