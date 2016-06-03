model = require "./model"
messages = require "./messages"

module.exports = (request, reply) ->
	if request.method is 'post' and request.payload.title isnt '' or request.payload.body isnt ''
		post =
			title: request.payload.title
			body: request.payload.body
			author_email: request.auth.credentials.email
		model.setPost post, (err, added) ->
			if err
				throw err
			else if added
				reply messages.post.success
	else
		reply messages.post.isn_payload
