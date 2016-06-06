Hapi 		= require "hapi"
config 	= require "./config"

server = new Hapi.Server()
server.connection({ port: 8012, host: 'localhost' })

server.app.logins = { 1: 'saeid@me.com' }
server.app.uid = 1

server.register([require('hapi-auth-jwt2'), require('inert'), require('vision'), {
	register: require('lout')
	options:
		auth: mode: 'required'}], (err) ->
	
	server.views({
		engines:
			jade: require 'jade'
		relativeTo: __dirname
		path: './../template'
	})
	
	validate = (decoded, request, cb) ->
		login = request.server.app.logins[decoded.id]
		if !login
			return cb(null, false)
		else
			cb(null, true)

	server.auth.strategy('jwt', 'jwt', true, {
		key: config.tokenKey
		verifyOptions: { ignoreExpiration: false, algorithms: ['HS256'] }
		validateFunc: validate
	})

	methods = require "./methods"
	for method in methods
		server.method( method.name, method.method, method.options)

	server.route require('./routes')

	server.start (err) ->
		if err
			throw err
		console.log "server running at: #{server.info.uri}"
)
