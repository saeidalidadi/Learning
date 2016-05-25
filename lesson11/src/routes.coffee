config = require "./config"
users = require "./users"
jwtoken = require "jsonwebtoken"

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
			return reply('No information')
		payload = request.payload
		if !payload.email or !payload.password or !payload.fullname or
			 !payload.dob or !payload.weight or !payload.height
			reply('all field must be filled')
		else if users[payload.email]
			reply('This email has been registered before')
		else
			users[payload.email] = payload
			#users[payload.email].state = 'out'
			return reply("Your registeration was successful login to your account")
}
,
{
	path: '/login'
	method: 'POST'
	config:
		auth: { mode: 'try' }
	handler: (request, reply) ->
		if !request.payload
			return reply('not a payload')
		if request.auth.isAuthenticated
			reply('you are loged in as a valid user')
		else if !request.payload.email or !request.payload.password
			reply('password or email is not valid')
		else if !users[request.payload.email]
			reply('You are not registered')
		else
			cr = { email: users[request.payload.email].email }
			reply('authorized').header('Autherization', jwtoken.sign(cr, config.tokenKey, { expiresIn: "50s" }))
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


