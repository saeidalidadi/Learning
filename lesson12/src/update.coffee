model = require "./model"

module.exports = (request, reply) ->
	model.getPost request.params.doc_key, (err, post) ->
		reply.view "update", { post: post.doc, token: request.auth.token }
