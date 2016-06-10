###
#
#	posts-page.coffee
# Method: GET
# Path: /posts?size={integer}
# Des: will show a page contains five posts and paginations
#
###
model = require "./model"

module.exports = (request, reply) ->
	page = Number request.query.size
	from = page * 5
	console.log 'from',from
	if request.auth.isAuthenticated
		email = request.auth.credentials.email
		isLoggedin = true
		token = request.auth.token
	else
		email = null

	model.getPosts(5, from, email, (err, posts) ->
		request.server.methods.countPagination null, (err, pages) ->
			locals =
				posts: posts
				isLoggedin: isLoggedin
				token: token
				paginations: pages
				page: page
			
			reply.view "posts", locals
	)
