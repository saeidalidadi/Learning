module.exports = [{
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
}]
