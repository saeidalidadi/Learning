###
#
#	posts-page.coffee
# Method: GET
# Path: /posts?size={integer}
# Des: will show a page contains five posts and paginations
#
###

module.exports = (request, reply, options) ->
	M = options.model
	page = Number request.query.size
	from = page * 5
	if request.auth.isAuthenticated
		email = request.auth.credentials.email
		isLoggedin = true
		token = request.auth.token
	else
		email = null

	M::getPosts(5, from, email, (err, posts) ->
		request.server.methods.countPagination null, (err, pages) ->
			locals =
				posts: posts
				isLoggedin: isLoggedin
				token: token
				paginations: pages
				page: page
			
			reply.view "posts", locals
	)
