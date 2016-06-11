module.exports = [{

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
