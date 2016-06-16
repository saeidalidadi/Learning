Hapi    = require "hapi"
config  = require "./config"

server = new Hapi.Server()
server.connection({ port: 8012, host: 'localhost' })

server.app.logins = { 1: 'saeid@me.com' }
server.app.uid = 1
server.log ['error']

validate = (decoded, request, cb) ->
  console.log 'ssss'
  if request.query.server? and request.query.path? and request.path is '/docs'
    return cb null, true
  isDocs = if request.path is '/docs' then on else off
  isAdmin = if decoded.type? and decoded.type is 'docs' then on else off
  if isAdmin and isDocs
    return cb null, true
  login = request.server.app.logins[decoded.id]
  if login
    return cb(null, true)
  else
    cb(null, false)


server.register([require('hapi-auth-jwt2'), require('inert'), require('vision')], (err) ->

  if err
    throw err

  server.views({
    engines:
      jade: require 'jade'
    relativeTo: __dirname
    path: '../../template'
  })

  server.auth.strategy('jwt', 'jwt', {
    key: config.tokenKey
    verifyOptions: { ignoreExpiration: false, algorithms: ['HS256'] }
    validateFunc: validate
  })

  server.auth.default('jwt')
  ###
  methods = require "./methods"
  for method in methods
    server.method( method.name, method.method, method.options)
  ###
  server.route require('./routes')

)

server.register require('./plugins'), (err) ->
  
  if err
    throw err

  server.start (err) ->
    if err
      throw err
    console.log "server running at: #{server.info.uri}"


