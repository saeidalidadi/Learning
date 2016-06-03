config   = require "./config"
users    = require "./users"
jwtoken  = require "jsonwebtoken"
messages = require "./messages"
model		 = require "./model"

module.exports = [{
	path: '/'
	method: 'GET'
	config:
		auth: { mode: 'try' }
	handler: require "./home"
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
		identity = request.auth.credentials.email
		reply users[identity]

}
,
{
	path: '/posts'
	method: ['GET','POST']
	handler: require './posts'
}
,
{
	path: '/logout'
	method: ['GET', 'POST']
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

