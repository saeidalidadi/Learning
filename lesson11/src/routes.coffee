config   = require "./config"
users    = require "./users"
jwtoken  = require "jsonwebtoken"
messages = require "./messages"

module.exports = [{
	path: '/'
	method: 'GET'
	handler: (request, reply) ->
		reply()
}
,
{
	path: '/signup'
	method: 'POST'
	config:
		auth: { mode: 'try' }
	handler: (request, reply) ->

		if !request.payload
			return reply(messages.signup.isn_payload)

		payload = request.payload
		if !payload.email or !payload.password or !payload.fullname or
			 !payload.dob or !payload.weight or !payload.height
			reply(messages.signup.isn_payload)

		else if users[payload.email]
			reply(messages.signup.before_registered)

		else
			users[payload.email] = payload
			#users[payload.email].state = 'out'
			return reply(messages.signup.success)
}
,
{
	path: '/login'
	method: 'POST'
	config:
		auth: { mode: 'try' }
	handler: (request, reply) ->
		if !request.payload
			return reply(messages.login.invalid)

		if request.auth.isAuthenticated
			reply(messages.login.loggedin)

		else if !request.payload.email or !request.payload.password
			reply(messages.login.invalid)

		else if !users[request.payload.email]
			reply(messages.login.unregistered)

		else
			cr = { email: users[request.payload.email].email }
			reply(messages.login.success).header('Autherization', jwtoken.sign(cr, config.tokenKey, { expiresIn: "50s" }))
}
,
{
	path: '/me'
	method: 'GET'
	handler: (request, reply) ->
		identity = request.auth.credentials.email
		reply users[identity]
}
,
{
	path: '/feed'
	method: 'GET'
	config:
		auth: { mode: 'try'}
	handler: (request, reply) ->
		if !request.auth.isAuthenticated
			reply [ { card: 'menu' }, { card: 'login' } ]
		else
			name = users[request.auth.credentials.email].fullname
			reply [ { card: 'menu' }, { card: 'profile', name: name } ]
}
,
{
	path: '/logout'
	method: 'POST'
	config:
		auth: { mode: 'try' }
	handler: (request, reply) ->
		if request.auth.isAuthenticated
			console.log request.auth.token
			reply()
}]


