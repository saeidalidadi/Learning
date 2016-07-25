Joi = require 'joi'

module.exports = (server, options) ->
  [{

    path: '/register'
    method: ['GET']
    config:
      auth: { mode: 'try' }
      handler: (request, reply) ->
        require('./handlers/register') request, reply, options
      description: 'Show the registeration page'
      tags: ['user', 'view']
  }
  ,
  {

    path: '/register'
    method: ['POST']
    config:
      auth: { mode: 'try' }
      handler: (request, reply) ->
        require('./handlers/register') request, reply, options
      validate:
        payload:
          name: Joi.string().min(2).max(32).required()
          email: Joi.string().required()
          password: Joi.string().min(2).max(32).required()
      description: 'Creates a user in blog'
      tags: ['user']
  }
  ,
  {
    path: '/login'
    method: ['GET']
    config:
      auth: { mode: 'try' }
      handler: (request, reply) ->
        require('./handlers/login') request, reply, options
      description:  'Show login page'
      tags: ['user', 'view']
  }
  ,
  {
    path: '/login'
    method: ['POST']
    config:
      auth: { mode: 'try' }
      handler: (request, reply) ->
        require('./handlers/login') request, reply, options
      validate:
        payload:
          email: Joi.string().email().required()
          password: Joi.string().min(2).max(32).required()
      description:  'Generates a token for logged in user'
      tags: ['user']
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
