model = require "./model"

module.exports = (request, reply) ->
	if request.auth.isAuthenticated
		isLoggedin = true
		email = request.auth.credentials.email
		token = request.auth.token
	else
		isLoggedin = false
		email = ''
	model.getPosts 1, 5, email, (err, posts) ->
		model.countPosts (total) ->
			if total % 5 is 0 and total >= 5
				paginations = total // 5
			else if total > 5
				paginations = (total // 5) + 1
			reply.view 'home', { isLoggedin: isLoggedin, token: token, posts: posts, paginations: paginations }

