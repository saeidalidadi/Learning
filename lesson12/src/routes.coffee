config   = require "./config"
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
	path: '/docs/{admin}'
	method: 'GET'
	config: auth: false
	handler: (request, reply) ->
		console.log request.params
		if request.params.admin is config.docs.username
			reply.view 'docs'
}
,
{
	path: '/docs'
	method: 'POST'
	config:
		auth: mode: 'try'
	handler: (request, reply) ->
		console.log config.docs
		if request.payload.username is config.docs.username and request.payload.password is config.docs.password
			token = jwtoken.sign { type: 'docs' }, config.tokenKey
			reply.redirect "/docs?token=#{token}"
		else
			reply.view 'docs'
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
		email = request.auth.credentials.email
		model.getUser email, (err, user) ->
			locals =
				name: user.name
				email: user.email
			reply.view "profile", locals

}
,
{
	path: '/me/posts'
	method: 'GET'
	handler: require "./user-posts"
}
,
{
	path: '/posts'
	method: ['GET','POST']
	config:
		auth: mode: 'try'
	handler: (request, reply) ->
		if request.method is 'get'
			require("./posts-page") request, reply
		else require("./posts") request, reply
}
,
{
	path: '/update/{doc_key}'
	method: 'GET'
	handler: require "./update-page"
}
,
{
	path: '/posts/{post_key}'
	method: ['PUT', 'DELETE', 'GET']
	config:
		auth: mode: 'try'
	handler: (request, reply) ->
		console.log request.method
		if request.method is 'put'
			require("./update-post") request, reply
		else if request.method is 'delete'
			require("./delete-post") request, reply
		else if request.method is 'get'
			require("./one-post") request, reply
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

