model = require "./model"

module.exports = (request, reply) ->
	if request.auth.isAuthenticated
		isLoggedin = true
		token = request.auth.token
	else
		isLoggedin = false
	model.getPosts 1, 5, (err, posts) ->
		reply.view 'home', { isLoggedin: isLoggedin, token: token, posts: posts}

