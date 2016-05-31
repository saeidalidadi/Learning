Hapi 		= require "hapi"
jwtoken = require "jsonwebtoken"
config 	= require "./config"
users 	= require "./users"

server = new Hapi.Server()
server.connection({ port: 8012, host: 'localhost' })

server.app.logins = {}
server.app.uid = 0

server.register([require('hapi-auth-jwt2'), require('inert'), require('vision'), require('lout')], (err) ->
	
	server.views({
		engines:
			jade: require 'jade'
		relativeTo: __dirname
		path: './../template'
	})
	
	validate = (decoded, request, cb) ->
		login = request.server.app.logins[decoded.id].email
		if !users[decoded.email] and  !login
			return cb(null, false)
		else
			cb(null, true)

	server.auth.strategy('jwt', 'jwt', true, {
		key: config.tokenKey
		verifyOptions: { ignoreExpiration: false, algorithms: ['HS256'] }
		validateFunc: validate
	})

	server.route require('./routes')

	server.start (err) ->
		if err
			throw err
		console.log "server running at: #{server.info.uri}"
)
