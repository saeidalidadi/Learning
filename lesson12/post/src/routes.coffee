module.exports = (server, options) ->
	
	[{
		path: '/'
		method: 'GET'
		config:
			auth: { mode: 'try' }
		handler: (request, reply) ->
			require("./handlers/home") request, reply, options
	}
	,
	{
		path: '/me/posts'
		method: 'GET'
		handler: require "./handlers/user-posts"
	}
	,
	{
		path: '/posts'
		method: ['GET','POST']
		config:
			auth: mode: 'try'
		handler: (request, reply, options) ->
			if request.method is 'get'
				require("./posts-page") request, reply
			else require("./posts") request, reply
	}
	,
	{
		path: '/update/{doc_key}'
		method: 'GET'
		handler: require "./handlers/update-page"
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
	}]

