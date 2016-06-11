###
#
#	home.coffee
#	Method: GET
#	Path: /
#
###

model = require "./model"

module.exports = (request, reply) ->
	if request.auth.isAuthenticated
		isLoggedin = true
		email = request.auth.credentials.email
		token = request.auth.token
	else
		isLoggedin = false
		email = ''
	model.getPosts 5, 0, email, (err, posts) ->
		request.server.methods.countPagination null, (err, result) ->
			model.getRandomPosts [6, 8], (err, randoms) ->
				locals =
					isLoggedin: isLoggedin
					token: token
					posts: posts
					paginations: result
					randoms: randoms
					pageUrl: "/posts"

				reply.view "posts", locals
