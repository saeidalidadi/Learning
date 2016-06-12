###
#
#	user-posts.coffee
#	Method: GET
#	Path: /me/posts?size={integer}
#
###

module.exports = (request, reply, options) ->
	model = options.model
	size = Number request.query.size
	from = size * 5
	email = request.auth.credentials.email
	model.getPostsOf email, 5, from, (err, posts) ->
		request.server.methods.countPagination email, (err, result) ->
			locals =
				token: request.auth.token
				isLoggedin: true
				posts: posts
				paginations: result
				page: size
				postsUrl: '/posts'
				pageUrl: "/me/posts"
				userPosts: true

			reply.view "posts", locals
