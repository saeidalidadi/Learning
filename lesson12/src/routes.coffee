config   = require "./config"
users    = require "./users"
jwtoken  = require "jsonwebtoken"
messages = require "./messages"
model		 = require "./model"

module.exports = [{
	path: '/'
	method: 'GET'
	config:
		auth: false
	handler: (request, reply) ->
		reply.redirect '/register'
}
,
{
	path: '/register'
	method: ['GET', 'POST']
	config:
		auth: { mode: 'try' }
  handler: require './register'
}
,
{
	path: '/login'
	method: ['GET', 'POST']
	config:
		auth: { mode: 'try' }
	handler: require './login'
}
,
{
	path: '/me'
	method: 'GET'
	handler: (request, reply) ->
		console.log request.headers
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
	method: ['GET', 'POST']
	config:
		auth: { mode: 'try' }
	handler: (request, reply) ->
		console.log request.headers
		if request.auth.isAuthenticated
			id = request.auth.credentials.id
			delete request.server.app.logins[id]
			reply messages.logout.success
		else
			reply messages.logout.isn_loggedin
}]

