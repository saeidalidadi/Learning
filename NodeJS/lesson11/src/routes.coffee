config   = require "./config"
users    = require "./users"
jwtoken  = require "jsonwebtoken"
messages = require "./messages"

id = 0

module.exports = [{
	path: '/'
	method: 'GET'
	config:
		auth: false
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
			id = String ++request.server.app.uid
			request.server.app.logins[id] = request.payload.email
			cr = { email: users[request.payload.email].email, id: id }
			reply(messages.login.success).header('Autherization', jwtoken.sign(cr, config.tokenKey, { expiresIn: "3m" }))
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
			id = request.auth.credentials.id
			delete request.server.app.logins[id]
			reply messages.logout.success
		else
			reply messages.logout.isn_loggedin
}]


