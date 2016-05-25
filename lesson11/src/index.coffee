Hapi = require "hapi"
jwtoken = require "jsonwebtoken"
config = require "./config"

users =
	'alidadisaeid@gmail.com':
		email: 'alidadisaeid@gmail.com'
		password: 'pass'
		fullname: 'Saeid Alidadi'
		dob: '1989-05-12'
		weight: 74
		height: 172

server = new Hapi.Server()
server.connection({ port: 8011, host: 'localhost' })

server.register(require('hapi-auth-jwt2'), (err) ->
	
	validate = (decoded, request, cb) ->
		if !users[decoded.email]
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
